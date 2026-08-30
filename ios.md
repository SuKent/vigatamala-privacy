# Vigatamala 隱私政策

**最後更新:2026-08-30**
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

- **我們沒有帳號後端,也收不到你的瀏覽資料。** App **自己主動**連向我們網域的,
  只有下載阻擋規則清單的那條請求(見第 3 節第 (1) 項)—— 它只帶要下載的檔名,
  不帶你造訪過的網址,也不帶帳號或裝置識別碼。
  (設定 → 關於裡的「隱私政策」與「阻擋規則授權」頁的鏡像連結也指向同一個網域,
  但那是兩個**一般的網頁連結**:你點了才會前往,和你在任何瀏覽器裡開一個網址
  沒有兩樣。除此之外沒有任何連向我們的連線。)
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

但要誠實講一件事:若你開啟 iCloud 備份、或用電腦備份 iPhone,這些檔案**多數**會隨
**系統備份**一併複製。那是 Apple 的備份機制,備份內容我們讀不到,也無法讀。
我們沒有把書籤、歷史、分頁那些排除在備份之外 —— 排除了你換手機時它們就會消失。

**兩份例外**,我們主動排除在備份之外:**規則清單快取**(隨時可以重新下載的
衍生資料,沒有理由佔用你的 iCloud 空間)與**診斷紀錄**(裡面有你造訪過的
網站主機,沒有理由讓它離開這台裝置)。

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
| 分頁互動狀態 | 每個分頁的上一頁/下一頁清單(含網址)與捲動位置(**私密分頁不寫檔**) | 跟著分頁走 | 關閉該分頁即刪;「清除瀏覽歷史」也會把磁碟上的這份一併清掉 |
| 規則更新紀錄 | 上次更新時間、規則筆數、以及是否走過沒有簽章的退路 | 無上限 | 目前沒有刪除入口(刪除 App 會一併移除) |
| 規則清單快取 | 下載回來的阻擋規則本身(約 10 MB),**不含任何你的資料** | 到下次更新覆蓋 | 目前沒有刪除入口(刪除 App 會一併移除);**不進備份** |
| 診斷紀錄 | **預設關閉**。開啟後記錄功能事件,一般分頁只留網站主機、私密分頁連主機都不留 | 約 600 KB 封頂,超過只留後半 | 設定 →「隱私」→ 關閉「診斷紀錄」即**刪除整份**;**不進備份** |
| 安裝識別碼 | 一組隨機產生的 UUID,存在 Keychain 而不是檔案裡。不含任何個人資料 | 無上限 | 見下方第 4 點 —— **刪除 App 不保證會移除** |

**要知道的四件事:**

1. **搜尋字詞會以網址的形式留在歷史裡。** 你在網址列打字搜尋,產生的是一個含
   `?q=你打的字` 的搜尋網址,那個網址會被記進瀏覽歷史。清除歷史就會一起消失。
2. **「清除瀏覽歷史」不會清掉分頁、書籤與稍後閱讀。** 那三者各自有自己的刪除方式
   (見上表)。
3. **購買紀錄不在我們這裡,我們也沒有另外抄一份。** 訂閱狀態由 Apple 的
   App Store 保管;App 只是向系統問「這個 Apple ID 現在有沒有有效訂閱」。
   交易編號、扣款日期、剩餘天數之類的東西,我們**沒有**在你的裝置上另存一份,
   也沒有伺服器可以存。
4. **安裝識別碼刪除 App 之後可能仍然留著,而且會跟著加密備份到新裝置。**
   它存在 Keychain 裡,而 Apple **沒有保證**刪除 App 時會一併清除 Keychain
   項目(實務上多半會留下)。我們也刻意沒有把它標成「僅限本機」,所以你從加密
   備份還原到新 iPhone 時,它會是同一組值 —— 這是為了讓換機的你被當成同一個
   安裝,而不是憑空多一台裝置。它只是一組隨機字串,不含任何個人資料,而且
   **目前沒有任何程式碼會把它送出裝置**。將來若要靠它做帳號關聯,我們會先更新
   這份政策(見第 8 節)再做。

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
交易紀錄由 StoreKit(Apple 的系統元件)保管,**我們沒有另外抄一份在裝置上**,
也沒有伺服器可以抄 —— App 只是在啟動與購買後向系統問一句「這個 Apple ID
現在有沒有有效訂閱」,拿到的是有或沒有,以及到期時間。

