# Vigatamala Privacy Policy

[繁體中文](/ios.zh-Hant) · [简体中文](/ios.zh-Hans) · [English](/ios.en) · [日本語](/ios.ja) · [한국어](/ios.ko)

**Last updated: 5 October 2026**
**Applies to: Vigatamala for iOS**

---

## In short

**Vigatamala does not send your browsing data to us.**

Builds with CISIP integration use our account and subscription server, and the Weather and Driving Safety widgets use our weather and traffic data service (both in section 3). The app contains no analytics, telemetry, crash
reporting or advertising components, and no third-party packages of any kind.
Which sites you visit, what you watch and what you search for stay on the device you use.

The rest of this policy sets out three things: **what actually stays on your
device**, **where the app connects on its own**, and **how you delete it**.
Including a few places where we have not done well enough yet.

---

## 1. What we cannot receive

- **We do not receive browsing data.** The app downloads rule lists from our domain; in CISIP-enabled builds it registers the installation and synchronizes subscriptions; and in the Weather and Driving Safety widgets it reads weather and traffic data. Rule requests carry no account identifier. Account requests contain only the identity and transaction data described below. The only identifying data in weather and traffic requests is an App Attest key ID and signature used for verification (section 3, item 8). None of these requests contain browsing data. Privacy-policy and licence links remain ordinary pages opened when tapped.
- **No third-party SDKs** — no Google Analytics, Firebase, Crashlytics, Sentry
  or ad networks.
- **No advertising identifier (IDFA)** and no tracking permission prompt.
- **Website location requests (in builds that support this feature).** When a website requests your location, iOS and WebKit handle permission prompts. You decide whether to allow access. Only while-in-use location permission is requested, never always-on location access. An approved website can receive your location and handles it under its own privacy policy. Vigatamala does not collect, store, or send your coordinates to us. You can revoke app location access in iOS Settings. Older builds do not request location access.
- **Address bar suggestions are computed entirely on device** by matching what
  you type against your local history and bookmarks. Most browsers send your
  keystrokes to a search engine for suggestions. We do not. (A private tab shows
  **nothing at all** until you start typing — see section 4.)
- **Ad and tracker blocking decisions happen on device.** We never send the URL
  you are opening to a server of ours. (iOS's built-in fraudulent website
  warning is separate — see item (6) in section 3 — that is a system-level
  feature; the query goes to Apple, not to us.)

---

## 2. Data stored on your device

The browsing data in the table stays on your device. **The install identifier, subscription sync data and the device key for the weather and traffic data service are exceptions**, described in section 3.

To be straightforward about one thing: if you use iCloud Backup or back up your
iPhone or iPad to a computer, **most** of these files are copied as part of that **system
backup**. That is Apple's mechanism; we cannot read its contents, and have no way
to. We deliberately do not exclude bookmarks, history and tabs from backup —
doing so would lose them when you move to a new device.

**Four exceptions we do exclude** from backup: the **rule-list cache** (derived
data you can always re-download, with no reason to take up your iCloud storage),
the **site-icon cache** (its file names are derived from hosts you visited, so it
has no business leaving this device), **tab thumbnails** (those are the page
images themselves — even less reason to leave this device than a list of hosts)
and the **diagnostic log** (it contains hosts you visited — same reason).

