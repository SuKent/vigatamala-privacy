# Vigatamala Privacy Policy

[繁體中文](/ios.zh-Hant) · [简体中文](/ios.zh-Hans) · [English](/ios.en) · [日本語](/ios.ja) · [한국어](/ios.ko)

**Last updated: 16 September 2026**
**Applies to: Vigatamala for iOS**

---

## In short

**Vigatamala does not send your browsing data to us.**

Builds with CISIP integration use our account and subscription server (section 3). The app contains no analytics, telemetry, crash
reporting or advertising components, and no third-party packages of any kind.
Which sites you visit, what you watch and what you search for stay on your iPhone.

The rest of this policy sets out three things: **what actually stays on your
phone**, **where the app connects on its own**, and **how you delete it**.
Including a few places where we have not done well enough yet.

---

## 1. What we cannot receive

- **We do not receive browsing data.** The app downloads rule lists from our domain and, in CISIP-enabled builds, registers the installation and synchronizes subscriptions. Rule requests carry no account identifier. Account requests contain only the identity and transaction data described below. Privacy-policy and licence links remain ordinary pages opened when tapped.
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

The browsing data in the table stays on your device. **The install identifier and subscription sync data are exceptions**, described in section 3.

To be straightforward about one thing: if you use iCloud Backup or back up your
iPhone to a computer, **most** of these files are copied as part of that **system
backup**. That is Apple's mechanism; we cannot read its contents, and have no way
to. We deliberately do not exclude bookmarks, history and tabs from backup —
doing so would lose them when you move to a new phone.

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
| Diagnostic log | **Off by default.** Once on, it records feature events; ordinary tabs keep only the site host, private tabs not even the host | Capped at roughly 600 KB; past that only the later half is kept | Settings → "Privacy" → turn off "Diagnostic log", which **deletes the whole log**; **excluded from backup** |
| Install identifier | One randomly generated UUID, stored in the Keychain rather than in a file. Contains no name or email, but links purchases | No limit | See point 4 below — **deleting the app does not guarantee its removal** |

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

The app makes no other outbound connections.

**(7) Device accounts and subscription sync → `apple.link2us.link` (CISIP-enabled builds)**
On launch or foregrounding, the app sends the install UUID, app bundle ID and platform ios over HTTPS to create or recover a device account. Subsequent requests use the session token saved in Keychain. For Plus transactions it sends transaction and original transaction IDs, product ID, production/sandbox environment, any existing appAccountToken, and the Apple-signed transaction. The backend verifies with Apple and, where needed, adds a token to an externally redeemed transaction and queries subscription status again. **No browsing history, URLs, searches, bookmarks, viewed media or location are sent.** Connection services still process necessary connection information such as IP addresses. This data is used for account association and subscription service, not advertising tracking. Deleting the app or browser data does not delete backend records; contact the address in section 9 for account-data access or deletion. Account and transaction records are retained as needed to provide service and handle purchase disputes. Older builds without CISIP do not make these requests.


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

- We do not sell, share or rent any of your data — we do not have it in the
  first place.
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