**(6) 詐騙網站警告 → Apple**
iOS 內建的網頁引擎會就你造訪的網址向 Apple 查詢是否為已知的詐騙或惡意網站,
並在命中時擋下。**這是 iOS 的系統層功能,查詢對象是 Apple,我們看不到也碰不到。**
我們選擇保留它 —— 關掉可以讓這份政策少一條,但會讓你少一層保護。

**(選用)回報問題**:設定 → 關於 →「回報問題」會開啟**你自己的**郵件
(或分享面板),收件人是我們的支援信箱。App 不會自行傳送任何資料 ——
內文與附件在寄出前全部可見,按下送出的是你。除了你寫的描述之外,信件會
預先填入三行:App 版本、iOS 版本、裝置機型(例如「iPhone」)—— 沒有序號、
沒有任何識別碼,而且你可以在寄出前刪掉它們。

附件是「診斷紀錄」(設定 → 隱私,**預設關閉**),只記錄功能事件
(播放、阻擋、全螢幕等)。網址在**寫入磁碟的當下**就已經遮蔽,不是寄出時才處理:

- 一般分頁:只留 `https://主機`,路徑與查詢字串一律換成「…」;
- **私密分頁:連主機都不留**,整個網址換成「‹私密›」;
- 網址裡若內嵌了帳號密碼(`https://帳號:密碼@…` 這種形式),
  會在遮蔽之前先被拔掉。

關閉開關即刪除整份紀錄。我們收到的回報僅用於除錯,不與任何其他資料關聯、
不提供第三方,處理完成後 90 天內刪除。

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
- 自動關閉「用 App 開啟」的招攬牆 —— 找得到「暫時不要」這類否定選項時
  **代你按下它**,找不到就只把那片浮層藏起來。**永遠不會按招攬鈕**,
  含密碼欄的浮層(登入牆)也不動。同上,被按下的那個選項若讓網站記下
  「這個人選了不要」,那是該網站的行為;
- 在送出請求前改寫網址:剝除只用於追蹤的參數、把 Google 的 AMP 殼還原成
  原始頁面(這一項會換主機,落點是該連結本來就指向的那一頁)、
  以及把 http 升級為 https(升級失敗不會靜默退回,會問你);
- 送出與 Safari 一致的 User-Agent 字串(讓網站不會因為認不得這個瀏覽器而
  給你閹割版頁面);
- 你開啟夜間模式時,對淺色網頁套用色彩反轉。

**除了 User-Agent 之外,以上每一項都可以全域關閉**,多數還能在網址列的盾牌
選單針對個別網站關閉(阻擋、追蹤器阻擋、殘留版位收合、反劫持、指紋防護、
HTTPS 強制、cookie 橫幅、夜間模式、桌面版網頁)。兩個例外要講清楚:

- **User-Agent 沒有關閉選項。** App 一律以與 Safari 一致的字串自我介紹
  (盾牌選單的「桌面版網頁」只是換成 macOS Safari 的版本,不是關掉它)。
  這是刻意的:一個認不出來的瀏覽器字串會讓部分網站直接拒絕服務或給你
  閹割版頁面,而它送出的資訊比預設值**更少**辨識度 —— 它讓你看起來
  和其他所有 Safari 使用者一樣,而不是「某個小眾瀏覽器的使用者」。