| Data | Contents | Retention | How to delete |
|---|---|---|---|
| Browsing history | Full URLs, titles, timestamps | Newest 2,000 | Settings → "Data" → "Clear browsing history"; or "Clear" at the top right of the history page |
| Tabs | URL, title, custom name, pinned state, group membership (group name and color) | No limit | Close the tab, or "Close all tabs" in the tab switcher menu (pinned tabs are skipped) |
| Bookmarks | URL, title, time added, **whether it was saved from a private tab** | No limit | "Bookmarks" under Shortcuts on the home page → swipe left to delete on the list; or "Reorder" at the top right, then delete in edit mode |
| Reading list | URL, title, timestamp (**never the article text**) | No limit | Swipe left to delete on the list page; "Clear read" at the top right |
| Playback queue | Media URL, title, artist, artwork URL (**private tabs keep theirs in memory only**) | No limit | Swipe left to delete in the queue panel; closing that tab discards the whole queue |
| Watch positions | Media identifier, playback position | 90 days or 500 entries | Cleared along with "Clear browsing history" |
| Tab thumbnails | Screenshots of the page shown on the tab card (**private tabs are never captured at all, not even in memory**) | At most 60 files, oldest deleted first | Deleted when you close that tab; cleared along with "Clear browsing history"; **excluded from backup** |
| Site-icon cache | Small icons the sites you opened declare for themselves, fetched from that site **at visit time** (never from a third party, never in the background); file names are a hash of the host (**private tabs never write to disk**) | At most 200 files | Cleared along with "Clear browsing history"; **excluded from backup** |
| Preferences | Each of the switches; **and any exceptions you have set for an individual site** | No limit | Removed automatically once every override for that site is set back to "follow global" |
| Website data | Cookies, caches, localStorage (managed by WebKit, **a separate store per tab**) | Erased when the tab closes | Settings → "Data" → "Clear all website data"; or clear an individual site from the shield menu |
| Per-tab interaction state | Each tab's back/forward list (which contains URLs) and scroll position (**never written to a file for private tabs**) | Lives as long as the tab | Closing that tab deletes it; "Clear browsing history" also clears this copy from disk |
| Rule-update bookkeeping | Time of the last update, number of rules, and whether the unsigned fallback was used | No limit | No deletion entry point today (deleting the app removes it) |
| Rule-list cache | The downloaded blocking rules themselves (~14 MB; WebKit keeps a separate compiled output of roughly 53 MB), **containing none of your data** | Overwritten at the next update | No deletion entry point today (deleting the app removes it); **excluded from backup** |
| Diagnostic log | **Off by default.** While off, only this session's most recent 100 events stay in memory, keeping not even the site host; once on, they are written to a file where ordinary tabs keep the site host and private tabs not even the host | In memory: 100 events, gone when you close the app. File: capped at roughly 600 KB; past that only the later half is kept | Settings → "Privacy" → turn off "Diagnostic log", which **deletes both**; **excluded from backup** |
| Install identifier | One randomly generated UUID, stored in the Keychain rather than in a file. Contains no name or email, but links purchases | No limit | See point 4 below — **deleting the app does not guarantee its removal** |
| Device key for the weather and traffic data service (in builds that support this feature) | The key ID and registration progress of an Apple App Attest key, stored in the Keychain on this device only. Contains no name or email, and is not linked to the install identifier | No limit; the server-side record is deleted 90 days after last use | No delete option; **deleting the app does not guarantee its removal**. After reinstalling, the key stops working and the app creates a new one |

**Four things to know:**

1. **Search terms persist in history in the form of a URL.** Typing a search into
   the address bar produces a search URL containing `?q=what you typed`, and that
   URL is recorded in your browsing history. Clearing history removes it too.
2. **"Clear browsing history" does not clear tabs, bookmarks or the reading
   list.** Those three each have their own removal action (see the table above).
3. **Apple holds subscription transactions, and CISIP also receives subscription records.** The app keeps signed transactions awaiting delivery for retry, removes them after success, and excludes this queue from backup. The backend stores device/account associations, subscriptions and transactions for purchase verification, restoration and refunds.
4. **The install UUID and session token are stored in Keychain.** The app does not deliberately replace the UUID on launch, browser-data clearing or reinstall. Apple does not guarantee Keychain survival after deletion; erasing a device can remove it. Encrypted backups may carry the same UUID to another device. The UUID contains no name or email but links an installation account and purchases; it is not unlinkable anonymous data.


---

## 3. Outbound connections the app makes

Apart from the pages you browse yourself, the app makes only these kinds of
connections:

