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

do {
    let json = try result.rules.encodedJSON()
    try json.write(toFile: outputPath, atomically: true, encoding: .utf8)
    let bytes = (try? Data(contentsOf: URL(fileURLWithPath: outputPath)).count) ?? 0
    print("\(URL(fileURLWithPath: inputPath).lastPathComponent) → "
        + "\(result.rules.count) 條(略過 \(result.skipped.count) 條),"
        + "\(bytes / 1024) KB")
} catch {
    FileHandle.standardError.write(Data("寫檔失敗:\(error)\n".utf8))
    exit(1)
}