- **Global Privacy Control 只有全域開關**(它是一個對所有網站一致的法律訊號,
  逐站送不送反而沒有意義)。技術限制也一併講明:`Sec-GPC` 標頭只掛得上
  App 自己發起的主框架請求,iOS 的網頁引擎不提供為頁面內的子資源請求
  加標頭的途徑;`navigator.globalPrivacyControl` 則對整頁都成立。

---

## 6. 我們不做的事

- 不販售、不分享、不出租你的任何資料 —— 我們根本沒有你的資料。
- 不插入廣告、聯盟連結或贊助內容。
- 不追蹤你跨 App 或跨網站的行為。
- 不提供內容下載或離線儲存功能。

---

## 7. 兒童

本 App 不面向 13 歲以下兒童,也不會在知情的情況下收集兒童的個人資料。

本 App 在 App Store 的年齡分級為 **16+**。這是通用瀏覽器的必然結果 ——
它能開啟任何網頁(Apple 問卷裡的「不受限的網頁存取」),而該項目的最低分級
就是 16+,所有主流瀏覽器都一樣。

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

**Last updated: 30 August 2026**
**Applies to: Vigatamala for iOS**

## In short

**Vigatamala does not send your browsing data to us.**

We run no account servers. The app contains no analytics, telemetry, crash
reporting or advertising components, and no third-party packages of any kind.
Which sites you visit, what you watch and what you search for stay on your iPhone.

## 1. What we cannot receive

- **We have no account backend and receive none of your browsing data.** The only
  request the app makes to a domain of ours **on its own initiative** is to download
  blocking rule lists (see section 3, item 1). It carries the filename being
  requested — no URL you visited, no account or device identifier. (The "Privacy
  policy" link in Settings → About, and the mirror link on the blocking-rule
  licence page, point at the same domain, but those are ordinary web links: they
  go nowhere until you tap them, exactly like opening any URL in any browser.)
  Nothing else connects to us.
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
exceptions you set, per-tab interaction state (each tab's back/forward list —
which contains URLs — and scroll position; never written to disk for private
tabs), website data (cookies, caches) managed by WebKit in a **separate store
per tab**, and rule-update bookkeeping (when each list was last refreshed, how
many rules it held, and whether it came from the unsigned fallback). Two further
items hold no data of yours: the **downloaded rule lists themselves** (~10 MB of
cache, overwritten at the next update) and the **diagnostic log** (off by default;
see section 3 — capped at roughly 600 KB, and deleted the moment you turn the
switch off). None of it is sent to us or to any third party.

**Purchase records are not kept here, and we do not keep a copy.** Your
subscription status is held by Apple's App Store; the app simply asks the system
whether this Apple ID currently has an active subscription. Transaction
identifiers, billing dates and remaining entitlement days are **not** stored on
your device by us, and there is no server of ours that could store them.

**One item lives in the Keychain rather than in a file: a randomly generated
install identifier.** It is a random string containing no personal data, and no
code in the app sends it anywhere today. Two things about it are worth knowing:
Apple does **not** guarantee that Keychain items are removed when you delete an
app (in practice they usually survive), and we deliberately do not mark it
device-only, so restoring an encrypted backup carries the same value to a new
iPhone — that is so a phone upgrade counts as the same installation rather than
a new device. If we ever start using it to link devices to an account, we will
update this policy first (see section 8).

Deletion: Settings → Data → Clear browsing history (which also clears watch
positions and the saved per-tab interaction state) and Clear all website data.
Tabs, bookmarks and the reading list have their own removal actions — clearing
history does not remove them.

To be straightforward about one thing: if you use iCloud Backup or back up your
iPhone to a computer, **most** of these files are copied as part of that **system
backup**. That is Apple's mechanism; we cannot read its contents. We deliberately
do not exclude bookmarks, history and tabs from backup — doing so would lose them
when you move to a new phone. **Two exceptions we do exclude:** the rule-list
cache (derived data you can always re-download) and the diagnostic log (it
contains hosts you visited, so it has no business leaving this device).

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
5. **In-app purchases → Apple (StoreKit)**, only when you buy or restore. The
   round trip is with Apple, not with us. Transaction records are held by
   StoreKit, Apple's own system component; **we keep no separate copy on your
   device** and have no server that could keep one. The app only asks the system
   whether this Apple ID currently has an active subscription, and gets back a
   yes/no plus an expiry date.
