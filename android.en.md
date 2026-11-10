# Vigatamala Privacy Policy (Android)

[繁體中文](/android.zh-Hant) · [简体中文](/android.zh-Hans) · [English](/android.en) · [日本語](/android.ja) · [한국어](/android.ko)

**Last updated: 10 November 2026**
**Applies to: Vigatamala for Android**

---

## In short

**Vigatamala does not send your browsing data to us.**

The app uses our account and subscription server (which records the time and type of each connection for troubleshooting, abuse prevention and usage statistics; see section 3).
The app contains no analytics, crash-reporting or advertising packages; the only third-party components are Google Play's billing and review components (for buying a subscription and asking you for a rating) and Google ML Kit (text and QR code recognition in camera search; it starts only when you open camera search and sends usage statistics to Google; see section 3, item (7)).
Which sites you visit, what you watch and what you search for stay on the device you use.

## Deleting your data

**Data kept on your phone** (browsing history, tabs, bookmarks, website data, settings…) stays only on your phone; see section 2 for how to delete each kind. **Uninstalling the app deletes all of it.**

**Data on our servers** (installation ID, device account, subscription status, purchase records and connection records; see section 3, item (2)) is deleted when you ask us by email:

1. Open Vigatamala → "⋯" → "Settings" → "About" at the bottom → tap "Installation ID" (a single tap copies it).
2. Email **vigatamala@link2us.link** with the subject "Delete data" and paste the installation ID in the body. If you have subscribed, you can include the order number from your Google Play receipt (it starts with GPA.) instead — use it if you have already uninstalled the app and can't find your installation ID.
3. Once we have deleted it, we reply to let you know.

**What is deleted:** the device account, device links, and entitlement and subscription status.

**What is not deleted with it:**
- **The device record itself (including the installation ID)**: deleted automatically after 90 days without activity, except where abuse prevention requires keeping it.
- **Transaction records**: kept with your association stripped — they are the evidence used to handle refunds and purchase disputes.
- **Device-activity records** (the time and type of each connection): kept for 180 days by default.
- **Server backups**: nightly backups on the server are kept for 14 days; encrypted off-site copies are kept for 90 days, the first copy of each month for an additional 6 months, at least the 3 most recent copies of each service are always kept, and copies of a deleted service are kept for 1 year. After deletion, copies in existing backups remain until those periods end.

If you have never subscribed and can't find your installation ID, we have no way of telling which record is yours; that record is deleted automatically after 90 days without a connection.
**Data held by Google** (subscriptions, payments, and the account identifier given to Google at purchase) is in your Google Account and is handled by Google under its privacy policy; subscriptions are managed in Google Play under "Payments & subscriptions".

## 1. What we cannot receive

