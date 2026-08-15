import Foundation

/// Adblock Plus / EasyList 語法 → Safari content blocker 規則。
///
/// 對應 CLAUDE.md「擋廣告(兩層)」的第一層:`WKContentRuleList` 吃的是 Safari content
/// blocker 的 JSON 規則格式,而社群長年維護的清單(EasyList / EasyPrivacy 之類)寫的是
/// ABP 語法,中間這道轉換就是本檔。
///
/// 全檔純 Foundation:iOS 殼負責把結果編成 `WKContentRuleList`,未來的 Android / Web 殼
/// 可以重用同一份轉換輸出,符合「核心邏輯跨平台共用、殼只是殼」的架構原則。
///
/// ## 設計原則:寧可少擋,不可擋錯
///
/// WebKit 的 `url-filter` 只吃**受限**的正規表示式(無反向參照、無前瞻、無非貪婪),
/// `trigger` 也沒有 uBO / AdGuard 那些擴充能力(`$removeparam`、`$csp`、`:has-text()` …)。
/// 凡是表達不出來的一律**跳過並記下原因**,絕不硬湊一條語意不同的規則出來——
/// 一條擋錯的規則會直接弄壞使用者的網站,後果比少擋一個廣告嚴重一個量級。
///
/// ## 輸出順序
///
/// WebKit 是「後面的規則覆蓋前面的」,而 `ignore-previous-rules` 只能解除**它之前**的規則。
/// 原始清單裡例外規則(`@@`)與阻擋規則是交錯的,所以輸出時重新分成三段:
/// 阻擋 → 元素隱藏 → 例外。段內維持原始先後順序。
public enum AdblockRuleConverter {

    // MARK: - 公開型別

    /// 被跳過的過濾規則,連同原因,給規則更新流程與診斷面板用。
    public struct SkippedFilter: Sendable, Equatable {
        /// 原始過濾規則文字(已去除前後空白)。
        public var filter: String
        /// 跳過的原因。
        public var reason: String

        public init(filter: String, reason: String) {
            self.filter = filter
            self.reason = reason
        }
    }

    public struct ConversionResult: Sendable {
        /// 可直接編碼成 content blocker JSON 的規則。
        public var rules: [ContentBlockerRule]
        /// 成功轉換的過濾規則「條數」(注意:元素隱藏會合併,所以不等於 `rules.count`)。
        public var acceptedCount: Int
        /// 被跳過的過濾規則總數。
        public var skippedCount: Int
        /// 被跳過的樣本,最多 ``skippedSampleCap`` 筆(避免整份清單塞爆記憶體)。
        public var skipped: [SkippedFilter]

        public init(
            rules: [ContentBlockerRule] = [],
            acceptedCount: Int = 0,
            skippedCount: Int = 0,
            skipped: [SkippedFilter] = []
        ) {
            self.rules = rules
            self.acceptedCount = acceptedCount
            self.skippedCount = skippedCount
            self.skipped = skipped
        }
    }

    /// 跳過原因字串。集中放在這裡,測試與 UI 才不必硬寫字面值。
    public enum SkipReason {
        public static let cosmeticException = "元素隱藏例外規則(#@#)在 WebKit 沒有對應動作"
        public static let extendedCosmetic = "擴充語法的元素隱藏規則(#?# / #$# / #%#)無法表達"
        public static let scriptletInjection = "腳本注入規則(+js / script:)無法表達"
        public static let htmlFiltering = "HTML 過濾規則(##^)無法表達"
        public static let regexLiteral = "正規表示式字面值 /…/ 不轉換"
        public static let mixedDomains = "if-domain 與 unless-domain 不能並存於同一條 trigger"
        public static let nonASCII = "含非 ASCII 字元,WebKit 的 url-filter 只吃 ASCII"
        public static let emptySelector = "選擇器是空的"
        public static let invalidSelector = "選擇器語法不安全,略過以免整份規則編譯失敗"
        public static let unconstrained = "樣式等同於比對全部網址,又沒有網域限制"
        public static let limitReached = "超出規則數量上限"
        public static let conflictingLoadType = "first-party 與 third-party 互斥"
        public static let mixedResourceNegation = "資源類型的正向與反向條件不可混用"
        public static let emptyResourceTypes = "反向資源類型把所有類型都排除光了"
        public static let invalidDomain = "網域條件格式不合法"
        public static let wildcardDomain = "含萬用字元的網域條件無法表達"

        public static func unsupportedOption(_ name: String) -> String {
            "不支援的選項:\(name)"
        }

        /// 選項的值本身含逗號之類的怪東西,切不出乾淨的選項清單。
        public static func unparsableOptions(_ name: String) -> String {
            "選項字串無法解析:\(name)"
        }

        public static func proceduralSelector(_ token: String) -> String {
            "程序型選擇器無法表達:\(token)"
        }
    }

