# Vigatamala 隱私政策

**最後更新:2026-08-17**
**適用對象:Vigatamala for iOS**

*English version below — [jump to English](#privacy-policy-english).*

---

## 先講結論

**Vigatamala 不會把你的瀏覽資料傳給我們。**

我們沒有帳號伺服器。App 裡沒有任何分析、遙測、當機回報或廣告元件,也沒有任何
第三方軟體套件。你造訪過哪些網站、看過什麼、搜尋過什麼,全部只留在你的 iPhone 上。

這份政策的其餘部分是把三件事講清楚:**留在你手機上的到底是什麼**、
**App 自己會連到哪裡**、**你怎麼刪掉**。包含幾個我們目前還沒做好的地方。

---

## 1. 我們收不到的東西

- **我們沒有帳號後端,也收不到你的瀏覽資料。** App 唯一會連向我們網域的,是
  下載阻擋規則清單的那條請求(見第 3 節第 (1) 項)—— 它只帶要下載的檔名,
  不帶你造訪過的網址,也不帶帳號或裝置識別碼。除此之外沒有任何連向我們的連線。
- **沒有任何第三方軟體套件。** 沒有 Google Analytics、Firebase、Crashlytics、
  Sentry,也沒有廣告聯播網。
- **沒有廣告識別碼(IDFA)**,不會跳出「允許追蹤」的要求。
- **不使用定位。** App 沒有任何位置權限。
- **網址列建議完全在裝置上產生。** 你打的每一個字都是拿去比對本機的歷史與書籤。
  多數瀏覽器會把你的按鍵送給搜尋引擎換「搜尋建議」,我們沒有。
- **廣告與追蹤器的阻擋判斷全部在裝置上完成。** 我們不會把你要開的網址送去
  任何伺服器問「這個要不要擋」。(iOS 內建的「詐騙網站警告」是另一回事,
  見第 3 節第 (6) 項 —— 那是系統層功能,對象是 Apple 而不是我們。)

---

## 2. 存在你裝置上的資料

以下全部存在 App 的私有資料夾內,**不會傳送給我們或任何第三方**。

但要誠實講一件事:若你開啟 iCloud 備份、或用電腦備份 iPhone,這些檔案會隨
**系統備份**一併複製。那是 Apple 的備份機制,備份內容我們讀不到,也無法讀。
我們沒有把這些檔案排除在備份之外 —— 排除了你換手機時書籤與歷史就會消失。

| 資料 | 內容 | 保留 | 怎麼刪 |
|---|---|---|---|
| 瀏覽歷史 | 完整網址、標題、時間 | 最新 2000 筆 | 設定 →「資料」→「清除瀏覽歷史」;或瀏覽紀錄頁右上「清除」 |
| 分頁 | 網址、標題、自訂名稱、釘選狀態 | 無上限 | 關閉分頁,或分頁切換器選單的「關閉所有分頁」(釘選的會被略過) |
| 書籤 | 網址、標題、加入時間 | 無上限 | 首頁書籤格逐一移除 |
| 稍後閱讀 | 網址、標題、時間(**不存內文**) | 無上限 | 清單頁左滑刪除;右上「清除已讀」 |
| 播放佇列 | 媒體網址、標題、演出者、封面網址(**私密分頁的只留在記憶體**) | 無上限 | 佇列面板左滑刪除;關閉該分頁會整份丟掉 |
| 觀看進度 | 媒體識別碼、播放位置 | 90 天或 500 筆 | 隨「清除瀏覽歷史」一併清除 |
| 偏好設定 | 各項開關;**以及你為個別網站設過的例外** | 無上限 | 該站所有覆寫都改回「沿用全域」時會自動移除 |
| 網站資料 | cookie、快取、localStorage(由 WebKit 管理,**每個分頁一份獨立的**) | 分頁關閉即抹除 | 設定 →「資料」→「清除所有網站資料」;或盾牌選單清除單一站台 |
| 授權紀錄 | 本機產生的帳號 UUID、購買交易編號與日期、授權天數帳本 | 無上限 | 目前沒有刪除入口(刪除 App 會一併移除) |
| 阻擋統計 | 累計擋掉幾個劫持、關掉幾個橫幅 | 無上限 | 同上 |
| 規則更新紀錄 | 上次更新時間與規則筆數 | 無上限 | 同上 |

**要知道的兩件事:**

1. **搜尋字詞會以網址的形式留在歷史裡。** 你在網址列打字搜尋,產生的是一個含
   `?q=你打的字` 的搜尋網址,那個網址會被記進瀏覽歷史。清除歷史就會一起消失。
2. **「清除瀏覽歷史」不會清掉分頁、書籤與稍後閱讀。** 那三者各自有自己的刪除方式
   (見上表)。

---

## 3. App 自己會連到哪裡

除了你主動瀏覽的網頁之外,App 自己只發出這幾種連線:

**(1) 阻擋規則清單下載/更新 → `privacy.link2us.link`(退路:`easylist.to`)**
EasyList 與 EasyPrivacy 這兩份大型公開清單**不隨 App 打包**,要由你自己下載。
預設從我們的鏡像 `https://privacy.link2us.link/rules/` 取得已預先轉換並簽章的
版本(裝置端驗簽);鏡像不可用時才退回上游 `easylist.to` 抓原始清單、
在你的裝置上轉換。

**什麼時候會下載**:首次啟動時問你一次(可選「稍後」);設定 →「內容阻擋」
裡隨時可以按「下載清單」。**這兩者都不需要訂閱。**訂閱的是「自動更新規則」
(預設關閉):開啟後 App 才會在啟動時自動檢查更新,最快 24 小時一次。

**這條請求裡有什麼**:只有要下載的檔名。不含你造訪過的網址,不附加任何帳號或
裝置識別碼,並使用獨立的網路設定(不帶 cookie、不寫快取)。唯一額外的標頭是
`If-None-Match` —— 上次下載時伺服器給的檔案版本標記,用來在內容沒變時省下重抓;
它對應的是那份檔案而不是你,拿到同一份清單的人都是同一個值。

**我們這端會收到什麼**:這是整份政策裡唯一一條連向我們自己網域的請求,所以要
講清楚。和任何網頁伺服器一樣,連線本身會帶著你的 IP 位址、瀏覽器識別字串、時間
與請求的檔名。那個網域只是靜態檔案託管(Cloudflare),我們沒有在上面放自己的
程式碼,**也沒有把逐筆存取紀錄匯出或保存到任何地方**;我們看得到的只有服務商的
彙總流量統計(總請求數、快取命中率之類),裡面沒有個別使用者。IP 位址仍會被
服務商在傳送與防濫用的過程中處理,那是連線本身無法避免的。退回上游
`easylist.to` 時,看到你 IP 的是 EasyList 的基礎設施(第三方),不在我們手上。

**(2) 鎖定畫面的封面圖 → 該網頁指定的圖片來源**
播放媒體時,鎖定畫面要顯示封面。那張圖的網址來自網頁自己的 metadata,
通常是第三方圖床或 CDN。**這是唯一在你沒有主動開著頁面的情況下也會發生的第三方連線** ——
App 在背景、螢幕鎖著時,它仍然會發出。 我們把它限制到最小:使用不帶 cookie、不寫快取的獨立網路設定,
而且**私密分頁完全不抓封面圖、也不送任何資訊到鎖定畫面**。
要完全停用:設定 →「媒體」→ 關閉「鎖定畫面控制」。
請注意那個開關會一併停用鎖定畫面與控制中心的曲目資訊與播放控制。

**(3) 訂閱來源(RSS/Atom)→ 你點的那個來源網址**
在你點擊網址列的訂閱圖示時發生。訂閱來源頁是一個**一般分頁**,所以你重新整理
它、或下次啟動 App 還原該分頁時,也會重新抓一次。使用獨立的網路設定,
不帶 cookie、不寫快取,內容只在記憶體解析,不落磁碟。

**(4) 閱讀器畫面裡的圖片 → 文章來源與其圖床**
閱讀器重排後仍會載入原文的圖片。這個畫面套用與該分頁相同的阻擋規則,
也使用該分頁自己的儲存區(所以私密分頁的閱讀器一樣不落地)。

**(5) App 內購買 → Apple(StoreKit)**
只在你購買或恢復購買時發生。往返對象是 Apple,不是我們。
你完成購買時,Apple 給我們的交易編號與購買日期**只寫在你的裝置上**。

**(6) 詐騙網站警告 → Apple**
iOS 內建的網頁引擎會就你造訪的網址向 Apple 查詢是否為已知的詐騙或惡意網站,
並在命中時擋下。**這是 iOS 的系統層功能,查詢對象是 Apple,我們看不到也碰不到。**
我們選擇保留它 —— 關掉可以讓這份政策少一條,但會讓你少一層保護。

**(選用)回報問題**:設定 → 關於 →「回報問題」會開啟**你自己的**郵件
(或分享面板),收件人是我們的支援信箱。App 不會自行傳送任何資料 ——
內文與附件在寄出前全部可見,按下送出的是你。附件是「診斷紀錄」
(設定 → 隱私,**預設關閉**):只記錄功能事件(播放、阻擋、全螢幕等),
網址在寫入時就只保留網站主機的部分;關閉開關即刪除整份紀錄。
我們收到的回報僅用於除錯,不與任何其他資料關聯、不提供第三方,
處理完成後 90 天內刪除。

除上述之外,App 不會發出其他對外連線。

---

## 4. 私密分頁

**做到的:**

- 不寫入瀏覽歷史,不寫入分頁清單,重開 App 不還原。
- 網站資料(cookie、快取)只放在記憶體,關閉即消失。
- 閱讀器使用同一個「只在記憶體」的儲存區。
- 不把標題或封面送上鎖定畫面、控制中心或車機。
- 播放佇列只留在記憶體,不寫入磁碟。

**你主動做的動作仍會留下痕跡:** 在私密分頁裡加書籤或加入稍後閱讀,
那筆網址就會被寫進對應的清單。這是刻意的 —— 你明確要求保存的東西,
我們不會偷偷丟掉。但值得知道。

---

## 5. 我們對網頁做了什麼

Vigatamala 是內容阻擋型瀏覽器。為了達成阻擋,我們會:

- 依規則阻擋網路請求、隱藏頁面元素;
- 攔截頁面自己的資料請求以移除廣告版位(這代表我們會讀取並改寫網站送來的
  部分回應內容);
- 攔截彈出視窗與返回鍵劫持;
- 對網站回報經過雜訊處理的瀏覽器指紋(降低你被跨站辨識的機率);
- 送出 Global Privacy Control 訊號;
- 自動關閉 cookie 同意橫幅 —— **一律選擇拒絕**。部分網站的同意平台會把這個
  「拒絕」決定回報給它自己的伺服器,那是該平台的行為,不是我們發起的;
- 在送出請求前改寫網址:剝除只用於追蹤的參數、把 Google 的 AMP 殼還原成
  原始頁面(這一項會換主機,落點是該連結本來就指向的那一頁)、
  以及把 http 升級為 https(升級失敗不會靜默退回,會問你);
- 送出與 Safari 一致的 User-Agent 字串(讓網站不會因為認不得這個瀏覽器而
  給你閹割版頁面);
- 你開啟夜間模式時,對淺色網頁套用色彩反轉。

**以上每一項都可以全域關閉。** 其中阻擋、殘留版位收合、反劫持、指紋防護與
夜間模式還可以在網址列的盾牌選單針對個別網站關閉。
Global Privacy Control 訊號只有全域開關(它是一個對所有網站一致的法律訊號,
逐站送不送反而沒有意義)。

---

## 6. 我們不做的事

- 不販售、不分享、不出租你的任何資料 —— 我們根本沒有你的資料。
- 不插入廣告、聯盟連結或贊助內容。
- 不追蹤你跨 App 或跨網站的行為。
- 不提供內容下載或離線儲存功能。

---

## 7. 兒童

本 App 不面向 13 歲以下兒童,也不會在知情的情況下收集兒童的個人資料。

---

## 8. 未來的變更

當我們接上帳號後端、推出跨裝置同步或學生驗證時,收集的資料會改變。
屆時我們會更新這份政策並在 App 內告知。**目前這些功能都尚未上線。**

---

## 9. 聯絡我們

有任何疑問請寄到:**vigatamala@link2us.link**

開發者:**神農工作室**

---
---

<a name="privacy-policy-english"></a>

# Privacy Policy (English)

**Last updated: 17 August 2026**
**Applies to: Vigatamala for iOS**

## In short

**Vigatamala does not send your browsing data to us.**

We run no account servers. The app contains no analytics, telemetry, crash
reporting or advertising components, and no third-party packages of any kind.
Which sites you visit, what you watch and what you search for stay on your iPhone.

## 1. What we cannot receive

- **We have no account backend and receive none of your browsing data.** The only
  request the app makes to a domain of ours is to download blocking rule lists
  (see section 3, item 1). It carries the filename being requested — no URL you
  visited, no account or device identifier. Nothing else connects to us.
- **No third-party SDKs** — no Google Analytics, Firebase, Crashlytics, Sentry
  or ad networks.
- **No advertising identifier (IDFA)** and no tracking permission prompt.
- **No location access.**
- **Address bar suggestions are computed entirely on device** by matching what
  you type against your local history and bookmarks. Most browsers send your
  keystrokes to a search engine for suggestions. We do not.
- **Ad and tracker blocking decisions happen on device.** We never send the URL
  you are opening to a server of ours. (iOS's built-in fraudulent website
  warning is separate — see item (6) in section 3.)

## 2. Data stored on your device

Browsing history (full URLs, titles, timestamps; newest 2,000), open tabs,
bookmarks, reading list (URLs only — never article text), playback queues,
watch positions (90 days or 500 entries), preferences including any per-site
exceptions you set, and website data (cookies, caches) managed by WebKit in a
**separate store per tab**. Also stored: your entitlement record (a locally
generated account UUID, purchase transaction identifiers), blocking counters,
and rule-update bookkeeping. None of it is sent to us or to any third party.

Deletion: Settings → Data → Clear browsing history (also clears watch
positions) and Clear all website data. Tabs, bookmarks and the reading list have
their own removal actions — clearing history does not remove them.

To be straightforward about one thing: if you use iCloud Backup or back up your
iPhone to a computer, these files are copied as part of that **system backup**.
That is Apple's mechanism; we cannot read its contents. We deliberately do not
exclude them from backup — doing so would lose your bookmarks and history when
you move to a new phone.

Note that search terms persist as part of the search URL recorded in history.

## 3. Outbound connections the app makes

1. **Blocking rule downloads/updates → `privacy.link2us.link` (fallback:
   `easylist.to`).** The large public EasyList/EasyPrivacy lists are **not bundled
   with the app**; you download them yourself. By default they come from our mirror
   at `https://privacy.link2us.link/rules/` as pre-converted, signed files (verified
   on device); only if the mirror is unavailable does the app fall back to fetching
   the raw lists from `easylist.to` and converting them locally.

   **When:** the app asks once on first launch (you may decline), and Settings →
   Content Blocking has a download button at any time. **Neither requires a
   subscription.** What the subscription buys is *automatic* updating (off by
   default), which checks at most once per 24 hours.

   **What the request carries:** only the filename. No URL you visited, no account
   or device identifier, and an isolated network configuration with no cookies and
   no cache. The one extra header is `If-None-Match`, a file-version tag from the
   previous download — it identifies the file, not you, and is identical for
   everyone holding that version.

   **What reaches us:** this is the only request in this policy that goes to a
   domain of ours, so to be explicit — as with any web server, the connection
   carries your IP address, user-agent string, time and the requested filename.
   That domain is static file hosting (Cloudflare); we run no code of our own on
   it and **we do not export or retain per-request logs anywhere**. What we can see
   is the provider's aggregate traffic statistics (request counts, cache hit rate),
   which contain no individual users. Your IP is still processed by the provider in
   the course of delivery and abuse prevention — unavoidable in any connection.
   When the upstream fallback is used, it is EasyList's infrastructure (a third
   party) that sees your IP, outside our hands.
