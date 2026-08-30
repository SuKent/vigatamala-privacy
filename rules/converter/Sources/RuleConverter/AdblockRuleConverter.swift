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
        public static let mediaSelfConflict = "會藏掉媒體引擎自己要用的元素(略過鈕 / 廣告標記 / 控制項)"

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

    /// 轉換的預設規則上限。
    ///
    /// 【為什麼要有這個常數】先前 `convert` 的預設是 50,000,而**所有**呼叫端
    /// 都傳 45,000(RuleUpdateService、build-rules.sh、sync-rules-mirror.sh)。
    /// 只在「漏傳參數」時才生效的預設值遲早會漂,集中在一處就不會。
    /// (先前這段還寫著 50,000 會「超過 WKContentRuleList 上限、編譯失敗」——
    /// **那是錯的**,WebKit 的拒收門檻是 150,000,50,000 遠低於它。)
    ///
    /// 【2026-08-30:45,000 → 75,000】
    /// 45,000 是「顧及舊機型」憑感覺挑的,從來沒有量過。實測之後改掉:
    ///
    /// - **它砍掉的不是長尾。** 截斷是 `blocking.prefix(...)`,照**上游檔案
    ///   順序**砍尾巴,而 `easylist_adservers.txt` 內部是**字母序** ——
    ///   實測被丟掉的 13,766 條裡包含 `ad.doubleclick.net`、`doubleclick.net`、
    ///   `2mdn.net`、`pagead`、`googlesyndication` 這些第一線廣告端點,
    ///   以及 EasyPrivacy 整段 `easyprivacy_specific_international.txt`
    ///   (約 2,000 條台/中/日/韓追蹤器)。對一個賣擋廣告、主打繁中市場的
    ///   App,這是實質功能缺口,不是覆蓋率的邊際問題。
    /// - **代價很小。** 兩份清單全開是 116,817 條:下載量 10.5 → 13.6 MiB,
    ///   裝置上的編譯產物 42.6 → 53 MB(mmap 檔案、跨分頁共用一份,
    ///   不隨分頁數成長),Mac 上編譯 1.3s → 1.8s。App 二進位**完全不變**
    ///   (大清單不進 bundle)。
    /// - **為什麼是 75,000 而不是 150,000。** 上游今天轉出來是 60,923 與
    ///   55,894,75,000 對兩份都是**零截斷**又留約 23% 成長餘裕。
    ///   150,000 是 WebKit 的**拒收門檻**,不是安全水位 —— 提出它的
    ///   WebKit commit 自陳編譯程序有「約 150 MB 的記憶體軟上限」,
    ///   而它附的 iOS 量測在 122,475 條時峰值已達 146 MB。
    ///   能編得起來的條數與值得編的條數不是同一件事。
    ///
    /// ⚠️ 改這個值要一併改 `Tools/build-rules.sh` 與 `Tools/sync-rules-mirror.sh`
    ///    傳進去的數字(它們是明文傳的,不吃這個預設值)。
    public static let defaultLimit = 75_000

    /// 不論外觀規則有多少,一定要留給阻擋規則的最低名額。
    ///
    /// 【為什麼需要一個底線】上限是先給例外與外觀佔位、剩下才給阻擋。
    /// 沒有底線的話,一份外觀規則特別多的清單會把阻擋預算擠成 0 ——
    /// 而「擋不掉廣告」比「藏不掉版位」嚴重一個等級,那個順序是反的。
    /// 8,000 是量級選擇:足以涵蓋主流追蹤器與廣告網域,又不會反過來把
    /// 外觀規則整批擠掉。
    ///
    /// ⚠️ 這是**上限**不是配額:實際保留的是 `min(阻擋規則條數, 8_000)`。
    /// 阻擋規則只有 50 條的清單只會扣掉 50 個名額,不是 8,000 個。
    static let minimumBlockingSlots = 8_000

    // MARK: - 進入點

    /// 轉換一整份清單文字。
    ///
    /// - Parameter mediaGuard: 「不准被外觀規則藏掉的元素」防線。預設用出貨的
    ///   profile 推導(見 `MediaSelectorGuard`)。傳 `.inactive` 可完全關掉,
    ///   測試用。
    public static func convert(
        _ text: String,
        limit: Int = defaultLimit,
        mediaGuard: MediaSelectorGuard.Guard = MediaSelectorGuard.vendored
    ) -> ConversionResult {
        convert(lines: text.split(whereSeparator: \.isNewline).map(String.init),
                limit: limit, mediaGuard: mediaGuard)
    }

    /// 轉換已切好行的清單。
    public static func convert(
        lines: [String],
        limit: Int = defaultLimit,
        mediaGuard: MediaSelectorGuard.Guard = MediaSelectorGuard.vendored
    ) -> ConversionResult {
        var builder = Builder(limit: limit, mediaGuard: mediaGuard)
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
        /// 「不准被外觀規則藏掉的元素」防線,見 `MediaSelectorGuard`。
        let mediaGuard: MediaSelectorGuard.Guard

        var blocking: [ContentBlockerRule] = []
        /// 與 `blocking` 平行:每條阻擋規則來自哪一行。
        ///
        /// 上限現在在 `finish()` 才套用,那時已經看不到原始行了。少了這份,
        /// 「哪些規則因為超過上限被丟掉」這個診斷會退化成一個數字 ——
        /// 而那正是調上限時唯一有用的資訊。
        /// 代價是每條規則多一個字串(45,000 條約 1.4 MB),相對於 5.5 MB 的
        /// 輸出可以接受。
        var blockingSources: [String] = []
        var exceptions: [ContentBlockerRule] = []
        var cosmeticOrder: [CosmeticKey] = []
        var cosmeticSelectors: [CosmeticKey: [String]] = [:]
        var cosmeticSeen: [CosmeticKey: Set<String>] = [:]

        /// `#@#` 元素隱藏例外:選擇器 → **不要**在這些網域上套用它。
        ///
        /// 【為什麼非有不可】EasyList 的 `#@#` 存在的唯一理由,就是修正
        /// 前面某條通用隱藏規則在特定站台上的**過度隱藏**。整批丟掉等於出貨
        /// 一份「拆掉安全網」的 EasyList —— 而症狀(某個站台的內容莫名不見)
        /// 對使用者是完全無法歸因的,他只會覺得這個瀏覽器怪怪的,
        /// 而且**沒有任何救濟**:唯一的辦法是把整站的外觀阻擋關掉。
        var cosmeticExceptionDomains: [String: [String]] = [:]
        /// 網域段是空的 `#@#` —— 意思是這條選擇器整個不要用。
        var globallyExceptedSelectors: Set<String> = []

        var acceptedCount = 0
        var skippedCount = 0
        var skipped: [SkippedFilter] = []

        init(limit: Int, mediaGuard: MediaSelectorGuard.Guard) {
            self.limit = limit
            self.mediaGuard = mediaGuard
        }

        // MARK: 記錄

        mutating func skip(_ filter: String, _ reason: String) {
            skippedCount += 1
            if skipped.count < AdblockRuleConverter.skippedSampleCap {
                skipped.append(SkippedFilter(filter: filter, reason: reason))
            }
        }

        /// 記憶體上的絕對天花板 —— **不是**規則數上限。
        ///
        /// 真正的上限在 `finish()` 才套用,而且只砍阻擋規則(見那裡的說明)。
        /// 這裡留一個寬鬆的硬界線,是為了不讓惡意或損毀的輸入把記憶體吃光
        /// (實測:攔截式網路的登入頁也會被轉出合法規則)。
        var absoluteCeiling: Int { max(limit * 4, 200_000) }

        /// 收下這一條。回傳 false 只代表撞到記憶體天花板,正常情況永遠是 true。
        mutating func reserveSlot(_ filter: String) -> Bool {
            guard blocking.count + exceptions.count < absoluteCeiling else {
                skip(filter, SkipReason.limitReached)
                return false
            }
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
                // 【`#@#` 現在會被記下來,不再整條丟掉】
                // WebKit 沒有「元素隱藏例外」這種規則,但它有 `unless-domain` ——
                // 兩者表達得出同一件事:把例外的網域接到對應選擇器的規則上。
                // 見 finish() 的重新分組。
                if split.separator == "#@#" {
                    noteCosmeticException(line, split)
                    return
                }
                // `#@$#` / `#@?#` / `#@%#` 這些是**擴充語法的例外**,本體我們
                // 本來就表達不出來,例外自然也不必記。其餘 `#?#` / `#$#` / `#%#`
                // 同理。
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

            // var 而不是 let:下面的自我衝突防線可能要調整它們(見那一段)。
            var include: [String]
            var exclude: [String]
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
            // 【自我衝突:別藏掉我們自己要點的東西】
            //
            // 上游的一條通用規則曾把包著略過鈕的整個容器設成 display:none ——
            // 於是每一支可略過廣告的略過鈕都是我們自己藏掉、按不到的
            //(實測 89~109 次進入廣告對 0 次成功略過)。詳見 MediaSelectorGuard。
            //
            // 兩種形狀分開處理:
            //  - 通用規則(沒有 if-domain)→ 加上 unless-domain 避開媒體站台,
            //    其他站台照樣受益。
            //  - 已經限定站台的規則 → 從 if-domain 裡拿掉媒體站台;
            //    拿掉之後沒剩的話整條略過(Safari 的 trigger 不允許
            //    if-domain 與 unless-domain 並存,沒有第三種寫法)。
            if mediaGuard.conflicts(with: selector) {
                if include.isEmpty {
                    for domain in mediaGuard.unlessDomains where !exclude.contains(domain) {
                        exclude.append(domain)
                    }
                } else {
                    let kept = include.filter { !mediaGuard.unlessDomains.contains($0) }
                    if kept.count != include.count {
                        guard !kept.isEmpty else {
                            skip(line, SkipReason.mediaSelfConflict)
                            return
                        }
                        include = kept
                    }
                }
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

        /// 記下一條 `#@#` 例外。
        ///
        /// 比對是**選擇器字串相等**:EasyList 的例外一律逐字重複本體的選擇器,
        /// 所以字串比對就夠了,不需要 CSS 語意解析。
        ///
        /// ⚠️ 已知限制:網域比對也是字串相等。`##` 寫 `example.com` 而 `#@#`
        /// 寫 `m.example.com` 時對不上,例外不生效。那只是「少救一個站」,
        /// 不會造成新的錯誤 —— 而反過來(自作聰明做子網域推導)會讓例外
        /// 擴散到不該生效的地方,那才是真的壞。
        mutating func noteCosmeticException(
            _ line: String,
            _ split: (domains: String, separator: String, body: String)
        ) {
            let selector = split.body.trimmingCharacters(in: .whitespaces)
            guard !selector.isEmpty else {
                skip(line, SkipReason.emptySelector)
                return
            }
            let domainText = split.domains.trimmingCharacters(in: .whitespaces)
            guard !domainText.isEmpty else {
                // 沒有網域段 = 這條選擇器在任何地方都不要用。
                globallyExceptedSelectors.insert(selector)
                return
            }
            switch AdblockRuleConverter.parseDomains(domainText, separator: ",") {
            case .skip(let reason):
                skip(line, reason)
            case .ok(let parsed):
                // `#@#` 的網域段語意是「在這些站上停用」,對應 include。
                // 反向網域(`~foo.com#@#…`)表達的是「除了 foo.com 以外都停用」,
                // 那要展開成全站例外再挖洞,WebKit 表達不出來 —— 照舊跳過。
                guard !parsed.include.isEmpty, parsed.exclude.isEmpty else {
                    skip(line, SkipReason.cosmeticException)
                    return
                }
                var domains = cosmeticExceptionDomains[selector] ?? []
                for domain in parsed.include where !domains.contains(domain) {
                    domains.append(domain)
                }
                cosmeticExceptionDomains[selector] = domains
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
            //
            // 【只認 include,不認 exclude】`unless-domain` 是**反向**的:它讓規則適用於
            // 「除了這幾個以外的所有站台」,不是收束而是放大。把它算成限制條件的話,
            // `@@*$domain=~nonexistent.invalid` 會通過檢查,轉出
            // `url-filter=".*" + unless-domain` 的 ignore-previous-rules ——
            // 而例外一律排在最後(見 finish()),於是那**一行**會在幾乎每個網站上
            // 取消整份清單的所有阻擋。反方向的 `*$domain=~x.com` 則是擋掉除了
            // x.com 以外的整個網路。
            //
            // 這個安全網目前沒被觸發過(以忠實移植的版本跑今日上游:easylist 0 條、
            // easyprivacy 1 條命中 unconstrained),但它存在的理由正是「輸入不可信」——
            // 而遠端清單就是不可信輸入。
            let hasDomainConstraint = !options.includeDomains.isEmpty
            if AdblockRuleConverter.matchesEverything(urlFilter) && !hasDomainConstraint {
                skip(line, SkipReason.unconstrained)
                return
            }

            // 【@@…$document 是整站白名單,不是「只解除主文件的阻擋」】
            //
            // ABP 語意裡 `@@||safe.test^$document` 是「在這個頁面上停用所有過濾」。
            // 直譯成 `resource-type: ["document"]` 的話,條件變成「**請求網址**是
            // safe.test 而且資源型別是 document」—— 頁面裡對 ads.test 發出的
            // script / image / XHR,請求網址不是 safe.test,一條都不會命中,廣告照擋。
            // 實務上只達成一半:例外排在最後,所以該頁的 css-display-none 確實被解除
            // (外觀層有效),網路層則原封不動 —— 上游用這條規則要修的破版
            // (多半是反擋廣告偵測)因此修不好。今日上游 easylist 28 條、
            // easyprivacy 14 條落在這個情況。
            //
            // WebKit 表達整站白名單的慣用寫法是「比對全部網址 + if-domain」。
            // 抽不出網域時(樣式帶路徑、或不是 ||host^ 形)**維持原樣**,
            // 因為現行行為至少解除得了外觀層,改成跳過反而是淨損失。
            if isException,
               options.isDocumentOnly,
               options.includeDomains.isEmpty,
               options.excludeDomains.isEmpty,
               options.loadType == nil,
               let host = AdblockRuleConverter.siteWhitelistHost(from: split.pattern) {
                guard reserveSlot(line) else { return }
                exceptions.append(ContentBlockerRule(
                    trigger: ContentBlockerRule.Trigger(
                        urlFilter: ".*",
                        ifDomain: ["*" + host]
                    ),
                    action: ContentBlockerRule.Action(type: .ignorePreviousRules)
                ))
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
                blockingSources.append(line)
            }
        }

        // MARK: 收尾

        /// 收尾:在這裡才套用規則數上限。
        ///
        /// 【為什麼不在累積時擋】
        /// 先前是每收一條就 `acceptedCount += 1`,額滿即丟後面全部。
        /// 而 `@@` 例外規則在上游清單裡**集中在檔尾**(EasyList 第一條例外在
        /// 第 66,805 行 / 共 78,907 行),上限在讀到那裡之前就用完了 ——
        /// 實測出貨的 easylist.json 有 **0 條**例外(上游 758 條)、
        /// easyprivacy.json 只有 2 條(上游 834 條)。
        ///
        /// 例外規則的用途正是「這個別擋,擋了會壞」。整批丟掉的後果是站台破圖,
        /// 而且是靜默的 —— 我們出貨的等於是拆掉安全網的 EasyList。
        ///
        /// 所以:例外與外觀規則先佔位,上限只砍**阻擋規則**的尾巴。
        /// 阻擋規則的尾端是長尾網域,少幾條的代價遠小於少一條例外。
        /// 把 `#@#` 例外套進分組。
        ///
        /// 例外是 **per-selector** 的,而分組是 per-(if-domain, unless-domain) 的,
        /// 所以有例外的選擇器要從原組拆出來、單獨成一組。兩種形狀分開處理 ——
        /// 與 MediaSelectorGuard 的自我衝突防線完全同一套邏輯,理由也一樣:
        /// Safari 的 trigger **不允許 if-domain 與 unless-domain 並存**,
        /// 沒有第三種寫法。
        ///
        /// 順序:新拆出來的組接在原組後面,輸出保持決定性。
        func applyCosmeticExceptions() -> (order: [CosmeticKey], selectors: [CosmeticKey: [String]]) {
            guard !cosmeticExceptionDomains.isEmpty || !globallyExceptedSelectors.isEmpty else {
                return (cosmeticOrder, cosmeticSelectors)
            }
            var order: [CosmeticKey] = []
            var grouped: [CosmeticKey: [String]] = [:]
            // 去重:兩個**不同**的原始分組在削掉 if-domain 之後可能收斂成同一組。
            // 例如 `a.test,b.test##.x` + `b.test##.x` + `a.test#@#.x` ——
            // 前兩者都會變成 `if-domain: [b.test]`,同一個 `.x` 進來兩次,
            // 輸出成 `.x, .x`。CSS 上合法、行為也正確,但那是白白多出來的位元組,
            // 而且會讓人以為轉換器算錯了。`handleCosmetic` 那邊本來就有
            // `cosmeticSeen` 做同一件事,重新分組這條路先前漏了。
            var seen: [CosmeticKey: Set<String>] = [:]
            func add(_ key: CosmeticKey, _ selector: String) {
                if grouped[key] == nil {
                    order.append(key)
                    grouped[key] = []
                    seen[key] = []
                }
                guard seen[key]?.insert(selector).inserted == true else { return }
                grouped[key]?.append(selector)
            }

            for key in cosmeticOrder {
                for selector in cosmeticSelectors[key] ?? [] {
                    // 全站例外 → 這條選擇器整個不輸出。
                    if globallyExceptedSelectors.contains(selector) { continue }
                    guard let domains = cosmeticExceptionDomains[selector], !domains.isEmpty else {
                        add(key, selector)
                        continue
                    }
                    if key.ifDomain.isEmpty {
                        // 通用規則 → 加上 unless-domain 避開例外站台,其他站照樣受益。
                        var exclude = key.unlessDomain
                        for domain in domains where !exclude.contains(domain) {
                            exclude.append(domain)
                        }
                        add(CosmeticKey(ifDomain: [], unlessDomain: exclude), selector)
                    } else {
                        // 已限定站台 → 從 if-domain 裡拿掉例外站台;拿光了就整條不輸出。
                        let kept = key.ifDomain.filter { !domains.contains($0) }
                        guard !kept.isEmpty else { continue }
                        add(CosmeticKey(ifDomain: kept, unlessDomain: key.unlessDomain), selector)
                    }
                }
            }
            return (order, grouped)
        }

        func finish() -> ConversionResult {
            var cosmeticRules: [ContentBlockerRule] = []
            let effective = applyCosmeticExceptions()
            for key in effective.order {
                guard let selectors = effective.selectors[key], !selectors.isEmpty else { continue }
                for chunk in selectors.vgmChunked(into: AdblockRuleConverter.maxSelectorsPerRule) {
                    let trigger = ContentBlockerRule.Trigger(
                        urlFilter: ".*",
                        ifDomain: key.ifDomain.isEmpty ? nil : key.ifDomain,
                        unlessDomain: key.unlessDomain.isEmpty ? nil : key.unlessDomain
                    )
                    cosmeticRules.append(
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

            // 例外與外觀規則先佔名額,剩下的才給阻擋規則。
            //
            // 【`reserved > limit` 時會發生什麼 —— 先前是靜默的兩件壞事】
            // 1. `max(0, limit - reserved)` 把預算夾成 0 → **阻擋規則全數歸零**。
            //    使用者看到的是「更新成功、規則數還不少」,而實際上一條網路層
            //    阻擋都沒有掛上 —— 那正是這個 App 的核心功能。
            // 2. 就算歸零,最終輸出仍是 `reserved` 條,**照樣超過 limit**。
            //    上限的用意(WebKit 的編譯成本與記憶體)因此完全落空。
            //
            // 現在:外觀規則也吃上限,並且**保證阻擋規則拿得到一個底線名額**。
            // 順序上先犧牲外觀(藏不掉版位是體驗問題),再犧牲阻擋(擋不掉是功能問題),
            // 例外永遠不砍(丟例外會讓站台破圖,而且是靜默的)。
            let exceptionCount = exceptions.count
            // 例外本身就超過上限的話,上限已經沒有意義可言 —— 讓例外全過,
            // 其餘全砍,並在結果裡誠實反映。這是理論情境(EasyList 的例外約
            // 佔總數個位數百分比),但不留這條路的話就是上面那個靜默歸零。
            // 底線只保留**阻擋規則真的用得到**的份量。
            // 無條件扣 8,000 的話,一份阻擋規則本來就少的清單(自訂清單常見:
            // 幾百條網路層 + 一大批外觀)會平白損失七千多個名額 —— 那些名額
            // 沒有被任何規則用到,只是憑空消失。
            let blockingReserve = min(blocking.count, AdblockRuleConverter.minimumBlockingSlots)
            let cosmeticBudget = max(0, limit - exceptionCount - blockingReserve)
            let keptCosmetic = cosmeticRules.prefix(cosmeticBudget)
            let droppedCosmetic = cosmeticRules.count - keptCosmetic.count

            let reserved = exceptionCount + keptCosmetic.count
            let blockingBudget = max(0, limit - reserved)
            let keptBlocking = blocking.prefix(blockingBudget)
            let droppedBlocking = blocking.count - keptBlocking.count

            var rules = Array(keptBlocking)
            rules.append(contentsOf: keptCosmetic)
            // 例外一定放最後:`ignore-previous-rules` 只解得掉排在它前面的規則。
            rules.append(contentsOf: exceptions)

            var result = ConversionResult(
                rules: rules,
                // 回報**實際輸出的規則數**,不是消耗掉的 filter 數。
                // 先前兩者相差 18%(顯示 90,000、實際掛上 76,443),
                // 而這個數字是使用者判斷「更新成功了沒」的唯一訊號。
                acceptedCount: rules.count,
                skippedCount: skippedCount + droppedBlocking + droppedCosmetic,
                skipped: skipped
            )
            // 被上限砍掉的那些,逐條記進 skipped 樣本(上限內)。
            if droppedBlocking > 0 {
                for source in blockingSources[keptBlocking.count...] {
                    guard result.skipped.count < AdblockRuleConverter.skippedSampleCap else { break }
                    result.skipped.append(
                        SkippedFilter(filter: source, reason: SkipReason.limitReached)
                    )
                }
            }
            return result
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
        /// 使用者真的寫了 `$document` / `$doc`。
        ///
        /// **不能用 `positiveTypes == [.document]` 代替**:`subdocument` 與 `frame`
        /// 也對映到 `.document`(WebKit 沒有獨立的子框架型別),而
        /// `@@||x^$subdocument` 的意思是「x 當成子框架載入時別擋」——
        /// 那不是整站白名單,誤判會把一條窄例外放大成整站停用過濾。
        var sawDocumentOption = false

        /// 這條規則是不是**只**寫了 `$document`(整站白名單的判準)。
        var isDocumentOnly: Bool {
            sawDocumentOption && !sawNegatedType && positiveTypes == [.document]
        }
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
                        // 只有真的寫 document / doc 才算(subdocument / frame 也對映到
                        // .document,但語意完全不同 —— 見 NetworkOptions.sawDocumentOption)。
                        if name == "document" || name == "doc" { options.sawDocumentOption = true }
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
    /**
     從 `||host^` 這種網域錨定樣式抽出主機名 —— 抽不出來就回 nil。

     只接受「整條樣式就是一個網域」的形狀:`||host`、`||host^`、`||host/`、
     `||host|`、`||host^|`。帶路徑的(`||host/path`)刻意不接受 ——
     那是路徑範圍的例外,不是整站白名單,放大它會停用整個網站的過濾。
     含萬用字元的也不接受:`if-domain` 的比對語意與 url-filter 不同,
     翻譯錯的代價是靜默地把過濾關掉。
     */
    static func siteWhitelistHost(from rawPattern: String) -> String? {
        guard rawPattern.hasPrefix("||") else { return nil }
        var rest = Substring(rawPattern.dropFirst(2))

        // 收尾允許的裝飾:`^`(分隔符號)、`|`(結尾錨點)、單一個 `/`。
        while let last = rest.last, last == "|" || last == "^" || last == "/" {
            rest = rest.dropLast()
        }
        let host = String(rest).lowercased()
        guard !host.isEmpty, host.count <= 253, host.contains(".") else { return nil }
        guard host.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "." || $0 == "-") })
        else { return nil }
        // 前後不得是點或連字號,也不得有連續的點 —— 那不是合法主機名。
        guard !host.hasPrefix("."), !host.hasSuffix("."),
              !host.hasPrefix("-"), !host.hasSuffix("-"),
              !host.contains("..") else { return nil }
        return host
    }

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
