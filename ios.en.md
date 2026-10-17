# Vigatamala Privacy Policy

[繁體中文](/ios.zh-Hant) · [简体中文](/ios.zh-Hans) · [English](/ios.en) · [日本語](/ios.ja) · [한국어](/ios.ko)

**Last updated: 18 October 2026**
**Applies to: Vigatamala for iOS**

---

## In short

**Vigatamala does not send your browsing data to us.**

Builds with CISIP integration use our account and subscription server (which records the time and type of each connection for troubleshooting, abuse prevention and usage statistics), and the Weather and Drive Safe widgets use our weather and traffic data service (both in section 3). The app contains no analytics, telemetry, crash
reporting or advertising components, and no third-party packages of any kind.
Which sites you visit, what you watch and what you search for stay on the device you use.

The rest of this policy sets out three things: **what actually stays on your
device**, **where the app connects on its own**, and **how you delete it**.
Including a few places where we have not done well enough yet.

---

## 1. What we cannot receive

- **We do not receive browsing data.** The app downloads rule lists from our domain; in CISIP-enabled builds it registers the installation and synchronizes subscriptions; and in the Weather and Drive Safe widgets it reads weather and traffic data. Rule requests carry no account identifier. Account requests contain only the identity and transaction data described below. The only identifying data in weather and traffic requests is an App Attest key ID and signature used for verification (section 3, item 8). None of these requests contain browsing data. Privacy-policy and licence links remain ordinary pages opened when tapped.
- **No third-party SDKs** — no Google Analytics, Firebase, Crashlytics, Sentry
  or ad networks.