    /// 內部用的「成功帶值 / 失敗帶原因」小型結果型別。
    ///
    /// 不用 `Result` 是因為它的 Failure 必須 conform `Error`,而這裡的失敗只是一句人話原因,
    /// 包成錯誤型別反而多一層儀式。
    enum Outcome<Value> {
        case ok(Value)
        case skip(String)
    }

    /// `skipped` 樣本上限。
    public static let skippedSampleCap = 200

    /// 單一條 css-display-none 規則最多合併幾個選擇器。
    ///
    /// 合併是為了壓縮規則數(WebKit 的預算大約十幾萬條),但不能無上限:
    /// 只要清單裡有一個選擇器是 WebKit 的 CSS parser 不收的,**整條**規則會被拒,
    /// 分批可以把爆炸半徑限制在一批之內。
    public static let maxSelectorsPerRule = 200

    // MARK: - 進入點

    /// 轉換一整份清單文字。
    public static func convert(_ text: String, limit: Int = 50_000) -> ConversionResult {
        convert(lines: text.split(whereSeparator: \.isNewline).map(String.init), limit: limit)
    }

    /// 轉換已切好行的清單。
    public static func convert(lines: [String], limit: Int = 50_000) -> ConversionResult {
        var builder = Builder(limit: limit)
        for line in lines {
            builder.consume(line)
        }
        return builder.finish()
    }

    // MARK: - 累積器

    private struct CosmeticKey: Hashable {
        var ifDomain: [String]
        var unlessDomain: [String]
    }

    private struct Builder {
        let limit: Int

        var blocking: [ContentBlockerRule] = []
        var exceptions: [ContentBlockerRule] = []
        var cosmeticOrder: [CosmeticKey] = []
        var cosmeticSelectors: [CosmeticKey: [String]] = [:]
        var cosmeticSeen: [CosmeticKey: Set<String>] = [:]

        var acceptedCount = 0
        var skippedCount = 0
        var skipped: [SkippedFilter] = []

        init(limit: Int) {
            self.limit = limit
        }

        // MARK: 記錄

        mutating func skip(_ filter: String, _ reason: String) {
            skippedCount += 1
            if skipped.count < AdblockRuleConverter.skippedSampleCap {
                skipped.append(SkippedFilter(filter: filter, reason: reason))
            }
        }

        /// 佔一個名額。回傳 false 代表已達上限,呼叫端要放棄這條。
        mutating func reserveSlot(_ filter: String) -> Bool {
            guard acceptedCount < limit else {
                skip(filter, SkipReason.limitReached)
                return false
            }
            acceptedCount += 1
            return true
        }

        // MARK: 分流

        mutating func consume(_ raw: String) {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { return }              // 空行:靜默略過
            guard !AdblockRuleConverter.isComment(line) else { return }  // 註解:靜默略過

            if let split = AdblockRuleConverter.cosmeticSplit(line) {
                handleCosmetic(line, split)
            } else {
                handleNetwork(line)
            }
        }

        // MARK: 元素隱藏

        mutating func handleCosmetic(
            _ line: String,
            _ split: (domains: String, separator: String, body: String)
        ) {
            guard split.separator == "##" else {
                // `#@#` 系列是例外規則、`#?#` / `#$#` / `#%#` 系列是擴充語法,兩者 WebKit 都做不到。
                let reason = split.separator.contains("@")
                    ? SkipReason.cosmeticException
                    : SkipReason.extendedCosmetic
                skip(line, reason)
                return
            }

            let selector = split.body.trimmingCharacters(in: .whitespaces)
            guard !selector.isEmpty else {
                skip(line, SkipReason.emptySelector)
                return
            }
            if selector.hasPrefix("+js(") || selector.hasPrefix("script:") {
                skip(line, SkipReason.scriptletInjection)
                return
            }
            if selector.hasPrefix("^") {
                skip(line, SkipReason.htmlFiltering)
                return
            }
            if let token = AdblockRuleConverter.proceduralToken(in: selector) {
                skip(line, SkipReason.proceduralSelector(token))
                return
            }
            guard AdblockRuleConverter.isSafeSelector(selector) else {
                skip(line, SkipReason.invalidSelector)
                return
            }

            let include: [String]
            let exclude: [String]
            switch AdblockRuleConverter.parseDomains(split.domains, separator: ",") {
            case .skip(let reason):
                skip(line, reason)
                return
            case .ok(let parsed):
                include = parsed.include
                exclude = parsed.exclude
            }
            // 網域段寫了東西卻一個都沒解出來(例如 `,##.ad`):原意是限定站台,
            // 若順勢當成全站規則,會在**所有**網站上多隱藏元素,寧可整條跳過。
            guard split.domains.trimmingCharacters(in: .whitespaces).isEmpty
                || !include.isEmpty || !exclude.isEmpty else {
                skip(line, SkipReason.invalidDomain)
                return
            }
            guard include.isEmpty || exclude.isEmpty else {
                skip(line, SkipReason.mixedDomains)
                return
            }
            guard reserveSlot(line) else { return }

            let key = CosmeticKey(ifDomain: include, unlessDomain: exclude)
            if cosmeticSeen[key] == nil {
                cosmeticOrder.append(key)
                cosmeticSeen[key] = []
                cosmeticSelectors[key] = []
            }
            // 同一組網域條件下的重複選擇器只留一次。
            if cosmeticSeen[key]?.insert(selector).inserted == true {
                cosmeticSelectors[key]?.append(selector)
            }
        }

