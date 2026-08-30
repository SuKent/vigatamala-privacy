import Foundation

// 建置期規則轉換器。
//
// 把 EasyList 格式的過濾清單轉成 Safari content blocker JSON。
//
// ⚠️【它已經不是「打包進 App」了】原本的用途是建置時打包,但 2026-08-16 起
// 大清單**不隨 App 出貨**(理由見 CLAUDE.md:CC BY-SA 的散布爭議)。
// 現在的用途是產生**鏡像**上要放的預轉換 JSON,由 Tools/sync-rules-mirror.sh
// 呼叫;裝置端下載那份 JSON 並驗簽,或在鏡像不可用時退回上游自行轉換。
//
// 為什麼要有這一步:CLAUDE.md 定義免費層是「完整的通用網頁擋廣告(與免費
// 競品打平,作為安裝率來源)」。先前內建只有 137 條手寫規則,而完整的
// EasyList 是數萬條;轉換管線雖然寫好了,卻整條掛在訂閱牆後面且預設關閉。
//
// 用法:swift run RuleBundler <輸入.txt> <輸出.json> [上限]

let args = CommandLine.arguments

guard args.count >= 3 else {
    FileHandle.standardError.write(Data("用法:RuleBundler <輸入.txt> <輸出.json> [上限]\n".utf8))
    exit(2)
}

let inputPath = args[1]
let outputPath = args[2]
// 預設值與實際使用值必須一致。先前這裡是 50_000 而所有呼叫端都傳 45_000
// (Tools/build-rules.sh、Tools/sync-rules-mirror.sh),是一顆只在「漏傳參數」
// 時才引爆的未爆彈。
// (先前這裡還寫著引爆的形式是「超過 WKContentRuleList 上限、編譯失敗」——
//  **那是錯的**:WebKit 的拒收門檻是 150,000,50,000 遠低於它。
//  真正的代價只是「產出的條數與呼叫端以為的不一樣」。)
let limit = args.count >= 4 ? (Int(args[3]) ?? AdblockRuleConverter.defaultLimit)
                            : AdblockRuleConverter.defaultLimit

guard let text = try? String(contentsOfFile: inputPath, encoding: .utf8) else {
    FileHandle.standardError.write(Data("讀不到 \(inputPath)\n".utf8))
    exit(1)
}

// 【防線必須真的掛上】轉換會用 MediaSelectorGuard.vendored 讓通用外觀規則
// 避開媒體站台(見那個檔案的說明:上游一條 ##.video-ads 曾讓每一顆略過鈕
// 都被我們自己藏掉)。它靠讀 MediaProfiles.json 推導,讀不到就靜默變成空的
// —— 那會產出一份「看起來正常、但防線不存在」的規則檔,而且完全沒有跡象。
// 建置期是唯一還能發現這件事的時機,所以在這裡出聲。
if !MediaSelectorGuard.vendored.isActive {
    FileHandle.standardError.write(Data(
        "⚠️ 媒體選擇器防線是空的(讀不到 MediaProfiles?):產出的規則可能會藏掉略過鈕\n".utf8))
}

let result = AdblockRuleConverter.convert(text, limit: limit)
guard !result.rules.isEmpty else {
    FileHandle.standardError.write(Data("轉換結果是空的,不寫檔\n".utf8))
    exit(1)
}

// ── 上限真的咬到了嗎 ────────────────────────────────────────────────
//
// 【為什麼要單獨講】「被上限砍掉」與「語法不支援所以跳過」先前混在同一個
// 「略過 N 條」裡,分不出來 —— 而兩者的意義完全相反:後者是正常的
//(WebKit 表達不出來的規則本來就該丟),前者代表**我們自己設的天花板
// 開始丟掉有效規則了**,而且丟的是排在字母序尾巴的那些。
// 2026-08-30 查出 45,000 砍掉的是 `doubleclick.net` 這一級的東西,
// 正是因為沒有人看得出上限已經咬到。
//
// 上限現在是 65,000,而上游今天是 60,928 / 55,895 —— 餘裕只有約 6.7%。
// 上游長過去的那一天必須有人知道,所以這裡吵。
// 刻意**不**用非零離開碼:上游成長是常態,讓每日 CI 因此變紅會製造
// 「紅了也不看」的習慣,反而更糟。要的是看得見,不是擋下來。
let hitLimit = result.rules.count >= limit
if hitLimit {
    // 【不要在這裡列樣本】`skipped` 的樣本額度(skippedSampleCap = 200)
    // 在跑到上限那一步之前,早就被「語法不支援」的跳過填滿了 ——
    // 過濾出 limitReached 幾乎必然是空陣列。承諾了證據卻拿不出來,
    // 比不提更糟。要看被砍掉了什麼,把上限調高再 diff 兩份輸出。
    FileHandle.standardError.write(Data("""

    ⚠️⚠️ 上限咬到了:\(URL(fileURLWithPath: inputPath).lastPathComponent) 產出 \(result.rules.count) 條 = 上限 \(limit)
         代表有**有效規則**被砍掉了,而截斷是照上游檔案順序砍尾巴
         (easylist_adservers.txt 內部是字母序)—— 被丟掉的不是長尾,
         是剛好排在後面的東西。2026-08-30 就是這樣丟掉 doubleclick.net 的。
         → 調高 AdblockRuleConverter.defaultLimit,並同步改 Tools/build-rules.sh
           與 Tools/sync-rules-mirror.sh 傳進去的數字。
         → 想確認丟了什麼:用高上限再轉一次,diff 兩份輸出的 url-filter。

    """.utf8))
}

do {
    let json = try result.rules.encodedJSON()
    try json.write(toFile: outputPath, atomically: true, encoding: .utf8)
    let bytes = (try? Data(contentsOf: URL(fileURLWithPath: outputPath)).count) ?? 0
    let headroom = limit - result.rules.count
    print("\(URL(fileURLWithPath: inputPath).lastPathComponent) → "
        + "\(result.rules.count) 條(略過 \(result.skipped.count) 條),"
        + "\(bytes / 1024) KB"
        + (hitLimit ? "  ⚠️ 已達上限" : "  上限餘裕 \(headroom) 條"))
} catch {
    FileHandle.standardError.write(Data("寫檔失敗:\(error)\n".utf8))
    exit(1)
}
