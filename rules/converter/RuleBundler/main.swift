import Foundation
import VigatamalaCore

// 建置期規則轉換器。
//
// 把 EasyList 格式的過濾清單轉成 Safari content blocker JSON,好在**建置時**
// 就打包進 App —— 而不是等使用者訂閱之後才在執行期下載。
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
let limit = args.count >= 4 ? (Int(args[3]) ?? 50_000) : 50_000

guard let text = try? String(contentsOfFile: inputPath, encoding: .utf8) else {
    FileHandle.standardError.write(Data("讀不到 \(inputPath)\n".utf8))
    exit(1)
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