        // MARK: 網路層

        mutating func handleNetwork(_ line: String) {
            var body = line
            var isException = false
            if body.hasPrefix("@@") {
                isException = true
                body = String(body.dropFirst(2))
            }

            let split: (pattern: String, options: String?)
            switch AdblockRuleConverter.splitOptions(body) {
            case .skip(let reason):
                skip(line, reason)
                return
            case .ok(let value):
                split = value
            }

            // ABP 規定「頭尾都是 /」代表整條是正規表示式。WebKit 的 regex 子集不保證吃得下,
            // 且誤譯的代價太高,直接跳過。
            if AdblockRuleConverter.isRegexLiteral(split.pattern) {
                skip(line, SkipReason.regexLiteral)
                return
            }

            var options = NetworkOptions()
            if let text = split.options,
               let reason = AdblockRuleConverter.parseOptions(text, into: &options) {
                skip(line, reason)
                return
            }
            guard options.includeDomains.isEmpty || options.excludeDomains.isEmpty else {
                skip(line, SkipReason.mixedDomains)
                return
            }

            let resourceTypes: [ContentBlockerRule.ResourceType]
            switch options.resolvedResourceTypes() {
            case .skip(let reason):
                skip(line, reason)
                return
            case .ok(let types):
                resourceTypes = types
            }

            guard let urlFilter = AdblockRuleConverter.urlFilterRegex(
                for: split.pattern,
                matchCase: options.matchCase
            ) else {
                skip(line, SkipReason.nonASCII)
                return
            }

            // 「擋掉整個網際網路」不是使用者要的。能把「比對全部網址」收束回可接受範圍的
            // 只有網域條件;資源類型與 first/third-party 都不算——`*$script` 會擋掉全網的
            // 腳本、`@@*$image` 會把整個圖片阻擋一次解除,兩者都是全域級的破壞。
            let hasDomainConstraint = !options.includeDomains.isEmpty
                || !options.excludeDomains.isEmpty
            if AdblockRuleConverter.matchesEverything(urlFilter) && !hasDomainConstraint {
                skip(line, SkipReason.unconstrained)
                return
            }

            guard reserveSlot(line) else { return }

            let trigger = ContentBlockerRule.Trigger(
                urlFilter: urlFilter,
                urlFilterIsCaseSensitive: options.matchCase ? true : nil,
                ifDomain: options.includeDomains.isEmpty ? nil : options.includeDomains,
                unlessDomain: options.excludeDomains.isEmpty ? nil : options.excludeDomains,
                resourceType: resourceTypes.isEmpty ? nil : resourceTypes,
                loadType: options.loadType.map { [$0] }
            )
            let rule = ContentBlockerRule(
                trigger: trigger,
                action: ContentBlockerRule.Action(type: isException ? .ignorePreviousRules : .block)
            )
            if isException {
                exceptions.append(rule)
            } else {
                blocking.append(rule)
            }
        }

        // MARK: 收尾

        func finish() -> ConversionResult {
            var rules = blocking

            for key in cosmeticOrder {
                guard let selectors = cosmeticSelectors[key], !selectors.isEmpty else { continue }
                for chunk in selectors.vgmChunked(into: AdblockRuleConverter.maxSelectorsPerRule) {
                    let trigger = ContentBlockerRule.Trigger(
                        urlFilter: ".*",
                        ifDomain: key.ifDomain.isEmpty ? nil : key.ifDomain,
                        unlessDomain: key.unlessDomain.isEmpty ? nil : key.unlessDomain
                    )
                    rules.append(
                        ContentBlockerRule(
                            trigger: trigger,
                            action: ContentBlockerRule.Action(
                                type: .cssDisplayNone,
                                selector: chunk.joined(separator: ", ")
                            )
                        )
                    )
                }
            }

            // 例外一定放最後:`ignore-previous-rules` 只解得掉排在它前面的規則。
            rules.append(contentsOf: exceptions)

            return ConversionResult(
                rules: rules,
                acceptedCount: acceptedCount,
                skippedCount: skippedCount,
                skipped: skipped
            )
        }
    }