- **No advertising identifier (IDFA)** and no tracking permission prompt.
- **Website location requests (in builds that support this feature).** When a website requests your location, iOS and WebKit handle permission prompts. You decide whether to allow access. Only while-in-use location permission is requested, never always-on location access. An approved website can receive your location and handles it under its own privacy policy. Vigatamala does not collect, store, or send your coordinates to us. You can revoke app location access in iOS Settings. Older builds do not request location access.
- **Voice search (in builds that support this feature).** When you tap the microphone in the address bar and speak, recognition runs only on this device: Vigatamala uses iOS on-device speech recognition only, does not send your voice over the network, and does not keep the recording. The recognized text is used only to run that one search and is then handled the same way as a search you type yourself. If your language cannot be recognized on the device, the microphone button does not appear. The iOS permission prompt for speech recognition includes a general Apple notice that speech data is sent to Apple; that notice applies to network-based recognition, which this app does not use. Older builds do not request microphone or speech-recognition access.
- **Camera search (in builds that support this feature).** The camera button in the address bar opens the camera. QR codes and on-screen text are recognized only on this device; when a code contains a web address, the site name is shown first and you decide whether to open it. Tapping a piece of text lets you search it, put it in the address bar, or translate it (translation is handled by the translation built into iOS; Vigatamala does not keep the text or the translation). Only when you tap "Search Photo with Google" (or the search engine named on the button) is the photo you just took scaled down and sent to that search engine, which handles it under its own privacy policy. The photo carries no location or other attached data, and Vigatamala does not keep it or send it to us.
- **Website camera and microphone (in builds that support this feature).** When a website asks to use the camera or microphone (for example, for a video call), iOS and WebKit ask you site by site, and you decide whether to allow it. An approved website receives the video or audio and handles it under its own privacy policy; Vigatamala does not store it or send it to us. While a website is using them, an indicator appears in the address bar and you can stop it at any time. You can revoke the app's camera and microphone access in iOS Settings. Older builds do not request camera or microphone access.
- **Receipt lottery (in builds that support this feature; offered when your region is Taiwan).** The "Lottery" widget on the start page can scan the barcode or number on a Taiwan receipt with the camera, or check a receipt by its last 3 digits. Recognition happens only on this device. Receipts you scan or type are **never saved** and never sent to us — they are gone when you close the screen.
- **Current location in Weather (in builds that support this feature).** **Weather in the app**: only after you tap "Use My Location" in the Weather widget does the app read your location while you are viewing the weather (once when it opens; again when you pull to refresh or come back after more than 10 minutes; never in the background), rounded to two decimal places (about 1 km). That coordinate is sent to Apple to look up the place name and weather (section 3, item (10)); in Taiwan, the app also asks Apple for your county and township to pick out local warnings and work/school closures on the phone. Only if "Taiwan data source" is set to the Central Weather Administration is the **county or city** code sent to our weather service (section 3, item (8)); neither the coordinate nor the township is sent. The location and county read here stay in memory and are not stored on the device; turning off "My Location" in your weather locations stops reading. **The Home Screen weather widget** is separate (it can also be placed on the Lock Screen, and everything this policy says about the Home Screen weather widget applies there too; because the Lock Screen can be seen without unlocking, My Location shows only "My Location", never a place name): new weather widgets show "My Location" by default (you can switch to a city in Edit Widget); only while a widget shows My Location and you let iOS extend location access to widgets ("While Using the App or Widgets") does the widget read your location when iOS updates it (iOS allows this only shortly after you have looked at the widget); the app also reads it once for the widget when you tap that widget to open the app. That location is likewise rounded to about 1 km and kept, with the time it was read, in space shared by the app and its widgets on this device (not backed up; section 2), so the app can look up the weather for it when you open the app and during background updates scheduled by iOS: the coordinate goes only to Apple Weather (no place-name lookup; the county is worked out on the phone from Taiwan's official county boundaries), and in Taiwan with the Central Weather Administration only the county or city code goes to our weather service. A location more than 6 hours old is no longer used. To stop: choose a city in Edit Widget, remove the widget, or turn off location access for Vigatamala's widgets in iOS Settings; the stored coordinate is deleted the next time the app opens or updates in the background.
- **Drive Safe widget location (in builds that support this feature).** After you tap "Start Driving Alerts", the app continuously reads your precise location and speed (it asks only for while-in-use location permission, never always-on access) and compares them, on this device only, with speed cameras, average-speed sections, freeway routes and traffic incidents. With "Run in Background" on, it continues while the screen is locked or you are in another app, and iOS shows its location-in-use indicator. Tapping "Stop Driving Alerts" ends it. Driving coordinates and routes are **neither stored nor sent to us or anyone else**; the matching uses public data downloaded in full (section 3, items 8 and 9).
- **Drive Safe widget barometer (in builds that support this feature).** While driving alerts are on, the app reads changes in air pressure from your phone's barometer (this needs Motion & Fitness permission; iOS asks if you haven't allowed it yet) to tell, on this device only, whether you are on an elevated road or the road below it, so the right speed limit is shown. Readings stay in memory and stop when you tap "Stop Driving Alerts"; they are **neither stored nor sent to us or anyone else**. If you don't allow this permission, GPS altitude is used instead, which is less accurate near elevated roads.
- **Megaphone microphone and recording (in builds that support this feature).** The Megaphone in Cheer Kit can amplify your voice live through the microphone, play back a short recording, or read out text you type (using the text-to-speech built into iOS; you can first translate it with the translation built into iOS). Sound is processed on this device only and played through the speaker; it is never sent to us or anyone else, and live amplification records nothing. Only when you tap record does the app keep one recording on this device (excluded from backups); the next recording replaces it, and you can remove it with "Delete recording".
- **Cheer Kit multi-phone marquee (in builds that support this feature).** When several phones show one marquee together or glow together as light sticks, the phone that starts the link (the host) sends the board text and display settings to the phones that join with the room number; each joining phone sends its screen size (width, height and scale), the time it was tapped while arranging, and timestamps for clock sync. This data travels only directly between nearby phones (Section 3, item (16)) — **it does not go through our servers and is never sent to us**. Joining phones keep the received text in memory only; it is not saved and is gone when the link ends. The first time, iOS asks whether the app may find devices on your local network; declining does not affect other features, and you can change it later in iOS Settings.
- **Currency (in builds that support this feature).** The "Currency" widget on the start page converts amounts on this device. The amounts and calculations you type stay **in memory only** — they are not saved and are never sent to us or anyone else, and they are gone when the app quits. Exchange rates are public data downloaded when you open the widget (section 3, item (14)).
- **Radio (in builds that support this feature).** The "Radio" widget on the start page finds internet radio stations and podcasts and plays them online. The text you search for and the country (by default, that of your App Store account) are sent to a station directory or Apple's podcast directory, and audio streams directly from the station's or the podcast publisher's servers (section 3, item (15)); **none of these connections go through us**, and we do not know what you listen to. Favorite stations, subscribed podcasts, recently played stations and podcast playback positions stay on this device (section 2). The start-page tile shows only its icon and name, plus a speaker badge while it plays (it only says that something is playing), never the station or podcast you are listening to.
- **PTT (in builds that support this feature).** The "PTT" widget on the start page reads PTT directly from PTT's official website and bulletin board system (section 3, item (17)); **nothing passes through our servers**, and we can't see what you read or write on PTT. Signing in uses your own PTT account: your username and password are stored only in this device's Keychain (not synced or carried to other devices), are sent only to PTT when you sign in, and are deleted when you tap "Sign out and forget credentials". Comments, posts, replies, PTT mail, your favorites and "Report" (a PTT mail sent from your account to the board's moderator, shown to you in full before it is sent) all go directly to PTT, and changes you make in PTT Settings (nickname, profile card, signatures, password and two-step verification) are made directly on PTT (after a password change, the password saved on this device is updated too). Results of "Author Info" and "Post Info", and the profile, account logs, signatures and profile card read in PTT Settings, stay in memory only. If you let this device enter two-step verification codes automatically (by turning on two-step verification or pasting your key), the key is stored where your credentials are (this device's Keychain, not synced or carried to other devices by backups), and the code is calculated on the device and sent to PTT when you sign in; it is deleted when you tap "Stop Entering Codes Automatically", turn off two-step verification, or tap "Sign out and forget credentials". The recovery codes PTT gives you when you turn it on are kept there only until you tap "I've Saved My Recovery Codes"; the app keeps no copy. When you tap "Add to Passwords" or "Add to Another Authenticator", the key is handed to the app you choose; when you copy a code, the recovery codes or the key, it goes only to this device's clipboard (not to your other devices) and is cleared after two minutes. "Block" only hides that account's posts, comments and mail on this device; nothing changes on PTT, and the other person is not notified.
- **Crisis Prep (in builds that support this feature; offered when your region is Taiwan).** In the "Crisis Prep" widget on the start page, your supply lists and expiration dates, family meeting points and key contacts, and the places you name with their saved shelter-map views are stored only on this device (section 2); the app **never sends them to us or anyone else** (unless you share them yourself). The siren sounds are official recordings bundled with the app, and the disaster, first-aid and other guide pages and the knot-tying guide are built into the app too, so playing and reading them makes no connection. While a siren plays, the lock screen, Control Center and car displays show its name and "Crisis Prep", regardless of "Show Track on Lock Screen". Apart from external links you open yourself (see the end of this item), the app connects to the government map websites only when you open an official map in "Shelter Maps" (section 3, item (18)); if a website asks for your location, iOS and WebKit ask you, as described under "Website location requests" above. A saved view is the map web page as it was when you tapped "Save This View": if you allowed the website to use your location and the map marked it, that marker is in the image too. Emergency hotlines and your contacts' numbers are dialed by iOS; when you share your meeting points (as plain text) or a shelter map (as a PDF), the content goes wherever you choose in the share sheet. External links in the widget (the official website, the handbook download page and links in the guide pages) open in a sub-page, just like web pages you open in the browser, and links to the official disaster apps open in the App Store. The start-page tile shows only its icon and name, never items about to expire or anything you have recorded.
- **Toolkit (in builds that support this feature).** The "Toolkit" widget on the start page reads sensors and does its calculations on this device only and **makes no network connections**; camera images, sound, locations and readings are **neither stored nor sent to us or anyone else**. Sensors are read only while that tool's screen is open and the app is in the foreground, and stop when you leave the screen or the app goes to the background. Tools that use the camera, microphone, location or barometer start reading only after you tap the tool's start button (for true north, "Allow Location for This Tool"); iOS asks at that point for any permission you haven't granted yet, and you can withdraw it later in iOS Settings. **Camera**: Distance & Area (also using LiDAR depth data on devices that have it), Light Meter, Picture Hanging, Magnifier and the Protractor's camera mode show only the live view and results worked out on this device; nothing is photographed or recorded, and "Freeze" only stops the picture. **Microphone**: Sound Meter and Tuner analyze loudness and pitch live, without recording. **Location**: Speedometer (needs Precise Location) and the Compass's true north (your location corrects for magnetic declination; magnetic north needs no location); locations and routes are not stored. **Motion & Fitness permission**: Pressure & Relative Height reads the barometer; the motion sensors and magnetic readings used by Slope & Level, Picture Hanging, Compass and Magnetometer need no permission. Readings, the reference calibrations in Sound Meter and Light Meter, zero points, baselines and bearing marks, and what you enter in Unit Converter, BMI, Unit Price Comparison, Split Bill & Tip, Date Calculator and Counter (numbers, dates and names) stay in memory and are cleared when you leave that screen; **the only thing the Toolkit stores is the Ruler's calibration** (section 2).
- **Fate: digital divination blocks (in builds that support this feature).** Besides tapping "Divination blocks", you can hold your phone and flick it upward. To recognize that motion, the app reads the motion sensor's acceleration (no permission needed) while the divination screen is open, the app is in the foreground and no toss is in progress, and decides on this device only; readings stay in memory and are **neither stored nor sent to us or anyone else**. Reading stops when a toss starts, when you leave the divination screen, or when the app goes to the background.
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

The browsing data in the table stays on your device. **The install identifier, subscription sync data, the device key for the weather and traffic data service, weather locations, and Home Screen weather widget data are exceptions**, described in section 3.

To be straightforward about one thing: if you use iCloud Backup or back up your

Also, each time the app saves a file, it first keeps the previous version as a backup copy (ending in `.bak`) so the data can be recovered if a write is interrupted. An item you delete (for example a bookmark or a family member's phone number) may therefore stay in that previous version until the same data is changed again. The backup copy sits next to the original and is copied by system backups along with it.
iPhone or iPad to a computer, **most** of these files are copied as part of that **system
backup**. That is Apple's mechanism; we cannot read its contents, and have no way
to. We deliberately do not exclude bookmarks, history and tabs from backup —
doing so would lose them when you move to a new device.

**Four kinds of browsing data we do exclude** from backup: the **rule-list cache** (derived
data you can always re-download, with no reason to take up your iCloud storage),
the **site-icon cache** (its file names are derived from hosts you visited, so it
has no business leaving this device), **tab thumbnails** (those are the page
images themselves — even less reason to leave this device than a list of hosts)
and the **diagnostic log** (it contains hosts you visited — same reason).
In builds that support widgets, some widget data is also excluded from backup; the table notes which. In builds that support private tab groups, kept private tabs and groups (including their website data) are also excluded from backup; see the table and section 4.

| Data | Contents | Retention | How to delete |
|---|---|---|---|
| Browsing history | Full URLs, titles, timestamps | Newest 2,000 | Settings → "Data" → "Clear browsing history"; or "Clear" at the top right of the history page |
| Tabs | URL, title, custom name, pinned state, group membership (group name and color) | No limit | Close the tab, or "Close all tabs" in the tab switcher menu (pinned tabs and tabs in pinned groups are skipped) |
| Bookmarks | URL, title, time added, **whether it was saved from a private tab** | No limit | "Bookmarks" under Shortcuts on the home page → swipe left to delete on the list; or "Reorder" at the top right, then delete in edit mode |
| Reading list | URL, title, timestamp (**never the article text**) | No limit | Swipe left to delete on the list page; "Clear read" at the top right |
| Playback queue | Media URL, title, artist, artwork URL (**private tabs keep theirs in memory only**) | No limit | Swipe left to delete in the queue panel; closing that tab discards the whole queue |
| Watch positions | Media identifier, playback position | 90 days or 500 entries | Cleared along with "Clear browsing history" |
| Tab thumbnails | Screenshots of the page shown on the tab card (**private tabs are never captured at all, not even in memory**) | At most 60 files, oldest deleted first | Deleted when you close that tab; cleared along with "Clear browsing history"; **excluded from backup** |
| Site-icon cache | Small icons the sites you opened declare for themselves, fetched from that site **at visit time** (never from a third party, never in the background); file names are a hash of the host (**private tabs never write to disk**) | At most 200 files | Cleared along with "Clear browsing history"; **excluded from backup** |
| Preferences | Each of the switches; **and any exceptions you have set for an individual site** | No limit | Removed automatically once every override for that site is set back to "follow global" |
| Website data | Cookies, caches, localStorage (managed by WebKit, **a separate store per tab**). The exception is a **sub-page** — a page a site asks to open separately, or a link you tap on a web page or in a widget, that slides up over the current screen: it **shares** the store of the tab beneath it. "Open in Tab" gives the new tab its **own copy** of the sign-in data at that moment and reloads the page; from then on the two tabs are independent. In a few cases a sub-page is first kept as a tab before another tab opens (for example, when you tap a link in another app, or open a page from History in the sub-page): if it is **playing with sound** (not muted) at that moment, it becomes a tab in place without reloading, so the sound is not interrupted, and **keeps sharing** the original tab's store; otherwise (not playing, or playing muted) it gets its own copy, as with "Open in Tab". Private and normal tabs never share | Erased when the tab closes; a shared store is erased when the last tab using it closes (closing a sub-page does not erase it) | Settings → "Data" → "Clear all website data"; or clear an individual site from the shield menu |
| Kept private tabs and groups (in builds that support this feature) | Private tabs you pinned, and groups of private tabs that have a passcode lock or are pinned, with their tabs: URL, title, custom name, last-visited time, pinned state, group membership (group name and color), a hash of the group passcode (not the passcode itself) and the record of consecutive wrong attempts; plus these tabs' website data (cookies; after the app is reopened, also caches, localStorage and so on; sub-pages opened from them share it). No back/forward list, thumbnail or site icon is stored, and nothing goes into browsing history. **Excluded from backup** | Until you close the tab, or it is no longer kept (see section 4) | Close the tab (unpin a pinned one first), or long-press the group → "Close Group Tabs" (no passcode needed; a pinned group must first be unpinned with "Unpin Group", which also works while it is locked). "Close all tabs" skips them. Settings → "Data" → "Clear all website data" also clears their website data |
| Per-tab interaction state | Each tab's back/forward list (which contains URLs) and scroll position (**never written to a file for private tabs**) | Lives as long as the tab | Closing that tab deletes it; "Clear browsing history" also clears this copy from disk |
| Rule-update bookkeeping | Time of the last update, number of rules, and whether the unsigned fallback was used | No limit | No deletion entry point today (deleting the app removes it) |
| Rule-list cache | The downloaded blocking rules themselves (~14 MB; WebKit keeps a separate compiled output of roughly 53 MB), **containing none of your data** | Overwritten at the next update | No deletion entry point today (deleting the app removes it); **excluded from backup** |
| Diagnostic log | **Off by default.** While off, only this session's most recent 100 events stay in memory, keeping not even the site host; once on, they are written to a file where ordinary tabs keep the site host and private tabs not even the host | In memory: 100 events, gone when you close the app. File: capped at roughly 600 KB; past that only the later half is kept | Settings → "Privacy" → turn off "Diagnostic log", which **deletes both**; **excluded from backup** |
| Install identifier | One randomly generated UUID, stored in the Keychain rather than in a file. Contains no name or email, but links purchases | No limit | See point 4 below — **deleting the app does not guarantee its removal** |
| Device key for the weather and traffic data service (in builds that support this feature) | The key ID and registration progress of an Apple App Attest key, stored in the Keychain on this device only. Contains no name or email, and is not linked to the install identifier | No limit; the server-side record is deleted 90 days after last use | No delete option; **deleting the app does not guarantee its removal**. After reinstalling, the key stops working and the app creates a new one |
| Start-page widgets (in builds that support this feature) | The widgets you added to the start page and their order | Until you remove them | Long-press a widget on the start page → "Remove" |
| Winning-numbers cache (in builds that support this feature) | Public uniform-invoice winning numbers from Taiwan's Ministry of Finance, with each period's official prize descriptions and claiming notes, **containing none of your data** | Replaced on the next update; periods past their claim deadline are removed | No delete control at present (deleting the app removes it); **not backed up** |
| Timer (in builds that support this feature) | The last mode, time and duration you used; while a countdown runs, its target time is also kept (excluded from backups). What you counted down to is not recorded | Settings until next overwritten; the running record is deleted when you stop | No delete control at present (deleting the app removes it) |
| Weather locations (in builds that support this feature) | City names, coordinates and time zones you added in the Weather widget, with the country, county or city and township returned by map search; whether to use your location; your Taiwan weather source | Until you remove them | Swipe left to delete in "Weather Locations" |
| Home Screen weather widget, including on the Lock Screen (in builds that support this feature) | Names and identifiers of the cities in your weather locations (no coordinates; used to choose a location in Edit Widget); if a widget shows My Location (the default), the most recent location read, rounded to about 1 km, and when it was read; the latest forecast for each location a widget is showing (the My Location forecast notes which ~1 km coordinate it was looked up for). Kept in space shared by the app and its widgets, **not backed up**. iOS also keeps the rendered widget images | The city list until you remove a city; the coordinate is overwritten when a new location is read and deleted when no widget uses My Location or location access is withdrawn; forecasts until the widget is removed or stops showing that location | Remove the weather widget from the Home Screen (the coordinate and forecasts are deleted the next time the app opens or updates in the background), or swipe left on a city in your weather locations |
| Drive Safe (in builds that support this feature) | Settings (country, sound, run in background); downloaded public speed-camera, average-speed-section, road-route, speed-limit and traffic data (the copies downloaded from our service are excluded from backups), **containing none of your data**. No driving routes are stored | Settings until you change them; public data until the next update replaces it | No delete control at present (deleting the app removes it) |
| Cheer Kit (in builds that support this feature) | Board mode, colours, motion, appearance, alarm settings and handwriting (included in device backups); the current text and the five most recent texts for the board and for Megaphone text to speech (this device only, excluded from backups) | Until you change them | Clear handwriting on the board with "Clear"; delete recent texts one at a time after tapping the text field; no delete control for the rest at present (deleting the app removes it) |
| Megaphone recording (in builds that support this feature) | One recording made when you tap record, on this device only, excluded from backups; speech synthesized for text to speech is also kept there temporarily | The recording until the next one replaces it; synthesized speech is deleted when you stop or the next time the app opens | "Delete recording" in Megaphone |
| Currency (in builds that support this feature) | The currencies you chose and their order, the currency you type in, the country of the rate source and the type of board rate (included in device backups); downloaded public exchange rates (excluded from backups), **containing none of your data**. **The amounts you type are not saved** | Settings until you change them; rates until the next update, and the system may clear them first when storage runs low | No delete option yet (deleting the app removes them) |
| Radio (in builds that support this feature) | Favorite stations, subscribed podcasts (including their RSS addresses), recently played stations (up to 20), each episode's playback position and completed mark (recorded under the podcast's RSS address and the episode's identifier; for an episode without an identifier, its audio address), and the country chosen for stations and for podcasts (all included in device backups); temporary copies of station directories, search results and episode lists (excluded from backups). **No recordings and no audio downloads** | Favorites, subscriptions, recents and positions until you delete them, the country choice until you change it; temporary copies stop being used after 24 hours, and the system may clear them first when storage runs low | Remove favorites and subscriptions in Radio; "Clear" next to Recently Played on the Favorites page; temporary copies with Settings → "Data" → "Clear All Cache"; choose "Use current Apple account" to stop keeping a specific country; playback positions have no delete option yet, and unsubscribing does not remove them (deleting the app removes them) |
| PTT (in builds that support this feature) | Favorite boards kept on this device when you aren't signed in, blocked accounts, posts you have read (PTT's file names, up to 3,000), whether you accepted PTT's age confirmation, and the Chinese names of boards (up to 500); all included in device backups | Read posts: the oldest are dropped past the limit; the rest until you delete them | Device favorites: swipe left on the Favorites tab; blocked accounts: PTT Settings → Blocked Accounts, swipe left; read posts: "Clear Read History"; age confirmation: "Withdraw Age Confirmation"; board names: no delete option yet (deleting the app removes them) |
| PTT account (in builds that support this feature) | Your PTT username and password; the two-step verification key if you let this device enter codes automatically; and the recovery codes from turning on two-step verification until you tap "I've Saved My Recovery Codes". All stored in the Keychain on this device only (not synced, and not carried to other devices by backups) | Credentials until you sign out; the key until you tap "Stop Entering Codes Automatically", turn off two-step verification or sign out; recovery codes until you tap "I've Saved My Recovery Codes" | PTT Settings → "Sign out and forget credentials" (everything); Two-Step Verification → "Stop Entering Codes Automatically" (the key only) |
| Fate (in builds that support this feature) | The wheels you create (names, options and weights, whether repeats are allowed, whether weights are hidden), the wheel currently selected, and each game's settings (number of dice, the range and count for random numbers, whether numbers may repeat) (included in device backups). **Draw results, finger positions and divination block results are not saved** | Until you delete or change them | Delete a wheel by swiping left in the wheel list; the other settings have no delete option yet (deleting the app removes them) |
| Crisis Prep (in builds that support this feature) | Supply lists: for each item in "Home Supplies" and "Go Bag", whether it is ready, the expiration dates and quantities you record (up to 20 batches per item), names of items you add, and the date you last tapped "Mark Checked"; family meeting points: three meeting points and up to 20 key contacts (name, phone, note). All included in device backups | Until you delete or change them | Expiration dates: swipe left on the item page; items you added: swipe left → "Remove" on the list (their dates go too); contacts: swipe left → "Remove" in "Family Meeting Points", and clear a meeting point by deleting its text; "Ready" can be switched off at any time; the check date has no delete option yet (deleting the app removes it). Removing the widget from the start page does not delete this data |
| Crisis Prep shelter maps (in builds that support this feature) | Places you name (for example Home or Work) and the screenshots you save with "Save This View" on an official map (JPEG, up to 12 per place, with the time taken and which map it came from). A screenshot is the map web page as it was at that moment and may include your location if the site marked it. All included in device backups. When you open a saved view, the app writes a PDF of it for sharing (place name, time taken, map name and source site, and the map image) to the system's temporary folder; it is not backed up | Until you delete them; the app does not delete the temporary PDF itself (deleting the view or the place does not remove it), and iOS clears it from time to time | Delete one view by swiping left on the place page, or open it and use the delete button at the top right; delete a place and its views with "Delete Place" in the menu at the top right of the place page. Removing the widget from the start page does not delete this data |
| Toolkit (in builds that support this feature) | The Ruler's calibration: screen points per millimeter, plus the screen size, scale and device model code at the time (for example iPhone16,2, not a serial number; used to tell when the device or a display setting has changed and the ruler must be recalibrated); included in device backups. **Readings and calibrations in the other tools, camera images, sound, locations and what you enter are not stored** | Until you recalibrate | Recalibrating overwrites it; no delete option yet (deleting the app removes it) |

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
**Among the browsing features, this is the only third-party connection that can happen while you are not
actively looking at a page** — it fires with the app in the background and the
screen locked (widgets may also connect in the background: items (8) and (9) while driving alerts are on, item (13) while a countdown is running, item (15) while the radio is playing, and items (8) and (10) during background updates scheduled by iOS while a weather widget is on the Home Screen). We hold it to a minimum: it uses an isolated network configuration
with no cookies or cache, and **private tabs fetch no artwork and publish nothing
to the lock screen**.
To disable entirely: Settings → Media → Show Track on Lock Screen (called
“Lock screen controls” in version 1.1 and earlier).
When off, the lock screen, Control Center and car displays show none of the track
info or artwork we publish; playback and its controls are unaffected. (Exception: while Cheer Kit's alarm or a Crisis Prep siren is playing, the lock screen, Control Center and car displays show the alarm's name regardless of this setting.)

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
the same blocking rules as that tab and uses that tab's own store (so a private tab's reader view likewise leaves nothing on disk, except for kept private tabs; see section 4).

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
On launch or foregrounding, the app sends the install UUID, app bundle ID, platform ios and the app version number over HTTPS to create or recover a device account. Subsequent requests use the session token saved in Keychain. For Plus transactions it sends transaction and original transaction IDs, product ID, production/sandbox environment, any existing appAccountToken, and the Apple-signed transaction. The backend verifies with Apple and, where needed, adds a token to an externally redeemed transaction and queries subscription status again. **No browsing history, URLs, searches, bookmarks, viewed media or location are sent.** Connection services still process necessary connection information such as IP addresses. This data is used for account association and subscription service. The server also records the time and type of each connection (launch, return to foreground, subscription sync) in the account's device-activity records, which are used for troubleshooting, abuse prevention and aggregate usage statistics (such as daily active devices, retention and app-version distribution); administrators can view these records for an individual account. They are not provided to third parties and are not used for advertising or cross-app tracking. Deleting the app or browser data does not delete backend records; contact the address in section 9 for account-data access or deletion. **Deletion removes device links, and entitlement and subscription state. Two things do not go with it: the device record itself (including the install identifier), which does not disappear when the account is deleted and is removed automatically only after 90 days without activity, except where abuse prevention requires keeping it; and transaction records and the original Apple-signed notifications themselves, which are kept with your association stripped** — they are the evidence used to handle refunds and purchase disputes. Account and transaction records are retained as needed to provide service and handle purchase disputes; device-activity records are kept for 180 days by default. **Our server's backups also include this data**: nightly backups on the server are kept for 14 days; encrypted off-site copies are kept for 90 days, the first copy of each month for an additional 6 months, at least the 3 most recent copies of each service are always kept, and copies of a deleted service are kept for 1 year. After account data is deleted, copies in existing backups remain until those periods end. Older builds without CISIP do not make these requests.

