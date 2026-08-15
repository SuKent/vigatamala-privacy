import Foundation

/// Safari content blocker 規則格式(WKContentRuleList 吃的就是這個)。
public struct ContentBlockerRule: Codable, Equatable, Sendable {
    public var trigger: Trigger
    public var action: Action

    public init(trigger: Trigger, action: Action) {
        self.trigger = trigger
        self.action = action
    }

    public struct Trigger: Codable, Equatable, Sendable {
        public var urlFilter: String
        public var urlFilterIsCaseSensitive: Bool?
        public var ifDomain: [String]?
        public var unlessDomain: [String]?
        public var resourceType: [ResourceType]?
        public var loadType: [LoadType]?
        public var ifTopURL: [String]?
        public var unlessTopURL: [String]?

        public init(
            urlFilter: String,
            urlFilterIsCaseSensitive: Bool? = nil,
            ifDomain: [String]? = nil,
            unlessDomain: [String]? = nil,
            resourceType: [ResourceType]? = nil,
            loadType: [LoadType]? = nil,
            ifTopURL: [String]? = nil,
            unlessTopURL: [String]? = nil
        ) {
            self.urlFilter = urlFilter
            self.urlFilterIsCaseSensitive = urlFilterIsCaseSensitive
            self.ifDomain = ifDomain
            self.unlessDomain = unlessDomain
            self.resourceType = resourceType
            self.loadType = loadType
            self.ifTopURL = ifTopURL
            self.unlessTopURL = unlessTopURL
        }

        enum CodingKeys: String, CodingKey {
            case urlFilter = "url-filter"
            case urlFilterIsCaseSensitive = "url-filter-is-case-sensitive"
            case ifDomain = "if-domain"
            case unlessDomain = "unless-domain"
            case resourceType = "resource-type"
            case loadType = "load-type"
            case ifTopURL = "if-top-url"
            case unlessTopURL = "unless-top-url"
        }
    }

    public struct Action: Codable, Equatable, Sendable {
        public var type: ActionType
        public var selector: String?

        public init(type: ActionType, selector: String? = nil) {
            self.type = type
            self.selector = selector
        }
    }

    public enum ActionType: String, Codable, Sendable {
        case block
        case blockCookies = "block-cookies"
        case cssDisplayNone = "css-display-none"
        case ignorePreviousRules = "ignore-previous-rules"
        case makeHTTPS = "make-https"
    }

    public enum ResourceType: String, Codable, Sendable, CaseIterable {
        case document
        case image
        case styleSheet = "style-sheet"
        case script
        case font
        case raw
        case svgDocument = "svg-document"
        case media
        case popup
        case ping
        case fetch
        case websocket
    }

    public enum LoadType: String, Codable, Sendable {
        case firstParty = "first-party"
        case thirdParty = "third-party"
    }

    /// 便利建構:對指定主機清單解除所有先前規則(站台例外用)。
    public static func allowlist(domains: [String]) -> ContentBlockerRule {
        ContentBlockerRule(
            trigger: Trigger(urlFilter: ".*", ifDomain: domains.map { "*" + $0 }),
            action: Action(type: .ignorePreviousRules)
        )
    }
}

public extension Array where Element == ContentBlockerRule {
    /// 編成 WKContentRuleList 需要的 JSON 字串。
    func encodedJSON() throws -> String {
        let encoder = JSONEncoder()
        // 【.sortedKeys 是必要的,不是美觀】
        //
        // 少了它,同一個 binary 對同一份輸入跑兩次會產出**不同的位元組** ——
        // Foundation 的 JSONEncoder 底層以雜湊字典序列化,而 Swift 的字典順序
        // 每個行程隨機(實測:trigger 內 url-filter 與 load-type 的先後每次不同)。
        //
        // 後果是連鎖的:
        //  - WKContentRuleList 的 identifier 含內容指紋,指紋每次都變 →
        //    每次重建都被當成新清單重編譯,並留下一份舊的編譯產物;
        //  - 規則進版控時,即使規則一條都沒變,git 也會看到整份檔案改了
        //    (一次 8.7 MB 的 blob);
        //  - 「同樣的輸入可以重現同樣的輸出」這個對外的說法不成立。
        encoder.outputFormatting = [.withoutEscapingSlashes, .sortedKeys]
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}

/// 一份規則清單的來源描述。
public struct RuleListSource: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable {
        /// 已經是 content blocker JSON。
        case contentBlockerJSON
        /// Adblock Plus / EasyList 語法的純文字,需要轉換。
        case adblockText
    }

    public let id: String
    public var title: String
    public var detail: String
    public var kind: Kind
    /// 內建於 App bundle 的檔名(不含副檔名)。
    public var bundledResource: String?
    /// 遠端更新來源。
    public var remoteURL: String?
    /// 使用者可否關閉。
    public var isOptional: Bool
    public var defaultEnabled: Bool
    /// 是否為大型清單(數萬條)。
    ///
    /// 大型清單編譯要好幾秒,不能擋在啟動路徑上 —— 使用者會盯著「正在準備…」。
    /// 這些改在背景編譯,編好之後由既有的規則變動訂閱推進所有分頁。
    public var isLarge: Bool

    public init(
        id: String,
        title: String,
        detail: String,
        kind: Kind,
        bundledResource: String? = nil,
        remoteURL: String? = nil,
        isOptional: Bool = true,
        isLarge: Bool = false,
        defaultEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.kind = kind
        self.bundledResource = bundledResource
        self.remoteURL = remoteURL
        self.isOptional = isOptional
        self.isLarge = isLarge
        self.defaultEnabled = defaultEnabled
    }
}

/// 內建規則清單目錄。
public enum RuleCatalog {
    public static let ads = RuleListSource(
        id: "ads",
        title: "廣告版位",
        detail: "橫幅、插頁與廣告請求的網路層阻擋。",
        kind: .contentBlockerJSON,
        bundledResource: "ads",
        isOptional: false,
        defaultEnabled: true
    )

    public static let trackers = RuleListSource(
        id: "trackers",
        title: "追蹤器",
        detail: "分析、指紋與跨站行為追蹤服務。",
        kind: .contentBlockerJSON,
        bundledResource: "trackers",
        isOptional: false,
        defaultEnabled: true
    )

    /// EasyList —— 免費層的主力擋廣告清單(建置期預先轉換,見 Tools/build-rules.sh)。
    ///
    /// CLAUDE.md 定義免費層是「完整的通用網頁擋廣告,與免費競品打平」。
    /// 手寫的 ads/trackers 只有一百多條,那個目標靠它們達不到。
    public static let easylist = RuleListSource(
        id: "easylist",
        title: "EasyList",
        detail: "社群維護的通用廣告過濾清單。",
        kind: .contentBlockerJSON,
        bundledResource: "easylist",
        isOptional: false,
        isLarge: true,
        defaultEnabled: true
    )

    public static let easyprivacy = RuleListSource(
        id: "easyprivacy",
        title: "EasyPrivacy",
        detail: "社群維護的通用追蹤器過濾清單。",
        kind: .contentBlockerJSON,
        bundledResource: "easyprivacy",
        isOptional: false,
        isLarge: true,
        defaultEnabled: true
    )

    public static let cosmetic = RuleListSource(
        id: "cosmetic",
        title: "殘留版位",
        detail: "阻擋後仍留在版面上的空容器與推薦版位。",
        kind: .contentBlockerJSON,
        bundledResource: "cosmetic",
        isOptional: true,
        defaultEnabled: true
    )

    public static let all: [RuleListSource] = [ads, trackers, cosmetic, easylist, easyprivacy]
}