    // MARK: - 註解與行分類

    static func isComment(_ line: String) -> Bool {
        if line.hasPrefix("!") { return true }
        if line.hasPrefix("[") && line.lowercased().hasPrefix("[adblock") { return true }
        // `# 這是註解`:開頭是 # 但接不上任何元素隱藏分隔符號。
        if line.hasPrefix("#") && cosmeticSeparator(in: Array(line), at: 0) == nil { return true }
        return false
    }

    /// 元素隱藏的分隔符號,依長度由長到短排,才不會被短的先吃掉。
    private static let cosmeticSeparators: [[Character]] = [
        "#@$?#", "#@$#", "#@?#", "#@%#", "#$?#",
        "#@#", "#$#", "#?#", "#%#", "##",
    ].map(Array.init)

    /// 分隔符號前面(網域清單)不允許出現的字元。出現了就代表這其實是網路層規則。
    private static let forbiddenInDomainPrefix: Set<Character> = ["/", "|", "@", "\"", "!", "$"]

    private static func cosmeticSeparator(in chars: [Character], at index: Int) -> [Character]? {
        for separator in cosmeticSeparators
        where index + separator.count <= chars.count
            && Array(chars[index..<(index + separator.count)]) == separator {
            return separator
        }
        return nil
    }

    /// 把 `domains##selector` 拆成三段。不是元素隱藏規則就回傳 nil。
    static func cosmeticSplit(_ line: String) -> (domains: String, separator: String, body: String)? {
        let chars = Array(line)
        var index = 0
        while index < chars.count {
            if chars[index] == "#", let separator = cosmeticSeparator(in: chars, at: index) {
                let prefix = chars[..<index]
                guard !prefix.contains(where: { forbiddenInDomainPrefix.contains($0) }) else {
                    return nil
                }
                return (
                    String(prefix),
                    String(separator),
                    String(chars[(index + separator.count)...])
                )
            }
            index += 1
        }
        return nil
    }

    // MARK: - 選擇器檢查

    /// uBO / AdGuard 的程序型選擇器。這些要在 JS 層才做得到,content blocker 一律做不到。
    private static let proceduralTokens: [String] = [
        ":has(", ":has-text(", ":contains(", ":matches-css", ":matches-attr",
        ":matches-path", ":matches-property", ":matches-media", ":xpath(",
        ":style(", ":remove(", ":remove-attr(", ":remove-class(", ":upward(",
        ":nth-ancestor(", ":min-text-length(", ":watch-attr(", ":if(", ":if-not(",
        ":others(", "-abp-has", "-abp-contains", "-abp-properties",
    ]

    static func proceduralToken(in selector: String) -> String? {
        let lowered = selector.lowercased()
        return proceduralTokens.first { lowered.contains($0) }
    }

    /// 保守的選擇器健檢。
    ///
    /// 動機很現實:合併後的規則只要有一個選擇器讓 WebKit 的 CSS parser 失敗,
    /// **整份** rule list 會編譯失敗,連帶所有阻擋規則都上不了。寧可丟掉幾條可疑的。
    static func isSafeSelector(_ selector: String) -> Bool {
        if selector.contains("{") || selector.contains("}") || selector.contains(";") { return false }
        if selector.contains("/*") || selector.contains(">>>") { return false }
        if selector.unicodeScalars.contains(where: { $0.value < 0x20 }) { return false }
        if hasEmptyNameToken(selector) { return false }

        var round = 0
        var square = 0
        var singleQuotes = 0
        var doubleQuotes = 0
        var escaping = false
        for ch in selector {
            if escaping {
                escaping = false
                continue
            }
            switch ch {
            case "\\": escaping = true
            case "(": round += 1
            case ")":
                round -= 1
                if round < 0 { return false }
            case "[": square += 1
            case "]":
                square -= 1
                if square < 0 { return false }
            case "'": singleQuotes += 1
            case "\"": doubleQuotes += 1
            default: break
            }
        }
        if escaping { return false }                       // 尾端懸空的跳脫字元
        guard round == 0, square == 0 else { return false }
        guard singleQuotes.isMultiple(of: 2), doubleQuotes.isMultiple(of: 2) else { return false }

        let combinators: Set<Character> = [",", ">", "+", "~"]
        if let first = selector.first, combinators.contains(first) { return false }
        if let last = selector.last, combinators.contains(last) { return false }
        return true
    }

