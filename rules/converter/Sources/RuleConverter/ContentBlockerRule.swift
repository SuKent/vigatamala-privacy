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

    /// 這份清單跟著哪個分類開關。
    ///
    /// 沒有這個欄位之前,`BlockingPlan` 是靠寫死的 id 清單分類的,而下載回來的
    /// 遠端清單不在那份寫死清單裡 —— 於是它們繞過了「封鎖廣告 / 封鎖追蹤器」,
    /// 開關看起來有動、實際上什麼都沒關。分類跟著來源走才不會再漏。
    public enum Category: String, Codable, Sendable {
        /// 廣告版位與廣告請求(含阻擋後殘留的空版位)。
        case ads
        /// 追蹤、分析、指紋。額外吃站台層級的追蹤器覆寫。
        case trackers
    }

    public let id: String
    public var title: String
    public var detail: String
    public var kind: Kind
    public var category: Category
    /// 這份清單做的是不是「外觀層」的事(css-display-none 隱藏殘留版位)。
    ///
    /// 需要它是因為盾牌有一個獨立的「移除殘留版位」逐站開關,而那個開關先前
    /// 只關得掉注入層 —— 網路層那份 cosmetic.json 擋的是幾乎同一批選擇器,
    /// 照樣把元素藏著。使用者關了開關卻毫無變化,只能再往下把整站阻擋關掉。
    /// 用資料欄位而不是在 BlockingPlan 裡比對 id,理由同 category
    /// (見上面那段:寫死 id 正是 42ea5cb 那個缺陷的來源)。
    public var isCosmetic: Bool
    /// 內建於 App bundle 的檔名(不含副檔名)。
    public var bundledResource: String?
    // 【2026-08-25 移除三個死欄位:remoteURL / isOptional / defaultEnabled】
    //
    // 三個都是「保留給未來跨平台用」而留著的,但它們不是中性的佔位符,
    // 是**會誤導人的假訊號**:
    //
    //  - `remoteURL` 連寫入端都沒有(`RuleCatalog` 五個定義全部省略),執行期
    //    恆為 nil。而讀到這個型別的人會合理以為遠端來源出自這裡 —— 真正的
    //    網址硬編在 `RuleUpdateService.defaultSources`。一個「不可以相信它有值」
    //    的欄位,價值是負的。
    //  - `isOptional` / `defaultEnabled` 有被**寫入**看似有意義的值
    //    (內建清單 false、大型清單 true),卻零讀取者:哪幾份清單生效完全由
    //    `BlockingPlan` 依偏好與逐站政策決定。有人想改行為而去翻這兩個旗標,
    //    改完什麼都不會發生,而且他不會知道為什麼。
    //
    // 真的接 Android / Web 的那天再加回來,成本是幾行;留著的成本是每個讀到
    // 這個型別的人都要重新確認一次它到底有沒有在用。
    // (同一個判準先前已經用在 `lastSkippedCount`、`compileLargeLists()`、
    //  `contribution_reward` 上。)

    /// 是否為大型清單(數萬條)。
    ///
    /// 大型清單編譯要好幾秒,不能擋在啟動路徑上 —— 使用者會盯著「正在準備…」。
    ///
    /// ⚠️ 它**不再驅動任何背景編譯**。自從大清單不隨 App 打包(2026-08-16),
    /// 這個旗標唯一的作用是把它們**排除**在 `compileBundledLists()` 之外;
    /// 真正的編譯入口在 `RuleUpdateService`。先前那支
    /// `compileLargeLists()` 已於 2026-08-24 刪除(它是保證的 no-op)。
    public var isLarge: Bool

    public init(
        id: String,
        title: String,
        detail: String,
        kind: Kind,
        category: Category,
        isCosmetic: Bool = false,
        bundledResource: String? = nil,
        isLarge: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.kind = kind
        self.category = category
        self.isCosmetic = isCosmetic
        self.bundledResource = bundledResource
        self.isLarge = isLarge
    }
}

/// 內建規則清單目錄。
public enum RuleCatalog {
    public static let ads = RuleListSource(
        id: "ads",
        title: "廣告版位",
        detail: "橫幅、插頁與廣告請求的網路層阻擋。",
        kind: .contentBlockerJSON,
        category: .ads,
        bundledResource: "ads"
    )

    public static let trackers = RuleListSource(
        id: "trackers",
        title: "追蹤器",
        detail: "分析、指紋與跨站行為追蹤服務。",
        kind: .contentBlockerJSON,
        category: .trackers,
        bundledResource: "trackers"
    )

    /// EasyList —— **不隨 App 打包,改由使用者在 App 內下載**。
    ///
    /// 理由有二,缺一都不足以改變設計:
    ///  1. 授權:CC BY-SA 的改作物「透過 App Store 散布」在 CC 自己的說明裡
    ///     都沒有定論。個人小成本開發不打算為此走法律諮詢,那就別把它放進
    ///     二進位檔 —— 改成「我們提供可下載的來源,使用者自行取得」,
    ///     等同一般擋廣告工具的做法,爭議面小得多。
    ///  2. 體積:兩份合計約 10 MB,對安裝檔是純負擔。
    ///
    /// 代價誠實記錄:首次安裝到下載完成之間,擋廣告只有自維的 ads/trackers
    /// (一百多條),弱於 CLAUDE.md 對免費層「與免費競品打平」的期待。
    /// 因此首次啟動要主動提示下載,而且**下載本身免費**(只有自動更新是訂閱)。
    public static let easylist = RuleListSource(
        id: "easylist",
        title: "EasyList",
        detail: "社群維護的通用廣告過濾清單。",
        kind: .contentBlockerJSON,
        category: .ads,
        bundledResource: nil,
        isLarge: true
    )

    public static let easyprivacy = RuleListSource(
        id: "easyprivacy",
        title: "EasyPrivacy",
        detail: "社群維護的通用追蹤器過濾清單。",
        kind: .contentBlockerJSON,
        category: .trackers,
        bundledResource: nil,   // 同 easylist:改為 App 內下載
        isLarge: true
    )

    public static let cosmetic = RuleListSource(
        id: "cosmetic",
        title: "殘留版位",
        detail: "阻擋後仍留在版面上的空容器與推薦版位。",
        kind: .contentBlockerJSON,
        category: .ads,
        isCosmetic: true,
        bundledResource: "cosmetic"
    )

    public static let all: [RuleListSource] = [ads, trackers, cosmetic, easylist, easyprivacy]
}