2. **Lock screen artwork → the image host the page specifies.** This is the only third-party connection that can
   happen while you are not actively looking at a page — it fires with the app in
   the background and the screen locked. It uses an isolated configuration with no cookies or cache, and
   **private tabs fetch no artwork and publish nothing to the lock screen**.
   To disable entirely: Settings → Media → Lock screen controls (this also
   disables lock screen and Control Center playback info and controls).
3. **Feed (RSS/Atom) fetching → the feed URL you tapped.** The feed page is an
   ordinary tab, so it is fetched again when you reload it or when that tab is
   restored at next launch. Isolated configuration, no cookies, no cache,
   parsed in memory only.
4. **Images inside reader view → the article's own sources.** Reader view
   applies the same blocking rules and uses the same per-tab store as the tab it
   came from.
5. **In-app purchases → Apple (StoreKit)**, only when you buy or restore.
   Transaction identifiers Apple gives us are stored **only on your device**.
6. **Fraudulent website warning → Apple.** iOS's built-in web engine checks the
   URLs you visit against Apple's list of known fraudulent sites. This is a
   system-level feature; the query goes to Apple and we can neither see nor
   influence it. We keep it on — turning it off would shorten this policy but
   leave you less protected.

The app makes no other outbound connections.

**(Optional) Issue reports.** Settings → About → "Report a problem" opens
**your own** mail composer (or the share sheet) addressed to our support
mailbox. The app transmits nothing by itself — the body and attachment are
fully visible before sending, and it is you who taps send. The attachment is
the diagnostic log (Settings → Privacy, **off by default**): it records
feature events only (playback, blocking, fullscreen and the like), URLs are
reduced to their host at write time, and turning the switch off deletes the
log. Reports we receive are used solely for debugging, are not linked to any
other data, are not shared, and are deleted within 90 days of resolution.