    /// 有沒有空的 class / ID 名稱(`.`、`#`、`.a##.b` 這類殘缺寫法)。
    ///
    /// 這種選擇器 WebKit 的 CSS parser 收不下,而合併後的一條 css-display-none 只要選擇器
    /// 無效整條就失效——同一批(最多 ``maxSelectorsPerRule`` 個)選擇器會一起陪葬。
    /// 中括號裡是屬性值(可能長得像 `a[href="#"]`),不檢查。
    static func hasEmptyNameToken(_ selector: String) -> Bool {
        let terminators: Set<Character> = [".", "#", ",", ">", "+", "~", ")", "]", " ", "\t"]
        let chars = Array(selector)
        var index = 0
        var bracketDepth = 0
        var quote: Character?

        while index < chars.count {
            let ch = chars[index]
            if ch == "\\" {                       // 跳脫字元:連同下一個字元一起跳過
                index += 2
                continue
            }
            if let open = quote {
                if ch == open { quote = nil }
                index += 1
                continue
            }
            switch ch {
            case "'", "\"": quote = ch
            case "[": bracketDepth += 1
            case "]": bracketDepth = max(0, bracketDepth - 1)
            case ".", "#":
                guard bracketDepth == 0 else { break }
                let next = index + 1 < chars.count ? chars[index + 1] : nil
                guard let next, !terminators.contains(next) else { return true }
            default: break
            }
            index += 1
        }
        return false
    }

    // MARK: - 網域清單

    struct ParsedDomains {
        var include: [String]
        var exclude: [String]
    }

    /// 把 `a.com|~b.com`(選項)或 `a.com,~b.com`(元素隱藏)轉成 WebKit 的網域條件。
    ///
    /// WebKit 的 if-domain / unless-domain:前面加 `*` 代表「該網域與其子網域」,
    /// 這正是 ABP `domain=` 的語意。
    static func parseDomains(_ text: String, separator: Character) -> Outcome<ParsedDomains> {
        var include: [String] = []
        var exclude: [String] = []

        for rawEntry in text.split(separator: separator) {
            var entry = rawEntry.trimmingCharacters(in: .whitespaces)
            guard !entry.isEmpty else { continue }

            var negated = false
            if entry.hasPrefix("~") {
                negated = true
                entry = String(entry.dropFirst())
            }
            entry = entry.lowercased()
            guard !entry.isEmpty else { return .skip(SkipReason.invalidDomain) }
            guard entry.allSatisfy(\.isASCII) else { return .skip(SkipReason.nonASCII) }
            if entry.contains("*") { return .skip(SkipReason.wildcardDomain) }
            let allowed: Set<Character> = ["-", "_", "."]
            guard entry.allSatisfy({ $0.isLetter || $0.isNumber || allowed.contains($0) }) else {
                return .skip(SkipReason.invalidDomain)
            }
            guard !entry.hasPrefix("."), !entry.hasSuffix(".") else {
                return .skip(SkipReason.invalidDomain)
            }

            let value = "*" + entry
            if negated {
                if !exclude.contains(value) { exclude.append(value) }
            } else {
                if !include.contains(value) { include.append(value) }
            }
        }
        return .ok(ParsedDomains(include: include, exclude: exclude))
    }

    // MARK: - 選項

    private struct ResourceMapping {
        /// 正向指定時對應的 WebKit 類型。
        var positive: Set<ContentBlockerRule.ResourceType>
        /// 反向(`~type`)時要從全集扣掉的類型。
        ///
        /// 之所以跟 `positive` 不同:WebKit 的 `raw` 是 fetch / websocket / other 的**聯集**,
        /// 所以排除 xmlhttprequest 時必須連 `raw` 一起扣掉,否則 fetch 又從 `raw` 漏回來擋到。
        var negationRemoval: Set<ContentBlockerRule.ResourceType>

        init(
            _ positive: Set<ContentBlockerRule.ResourceType>,
            removing negationRemoval: Set<ContentBlockerRule.ResourceType>? = nil
        ) {
            self.positive = positive
            self.negationRemoval = negationRemoval ?? positive
        }
    }

    private static let resourceMappings: [String: ResourceMapping] = [
        "script": ResourceMapping([.script]),
        "image": ResourceMapping([.image]),
        "stylesheet": ResourceMapping([.styleSheet]),
        "css": ResourceMapping([.styleSheet]),
        "font": ResourceMapping([.font]),
        "media": ResourceMapping([.media]),
        "xmlhttprequest": ResourceMapping([.fetch], removing: [.fetch, .raw]),
        "xhr": ResourceMapping([.fetch], removing: [.fetch, .raw]),
        "websocket": ResourceMapping([.websocket], removing: [.websocket, .raw]),
        "ping": ResourceMapping([.ping]),
        "beacon": ResourceMapping([.ping]),
        "other": ResourceMapping([.raw]),
        // WebKit 沒有獨立的子框架類型,子框架文件走的就是 document。
        "subdocument": ResourceMapping([.document]),
        "frame": ResourceMapping([.document]),
        "document": ResourceMapping([.document]),
        "doc": ResourceMapping([.document]),
        "popup": ResourceMapping([.popup]),
    ]