**(8) Weather and traffic data → `data.link2us.link` (Weather and Drive Safe widgets; in builds that support this feature)**
This is our own service, relayed through Cloudflare. It serves only public data that it has already collected and prepared: Central Weather Administration forecasts, warnings and advisories, speed cameras, freeway routes and speed limits, provincial-highway routes and speed limits (mainly government open data, with elevated sections marked and split using OpenStreetMap; the dataset as a whole is under the ODbL), speed limits for other roads (derived from OpenStreetMap under the ODbL), live traffic incidents, and the positions of ambulances and fire engines on calls in New Taipei City. The provincial-highway and other-road datasets are also published on the same service for anyone to download. Apart from these two datasets, which contain OpenStreetMap-derived content, all of it is government open data. Your request never makes it fetch anything extra from a government site or from OpenStreetMap. The app connects only in these three cases:

- **When you view the weather for a place in Taiwan**: it reads the single, Taiwan-wide set of Central Weather Administration warnings and advisories, whichever Taiwan weather source you chose. The request contains no location, county, city or township; your phone works out which county or city applies.
- **When "Taiwan weather source" is set to Central Weather Administration**: it also reads the township forecasts for your county or city. It sends the dataset code of that **county or city** (in a header, not in the URL); coordinates and township are not sent. When a Home Screen weather widget shows a city in Taiwan (or My Location is in Taiwan), the app also reads that county's forecast for it when you open the app and during background updates scheduled by iOS (which can happen while the app isn't open), at most once an hour per location; what is sent is the same: only the county or city code.
- **When you use the Drive Safe widget**: it downloads speed cameras, freeway and provincial-highway routes and speed limits, speed limits for other roads, and live traffic incidents — datasets that are the same for everyone in Taiwan. Camera, route and speed-limit data are checked for new versions about once a day; while driving alerts are on, traffic incidents are read about every one to two minutes. **While you are in or around New Taipei City**, it also reads the positions of ambulances and fire engines on calls, as published by the New Taipei City Fire Department, about every 20 to 30 seconds — one city-wide list, not filtered by your location. The requests contain no location; all matching, including whether you are around New Taipei City, happens on your phone.