**(1) Blocking rule downloads/updates → `privacy.link2us.link` (fallback: `easylist.to`)**
The large public EasyList/EasyPrivacy lists are **not bundled with the app**; you
download them yourself. By default they come from our mirror at
`https://privacy.link2us.link/rules/` as pre-converted, signed files (verified on
device); only if the mirror is unavailable does the app fall back to fetching the
raw lists from `easylist.to` and converting them locally.

**When:** the app asks once on first launch (you may decline), and Settings →
Content Blocking has a download button at any time. **Neither requires a
subscription.** What the subscription buys is *automatic* updating (off by
default), which checks at most once per 24 hours.

**What the request carries:** only the filename. No URL you visited, no account
or device identifier, and an isolated network configuration with no cookies and
no cache. The one extra header is `If-None-Match`, a file-version tag from the
previous download — it identifies the file, not you, and is identical for
everyone holding that version.

**What reaches us:** as with any web server, the connection
carries your IP address, user-agent string, time and the requested filename.
That domain is static file hosting (Cloudflare); we run no code of our own on
it and **we do not export or retain per-request logs anywhere**. What we can see
is the provider's aggregate traffic statistics (request counts, cache hit rate),
which contain no individual users. Your IP is still processed by the provider in
the course of delivery and abuse prevention — unavoidable in any connection.
When the upstream fallback is used, it is EasyList's infrastructure (a third
party) that sees your IP, outside our hands.

**(2) Lock screen artwork → the image host the page specifies**
When media plays, the lock screen has artwork to show. That image's URL comes
from the page's own metadata, usually a third-party image host or CDN.
**This is the only third-party connection that can happen while you are not
actively looking at a page** — it fires with the app in the background and the
screen locked. We hold it to a minimum: it uses an isolated network configuration
with no cookies or cache, and **private tabs fetch no artwork and publish nothing
to the lock screen**.
To disable entirely: Settings → Media → Show Track on Lock Screen (called
“Lock screen controls” in version 1.1 and earlier).
When off, the lock screen, Control Center and car displays show none of the track
info or artwork we publish; playback and its controls are unaffected.

**(3) Feed (RSS/Atom) fetching → the feed URL you tapped**
This happens when you tap the feed icon in the address bar. The feed page is a
**real tab**, so it is fetched again when you reload it or when that tab is
restored at next launch. It uses an isolated network configuration, no cookies,
no cache, and the content is parsed in memory only, never landing on disk.
**Opened from a private tab, the tab it opens is private too** — that address has
the site you are reading embedded in it, so opening it as a normal tab would write
it into your browsing history.

**(4) Images inside reader view → the article's own source and its image hosts**
Reader view still loads the original article's images after reflowing. It applies
the same blocking rules as that tab and uses that tab's own store (so a private
tab's reader view likewise leaves nothing on disk).

**(5) In-app purchases → Apple (StoreKit)**
Apple StoreKit handles purchasing and restoration. In-app purchases carry the same install UUID used for CISIP registration as appAccountToken; Apple stores it with the transaction. The app also reads subscription information on launch, foregrounding and transaction updates, and synchronizes it as described below.


**(6) Fraudulent website warning → Apple**
iOS's built-in web engine checks the URLs you visit against Apple's list of known
fraudulent or malicious sites, and blocks the ones that match. **This is a
system-level feature; the query goes to Apple and we can neither see nor
influence it.** We keep it on — turning it off would shorten this policy by one
item but leave you less protected.

**(Optional) Issue reports.** Settings → About → "Report a problem" opens
**your own** mail composer (or the share sheet) addressed to our support
mailbox. The app transmits nothing by itself — the body and attachment are
fully visible before sending, and it is you who taps send. Besides what you
write, the message is prefilled with four lines: app version, build time, operating system
version and device model (e.g. "iPhone" or "iPad") — no serial number, no identifier of
any kind, and you can delete them before sending.