    /// 反向資源類型的全集。
    ///
    /// 依 ABP 語意,`document` 與 `popup` 不在預設集合裡(要明講才算),
    /// 所以 `~script` 不會連帶擋掉最上層導覽——這點搞錯會讓使用者連網頁都開不了。
    private static let negationUniverse: Set<ContentBlockerRule.ResourceType> = [
        .image, .styleSheet, .script, .font, .media, .svgDocument, .ping, .fetch, .websocket, .raw,
    ]

    /// 認得但表達不出來的選項。列在這裡是為了兩件事:
    /// 一是 `$` 的位置判斷,二是跳過時能報出人看得懂的原因。
    private static let unsupportedOptions: Set<String> = [
        "removeparam", "queryprune", "redirect", "redirect-rule", "csp", "replace",
        "rewrite", "app", "denyallow", "method", "to", "header", "permissions",
        "urltransform", "jsonprune", "hls", "network", "extension", "badfilter",
        "elemhide", "ehide", "generichide", "ghide", "specifichide", "shide",
        "genericblock", "content", "all", "empty", "mp4", "object", "object-subrequest",
        "webrtc", "inline-script", "inline-font", "cookie", "stealth",
        "strict1p", "strict3p", "ipaddress", "referrerpolicy", "uritransform",
    ]

    private static let behaviourOptions: Set<String> = [
        "domain", "from", "third-party", "3p", "first-party", "1p", "match-case", "important", "noop",
    ]

    private static let knownOptionNames: Set<String> =
        Set(resourceMappings.keys).union(unsupportedOptions).union(behaviourOptions)

    private struct NetworkOptions {
        var includeDomains: [String] = []
        var excludeDomains: [String] = []
        var positiveTypes: Set<ContentBlockerRule.ResourceType> = []
        var negatedTypes: Set<ContentBlockerRule.ResourceType> = []
        var sawPositiveType = false
        var sawNegatedType = false
        var loadType: ContentBlockerRule.LoadType?
        var matchCase = false

        func resolvedResourceTypes() -> Outcome<[ContentBlockerRule.ResourceType]> {
            if sawPositiveType && sawNegatedType {
                return .skip(SkipReason.mixedResourceNegation)
            }
            var set: Set<ContentBlockerRule.ResourceType>
            if sawNegatedType {
                set = AdblockRuleConverter.negationUniverse.subtracting(negatedTypes)
                if set.isEmpty { return .skip(SkipReason.emptyResourceTypes) }
            } else {
                set = positiveTypes
            }
            // `raw` 已經涵蓋 fetch / websocket,列出來只是讓輸出變胖。
            if set.contains(.raw) {
                set.remove(.fetch)
                set.remove(.websocket)
            }
            return .ok(ContentBlockerRule.ResourceType.allCases.filter { set.contains($0) })
        }
    }

    /// 解析選項字串。回傳 nil 代表全部解析成功;回傳字串就是跳過原因。
    private static func parseOptions(_ text: String, into options: inout NetworkOptions) -> String? {
        for rawToken in text.split(separator: ",") {
            var token = rawToken.trimmingCharacters(in: .whitespaces)
            guard !token.isEmpty else { continue }

            var negated = false
            if token.hasPrefix("~") {
                negated = true
                token = String(token.dropFirst())
            }

            var name = token
            var value: String?
            if let equals = token.firstIndex(of: "=") {
                name = String(token[token.startIndex..<equals])
                value = String(token[token.index(after: equals)...])
            }
            name = name.lowercased()

            switch name {
            case "domain", "from":
                guard !negated, let value, !value.isEmpty else {
                    return SkipReason.invalidDomain
                }
                switch parseDomains(value, separator: "|") {
                case .skip(let reason):
                    return reason
                case .ok(let parsed):
                    // 值有寫但一個網域都沒解出來(例如 `$domain=|`):照著忽略等於把整條
                    // 規則的適用範圍從「某些站台」放大成「所有站台」,寧可跳過。
                    guard !parsed.include.isEmpty || !parsed.exclude.isEmpty else {
                        return SkipReason.invalidDomain
                    }
                    options.includeDomains.append(contentsOf: parsed.include)
                    options.excludeDomains.append(contentsOf: parsed.exclude)
                }

            case "third-party", "3p":
                let resolved: ContentBlockerRule.LoadType = negated ? .firstParty : .thirdParty
                if let existing = options.loadType, existing != resolved {
                    return SkipReason.conflictingLoadType
                }
                options.loadType = resolved

            case "first-party", "1p":
                let resolved: ContentBlockerRule.LoadType = negated ? .thirdParty : .firstParty
                if let existing = options.loadType, existing != resolved {
                    return SkipReason.conflictingLoadType
                }
                options.loadType = resolved

            case "match-case":
                options.matchCase = !negated

            case "important", "noop":
                // `important` 只影響優先序,不改變「哪些請求會被比對到」,
                // 降級成忽略最多是少擋,不會擋錯。`noop` 本來就是填充用。
                continue

            default:
                if name.allSatisfy({ $0 == "_" }) { continue }   // uBO 的 `_` / `__` 填充
                if let mapping = resourceMappings[name] {
                    if negated {
                        options.sawNegatedType = true
                        options.negatedTypes.formUnion(mapping.negationRemoval)
                    } else {
                        options.sawPositiveType = true
                        options.positiveTypes.formUnion(mapping.positive)
                    }
                } else {
                    return SkipReason.unsupportedOption(name)
                }
            }
        }
        return nil
    }