**Every request carries** this installation's Apple App Attest key ID and signature (plus Apple's attestation the first time), used to confirm that the request comes from the genuine app, along with the app's bundle ID, the dataset name and the version tag of the last download. **No account, no installation identifier from item (7) and no other device identifier is attached**, and this key is not linked to the account in item (7). The connections carry no cookies and write no disk cache. The key is kept in this device's Keychain; after you reinstall the app it stops working and the app creates a new one.

**What we keep**:
- **Key records**: one per key — the app's bundle ID, developer team ID, App Attest public key, signature counter and registration time.
  - The key ID is a hash of that public key, so it amounts to **a fixed code for each installation**.
  - The record contains **no county or city, no IP address and no time of individual reads**. It is deleted automatically 90 days after the last successful read; each read extends that. Background updates for the Home Screen weather widget count as reads: while the widget is on the Home Screen and uses the Central Weather Administration, this record keeps being extended even if you don't open the app.
  - Our server's backups also include these records: nightly backups on the server are kept for 14 days, and encrypted off-site copies for 90 days or longer (rules in item (7)).
- **One-time verification records**: they expire within 2 minutes and are deleted once used. They contain only the key, the purpose and whether it is weather or traffic — no county or city.
- **The county or city code**: compared in memory only, to return that one forecast, and **never written to any storage, log or backup**.
- **Abuse-prevention counters**: grouped by a hash of the IP address, and gone after 60 seconds. The hashing key is generated randomly each time the service starts and is never saved.
- **Service logs**: they do not record individual requests.