The message carries **diagnostic content**, which records feature events only
(playback, blocking, fullscreen and the like). It takes one of two forms,
depending on whether you have turned on Settings → Privacy → Diagnostic Logging
(**off by default**):

**While off (the default):** nothing is written to any file. Only **this
session's** most recent 100 events stay in memory, so that a report can at least
say what happened. That content keeps **not even the site's host** — every
address becomes "‹網址›" and only the event names remain. It is never written to
disk, never enters a backup, disappears when you close the app, and leaves your
device only when you yourself send a report.

**While on:** events are written to a log file on your device (capped at roughly
600 KB; past that only the newer half is kept) and sent as an attachment or
inline. URLs are redacted **as they are written to disk**, not at send time:

- ordinary tabs: only `https://host` survives; path and query become "…";
- **private tabs: not even the host** — the whole URL becomes "‹私密›";
- credentials embedded in a URL (`https://user:password@…`) are stripped before
  either of the above runs.

Turning the switch off deletes the log file, and clears the in-memory copy too.

⚠️ Tapping "Share with us" or "Open in Gmail" also copies the full content to
the **system clipboard**, so that you can paste it into your message (with
Gmail, iOS does not let the app attach a file directly). Other apps on iOS can
read the clipboard; copying anything else replaces it.

Reports we receive are used solely for debugging, are not linked to any other
data, are not shared, and are deleted within 90 days of resolution.

**(7) Device accounts and subscription sync → `apple.link2us.link` (CISIP-enabled builds)**
On launch or foregrounding, the app sends the install UUID, app bundle ID, platform ios and the app version number over HTTPS to create or recover a device account. Subsequent requests use the session token saved in Keychain. For Plus transactions it sends transaction and original transaction IDs, product ID, production/sandbox environment, any existing appAccountToken, and the Apple-signed transaction. The backend verifies with Apple and, where needed, adds a token to an externally redeemed transaction and queries subscription status again. **No browsing history, URLs, searches, bookmarks, viewed media or location are sent.** Connection services still process necessary connection information such as IP addresses. This data is used for account association and subscription service, not advertising tracking. Deleting the app or browser data does not delete backend records; contact the address in section 9 for account-data access or deletion. **Deletion removes device links, and entitlement and subscription state. Two things do not go with it: the device record itself (including the install identifier), which does not disappear when the account is deleted and is removed automatically only after 90 days without activity, except where abuse prevention requires keeping it; and transaction records and the original Apple-signed notifications themselves, which are kept with your association stripped** — they are the evidence used to handle refunds and purchase disputes. Account and transaction records are retained as needed to provide service and handle purchase disputes; device-activity records are kept for 180 days by default. Older builds without CISIP do not make these requests.

**(8) Weather and traffic data → `data.link2us.link` (Weather and Driving Safety widgets; in builds that support this feature)**
This is our own service, relayed through Cloudflare. It serves only government open data that it has already collected and prepared: Central Weather Administration forecasts, warnings and advisories, speed cameras, freeway routes and speed limits, and live traffic incidents. Your request never makes it fetch anything extra from a government site. The app connects only in these three cases:

- **When you view the weather for a place in Taiwan**: it reads the single, Taiwan-wide set of Central Weather Administration warnings and advisories, whichever Taiwan weather source you chose. The request contains no location, county, city or township; your phone works out which county or city applies.
- **When "Taiwan weather source" is set to Central Weather Administration**: it also reads the township forecasts for your county or city. It sends the dataset code of that **county or city** (in a header, not in the URL); coordinates and township are not sent.
- **When you use the Driving Safety widget**: it downloads speed cameras, freeway routes and speed limits, and live traffic incidents — datasets that are the same for everyone in Taiwan. Camera and freeway data are checked for new versions about once a day; while driving alerts are on, traffic incidents are read about every one to two minutes. The requests contain no location; all matching happens on your phone.