    // MARK: - 樣式與選項的切分

    /// 把 `pattern$options` 切開。
    ///
    /// 麻煩點在於 `$` 也可能是網址本身的字元。做法是由左往右找第一個「其後可以完整解析成
    /// 選項清單」的 `$`;若一個都沒有,再檢查是否有 `$` 後面接著已知選項名
    /// (例如 `$replace=/a,b/c/` 這種值裡含逗號、解析不了的),有的話寧可整條跳過,
    /// 也不要把 `$replace=…` 當成網址的一部分譯出一條錯規則。
    static func splitOptions(_ body: String) -> Outcome<(pattern: String, options: String?)> {
        let chars = Array(body)
        var index = 0
        while index < chars.count {
            if chars[index] == "$" && (index == 0 || chars[index - 1] != "\\") {
                let rest = String(chars[(index + 1)...])
                if isWellFormedOptionList(rest) {
                    return .ok((String(chars[..<index]), rest))
                }
            }
            index += 1
        }

        index = 0
        while index < chars.count {
            if chars[index] == "$" && (index == 0 || chars[index - 1] != "\\") {
                if let name = leadingOptionName(in: chars, after: index),
                   knownOptionNames.contains(name) {
                    return .skip(SkipReason.unparsableOptions(name))
                }
            }
            index += 1
        }
        return .ok((pattern: body, options: nil))
    }

    private static func isOptionNameCharacter(_ ch: Character) -> Bool {
        (ch.isASCII && (ch.isLetter || ch.isNumber)) || ch == "-" || ch == "_"
    }

    /// 這個字串像不像選項名。
    ///
    /// 一般選項名都以字母或底線開頭;數字開頭的只有 uBO 的 `1p` / `3p` 兩個縮寫,
    /// 所以數字開頭時要求必須是認得的名字——否則網址裡的 `$1`、`$2` 會被誤判成選項,
    /// 反而把樣式切掉一截。
    private static func isPlausibleOptionName(_ name: String) -> Bool {
        guard let first = name.first else { return false }
        if (first.isASCII && first.isLetter) || first == "_" { return true }
        return knownOptionNames.contains(name)
    }

    /// 讀出 `$` 之後的選項名(允許前導 `~`)。
    private static func leadingOptionName(in chars: [Character], after dollar: Int) -> String? {
        var index = dollar + 1
        if index < chars.count && chars[index] == "~" { index += 1 }
        var name = ""
        while index < chars.count, isOptionNameCharacter(chars[index]) {
            name.append(chars[index])
            index += 1
        }
        return name.isEmpty ? nil : name.lowercased()
    }

    /// 逗號分隔、每段都是 `~?name` 或 `~?name=value` 才算合法的選項清單。
    private static func isWellFormedOptionList(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        var any = false
        for rawToken in text.split(separator: ",") {
            let token = rawToken.trimmingCharacters(in: .whitespaces)
            guard !token.isEmpty else { continue }
            any = true

            var body = Substring(token)
            if body.hasPrefix("~") { body = body.dropFirst() }
            var index = body.startIndex
            while index < body.endIndex, isOptionNameCharacter(body[index]) {
                index = body.index(after: index)
            }
            guard isPlausibleOptionName(String(body[body.startIndex..<index]).lowercased()) else {
                return false
            }
            if index == body.endIndex { continue }          // 純選項名
            guard body[index] == "=" else { return false }  // 只允許 name=value
        }
        return any
    }

    // MARK: - url-filter

    /// ABP 的 `||` 網域錨點。
    ///
    /// 拆解:`^[^:]+:` 吃掉 scheme、`(//)?` 吃掉權威前綴、`([^/?#]*\.)?` 吃掉可有可無的
    /// 子網域(字元類排除 `/ ? #` 才不會跨進路徑或查詢字串,否則 `?u=http://example.com`
    /// 這種轉址參數會被誤判成命中)。
    static let domainAnchorPrefix = "^[^:]+:(//)?([^/?#]*\\.)?"