**Where we have not done well enough yet**:
- The connection passes through Cloudflare (our network provider). While relaying, it can see the whole request (including the county or city code) and your IP address, and it keeps sampled records of IP address, URL and time for up to 30 days (the URL does not include the county or city).
- Forecasts for different counties and cities differ in size (about 62 KB to 1.8 MB), so anyone who can see traffic statistics, Cloudflare included, could in theory infer the county or city from the size.
- The account service in item (7) runs through the same Cloudflare account, so anyone with that access could match requests from both by IP address and time. We do not do such matching.

**If it cannot be reached**: if this service is unreachable, or this device cannot be verified for a while, the app does not fall back to unverified requests. Weather does not switch sources by itself; the screen explains the situation and suggests switching to Apple Weather. The Drive Safe widget downloads directly from government sites instead (item 9).

**(9) Drive Safe widget → government open-data sites (when item (8) is unavailable; in builds that support this feature)**
The app downloads the National Police Agency's speed-camera list, New Taipei City's average-speed-section list and the Police Broadcasting Service's live traffic incidents directly (`data.gov.tw`, `opdadm.moi.gov.tw`, `data.ntpc.gov.tw`, `rtr.pbs.gov.tw`).
- Camera and section lists: downloaded directly only when the app has no data from item (8).
- Traffic incidents: downloaded from the Police Broadcasting Service whenever item (8) cannot be reached, about every two minutes while driving alerts are on.