- **We do not receive browsing data.** The app downloads rule lists from our domain, registers the device and syncs subscriptions (section 3); rule requests carry no identifier at all, account requests contain only the identity and transaction data listed in section 3, and neither kind of request contains browsing content.
- **The only third-party software packages are Google Play's billing and review components and Google ML Kit.** No Google Analytics, Firebase Analytics, Crashlytics or Sentry, and no ad networks. The Google Play billing component, and the Google Play services components it brings in, are handled by Google under its privacy policy (section 3, item (3)); for ML Kit, see section 3, item (7) (Firebase Components and Google Data Transport, listed on the "Open Source Licenses" page, are the components ML Kit uses to send those statistics; they are not Firebase Analytics).
- **No advertising ID.** The app does not declare the advertising ID permission.
- **Android WebView's usage-statistics reporting is turned off.** By default, Android's web component reports usage statistics to Google according to the phone's "Usage & diagnostics" setting; Vigatamala explicitly turns this off.
- **Websites requesting your location.** When a website asks for your location, Vigatamala first asks whether you want to give it to this site; only after you allow it does Android ask for location permission. Only "while using the app" location is requested, never background location. A website you allow can receive your location and handles it under its own privacy policy; Vigatamala does not collect or store your coordinates or send them to us. Your answer is not remembered: it applies only to that page, and you are asked again the next time you open it. You can revoke the app's location permission in Android Settings.
- **Website camera and microphone.** When a website asks to use the camera or microphone (for example, for a video call), Vigatamala first asks whether you want to give it to this site, and again your answer applies only to that page. A website you allow receives the video or audio and handles it under its own privacy policy; Vigatamala does not store it or send it to us. While a website is using them, a red icon appears in the address bar, and you can stop it at any time (this reloads that page). You can revoke the app's camera and microphone permissions in Android Settings.
- **Websites that play protected content.** Protected content such as paid video first needs an identifier that this phone issues for that website only. When a website asks for it, Vigatamala asks you first, and again your answer applies only to that page; the identifier is handled between Android and the website and is never sent to us.
- **Websites that ask you to sign in (HTTP authentication).** When a site such as a device on an internal network asks for a username and password, Vigatamala shows which site is asking; the username and password you enter are used only for this visit, are not saved on the device, and are never sent to us.
- **Local network.** When you open an address on your local network (for example a router's settings page or a home storage device), starting with Android 17 you need to allow the "Nearby devices" permission, which Android asks for. Vigatamala asks only when you open such an address. Android's prompt uses fixed wording: "find, connect to, and determine the relative position of nearby devices"; Vigatamala uses this permission only to connect to the address you opened, does not scan your local network, does not determine the position of any device, and never sends us where you connected. Once you allow it, content in the web pages you open can also connect to your local network.
- **Uploading files.** When a web page asks you to choose a file, you pick it from Android's photo picker or file picker, or take a photo or video on the spot (the phone's camera app opens only when you tap). Only the files you choose are given to that page; Vigatamala does not keep them or send them to us. A file taken on the spot is captured by the camera app and given to that page as is (any additional data the camera app writes, such as the location where it was taken, depends on your camera settings); it is kept temporarily in the app's cache and deleted the next time you open the app.
- **Camera search.** The camera button in the address bar opens the camera (Android asks for camera permission the first time); you can also pick a photo from your library instead (through Android's photo picker: Vigatamala receives only the photo you pick, cannot see the rest of your library, and does not need photo library permission). QR codes and text on screen or in the photo are recognized only on this device (using Google ML Kit; images and recognition results are not sent out; for ML Kit's own usage statistics, see section 3, item (7)); when a code contains a web address, the site name is shown first and you decide whether to open it. Tapping a piece of text lets you search it, put it in the address bar, or translate it (conversion between Simplified and Traditional Chinese is done on the device; other languages go to the Android system's offline translation, whose language data the system downloads; Vigatamala does not keep the original text or the translation). Only when you tap "Search Photo with Google" (or the other search engine named on the button) is the photo you just took or picked scaled down and sent to that search engine (section 3, item (8)); the photo carries no location or other attached data, and Vigatamala does not keep it or send it to us. The search results page is recorded in browsing history like any other web page (not in private tabs).
- **Voice search.** The first time you tap the microphone in the address bar, Android asks for microphone permission. When you speak, recognition runs only on this device: Vigatamala uses only Android's on-device speech recognition, does not send your voice over the network, and does not keep the recording; the recognized text is used only to run that one search and is then handled the same way as a search you type yourself. On Android 13 and later, if the speech-recognition data for your language hasn't been downloaded yet, tapping the microphone first explains this; after you tap "Download", the Android system (Google's speech services) downloads it — neither the downloaded content nor the connection passes through Vigatamala, and neither includes your voice; after the download, recognition still happens only on this device. If this device can't recognize your language on the device (or on Android 11 and earlier), the microphone button does not appear. You can revoke the app's microphone permission in Android Settings.
- **Address bar suggestions are generated entirely on the device.** What you type is only matched against your local browsing history and bookmarks; it is never sent to a search engine for "search suggestions". (A private tab lists nothing at all until you start typing; see section 4.)
- **Ad and tracker blocking decisions happen entirely on the device.** We never send the URL you are opening to any server to ask "should this be blocked?". (Safe Browsing, built into Android's web component, is a separate matter — see section 3, item (4) — that is Google's feature; the query goes to Google, not to us.)

## 2. Data stored on your device

The browsing data in the table below stays only on your device. **The installation ID and subscription sync data are exceptions**; their purpose and what is sent are described in section 3.

**System backup: only settings are backed up.** When Vigatamala uses Android's backup service, it backs up a single settings file: your switches and preferences such as the search engine, **plus any exceptions you have set for individual sites (including those sites' host names)**.
If backup is on for your Google Account, this settings file is stored in Google's backup service; we cannot read the backup's contents.
Browsing history, tabs, bookmarks, the reading list, website data and the installation ID are not in the backup.

**Website data needs a fairly recent Android System WebView.** If WebView is too old to support separate data profiles: all normal tabs share one set of website data, and closing a tab does not erase it; private tabs can't be opened; and Crisis Prep's official maps don't clear their cookies either.

| Data | Contents | Retention | How to delete |
|---|---|---|---|
| Browsing history | Full URLs, titles, timestamps (not recorded in private tabs) | Newest 2,000 | Settings → "Data" → "Clear Browsing History"; or "Clear" or swipe left on the History page |
| Tabs | URL, title, custom name, pinned, muted, home tab, tab groups (not saved for private tabs, **except kept private tabs**; see section 4) | No limit | Close the tab; or "Close All Tabs" in the tab switcher's "⋯" menu (pinned tabs, and pinned or passcode-protected groups, are skipped) |
| Bookmarks | URL, title, folder, time added, **whether it was saved from a private tab** | No limit | Swipe left on the bookmark list to delete, or delete after tapping "Edit" |
| Reading list | URL, title, timestamp, whether it was saved from a private tab (**never the article text**) | No limit | Swipe left on the list to delete; "Clear Read Items" |
| Playback queue | Media URL, title, artist, artwork URL (only the URL is stored; the image is not downloaded), duration, media identifier, time added (**private tabs keep theirs in memory only**) | No limit | Delete in the queue panel; closing that tab discards the whole queue |
| Watch positions | Media identifier, playback position (not recorded in private tabs) | 90 days or 500 entries | Cleared along with "Clear Browsing History" and "Clear All Website Data (Including Cache)"; turning off "Resume Playback" also deletes them |
| Tab thumbnails | The page image on the tab card (**in memory only, never written to the device**; private tabs are never captured at all) | Gone when you close the app | — |
| Site-icon cache | Small icons the sites you opened declare for themselves, fetched **at visit time** from that site or from the icon address it declares (for example, the CDN it uses); no third-party icon service is queried, and nothing is fetched separately in the background; file names are a hash of the host (**private tabs never write to disk**) | At most 200 files | Cleared along with "Clear Browsing History" |
| Preferences | Each of the switches; **and any exceptions you have set for individual sites** (backed up; see above) | No limit | Removed automatically once every override for that site is set back to "follow global" |
| Website data | Cookies, caches, localStorage (managed by Android's web component, **a separate store per tab**; except when WebView is too old, see above). A sub-page (a page a site asks to open separately, or a link you tap, that slides up over the current screen) shares the store of the tab beneath it | Erased when the tab closes | Settings → "Data" → "Clear All Website Data (Including Cache)" or "Clear All Cache (Keep Login Data)"; "Clear Site Data" in the shield menu; long-press a tab → "Storage Usage" → "Clear Cache" (cache only) |
| Crisis Prep | Supply-list check marks and expiration dates, and items you added yourself; places you named and the official map views you saved; family meeting points and your contacts' names, phone numbers and notes (**offered only in Taiwan**; stored only on this phone, never uploaded or backed up). A PDF created when you share a shelter map is kept temporarily in the app's cache | No limit (up to 12 map views per place); the shared PDF is deleted the next time you open the app | Delete entries one by one in Crisis Prep; uninstalling the app deletes it all too |
| Rating, default-browser and local-network prompts | How many pages you have browsed (a single number that stops counting at 20, with no URLs), whether the app has asked for a rating, whether it has asked about the default browser, and whether it has asked for local-network permission | No limit | Uninstalling the app deletes them |
| Diagnostic log | **Off by default.** While off, only this session's most recent 100 events stay in memory, keeping not even the site host; only once it is on are they written to a file, where normal tabs keep the site host and private tabs' URLs are not recorded | In memory: at most 100 events, gone when you close the app. File: capped at roughly 600 KB; past that only the later half is kept | Settings → "Privacy" → turn off "Diagnostic Logging", which **deletes both**; **not backed up** |
| Rule-list cache | The downloaded blocking rules themselves, **containing none of your data**; plus the time of the last update check | Overwritten at the next update | No deletion entry point today (uninstalling the app removes it) |
| Installation ID | One randomly generated UUID, stored in the app's private settings (not encrypted, not backed up). Contains no name or email, but links purchases. You can see it in Settings → "About", and a tap copies it | Until you uninstall the app; **reinstalling creates a new one** | Uninstall the app (for the copy on our server, see "Deleting your data") |
| Subscription sync data | The connection credential issued by the server (session token, reused until it expires); Google Play purchase records not yet delivered to our server (purchase token, product ID, order number, time, and the account identifier used at purchase); the last subscription-status snapshot. None of it is backed up | The credential is replaced when it expires; pending records are deleted once delivered; the snapshot is overwritten at the next update | Uninstall the app |

**Three things to know:**

1. **Search terms stay in browsing history in the form of a URL** (`?q=what you typed`). Clearing browsing history removes them too.
2. **"Clear Browsing History" does not clear tabs, bookmarks or the reading list.** Each has its own way of being deleted (see the table above).
3. **Subscription transactions are held by Google Play and are also synced to our authorization server** (section 3, item (2)).

## 3. Outbound connections the app makes

Apart from the pages you browse yourself, the app makes only these kinds of connections:

**(1) Blocking rule downloads/updates → `privacy.link2us.link` (fallback: `easylist.to`)**
EasyList and EasyPrivacy are not bundled with the app; you download them yourself (the app asks once on first launch, and you can download them at any time in Settings → "Content Blocking"). **Downloading does not require a subscription.**
By default they come from our mirror as pre-converted, signed files (verified on device); only if the mirror is unavailable does the app fall back to fetching the raw lists from `easylist.to` and converting them on your device.
What the subscription buys is "Automatic Rule Updates" (off by default): once it is on, the app checks for updates automatically when it launches or returns to the foreground, but only if more than 8 hours have passed since the last check and the network is not metered.
**What the request carries:** only the filename to download and its signature file, plus the file-version tag the server gave at the last download (`If-None-Match`; it identifies that file, not you, and is identical for everyone holding the same list); the User-Agent is a fixed "Vigatamala". Redirects requested by the server are followed. No URL you visited, no account or device identifier, no cookies, and nothing written to the cache.
**What reaches us:** as with any web server, the connection itself carries your IP address, the time and the requested filename. That domain is static file hosting (Cloudflare); we run no code of our own on it and **we do not export or retain per-request logs anywhere**; what we can see is the provider's aggregate traffic statistics (request counts, cache hit rate and the like), which contain no individual users. Your IP address is still processed by the provider in the course of delivery and abuse prevention — unavoidable in any connection. When the app falls back to `easylist.to`, it is EasyList's infrastructure (a third party) that sees your IP, outside our hands.

**(2) Device accounts and subscription sync → `apple.link2us.link`**
When the app launches (after it has first asked Google Play which purchases there are), each time you return to the app's screen (including coming back from the camera, a file picker or Google Play), when a purchase completes, and when you tap "Restore Purchases", the app sends over HTTPS the installation ID, the app's package name (`com.sanlong.vigatamala`), the platform `android` and the app version number, to create or recover a device account; later requests carry the session token issued by the server.
When there is a Plus purchase, it also sends: the package name, product ID, Google Play purchase token, purchase time, order number, and the account identifier given to Google at purchase (the installation ID of the installation that made the purchase; after you reinstall or switch phones, it is sent together with the current installation ID). The backend verifies the purchase with Google and then queries the subscription status.
The User-Agent is a fixed "Vigatamala" (no phone model). **No browsing history, URLs, searches, bookmarks or viewed media are sent.** Connection services still process necessary connection information such as IP addresses.
Purchase records that can't be sent stay on the device and are retried (after 1 minute, 5 minutes, 30 minutes, 2 hours and 6 hours, then at most once a day; they are sent only when you open or return to the app).
This data is used for account association and subscription service. The server also records the time and type of each connection (launch, return to foreground, subscription sync) in the account's device-activity records, which are used for troubleshooting, abuse prevention and aggregate usage statistics (such as daily active devices, retention and app-version distribution); administrators can view these records for an individual account. They are not provided to third parties and are not used for advertising or cross-app tracking. Uninstalling the app or clearing browsing data does not delete the records on the server; to delete or access them, see "Deleting your data" above (the scope of deletion and retention, the periods, and server backups are all described there). Account and transaction data are retained as long as needed to provide the service and handle purchase disputes.

**(3) In-app purchases → Google Play**
Google Play handles purchasing, restoring and managing subscriptions; payment details (such as credit cards) are collected by Google, and neither the app nor we can obtain them. Each time the app launches or returns to the foreground, it asks Google Play on the phone for this Google Account's subscriptions and, when needed, acknowledges a purchase. At purchase, the app gives Google the installation ID as the account identifier, and Google stores it in that transaction. The Google Play billing component handles data under Google's privacy policy.

**(4) Safe Browsing → Google**
Android's web component has Google Safe Browsing built in: it checks the URLs you visit with Google for known fraudulent or malicious sites, and blocks the ones that match. **This is Google's feature; the query goes to Google, and we can neither see nor influence it.**
We choose to keep it on (turning it off would shorten this policy by one item but leave you with one less layer of protection; the iOS version keeps Apple's fraudulent website warning for the same trade-off).

**(5) Images inside reader view → the article's own source and its image hosts**
Reader view still loads the original article's images after reflowing, applying the same blocking rules as that tab.

**(6) Site icons → the site you are viewing**
To show site icons on tab cards and bookmarks, the app fetches the icon, within the page you have open, from that site or from the icon address it declares (for example, the CDN it uses) (at most 4 times per page); no third-party icon service is queried.

**(7) Camera search usage statistics → Google (ML Kit)**
Text and QR code recognition in camera search uses Google ML Kit: the models are bundled in the app and recognition happens on the device, so **images and recognition results are never sent out**. ML Kit does, however, send usage statistics to Google for diagnostics and usage analytics: device information (manufacturer, model, OS version, available ML hardware accelerators), the app's package name and version, a per-installation identifier (which, according to Google, is not used to identify users or physical devices), performance metrics (such as latency), API configuration (such as image format and resolution), input and output sizes, feature version, event types and error codes. According to Google, this data is sent over HTTPS and is not passed to third parties. These statistics may be sent later, on a schedule set by the system, after you have finished using camera search. **There is no way to turn these statistics off**; if you have never opened camera search, ML Kit does not start.

**(8) Photo search → the search engine named on the button**
Sent only when you tap "Search Photo with ○○"; what is sent is that one photo (scaled down, re-encoded, with no attached data). It is sent in the current tab, just as if you had uploaded the photo on that site yourself, and the search engine handles it under its own privacy policy; we receive nothing.

**(9) Crisis Prep → official maps and links you open**
Crisis Prep connects only when you open an official map (`adr.npa.gov.tw`, `bear.emic.gov.tw` and their map tile servers), which is the same as opening those two sites in the browser: it uses a separate web view that is not subject to content blocking, **leaves no browsing history or cookies**, and asks you first when a site requests your location (as in section 1). Saved views stay only on this phone. Links in the handbook, the official websites and the guides connect only when you open them (in a sub-page, like ordinary web pages); links to official apps are handed to Google Play. Siren sounds, lists and guides are all in the app and work offline; dialing only opens the phone's dialer, and it is you who taps to call.

**(10) Ratings → Google Play**
After the app has been installed for a full seven days and you have used it for a while, the app asks Google Play to ask you once whether you'd like to rate it — only once, ever. The window is shown by Google Play, which also decides whether to actually show it; the stars and review you give go directly to Google Play and are published on the store under Google's rules. We can't see whether you rated, and we receive nothing. The app sends no browsing data for this.

The app makes no other outbound connections.

**(Optional) Issue reports**: Settings → "About" → "Report a Problem" opens **your own** mail app (if there is no mail app, Android's share sheet, or you copy the content yourself), addressed to our support mailbox. The app transmits nothing by itself — the body and attachments are fully visible before sending, and it is you who taps send. Besides the description you write, the message is prefilled with four lines: app version, when this version was installed, OS version, and the device's brand and model (for example "Google Pixel 9") — no serial number, no identifier of any kind, and you can delete them before sending.

The message carries **diagnostic content** (you can turn this off on the form), which records feature events only (playback, blocking, fullscreen and the like). It takes one of two forms, depending on whether you have turned on Settings → Privacy → "Diagnostic Logging" (**off by default**):

**While off (the default)**: nothing is written to any file. Only **this session's** most recent 100 events stay in memory, so that a report can at least say what happened. This content keeps **not even the site host** — every URL and host becomes "‹網址›" and only the event names remain. It is never written to disk, never backed up, disappears when you close the app, and leaves your device only when you yourself tap to send a report.

**While on**: events are written to a log file on the device (capped at roughly 600 KB; past that only the later half is kept) and sent as an attachment or in the body. URLs are redacted **at the moment they are written**, not at send time:

- normal tabs: only `https://host` is kept; path and query string become "…";
- **private tabs: URLs are not written to the log** (not even the host);
- credentials embedded in a URL (in the form `https://user:password@…`) are stripped before redaction.

Turning the switch off deletes the whole log file and clears the in-memory copy too. When you send, the attachment is first copied to the app's temporary folder and handed to the mail app; it is deleted the next time you open the report screen, the next time the app launches, or when you turn the switch off. Tapping "Copy Report Details" puts the full content on the system clipboard; copying anything else replaces it.

Reports we receive are used solely for debugging, are not linked to any other data, are not provided to third parties, and are deleted within 90 days of resolution.

**Media notifications**: when video or music is playing and "Background Playback" (Plus) is on, Android's notification, the lock screen and a connected car display show the title of what is playing.
**Private tabs don't show the title** (only "Vigatamala"); the same applies when "Show Track on Lock Screen" is turned off in Settings → "Media". The app does not download artwork.

## 4. Private tabs

**What they do:**

- Nothing is written to browsing history or to the tab list, and they are not restored when you reopen the app — **except the ones you ask to keep**: pinned private tabs, and pinned or passcode-protected private groups (with every tab in them),
  are kept after you close the app, **sign-ins included**. The URLs, titles and groups (name, color, the passcode's hash and salt, and the number of wrong guesses) of those kept tabs are written to a file on the device that is not backed up;
  once you unpin them or remove the passcode, they are no longer kept, and that copy is deleted the next time you open the app. Only a hash of the passcode is stored; a forgotten passcode can't be recovered, and the only option is to close the whole group (no passcode needed).
- Each private tab's website data (cookies, caches, localStorage) is its own copy: it is stored on this device while in use and **emptied when you close the tab**; Android doesn't allow a folder that has been used to be deleted during the same run, so the folder itself is deleted the next time you open the app. If the system ends the app outright, it is likewise deleted the next time you open the app (except for kept private tabs). If Android System WebView is too old, private tabs can't be opened (see section 2).
- The group passcode stops "someone holding your unlocked phone from opening the group", not "someone who has the device's files": the URLs of the tabs in the group are still written in plain text in that file, protected by Android's own data encryption and screen lock.
- Titles are not sent to media notifications, the lock screen or car displays.
- The playback queue stays in memory only and is never written to the device.
- No tab thumbnails are captured, and site icons are not written to files.
- The address bar lists no suggestions until you start typing; once you type, it still matches against your local history and bookmarks (all computed on the device). To turn off that part too, Settings → "Privacy" has "No Local Suggestions in Private Tabs".
- Shield settings you adjust for private tabs apply only to this session and are forgotten once the last private tab is closed.
- **If you leave the app while private content is on screen, its card in "Recents" shows no screenshot** (Android 13 and later). Android 12 and earlier don't have this option, so that card shows the screen as it was when you left.

**Actions you take deliberately still leave traces:** adding a bookmark or saving to the reading list from a private tab writes that URL into the list (and remembers that it was saved from a private tab, so it opens in a private tab again).

## 5. What we change on web pages

- **Block** connections to ads and trackers according to the rules, and hide the empty slots left behind after blocking.
- **Intercept** pop-ups that sites open on their own, new-tab hijacking and back-button hijacking.
- **Fingerprint noise**: add subtle noise when sites read device characteristics such as the canvas, making it harder to recognize the same phone across sites.
- **Automatically decline** non-essential cookies in cookie consent windows, and **dismiss** "open in app" promotion walls.
- **Strip** common tracking parameters from URLs, and restore AMP pages to the original page; night mode gives web pages dark colors.
- **User-Agent**: ordinary web pages get the default string of Android's web component (which includes the Android version and phone model, the same as the built-in browsers of most Android apps); "Request Desktop Site" in the shield menu switches to desktop Chrome's string.
- **Global Privacy Control**: `navigator.globalPrivacyControl` on the page is true; loads we initiate ourselves (the address bar, bookmarks, links opened from outside the app) carry `Sec-GPC: 1`; this header can't be added to links clicked within a page or to subresources.
- **HTTPS upgrade**: if a site can't be reached after upgrading, the app asks whether you want to use HTTP instead; once you agree, that site is not upgraded again until you close the app.

All of this happens on your device, and no web content is sent to us. From the shield menu you can adjust these for an individual site: “Block Trackers”, “Remove Leftover Ad Slots”, “Block Malicious Pop-ups and Redirects”, “Auto-Dismiss Cookie Notices”, “Fingerprinting Protection”, “Don’t Open Links in Other Apps”, “Always Use HTTPS”, “Web Page Night Mode”, and “Request Desktop Site”. Global Privacy Control and the User-Agent have no per-site setting.

## 6. What we never do

- We do not sell, share or rent any of your data. We never receive browsing data at all; account and subscription data are used only to provide the subscription service and for the troubleshooting, abuse prevention and aggregate usage statistics described in section 3, item (2).
- We insert no advertising, affiliate links or sponsored content.
- We do not track you across apps or websites.
- We provide no way to download web content (media or files).

## 7. Children

On Google Play, this app's target audience is ages 18 and over; it is not directed at children, and it does not knowingly collect personal information from children.

## 8. Changes

If new data uses are introduced, we will update this policy and notify you in the app.

## 9. Contact

Questions to: **vigatamala@link2us.link**. To delete data on our servers, see "Deleting your data" above.

Developer: **Su Shih-neng**