6. **Fraudulent website warning → Apple.** iOS's built-in web engine checks the
   URLs you visit against Apple's list of known fraudulent sites. This is a
   system-level feature; the query goes to Apple and we can neither see nor
   influence it. We keep it on — turning it off would shorten this policy but
   leave you less protected.

The app makes no other outbound connections.

**(Optional) Issue reports.** Settings → About → "Report a problem" opens
**your own** mail composer (or the share sheet) addressed to our support
mailbox. The app transmits nothing by itself — the body and attachment are
fully visible before sending, and it is you who taps send. Besides what you
write, the message is prefilled with three lines: app version, iOS version and
device model (e.g. "iPhone") — no serial number, no identifier of any kind, and
you can delete them before sending.

The attachment is the diagnostic log (Settings → Privacy, **off by default**),
which records feature events only (playback, blocking, fullscreen and the like).
URLs are redacted **as they are written to disk**, not at send time:

- ordinary tabs: only `https://host` survives; path and query become "…";
- **private tabs: not even the host** — the whole URL becomes "‹私密›";
- credentials embedded in a URL (`https://user:password@…`) are stripped before
  either of the above runs.

Turning the switch off deletes the log. Reports we receive are used solely for
debugging, are not linked to any other data, are not shared, and are deleted
within 90 days of resolution.

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
cookie consent banners — **always declining, never accepting**; dismiss
"open in app" promotion walls — pressing the site's own "not now" option when one
exists and merely hiding the overlay when it does not (**we never press the
promotion button**, and overlays containing a password field are left alone);
rewrite URLs before the request is sent (stripping tracking-only parameters,
unwrapping Google AMP shells, upgrading http to https — a failed upgrade asks
rather than silently downgrading); send a Safari-matching User-Agent string; and,
if you enable night mode, invert colours on light pages. Where a consent platform
or site records the choice we declined on your behalf, that is its behaviour, not
a request we initiate.

**Except for the User-Agent, every one of these can be turned off globally**, and
most can additionally be turned off per site from the shield menu (blocking,
tracker blocking, cosmetic cleanup, anti-hijacking, fingerprint protection,
HTTPS-only, cookie banners, night mode, desktop mode). Two exceptions, stated
plainly:

- **The User-Agent has no off switch.** The app always identifies itself as
  Safari (the shield menu's "desktop site" only swaps in the macOS Safari
  version; it does not disable it). This is deliberate: an unrecognised browser
  string gets you refused or served a degraded page by some sites, and it carries
  *less* identifying information than the alternative — it makes you look like
  every other Safari user rather than like the user of a niche browser.
- **Global Privacy Control is global only** — it is a consistent legal signal, so
  a per-site version would be meaningless. One technical limit, stated plainly:
  the `Sec-GPC` header can only be attached to main-frame requests the app itself
  issues, because iOS's web engine offers no way to add headers to a page's own
  subresource requests; `navigator.globalPrivacyControl` applies to the whole page.

## 6. What we never do

We do not sell, share or rent your data — we do not have it. We insert no
advertising, affiliate links or sponsored content. We do not track you across
apps or websites. We provide no content download or offline storage.

## 7. Children

This app is not directed at children under 13 and does not knowingly collect
personal information from children.

Its App Store age rating is **16+**. That follows from being a general-purpose
browser: it can open any web page ("Unrestricted Web Access" in Apple's
questionnaire), for which the minimum rating is 16+. Every mainstream browser
carries the same rating.

## 8. Changes

When we introduce accounts, cross-device sync or student verification, what is
collected will change. We will update this policy and notify you in the app.
**None of those features exist today.**

## 9. Contact

**vigatamala@link2us.link** — **SanLong Studio**