    /// ABP 的 `^` 分隔符號:字母、數字與 `_ - . %` 以外的任何字元。
    ///
    /// WebKit 在不分大小寫時會先把網址轉小寫再比對,所以預設只需要小寫的字元類。
    static let separatorClass = "[^a-z0-9_.%-]"
    static let separatorClassCaseSensitive = "[^a-zA-Z0-9_.%-]"

    static func isRegexLiteral(_ pattern: String) -> Bool {
        pattern.count > 2 && pattern.hasPrefix("/") && pattern.hasSuffix("/")
    }

    /// 這條 url-filter 是不是「任何網址都命中」。
    ///
    /// 不能只比對幾個字面值:`|`、`|*`、`*|`、`^` 這種殘缺行分別會轉出 `^`、`^`、`$`、
    /// 分隔符號字元類,四者都能在任意網址上找到落點——只要有一條這樣的規則進了清單,
    /// 使用者的整個網路就被擋死。做法是剝掉錨點與前後的 `.*`,剩下的是空的就代表全命中。
    static func matchesEverything(_ regex: String) -> Bool {
        var body = Substring(regex)
        if body.hasPrefix(domainAnchorPrefix) {
            body = body.dropFirst(domainAnchorPrefix.count)
        } else if body.hasPrefix("^") {
            body = body.dropFirst()
        }
        if body.hasSuffix("$") { body = body.dropLast() }
        // `*` 一律轉成 `.*`,而字面上的 `.` 一律轉成 `\.`,所以這裡剝掉的必定是萬用字元。
        while body.hasPrefix(".*") { body = body.dropFirst(2) }
        while body.hasSuffix(".*") { body = body.dropLast(2) }

        // 數剩下幾個「真的會限制網址」的字元:`\x` 是一個跳脫後的字面字元、分隔符號字元類
        // 算一個字元、`.*` 不算。只剩一個字元的樣式(`/`、`[^a-z0-9_.%-]`)每個網址都命中。
        var significant = 0
        var rest = body
        while let first = rest.first {
            if rest.hasPrefix(".*") {
                rest = rest.dropFirst(2)
            } else if rest.hasPrefix(separatorClass) {
                rest = rest.dropFirst(separatorClass.count)
                significant += 1
            } else if rest.hasPrefix(separatorClassCaseSensitive) {
                rest = rest.dropFirst(separatorClassCaseSensitive.count)
                significant += 1
            } else {
                rest = rest.dropFirst(first == "\\" ? 2 : 1)
                significant += 1
            }
            if significant > 1 { return false }
        }
        return true
    }

    /// ABP 樣式 → WebKit `url-filter` 正規表示式。含非 ASCII 時回傳 nil。
    static func urlFilterRegex(for rawPattern: String, matchCase: Bool) -> String? {
        // WebKit 在不分大小寫模式下是把網址轉小寫後比對,樣式若留著大寫就永遠比不中。
        var pattern = matchCase ? rawPattern : rawPattern.lowercased()
        guard pattern.allSatisfy(\.isASCII) else { return nil }

        var prefix = ""
        if pattern.hasPrefix("||") {
            pattern.removeFirst(2)
            prefix = domainAnchorPrefix
        } else if pattern.hasPrefix("|") {
            pattern.removeFirst()
            prefix = "^"
        }

        var suffix = ""
        if pattern.hasSuffix("|") {
            pattern.removeLast()
            suffix = "$"
        }

        // url-filter 是「網址任一處符合即算命中」,所以沒有錨點時頭尾的 `*` 純屬多餘,
        // 去掉可以讓輸出小一點,語意完全相同。
        if prefix.isEmpty {
            while pattern.hasPrefix("*") { pattern.removeFirst() }
        }
        if suffix.isEmpty {
            while pattern.hasSuffix("*") { pattern.removeLast() }
        }

        var body = ""
        for ch in pattern {
            switch ch {
            case "*":
                body += ".*"
            case "^":
                body += matchCase ? separatorClassCaseSensitive : separatorClass
            default:
                body += escapedForRegex(ch)
            }
        }

        let regex = prefix + body + suffix
        return regex.isEmpty ? ".*" : regex
    }

    private static let regexMetacharacters: Set<Character> = [
        "\\", "$", ".", "|", "?", "+", "(", ")", "[", "]", "{", "}", "^", "*",
    ]

    private static func escapedForRegex(_ ch: Character) -> String {
        regexMetacharacters.contains(ch) ? "\\" + String(ch) : String(ch)
    }
}

// MARK: - 便利別名

public typealias AdblockConversionResult = AdblockRuleConverter.ConversionResult
public typealias AdblockSkippedFilter = AdblockRuleConverter.SkippedFilter

private extension Array {
    /// 切成固定大小的批次。`size` 不合法時整包回傳。
    func vgmChunked(into size: Int) -> [[Element]] {
        guard size > 0, count > size else { return isEmpty ? [] : [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
