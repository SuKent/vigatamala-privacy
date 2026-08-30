// 由 `swift run RuleBundler --emit-guard` 產生 —— **不要手改**。
//
// 這是 `MediaSelectorGuard.bundled` 在同步當下的內容,來源是主 repo 的
// MediaProfiles.json。推導邏輯只有一份(MediaSelectorGuard+Profiles.swift),
// 這裡只是把結果搬過來,好讓這份獨立轉換器不必依賴 App 的 bundle。
//
// 它擋的是什麼:上游有一條**通用**外觀規則會把包著略過鈕的容器設成
// display:none。少了這份資料,產出的規則會讓每一顆略過鈕都變成 0x0、
// 按不到,而症狀只是「廣告一直播完」—— 完全看不出原因在規則層。
extension MediaSelectorGuard {
    /// 同步時算好的防線。獨立轉換器用這一份取代 `bundled`。
    public static let vendored = Guard(
        tokens: [
            "ad-interrupting",
            "ad-showing",
            "video-ads",
            "ytShortsCarouselShortsA11yNav",
            "ytp-ad-module",
            "ytp-ad-player-overlay",
            "ytp-ad-player-overlay-layout",
            "ytp-ad-player-overlay-skip-or-preview",
            "ytp-ad-preview-container",
            "ytp-ad-skip-ad-slot",
            "ytp-ad-skip-button",
            "ytp-ad-skip-button-container",
            "ytp-ad-skip-button-modern",
            "ytp-ad-skip-button-slot",
            "ytp-ad-survey-answer-button",
            "ytp-next-button",
            "ytp-prev-button",
            "ytp-skip-ad-button",
            "ytp-unmute",
        ],
        unlessDomains: [
            "*youtube.com",
            "*youtu.be",
            "*youtube-nocookie.com",
        ]
    )
}