The requests contain no location and no identifier, and they do not pass through our servers. Those sites can still see your IP address and the connection times, and the traffic-incident requests in effect show them when you are using driving alerts. The connections carry no cookies and write no cache.

**(10) Weather widget → Apple Weather, Apple Maps, the US National Oceanic and Atmospheric Administration (NOAA) (in builds that support this feature)**
Happens when you open the Weather widget. **If a weather widget is on your Home Screen**, opening the app and background updates scheduled by iOS (iOS decides when and how often; this can happen while the app isn't open; at most once an hour per location) also look up the location the widget shows. These look up only the forecast (Apple Weather and the county forecast in item (8)) — no place names, warnings, closures or wind maps, and no Apple Maps. The Home Screen widget itself makes no network connections. To stop background updates, remove the weather widget from the Home Screen or turn off Background App Refresh for Vigatamala in iOS Settings.
- **Apple Weather (WeatherKit)**: coordinates rounded to about 1 km, to look up current, hourly and ten-day forecasts (not used for places in Taiwan when Central Weather Administration is selected). According to Apple, location is used only to produce the forecast, is not associated with personally identifying data, and is not tracked across requests.
- **Apple Maps**: reverse lookup of the place name and county or city (with the same rounded coordinates), the text you type when searching for a city, and map tiles.
- **Central Weather Administration warnings and forecasts**: through our weather and traffic data service; see item (8).
- **NOAA GFS model data**: the data for the wind animation. The card sends one 20°×30° area aligned to a fixed grid around the place you are viewing. When you pan or zoom the full-screen map beyond the data already loaded, the app fetches data for the whole visible map: the visible area plus a 5° margin, with its north–south and east–west edges aligned to coarse 10° and 5° grids, at least 20°×30° and possibly larger (latitude is supported only up to ±85°). **It never sends precise coordinates or the precise visible area, but NOAA can infer the region you are looking at from the coarse grid area requested**, and it can see your IP address. Time frames already downloaded for the same run and area are reused from memory only.
- The app does not store the weather and wind data it looks up on the device, **except for the Home Screen weather widget**: the latest forecast for each location a widget is showing is kept in space shared by the app and its widgets, not backed up to iCloud or a computer, and deleted when the widget is removed or stops showing that location (section 2). The NOAA connection carries no cookies and writes no disk cache; Apple Weather and Apple Maps are iOS system services, and iOS handles their connections and caching.

**(11) Weather widget → Directorate-General of Personnel Administration, Taiwan (work and school closures) (in builds that support this feature)**
Only when you view the weather for a place in Taiwan or tap "Refresh now". The app downloads the **Taiwan-wide** closures page directly from the Directorate-General's website (`www.dgpa.gov.tw`, through Chunghwa Telecom's HiNet CDN) and picks out your county or city on your phone. **The request contains no location, no county or city, and no identifier of any kind**, and it does not pass through our servers; the site sees your IP address and ordinary connection information. The page stays in memory and is not written to the device. The connection carries no cookies and writes no cache.