## 4. Private tabs

Private tabs are excluded from history and from the saved tab list, use an
in-memory-only website data store (including in reader view), keep their
playback queue in memory only, and publish nothing to the lock screen. Actions
you take deliberately — adding a bookmark or saving to the reading list — do
still save that URL.

## 5. What we change on web pages

We block network requests and hide elements using public rule lists; intercept a
page's own data requests to remove ad slots (which means we read and modify part
of what the site sends); block popups and back-button hijacking; report
noise-adjusted fingerprinting values; send Global Privacy Control; dismiss
cookie consent banners — **always declining, never accepting**; rewrite URLs
before the request is sent (stripping tracking-only parameters, unwrapping
Google AMP shells, upgrading http to https — a failed upgrade asks rather than
silently downgrading); send a Safari-matching User-Agent string; and, if you
enable night mode, invert colours on light pages. Some consent
platforms report that decision to their own servers; that is their behaviour,
not a request we initiate. **Every one of these can be turned off globally**, and blocking, cosmetic
cleanup, anti-hijacking, fingerprint protection and night mode can additionally
be turned off per site from the shield menu. Global Privacy Control is global
only — it is a consistent legal signal, so a per-site version would be meaningless.

## 6. What we never do

We do not sell, share or rent your data — we do not have it. We insert no
advertising, affiliate links or sponsored content. We do not track you across
apps or websites. We provide no content download or offline storage.

## 7. Children

This app is not directed at children under 13 and does not knowingly collect
personal information from children.

## 8. Changes

When we introduce accounts, cross-device sync or student verification, what is
collected will change. We will update this policy and notify you in the app.
**None of those features exist today.**

## 9. Contact

**vigatamala@link2us.link** — **SanLong Studio**
