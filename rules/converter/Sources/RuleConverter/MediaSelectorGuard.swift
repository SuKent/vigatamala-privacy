import Foundation

/// 「自家清單藏掉自家要點的元素」的防線。
///
/// 【出過什麼事】
/// 上游清單的一條**通用**外觀規則(不限站台)把包著略過鈕的整個容器設成
/// `display:none`。結果是每一支可略過廣告的略過鈕都是**我們自己藏掉、按不到的**
/// —— 實測 89~109 次進入廣告對 0 次成功略過。症狀是「廣告一直播完」,
/// 而原因在完全不相干的一層,診斷花了好幾天的祖先鏈追查。
///
/// 當時的修法是在媒體引擎端對隱藏元素照樣 `click()`。那治得了這一次,
/// 但**管線本身仍然沒有防線**:下一次上游加一條蓋到別的容器、或蓋到我們用來
/// 判定廣告的標記,症狀會以完全不同的面貌重新出現,而且一樣難查。
///
/// 這裡把它變成管線層的不變式:**通用外觀規則不得在媒體 profile 的站台上,
/// 隱藏該 profile 自己列出的元素。** 命中的規則不是被丟掉,而是加上
/// `unless-domain` 避開那些站台 —— 其他站台照樣受益。
///
/// 【為什麼比對「token」而不是整條選擇器】
/// 上游寫的可能是 `.video-ads`、`div.video-ads`、`#player .video-ads`,
/// 字串比對只認得第一種。取出選擇器裡的 class / id token 再比對,
/// 三種都認得,而誤判的代價很小(那條規則在媒體站台上不生效而已)。
///
/// 【站名不寫在程式碼裡】受保護的選擇器與站台都來自 `MediaProfiles.json`
/// (`guardedSelectors` / `hostSuffixes`),與本專案其他地方一致。
/// profile 讀不到時整個防線靜默停用 —— 那是**維持原行為**,不是新的失敗模式。
///
/// 【這個檔案必須自足 —— 不得引用 MediaProfile】
/// 鏡像 repo(vigatamala-privacy)有一份可獨立建置的轉換器,GitHub Actions
/// 每天用它產生使用者實際下載的規則。它是純 SwiftPM 執行檔,沒有 App 的
/// bundle、也沒有 MediaProfiles.json。若這個檔案引用了 MediaProfile,
/// 就複製不過去 —— 而 2026-08-30 發現的正是那個後果:鏡像的轉換器**根本
/// 沒有這道防線**,每日自動更新產出的規則把略過鈕連同 `.video-ads` 一起藏掉,
/// 於是「89~109 次進入廣告對 0 次成功略過」在使用者端從來沒有被修好過,
/// 儘管 App 這一側的防線早就寫好、測試也通過。
///
/// 所以「從 profile 推導」與「隨 App 出貨的那一份」搬到
/// `MediaSelectorGuard+Profiles.swift`,這裡只留 token 解析與 Guard 本身。
/// `Tools/sync-rules-mirror.sh` 複製這個檔 + 一份產生出來的資料檔。
public enum MediaSelectorGuard {

    /// 從一條 CSS 選擇器裡取出所有 class / id token。
    ///
    /// 只認 ASCII 的 `[.#]` 後面那一段;偽類、屬性選擇器、組合子都當分隔符。
    /// 刻意不做完整解析 —— 這裡只需要「有沒有提到那個名字」。
    public static func tokens(in selector: String) -> Set<String> {
        var result: Set<String> = []
        var current = ""
        var collecting = false
        for ch in selector {
            if ch == "." || ch == "#" {
                if collecting, !current.isEmpty { result.insert(current) }
                current = ""
                collecting = true
                continue
            }
            if collecting {
                if ch.isLetter || ch.isNumber || ch == "-" || ch == "_" {
                    current.append(ch)
                } else {
                    if !current.isEmpty { result.insert(current) }
                    current = ""
                    collecting = false
                }
            }
        }
        if collecting, !current.isEmpty { result.insert(current) }
        return result
    }

    /// 一份「受保護 token → 該保護哪些站台」的對照。
    public struct Guard: Sendable, Equatable {
        /// 不得被藏起來的 class / id token。
        public let tokens: Set<String>
        /// 要避開的站台(已是 content blocker 的 `*host` 形式)。
        public let unlessDomains: [String]

        public init(tokens: Set<String>, unlessDomains: [String]) {
            self.tokens = tokens
            self.unlessDomains = unlessDomains
        }

        /// 空的防線 = 不改變任何規則。
        public static let inactive = Guard(tokens: [], unlessDomains: [])
        public var isActive: Bool { !tokens.isEmpty && !unlessDomains.isEmpty }

        /// 這條外觀規則會不會藏到我們自己要用的元素。
        public func conflicts(with selector: String) -> Bool {
            guard isActive else { return false }
            return !MediaSelectorGuard.tokens(in: selector).isDisjoint(with: tokens)
        }
    }
}