**(12) Receipt lottery winning numbers → `invoice.etax.nat.gov.tw`, `www.etax.nat.gov.tw` (Taxation Administration portal, Taiwan's Ministry of Finance; in builds that support this feature)**
Only when you open the "Lottery" widget on the start page, or scan a receipt from a period whose numbers the app doesn't have yet, does the app fetch the public uniform-invoice winning numbers, and each period's winning-numbers page (official prize descriptions, claiming notes and claim period), from the Ministry of Finance. If you don't use the widget, no connection is made, and nothing is fetched in the background. **What the request contains**: only the address of that public file — none of your receipt numbers or other data — sent with a separate network configuration (no cookies, no cache). The server sees your IP address, browser identifier string and the time. Matching happens on your device.

**(13) Timer clock sync → time servers of Taiwan's National Time and Frequency Standard Laboratory or Apple (in builds that support this feature)**
When you open the Timer, tap start or "Sync again", and as a countdown nears its end, the app asks a time server for the current time using standard network time sync (NTP): in Taiwan it asks the laboratory's five servers at once (`time`, `tick`, `watch`, `tock` and `clock.stdtime.gov.tw`); elsewhere it asks Apple's `time.apple.com`, the same service iOS uses to set its own clock. Each request is a standard 48-byte NTP packet containing only a random number — no phone time and no identifier. It does not pass through our servers; the server sees your IP address.

**(14) Currency exchange rates → `rate.bot.com.tw` (Bank of Taiwan), `api.frankfurter.dev` (Frankfurter) (in builds that support this feature)**
Only when you open the "Currency" widget on the start page, or tap refresh in it, does the app download public exchange rates: when the rate source is Taiwan, the Bank of Taiwan board rates; for other countries, that country's central bank reference rates through Frankfurter, an open-source exchange-rate aggregation service; and, from Frankfurter, international reference rates compiled from central banks whose terms allow reuse, used for currencies the main source doesn't quote. Downloaded rates are reused for a while (10 minutes for the Bank of Taiwan, 1 hour otherwise), and nothing is fetched in the background. **What the request contains**: only the address of that public data; requests to Frankfurter include the central bank code and currency code of the rate-source country (by default the country or region of your App Store account, or your system region if that cannot be read, or the United States if neither can; when that country is not in our list of rate centers, or you choose "International Reference Rates", only the international reference rates are requested, with no country), but none of the amounts you type or any identifier; they are sent with a separate network configuration (no cookies, no cache). The servers see your IP address, browser identifier string and the time, and handle them under their own privacy policies. Conversion happens on your device.

**(15) Radio → the Radio Browser station directory (`*.api.radio-browser.info`), Apple's podcast directory (`itunes.apple.com`), stations and podcast publishers (in builds that support this feature)**
These connections happen only when you open the "Radio" widget on the start page or use the radio (including changing stations with the buttons on headphones, in the car or on the lock screen); nothing is fetched in the background on a schedule:

- **Station directory**: the app first gets the list of directory servers from `all.api.radio-browser.info`, then looks up stations on one of them. The request contains the country code (by default that of your App Store account, or your system region if that cannot be read, or the United States if neither can; none when you choose "Worldwide"), the text you submitted as a search (up to 200 characters; nothing is sent while you are still typing) and the page position. Radio Browser is a public, community-maintained directory, not our service.
- **Apple's podcast directory**: searching podcasts, browsing top charts by category and getting a podcast's RSS address query Apple; the request contains your search text, the country or region and the category. The default country or region is chosen the same way (your App Store account, then your system region, then the United States).
- **Podcast RSS and audio**: opening a podcast reads its episode list from the publisher's RSS address (the RSS is always fetched over HTTPS), and playing an episode streams the audio directly from the address the publisher gives. Some podcasts give unencrypted HTTP audio addresses; while you play those episodes, others on the same network (for example whoever runs a public Wi-Fi) may be able to tell which episode of which podcast you are playing. Publishers often route episode audio (HTTPS or not) through hosting or listening-statistics services of their choice, which can also see the connection.
- **Station streams**: playing a station connects directly to the station's server. Some stations only offer unencrypted HTTP streams; while you listen to one of them, others on the same network (for example whoever runs a public Wi-Fi) may be able to tell which station you are playing. Song titles carried by the stream itself are shown in the player bar and on the lock screen; they are read from the stream already playing, without any extra connection. Station logos and podcast artwork are not fetched.

**What these requests contain**: beyond the query contents listed above, requests to the two directories use an isolated network configuration (no cookies, no cache), identify themselves as `Vigatamala/1.0`, and carry no account or device identifier; the app does not report to the directory which stations you click or play. The servers see your IP address and the time, and handle them under their own privacy policies. None of these connections go through our servers.

**(16) Cheer Kit multi-phone marquee → nearby phones that join with your room number (in builds that support this feature)**
Connections happen only after you tap Host or Join, and stop when the link ends or you close Cheer Kit. The host advertises a service nearby (Bonjour, over the same Wi-Fi network or Apple's peer-to-peer Wi-Fi between devices) under a randomly generated name that contains neither the device name nor the room number; joining phones find it using the room number you enter and connect directly. **What is sent**: the host sends the board text and its layout, display settings (color, motion, speed, look, text direction, screen orientation), the order of the phones and the start time; each joining phone sends a random identifier (newly generated each time the app opens, never saved), its screen size (width, height, scale, and whether its orientation can be locked), the time it was tapped while arranging, and timestamps for clock sync. The connection is encrypted (TLS) with a key derived from the room number. The room number has only four digits: people who cannot see the host's screen cannot join, but a determined person could still break it, so do not put anything on the board you would not want people nearby to see — the board is meant to be shown to the people around you anyway. These connections **do not go over the internet or through our servers**.

**(17) PTT → `www.ptt.cc`, `ws.ptt.cc` (PTT's official website and bulletin board system), image hosts in posts (in builds that support this feature)**
Connections are made only while you have the "PTT" widget on the start page open (the bulletin board connection may stay open for a while after you leave; see below); nothing is fetched on a schedule in the background:

- **Website**: boards, posts, search, popular and category boards are fetched from `www.ptt.cc`. If you accepted PTT's age confirmation, PTT's own `over18=1` cookie is sent; none of the cookies from your browser tabs are sent, and nothing is cached.
- **Bulletin board system**: if you saved an account, the app connects to PTT over an encrypted WebSocket (`wss://ws.ptt.cc`) and signs in, sending your username and password (and, when PTT asks for two-step verification, the code you enter or the one this device calculates if you let it enter codes automatically). When you then comment, post, reply, send mail, report, add or remove favorites, look up author or post info, or view or change your PTT account in Settings (profile, profile card, signatures, password, two-step verification, account logs), the app presses PTT's keys for you over this connection; after you sign in, opening a board or post also reads the latest page over this connection to show posts and comments the website hasn't caught up with yet. When “Stay Connected” in PTT's Settings is on (the default), the connection stays open for the time you choose (5 minutes by default) after you close the widget, so coming back doesn't sign you in again; while it's idle, the app sends a keep-alive signal at regular intervals (every 60 seconds by default; a telnet protocol signal with no content). While the connection is kept, PTT shows you as online. About half a minute after you switch to another app, iOS suspends the app; the connection usually stays open (while the app is suspended it can't be closed on time: past the time you chose, it stays open until you come back, lock the screen, or the network drops it, and PTT keeps showing you as online). If PTT was open when you left and the connection still works when you come back, the app keeps using it without signing in again. When you lock the screen, iOS drops the connection within a few seconds, and the app signs in again when you come back. With “Stay Connected” off, the connection is closed when you close the widget or the app goes to the background.
- **Images**: images in posts load directly from the image hosts the posters used (for example imgur). "Load Images in Posts Automatically" in PTT Settings is on by default; when it is off, images load only when you tap them. Images in PTT mail always load only when you tap them (so a sender can't use an image to learn that you opened the mail). Images stay in memory only, are not written to the device, and are requested without cookies or a referring address.

**What these requests contain**: PTT sees your IP address, your account when you are signed in, and what you do on PTT, and handles it under PTT's own rules; image hosts see your IP address and the time. None of these connections pass through our servers.

**(18) Crisis Prep shelter maps → `adr.npa.gov.tw` (Taiwan's National Police Agency), `bear.emic.gov.tw` (National Fire Agency), the resources these sites load, and pages you open from this screen (in builds that support this feature)**
Connections happen only while you have "Air Raid Shelter Map" or "Evacuation Shelter Map" open in "Shelter Maps"; they stop when you leave that screen, and nothing is fetched on a schedule in the background. These maps are web pages shown inside the widget: as when you visit those sites directly, each site loads the map tiles, scripts, fonts and other resources it chooses (for example, the National Police Agency's map gets its tiles from Taiwan's National Land Surveying and Mapping Center), and some of these may come from third-party services (such as map tiles or fonts). The site decides what is loaded.
- **This screen is not a tab**: the app's content blocking and the other web-page changes in section 5 do not apply (the User-Agent is WKWebView's default string), and nothing is written to your browsing history; the same goes for other pages you open from this screen. Cookies, localStorage and other website data are kept in memory only, never written to the device, and the map starts fresh each time you open it.
- **Location**: if the site asks for your location, iOS and WebKit ask you, as described under "Website location requests" in section 1. If you allow it, the location goes to that site and is handled under its privacy policy; Vigatamala does not store the coordinates (for a location marker in a saved view, see section 1).
- Links that are not web pages, such as phone numbers or links that open other apps, are never opened; when a site opens a new window, it opens in this screen.
**What these requests contain**: as with ordinary browsing, the sites and the services they load see your IP address, browser identifier string and the time, and can tell from the map-tile requests which area you are looking at; the app adds no other data or identifiers. These connections do not pass through our servers.

The app makes no other outbound connections.

---

## 4. Private tabs

**What they do:**

- Nothing is written to browsing history. Private tabs are not written to the saved tab list and are not restored when you reopen the app — except the private tabs you ask to keep (see the end of this section).
- Website data (cookies, caches) is kept in memory only and is gone the moment you close the tab — except for kept private tabs and the sub-pages opened from them (see the end of this section).
- Reader view uses the tab's own store, so it is likewise in memory only (except for kept private tabs).
- No title or artwork is published to the lock screen, Control Center or a car
  display.
- The playback queue stays in memory only and is never written to disk.
- **The address bar suggests nothing until you start typing.** In a normal tab,
  focusing the address bar lists the places you visit most (from your local
  history and bookmarks); in a private tab it does not — that would hand your
  frequently-visited list to whoever is holding the phone. Once you type, it
  still matches (entirely on device). To turn off that half too, see
  Settings → Privacy → "No local suggestions in private tabs".
- **If you leave the app while private content is on screen, the multitasking
  preview is covered.** iOS takes a full-screen snapshot of its own when an app
  goes to the background; before it does, we lay a blur over the screen. "On
  screen" means the selected tab is a private tab, or you are looking at the list
  of private tabs. Leaving the app from an ordinary tab does not cover it — even
  with private tabs still open in the background, the snapshot shows only what is
  on screen, and none of that is private.

**Actions you take deliberately still leave traces:** adding a bookmark or saving
to the reading list from a private tab writes that URL into the corresponding
list. This is intentional — we will not quietly discard something you explicitly
asked us to keep. But it is worth knowing.

**We do, however, remember that it came from a private tab, and reopen it in a
private tab.** Otherwise one tap on a bookmark would put that URL into your
browsing history and its cookies into the normal store — without you having made
any further choice. (Since 2026-09-07; bookmarks saved before that carry no such
information and are treated as coming from a normal tab.)

**Private tabs you ask to keep stay on the device (in builds that support this feature).** Private tabs can be grouped. Private tabs you **pin**, and groups of private tabs you **give a passcode lock or pin** (with every tab in them), are still there after you quit and reopen the app:
- Their URLs, titles, and group names and colors are stored on this device in a file **excluded from iCloud and computer backups** (section 2); when nothing is left to keep, the whole file is deleted. They are still never written to browsing history, and no back/forward list, thumbnail or site icon is stored for them.
- Once a tab is kept, its cookies (which most sites use to keep you signed in) are synced, whenever they change, to its own store on this device (also excluded from backup); after the app is reopened, all of that tab's website data (cookies, caches, localStorage and so on) lives there instead of in memory only. Sub-pages opened from it share that store, so sign-ins made there are kept too; "Open in Tab" turns a sub-page into a new tab with its own copy of the sign-in data at that moment (a sub-page kept in place because it was playing with sound when another tab opened keeps sharing the store for the rest of this session; see "Website data" in section 2), and whether that tab is kept depends on the new tab itself (for example, if it joins a passcode-locked private group).
- Closing the tab deletes all of this (if the web view has not released it yet, the copy on disk stays until the next time you open the app). When a tab no longer qualifies (for example you unpin it, remove it from its group or ungroup, or choose "Remove Passcode Lock"), it is no longer kept: a copy made since you last opened the app is deleted right away; one left from an earlier session keeps being used by that tab until you close it, and is deleted when you close the tab or reopen the app later.
- The **group passcode** is 4–8 digits, separate from your device passcode, and does not use Face ID. The app stores only a hash of it (PBKDF2) and the record of wrong attempts, in the file above; it never stores the passcode itself and never sends it to us or anyone else. You must enter it to open the group or add a tab to it; the group locks again when you leave the app, select a tab outside the group, or choose "Lock Now", and it is always locked when the app is reopened. While locked, the tab list shows only the group's name, color and a lock. A forgotten passcode can't be recovered, but "Close Group Tabs" works without it (unpin a pinned group first with "Unpin Group", which also needs no passcode; the stored data is deleted along with the tabs).
- **The passcode lock is meant to stop someone holding your unlocked phone from opening the group; it is not encryption.** The stored URLs and website data are not separately encrypted and are protected only by iOS's own file protection; Picture in Picture or background playback that is already running does not stop when the group locks.

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

**Exception:** the official map screen used for screenshots in Crisis Prep (section 3, item (18)) is not a tab; none of the above applies there, and the User-Agent is WKWebView's default string (which, as explained above, reveals more than the Safari-matching string).

---

## 6. What we never do

- We do not sell, share or rent any of your data. **We never receive your browsing data**;
  the account and subscription data and the weather and traffic service's key records described in
  section 3 are used only to provide those services and for the troubleshooting, abuse prevention and aggregate usage statistics described in item (7), and are not passed to third parties.
- We insert no advertising, affiliate links or sponsored content.
- We do not track you across apps or websites.
- We provide no way to download web content (media or files) or save web pages for offline use. Crisis Prep's "Shelter Maps" saves a screenshot of the map as it appeared when you tapped the button (section 2), not the web page itself.

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
