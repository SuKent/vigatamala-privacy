// 「民防準備」離線網頁的 service worker:第一次打開就把整個網頁(連五個警報錄音)存進手機,之後沒有網路也能打開。
//
// __VERSION__ 與 ["./", "./style.css", "./icons.js", "./content.js", "./store.js", "./app.js", "./manifest.webmanifest", "./icon.svg", "./icon-180.png", "./icon-192.png", "./icon-512.png", "./strings.zh-Hant.json", "./strings.zh-Hans.json", "./strings.en.json", "./strings.ja.json", "./strings.ko.json", "./sounds/civil-air-raid.mp3", "./sounds/civil-all-clear.mp3", "./sounds/civil-tsunami.mp3", "./sounds/civil-nuclear.mp3", "./sounds/civil-nuclear-all-clear.mp3"] 由 `python3 Tools/civil-web/build.py --out <資料夾>` 換掉:版本是所有檔案內容的雜湊,
// 內容一變就換一份新的快取、舊的刪掉。只處理這個資料夾裡的檔案,其他網址一律照常連網(官方地圖、App Store 的連結)。
'use strict';

const VERSION = 'dfc0d1ae40a2';
const FILES = ["./", "./style.css", "./icons.js", "./content.js", "./store.js", "./app.js", "./manifest.webmanifest", "./icon.svg", "./icon-180.png", "./icon-192.png", "./icon-512.png", "./strings.zh-Hant.json", "./strings.zh-Hans.json", "./strings.en.json", "./strings.ja.json", "./strings.ko.json", "./sounds/civil-air-raid.mp3", "./sounds/civil-all-clear.mp3", "./sounds/civil-tsunami.mp3", "./sounds/civil-nuclear.mp3", "./sounds/civil-nuclear-all-clear.mp3"];
const CACHE = 'vgm-civil-' + VERSION;

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(FILES)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k.startsWith('vgm-civil-') && k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim()),
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin || !url.pathname.startsWith(new URL('./', self.location).pathname)) return;
  // 打開網頁(包括 #/alarms 這類網址)一律給存著的「./」;其他檔照存著的給,沒存到才連網。
  // ⚠️ 不要用 './index.html' 當鍵:網站(Cloudflare)把 /civil/index.html 轉址到 /civil/,存下來的是「轉址過的回應」,
  // 拿它開網頁瀏覽器會拒絕、整頁空白(2026-11-20 放上網站後重新整理實際發生;本機的伺服器不轉址,沒看出來)。
  const key = req.mode === 'navigate' ? './' : req;
  const range = req.headers.get('range');
  event.respondWith(
    caches.open(CACHE)
      .then((cache) => cache.match(key, { ignoreSearch: true }))
      .then(async (hit) => {
        if (hit) return ranged(await unredirected(hit), range);
        // 沒存到的錄音(第一次打開、還在下載的時候)也切成一段:網站不回 206,Safari 拿整個檔不播
        if (range) return fetch(req.url).then((r) => (r.ok ? ranged(r, range) : r));
        return fetch(req);
      }),
  );
});

/** 轉址過的回應不能拿來回網頁,重新包一份乾淨的(萬一快取裡還有舊版存下的)。 */
async function unredirected(response) {
  if (!response.redirected) return response;
  return new Response(await response.blob(), { status: response.status, statusText: response.statusText, headers: response.headers });
}

/** Safari 播 <audio> 一律要「Range: bytes=…」的一段(206),給整個檔(200)它不播 —— 從快取切那一段給它。 */
async function ranged(response, range) {
  const m = /^bytes=(\d*)-(\d*)$/.exec(range || '');
  if (!m) return response;
  const body = await response.blob();
  const size = body.size;
  let start = m[1] === '' ? size - Number(m[2]) : Number(m[1]);
  let end = m[1] === '' || m[2] === '' ? size - 1 : Math.min(Number(m[2]), size - 1);
  start = Math.max(0, start);
  if (start >= size || end < start) return new Response(null, { status: 416, headers: { 'Content-Range': `bytes */${size}` } });
  return new Response(body.slice(start, end + 1), {
    status: 206,
    headers: {
      'Content-Type': response.headers.get('Content-Type') || 'audio/mpeg',
      'Content-Range': `bytes ${start}-${end}/${size}`,
      'Content-Length': String(end - start + 1),
      'Accept-Ranges': 'bytes',
    },
  });
}