**Every request carries** this installation's Apple App Attest key ID and signature (plus Apple's attestation the first time), used to confirm that the request comes from the genuine app, along with the app's bundle ID, the dataset name and the version tag of the last download. **No account, no installation identifier from item (7) and no other device identifier is attached**, and this key is not linked to the account in item (7). The connections carry no cookies and write no disk cache. The key is kept in this device's Keychain; after you reinstall the app it stops working and the app creates a new one.

**What we keep**:
- **Key records**: one per key — the app's bundle ID, developer team ID, App Attest public key, signature counter and registration time.
  - The key ID is a hash of that public key, so it amounts to **a fixed code for each installation**.
  - The record contains **no county or city, no IP address and no time of individual reads**. It is deleted automatically 90 days after the last successful read; each read extends that.
  - Our server's daily backups include these records: kept on the server for 14 days, with an encrypted off-site copy.
- **One-time verification records**: they expire within 2 minutes and are deleted once used. They contain only the key, the purpose and whether it is weather or traffic — no county or city.
- **The county or city code**: compared in memory only, to return that one forecast, and **never written to any storage, log or backup**.
- **Abuse-prevention counters**: grouped by a hash of the IP address, and gone after 60 seconds. The hashing key is generated randomly each time the service starts and is never saved.
- **Service logs**: they do not record individual requests.

**Where we have not done well enough yet**:
- The connection passes through Cloudflare (our network provider). While relaying, it can see the whole request (including the county or city code) and your IP address, and it keeps sampled records of IP address, URL and time for up to 30 days (the URL does not include the county or city).
- Forecasts for different counties and cities differ in size (about 62 KB to 1.8 MB), so anyone who can see traffic statistics, Cloudflare included, could in theory infer the county or city from the size.
- The account service in item (7) runs through the same Cloudflare account, so anyone with that access could match requests from both by IP address and time. We do not do such matching.

**If it cannot be reached**: if this service is unreachable, or this device cannot be verified for a while, the app does not fall back to unverified requests. Weather does not switch sources by itself; the screen explains the situation and suggests switching to Apple Weather. The Driving Safety widget downloads directly from government sites instead (item 9).

**(9) Driving Safety widget → government open-data sites (when item (8) is unavailable; in builds that support this feature)**
The app downloads the National Police Agency's speed-camera list, New Taipei City's average-speed-section list and the Police Broadcasting Service's live traffic incidents directly (`data.gov.tw`, `opdadm.moi.gov.tw`, `data.ntpc.gov.tw`, `rtr.pbs.gov.tw`).
- Camera and section lists: downloaded directly only when the app has no data from item (8).
- Traffic incidents: downloaded from the Police Broadcasting Service whenever item (8) cannot be reached, about every two minutes while driving alerts are on.

The requests contain no location and no identifier, and they do not pass through our servers. Those sites can still see your IP address and the connection times, and the traffic-incident requests in effect show them when you are using driving alerts. The connections carry no cookies and write no cache.

The app makes no other outbound connections.

---

## 4. Private tabs

**What they do:**

- Nothing is written to browsing history or to the saved tab list, and they are
  not restored when you reopen the app.
- Website data (cookies, caches) is kept in memory only and is gone the moment
  you close the tab.
- Reader view uses the same in-memory-only store.
- No title or artwork is published to the lock screen, Control Center or a car
  display.
- The playback queue stays in memory only and is never written to disk.
- **The address bar suggests nothing until you start typing.** In a normal tab,
  focusing the address bar lists the places you visit most (from your local
  history and bookmarks); in a private tab it does not — that would hand your
  frequently-visited list to whoever is holding the phone. Once you type, it
  still matches (entirely on device). To turn off that half too, see
  Settings → Privacy → "No local suggestions in private tabs".
- **While any private tab is open, the multitasking preview is covered.** iOS
  takes a full-screen snapshot of its own when an app goes to the background;
  we cover the screen before it does.

**Actions you take deliberately still leave traces:** adding a bookmark or saving
to the reading list from a private tab writes that URL into the corresponding
list. This is intentional — we will not quietly discard something you explicitly
asked us to keep. But it is worth knowing.

**We do, however, remember that it came from a private tab, and reopen it in a
private tab.** Otherwise one tap on a bookmark would put that URL into your
browsing history and its cookies into the normal store — without you having made
any further choice. (Since 2026-09-07; bookmarks saved before that carry no such
information and are treated as coming from a normal tab.)

---

## 5. What we change on web pages

Vigatamala is a content-blocking browser. To achieve that blocking, we:

- block network requests and hide page elements according to the rules;
- intercept a page's own data requests to remove ad slots (which means we read
  and modify part of what the site sends);
- block popups and back-button hijacking;
- report noise-adjusted fingerprinting values to sites (lowering the chance of
  your being recognised across sites);
- send the Global Privacy Control signal;
- dismiss cookie consent banners — **always declining, never accepting**. Some
  sites' consent platforms report that "decline" decision back to their own
  servers; that is the platform's behaviour, not a request we initiate;
- dismiss "open in app" promotion walls — pressing the site's own "not now"
  option for you when one exists, and merely hiding the overlay when none is
  found. **We never press the promotion button**, and overlays containing a
  password field (login walls) are left alone. Likewise, if the option pressed
  on your behalf makes the site record that "this person chose no", that is the
  site's behaviour;
- rewrite URLs before the request is sent: stripping tracking-only parameters,
  unwrapping Google AMP shells back to the original page (this one does change
  host; where it lands is the page that link pointed at in the first place), and
  upgrading http to https (a failed upgrade asks rather than silently
  downgrading);
- send a Safari-matching User-Agent string (so that sites do not serve you a
  degraded page because they cannot recognise this browser);
- if you enable night mode, invert colours on light pages.

**Except for the User-Agent, every one of these can be turned off globally**, and
most can additionally be turned off per site from the shield menu (blocking,
tracker blocking, cosmetic cleanup, anti-hijacking, fingerprint protection,
HTTPS-only, cookie banners, night mode, desktop mode). Two exceptions, stated
plainly:

- **The User-Agent has no off switch.** The app always identifies itself as
  Safari (the shield menu's "desktop site" only swaps in the macOS Safari
  version; it does not disable it). This is deliberate: an unrecognised browser
  string gets you refused or served a degraded page by some sites; and **the
  Safari-matching string** actually carries *less* identifying information than
  **WKWebView's default string** — it makes you look like every other Safari user
  rather than like the user of a niche browser.
- **Global Privacy Control is global only** — it is a consistent legal signal, so
  a per-site version would be meaningless. One technical limit, stated plainly:
  the `Sec-GPC` header can only be attached to main-frame requests the app itself
  issues, because iOS's web engine offers no way to add headers to a page's own
  subresource requests; `navigator.globalPrivacyControl` applies to the whole page.

---

## 6. What we never do

- We do not sell, share or rent any of your data. **We never receive your browsing data**;
  the account and subscription data and the weather and traffic service's key records described in
  section 3 are used only to provide those services and are not passed to third parties.
- We insert no advertising, affiliate links or sponsored content.
- We do not track you across apps or websites.
- We provide no content download or offline storage.

---

## 7. Children

This app is not directed at children under 13 and does not knowingly collect
personal information from children.

Its App Store age rating is **16+**. That follows from being a general-purpose
browser: it can open any web page ("Unrestricted Web Access" in Apple's
questionnaire), for which the minimum rating is 16+. Every mainstream browser
carries the same rating.

---

## 8. Changes

This update adds device accounts and subscription synchronization. Cross-device browsing-data sync and student verification are not yet available in the app. We will update this policy and notify you in the app when new data uses are introduced.


---

## 9. Contact

Questions to: **vigatamala@link2us.link**

Developer: **Su Shih-neng**
