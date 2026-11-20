// 「民防準備」離線網頁的畫面(照 Android `civil/CivilDefenseSheet.kt` 等的版面與順序)。
//
// 為什麼有網頁版(2026-11-20 使用者):Android 版的民防準備被 Google Play 擋下(要機構帳戶,Q83),行號先暫停,
// 先做成不經商店審查的離線網頁 —— Android、iPhone、電腦都能開,加到主畫面之後沒有網路也能打開。做不到求救通訊。
// 畫面以老人也會用為第一優先:字大、按鈕大、返回鍵有字、看得到的按鈕不靠手勢、顏色之外一定有字。
'use strict';

// MARK: - 文字

const Langs = [['zh-Hant', '繁體中文'], ['zh-Hans', '简体中文'], ['en', 'English'], ['ja', '日本語'], ['ko', '한국어']];
let STRINGS = {};
let LANG = 'zh-Hant';

function pickLang() {
  try { const saved = localStorage.getItem('vgm.civil.lang'); if (Langs.some(([l]) => l === saved)) return saved; } catch { /* 沒有 localStorage */ }
  for (const raw of navigator.languages || [navigator.language || '']) {
    const l = raw.toLowerCase();
    if (/^zh-(tw|hk|mo|hant)/.test(l)) return 'zh-Hant';
    if (/^zh/.test(l)) return 'zh-Hans';
    if (l.startsWith('ja')) return 'ja';
    if (l.startsWith('ko')) return 'ko';
    if (l.startsWith('en')) return 'en';
  }
  // 其他語言一律英文(同 App)
  return 'en';
}

/** 依目前語言的文字。字串表裡找不到就顯示繁中原文。單複數分開翻的,第一個參數是 1 時用「鍵#one」那一句。佔位符照 iOS:%lld、%@、%1$@。 */
function t(key, ...args) {
  const pattern = (args[0] === 1 && STRINGS[key + '#one']) || STRINGS[key] || key;
  let next = 0;
  return pattern.replace(/%(\d+\$)?(?:lld|@|d)/g, (_, pos) => {
    const i = pos ? parseInt(pos, 10) - 1 : next++;
    return args[i] === undefined ? '' : String(args[i]);
  });
}

const localeTag = () => ({ 'zh-Hant': 'zh-TW', 'zh-Hans': 'zh-CN', en: 'en', ja: 'ja', ko: 'ko' }[LANG]);
function dateText(iso) {
  const day = epochDay(iso);
  if (day === null) return iso;
  return new Intl.DateTimeFormat(localeTag(), { dateStyle: 'medium', timeZone: 'UTC' }).format(new Date(day * 86400000));
}
function dateTimeText(iso) {
  const d = new Date(iso);
  return isNaN(d) ? '' : new Intl.DateTimeFormat(localeTag(), { dateStyle: 'medium', timeStyle: 'short' }).format(d);
}

// MARK: - 畫元素

function h(tag, props, ...kids) {
  const el = document.createElement(tag);
  for (const [k, v] of Object.entries(props || {})) {
    if (v === null || v === undefined || v === false) continue;
    if (k === 'class') el.className = v;
    else if (k === 'text') el.textContent = v;
    // 樣式一律走 CSSOM:CSP 不允許 style 屬性(`style-src 'self'`)
    else if (k === 'style') Object.assign(el.style, v);
    else if (k.startsWith('on')) el.addEventListener(k.slice(2), v);
    else if (k === 'html') el.innerHTML = v;
    else el.setAttribute(k, v === true ? '' : v);
  }
  for (const kid of kids.flat(Infinity)) {
    if (kid === null || kid === undefined || kid === false) continue;
    el.append(kid instanceof Node ? kid : document.createTextNode(String(kid)));
  }
  return el;
}

/** 共用圖示(icons/ui 的 Fluent,`icons.js` 由 Tools/civil-web/build.py 產生)。裝飾用,意思一律有字。 */
function icon(name, cls = '') {
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('viewBox', '0 0 24 24');
  svg.setAttribute('aria-hidden', 'true');
  svg.setAttribute('class', 'icon ' + cls);
  if (!ICONS[name]) console.warn('[civil] 沒有這個圖示', name);
  svg.innerHTML = ICONS[name] || '';
  return svg;
}

const card = (...rows) => h('div', { class: 'card' }, rows);
const sectionHeader = (text) => h('h2', { class: 'section-header' }, text);
const footer = (text) => h('p', { class: 'footer' }, text);

/** 一列:圖示、標題、說明、右邊的值,點了到別頁。 */
function entryRow({ iconName, iconClass = '', title, subtitle, value, to, href, external }) {
  // 右邊的值(「已備妥 3／28」)放在說明下面一行:手機寬度放在右邊會把標題擠成兩三行
  const inner = [
    iconName ? h('span', { class: 'row-icon ' + iconClass }, icon(iconName)) : null,
    h('span', { class: 'row-text' }, h('span', { class: 'row-title' }, title), subtitle ? h('span', { class: 'row-sub' }, subtitle) : null,
      value ? h('span', { class: 'row-sub strong' }, value) : null),
    icon(external ? 'civil_open' : 'forward', 'row-chevron'),
  ];
  if (href) return h('a', { class: 'row link-row', href, target: '_blank', rel: 'noopener' }, inner);
  return h('a', { class: 'row link-row', href: '#' + to, onclick: (e) => { e.preventDefault(); go(to); } }, inner);
}

/** 按鈕。cls 帶 disabled 就按不動(已滿、今天已檢查)。 */
function button(label, onclick, cls = '') {
  const disabled = /\bdisabled\b/.test(cls);
  return h('button', { class: 'btn ' + cls.replace(/\bdisabled\b/, '').trim(), type: 'button', onclick, disabled }, label);
}

// MARK: - 導覽

let depth = 0;
const scrollMemory = new Map();
const currentRoute = () => (location.hash.replace(/^#/, '') || '/');

function go(to) {
  scrollMemory.set(currentRoute(), window.scrollY);
  depth += 1;
  history.pushState({ d: depth }, '', '#' + to);
  render({ top: true });
}

/** 上一頁:這次開網頁之後走進來的就退回去;直接開某一頁的網址(沒有上一頁)就到它的上一層。 */
function back() {
  if (depth > 0) { history.back(); return; }
  history.replaceState({ d: 0 }, '', '#' + parentOf(currentRoute()));
  render({ top: true });
}

function parentOf(route) {
  const parts = route.split('/').filter(Boolean);
  switch (parts[0]) {
    case 'item': return '/supplies/' + parts[1];
    case 'shot': return '/place/' + parts[1];
    case 'place': return '/shelters';
    case 'disaster': return '/disasters';
    case 'firstaid': return parts[1] ? '/firstaid' : '/';
    default: return '/';
  }
}

window.addEventListener('popstate', (e) => {
  depth = e.state?.d ?? 0;
  render({ restore: true });
});

// MARK: - 警報播放

const Player = {
  audio: null,
  playing: null,
  failed: false,
  raf: 0,
  toggle(alarm) {
    if (this.playing === alarm) { this.stop(); render(); return; }
    this.stop();
    this.failed = false;
    const audio = new Audio('sounds/' + AlarmInfo[alarm].file);
    this.audio = audio;
    this.playing = alarm;
    audio.addEventListener('ended', () => { if (this.audio === audio) { this.stop(); render(); } });
    audio.play().then(() => this.tick()).catch(() => {
      if (this.audio !== audio) return;
      this.stop();
      this.failed = true;
      render();
    });
    render();
  },
  stop() {
    cancelAnimationFrame(this.raf);
    if (this.audio) { this.audio.pause(); this.audio.src = ''; }
    this.audio = null;
    this.playing = null;
  },
  /** 節奏圖上的進度線:照音檔長度等比例對上去(同 App)。 */
  tick() {
    const a = this.audio;
    if (!a) return;
    const bar = document.querySelector(`[data-alarm-progress="${this.playing}"]`);
    if (bar && a.duration > 0) bar.style.left = Math.min(100, (a.currentTime / a.duration) * 100) + '%';
    this.raf = requestAnimationFrame(() => this.tick());
  },
};

// 離開這一頁(切到別的 App、鎖螢幕)就停:沒人看著的時候響警報,旁人會以為是真的。
document.addEventListener('visibilitychange', () => {
  if (document.hidden && Player.playing) { Player.stop(); render(); }
});

function alarmNotice() {
  return h('div', { class: 'notice' },
    icon('civil_info', 'notice-icon'),
    h('p', {}, t('播放的是官方網站上的錄音，音量可能很大；手機靜音時可能沒有聲音。請留意身邊的人，以免被誤會成真的警報。')),
    Player.failed ? h('p', { class: 'notice-error' }, t('現在無法播放這段錄音，請稍後再試。')) : null);
}

function alarmCard(alarm, withActions) {
  const playing = Player.playing === alarm;
  const pattern = alarmPattern(alarm);
  const total = alarmSeconds(alarm);
  const bar = h('div', { class: 'pattern', 'aria-hidden': 'true' },
    pattern.map((seg) => h('span', { class: 'seg seg-' + seg.kind, style: { flexGrow: String(seg.s) } })),
    playing ? h('span', { class: 'pattern-progress', 'data-alarm-progress': alarm }) : null);
  const legend = h('div', { class: 'legend' },
    h('span', {}, h('i', { class: 'swatch seg-tone' }), t('響')),
    h('span', {}, h('i', { class: 'swatch seg-pause' }), t('停')),
    pattern.some((s) => s.kind === 'voice') ? h('span', {}, h('i', { class: 'swatch seg-voice' }), t('語音廣播')) : null);
  const playLabel = playing ? t('停止%@', alarmTitle(alarm)) : t('播放%@', alarmTitle(alarm));
  return h('div', { class: 'alarm' + (playing ? ' is-playing' : '') },
    h('div', { class: 'alarm-head' },
      h('span', { class: 'row-icon tint-civil' }, icon(AlarmInfo[alarm].icon)),
      h('span', { class: 'row-text' }, h('span', { class: 'row-title' }, alarmTitle(alarm)), h('span', { class: 'row-sub' }, t('長約 %lld 秒', Math.round(total)))),
      h('button', { class: 'btn play' + (playing ? ' stop' : ''), type: 'button', 'aria-label': playLabel, onclick: () => Player.toggle(alarm) },
        playing ? t('停止') : t('播放'))),
    bar, legend,
    h('p', { class: 'alarm-rule' }, alarmRule(alarm)),
    withActions ? h('details', { class: 'alarm-actions' },
      h('summary', {}, t('聽到時怎麼做')),
      h('ol', {}, alarmActions(alarm).map((line) => h('li', {}, line)))) : null);
}

// MARK: - 每一頁的外框

function page(title, content, { home = false } = {}) {
  return [
    h('header', { class: 'bar' },
      home ? null : h('button', { class: 'back', type: 'button', onclick: back }, icon('back'), t('返回')),
      h('h1', {}, title)),
    h('main', { class: 'content' }, content),
  ];
}

function attributionFooter() {
  return h('div', { class: 'attribution' }, attribution().map((line) => h('p', {}, line)));
}

// MARK: - 首頁

/** 加到主畫面:沒加之前 Safari 七天沒打開就可能清掉資料,也只有加了才保證離線打得開。 */
let installEvent = null;
window.addEventListener('beforeinstallprompt', (e) => { e.preventDefault(); installEvent = e; render(); });
window.addEventListener('appinstalled', () => { installEvent = null; render(); });

const isStandalone = () => matchMedia('(display-mode: standalone)').matches || navigator.standalone === true;
const isAppleMobile = () => /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);

function installCard() {
  if (isStandalone()) return null;
  // iPhone、iPad:App 裡本來就有民防準備,而且比網頁完整(靜音也能播警報、地圖在 App 裡直接存)——先推薦 App,
  // 不想裝的人照樣能用網頁。網頁主要是給 Android(Play 版拿掉了民防準備)與沒裝 App 的人。不擋任何人(2026-11-20 使用者「照建議」)。
  const apple = isAppleMobile();
  const how = installEvent
    ? button(t('加到主畫面'), async () => { const e = installEvent; installEvent = null; await e.prompt().catch(() => {}); render(); }, apple ? 'wide' : 'primary wide')
    : h('p', {}, apple ? t('在 Safari 按「分享」（可能在「⋯」裡面），再選「加入主畫面」。') : t('用瀏覽器選單的「加到主畫面」或「安裝」。'));
  return h('div', { class: 'install' },
    apple ? [
      h('div', { class: 'install-title' }, icon('civil_add_circle'), t('Vigatamala App 裡就有民防準備')),
      h('p', {}, t('App 版功能比較完整：手機靜音時也能播警報，避難地圖可以在 App 裡直接存下來。')),
      h('a', { class: 'btn primary wide install-app', href: CivilLinks.vigatamalaApp, target: '_blank', rel: 'noopener' }, t('到 App Store 下載')),
      h('p', { class: 'install-or' }, t('不想裝 App，也可以把這一頁加到主畫面，沒有網路也能打開：')),
    ] : h('div', { class: 'install-title' }, icon('civil_add_circle'), t('加到主畫面，沒有網路也能打開')),
    how,
    apple ? h('p', { class: 'install-warn' }, t('還沒加到主畫面時，如果你用 Safari 七天都沒打開這一頁，Safari 可能清掉你在這裡記錄的資料。')) : null);
}

function expirySection() {
  const today = todayISO();
  const list = Store.checklist;
  const alerts = list.alerts(today);
  const unchecked = list.checkOverdue(today);
  if (!alerts.length && !unchecked.length) return null;
  const expired = alerts.filter((a) => a.daysLeft < 0).length;
  const soon = alerts.length - expired;
  const rows = [
    ...alerts.map((a) => h('a', { class: 'row link-row', href: `#/item/${a.kit}/${encodeURIComponent(a.id)}`, onclick: (e) => { e.preventDefault(); go(`/item/${a.kit}/${encodeURIComponent(a.id)}`); } },
      h('span', { class: 'row-icon ' + (a.daysLeft < 0 ? 'tint-red' : 'tint-orange') }, icon(a.daysLeft < 0 ? 'civil_warning' : 'civil_clock')),
      h('span', { class: 'row-text' }, h('span', { class: 'row-title strong' }, list.title(a.kit, a.id)), h('span', { class: 'row-sub' }, kitTitle(a.kit) + ' · ' + dateText(a.expires))),
      h('span', { class: 'row-value strong ' + (a.daysLeft < 0 ? 'tint-red' : 'tint-orange') }, expiryStatus(a.daysLeft)),
      icon('forward', 'row-chevron'))),
    ...unchecked.map((kit) => entryRow({ iconName: 'civil_check_due', iconClass: 'tint-orange', title: t('%@已超過半年沒檢查', kitTitle(kit)), to: '/supplies/' + kit })),
  ];
  return h('div', { class: 'expiry' + (expired ? ' has-expired' : '') },
    h('div', { class: 'expiry-counts' },
      expired ? h('p', { class: 'tint-red' }, icon('civil_expired'), t('%lld 項已過期', expired)) : null,
      soon ? h('p', { class: 'tint-orange' }, icon('civil_soon'), t('%lld 項 30 天內到期', soon)) : null),
    card(rows));
}

function officialApp(title, subtitle, iconName, links) {
  return h('div', { class: 'row app-row' },
    h('span', { class: 'row-icon tint-civil' }, icon(iconName)),
    h('span', { class: 'row-text' }, h('span', { class: 'row-title' }, title), h('span', { class: 'row-sub' }, subtitle),
      h('span', { class: 'store-links' },
        h('a', { class: 'btn small', href: links.ios, target: '_blank', rel: 'noopener' }, 'App Store'),
        h('a', { class: 'btn small', href: links.android, target: '_blank', rel: 'noopener' }, 'Google Play'))));
}

function homePage() {
  const list = Store.checklist;
  return page(t('民防準備'), [
    Store.saveFailed ? h('div', { class: 'notice error' }, h('p', {}, t('剛才的變更沒有存到這個瀏覽器（可能是私密瀏覽，或空間不夠）。'))) : null,
    installCard(),
    expirySection(),
    card(entryRow({ iconName: 'civil_speaker', iconClass: 'tint-civil', title: t('警報聲'), subtitle: t('官方錄音，先熟悉每一種警報'), to: '/alarms' })),
    sectionHeader(t('物資清單')),
    card(SupplyKits.map((kit) => {
      const [ready, total] = list.readyCount(kit);
      return entryRow({ iconName: KitIcon[kit], iconClass: 'tint-civil', title: kitTitle(kit), subtitle: kitSubtitle(kit), value: t('已備妥 %lld／%lld', ready, total), to: '/supplies/' + kit });
    })),
    h('div', { class: 'gap' }),
    card(entryRow({ iconName: 'civil_map', iconClass: 'tint-civil', title: t('避難地圖'), subtitle: t('存下官方地圖的畫面，沒有網路也能看'), to: '/shelters' })),
    sectionHeader(t('自救知識')),
    card(
      entryRow({ iconName: 'civil_warning', iconClass: 'tint-civil', title: t('災害應對'), subtitle: t('空襲、軍事侵略、地震、颱風等八種災害'), to: '/disasters' }),
      entryRow({ iconName: 'civil_first_aid', iconClass: 'tint-civil', title: t('傷患處理'), subtitle: t('燒燙傷、止血、搬運傷患、CPR 與 AED'), to: '/firstaid' }),
      ['misinformation', 'mental'].map((p) => entryRow({ iconName: GuidePages[p], iconClass: 'tint-civil', title: guideTitle(p), subtitle: guideSubtitle(p), to: '/guide/' + p }))),
    sectionHeader(t('緊急聯絡')),
    card(
      entryRow({ iconName: 'civil_phone', iconClass: 'tint-civil', title: t('緊急專線'), subtitle: t('110、119、112 等，點一下就撥號'), to: '/hotlines' }),
      entryRow({ iconName: 'civil_people', iconClass: 'tint-civil', title: t('家人會合地點'), subtitle: t('通訊中斷時在哪裡碰面、要聯絡誰'), to: '/family' })),
    sectionHeader(t('官方防災 App')),
    card(
      officialApp(t('消防署防災 App'), t('避難收容處所、救濟站、物資配售站的位置與即時警報'), 'civil_fire', CivilLinks.fireAgencyApp),
      officialApp(t('警政署 App'), t('防空避難所的位置與即時警報'), 'civil_shield', CivilLinks.policeApp)),
    sectionHeader(t('更多')),
    card(
      entryRow({ iconName: GuidePages.contribute, iconClass: 'tint-civil', title: guideTitle('contribute'), subtitle: guideSubtitle('contribute'), to: '/guide/contribute' }),
      entryRow({ iconName: 'civil_book', iconClass: 'tint-civil', title: t('手冊 PDF'), subtitle: t('在官方網站下載（中文、英文、泰文）'), href: CivilLinks.manualDownloads, external: true }),
      entryRow({ iconName: 'globe', iconClass: 'tint-civil', title: t('官方網站'), subtitle: 'prepare.mnd.gov.tw', href: CivilLinks.officialSite, external: true })),
    attributionFooter(),
    aboutFooter(),
  ], { home: true });
}

/** 首頁最下面:這個網頁存了什麼、語言。 */
function aboutFooter() {
  const select = h('select', { id: 'lang', onchange: async (e) => { await setLang(e.target.value); render(); } },
    Langs.map(([code, name]) => h('option', { value: code, selected: code === LANG }, name)));
  return h('div', { class: 'about' },
    h('p', {}, t('你在這裡記錄的物資、會合地點與截圖，只存在這個瀏覽器裡，不會上傳。這個網站不使用 Cookie，也沒有統計或廣告程式；跟一般網站一樣，網站主機會收到連線的 IP 位址。')),
    offlineReady ? h('p', { class: 'offline-ok' }, icon('civil_all_clear'), t('這一頁已經存在這支手機上，沒有網路也能打開。')) : null,
    h('label', { class: 'lang' }, t('語言'), select));
}

// MARK: - 警報聲

function alarmsPage() {
  return page(t('警報聲'), [
    alarmNotice(),
    CivilAlarms.map((alarm) => h('div', { class: 'card pad' }, alarmCard(alarm, true))),
    attributionFooter(),
  ]);
}

// MARK: - 物資清單

function supplyItemRow(kit, id) {
  const list = Store.checklist;
  const state = list.state(kit, id);
  const title = list.title(kit, id);
  const earliest = list.earliest(kit, id);
  const detail = list.isCustom(kit, id) ? null : templateDetail(id, kit);
  const to = `/item/${kit}/${encodeURIComponent(id)}`;
  return h('div', { class: 'row supply-row' },
    // 勾選與點進去是兩個動作:左邊這一格只切換「已備妥」,其餘整列開品項頁。
    h('button', {
      class: 'check' + (state.isReady ? ' on' : ''), type: 'button', role: 'checkbox', 'aria-checked': String(state.isReady), 'aria-label': title,
      onclick: () => { list.setReady(kit, id, !state.isReady); Store.saveChecklist(); render(); },
    }, icon(state.isReady ? 'selected' : 'civil_circle')),
    h('a', { class: 'supply-link', href: '#' + to, onclick: (e) => { e.preventDefault(); go(to); } },
      h('span', { class: 'row-text' }, h('span', { class: 'row-title' }, title), detail ? h('span', { class: 'row-sub' }, detail) : null),
      earliest ? expiryBadge(earliest) : null,
      icon('forward', 'row-chevron')));
}

function expiryBadge(day) {
  const left = daysLeft(todayISO(), day);
  const soon = left <= Limits.soonWindow;
  return h('span', { class: 'row-value badge ' + (left < 0 ? 'tint-red strong' : soon ? 'tint-orange strong' : '') }, soon ? expiryStatus(left) : dateText(day));
}

function addInput(placeholder, label, onAdd, max) {
  const input = h('input', { type: 'text', placeholder, maxlength: max, 'aria-label': placeholder,
    onkeydown: (e) => { if (e.key === 'Enter' && !e.isComposing) { e.preventDefault(); submit(); } } });
  function submit() { if (input.value.trim()) onAdd(input.value); }
  return h('div', { class: 'row add-row' }, input, button(label, submit, 'primary'));
}

function suppliesPage(kit) {
  if (!SupplyKits.includes(kit)) return notFound();
  const list = Store.checklist;
  const record = list.record(kit);
  const today = todayISO();
  const overdue = list.checkOverdue(today).includes(kit);
  const sections = SupplySections.map((s) => {
    const ids = s === 'custom' ? record.custom.map((c) => c.id) : (SupplyTemplates[kit].find(([name]) => name === s)?.[1] || []);
    if (!ids.length && s !== 'custom') return null;
    return [
      sectionHeader(sectionTitle(s)),
      card(ids.map((id) => supplyItemRow(kit, id)),
        s === 'custom' ? addInput(t('品項名稱'), t('加入'), (name) => { list.addCustom(kit, name); Store.saveChecklist(); render(); }, Limits.customName) : null),
      s === 'custom' ? footer(t('例如暖暖包、奶粉、其他照護對象需要的用品；一樣可以記有效期限。')) : null,
    ];
  });
  return page(kitTitle(kit), [
    card(
      kitPrinciples(kit).map((line) => h('div', { class: 'row principle' }, icon('civil_principle', 'tint-civil'), h('span', {}, line))),
      h('div', { class: 'row check-row' },
        h('span', { class: 'row-text' },
          h('span', { class: 'row-title small' }, record.lastChecked ? t('上次檢查：%@', dateText(record.lastChecked)) : t('還沒有檢查紀錄')),
          overdue ? h('span', { class: 'row-sub tint-orange' }, t('已超過半年，該檢查了')) : null,
          h('span', { class: 'row-sub' }, t('建議每半年檢查一次'))),
        h('button', { class: 'btn', type: 'button', disabled: record.lastChecked === today,
          onclick: () => { list.markChecked(kit, today); Store.saveChecklist(); render(); } }, t('檢查完成')))),
    sections,
    attributionFooter(),
  ]);
}

function quantityText(q) { return q > 0 ? t('數量：%lld', q) : t('不記數量'); }

function stepper(value, onChange) {
  return h('span', { class: 'stepper' },
    h('button', { type: 'button', class: 'btn step', 'aria-label': '−', disabled: value <= 0, onclick: () => onChange(value - 1) }, '−'),
    h('button', { type: 'button', class: 'btn step', 'aria-label': '+', onclick: () => onChange(value + 1) }, '+'));
}

let draftBatch = { key: '', expires: '', quantity: 0 };

function itemPage(kit, rawID) {
  const id = decodeURIComponent(rawID || '');
  const list = Store.checklist;
  if (!SupplyKits.includes(kit)) return notFound();
  if (!list.has(kit, id)) return page('', [h('p', { class: 'empty' }, t('這個品項已經移除了。'))]);
  const state = list.state(kit, id);
  const key = kit + '/' + id;
  if (draftBatch.key !== key) draftBatch = { key, expires: todayISO(), quantity: 0 };
  const detail = list.isCustom(kit, id) ? null : templateDetail(id, kit);
  const full = state.batches.length >= Limits.batches;
  const save = () => { Store.saveChecklist(); render(); };
  const dateInput = (value, onChange) => h('input', { type: 'date', class: 'date', value, 'aria-label': t('有效期限'),
    onchange: (e) => { if (isISODate(e.target.value)) onChange(e.target.value); } });
  return page(list.title(kit, id), [
    card(
      detail ? h('div', { class: 'row' }, h('span', { class: 'row-sub big' }, detail)) : null,
      h('label', { class: 'row toggle-row' },
        h('span', { class: 'row-title' }, t('已備妥')),
        h('input', { type: 'checkbox', class: 'switch', checked: state.isReady, onchange: (e) => { list.setReady(kit, id, e.target.checked); save(); } }))),
    footer(kitTitle(kit)),
    sectionHeader(t('有效期限')),
    card(
      state.batches.length ? null : h('div', { class: 'row' }, h('span', { class: 'row-sub big' }, t('還沒有記有效期限'))),
      state.batches.map((b) => h('div', { class: 'row batch' },
        h('div', { class: 'batch-line' },
          dateInput(b.expires, (day) => { list.updateBatch(kit, id, { ...b, expires: day }); save(); }),
          daysLeft(todayISO(), b.expires) <= Limits.soonWindow ? expiryBadge(b.expires) : null),
        h('div', { class: 'batch-line' },
          h('span', { class: 'row-sub' }, quantityText(b.quantity || 0)),
          stepper(b.quantity || 0, (q) => { list.updateBatch(kit, id, { ...b, quantity: q > 0 ? q : undefined }); save(); }),
          button(t('移除'), () => { list.removeBatch(kit, id, b.id); save(); }, 'danger'))))),
    footer(t('已過期或 30 天內到期的，會在「民防準備」最上方提示。同一個品項可以記好幾批，例如不同時間買的水。')),
    sectionHeader(t('新增一批')),
    card(
      h('div', { class: 'row' }, h('span', { class: 'row-title' }, t('有效期限')), dateInput(draftBatch.expires, (day) => { draftBatch.expires = day; })),
      h('div', { class: 'row' }, h('span', { class: 'row-title' }, quantityText(draftBatch.quantity)), stepper(draftBatch.quantity, (q) => { draftBatch.quantity = q; render(); })),
      h('div', { class: 'row' }, button(t('加入這一批'), () => {
        if (list.addBatch(kit, id, draftBatch.expires, draftBatch.quantity)) { draftBatch.quantity = 0; save(); }
      }, 'primary wide' + (full ? ' disabled' : '')))),
    list.isCustom(kit, id) ? h('div', { class: 'gap' }) : null,
    list.isCustom(kit, id) ? card(h('div', { class: 'row' }, button(t('移除這個品項'), () => {
      if (!confirm(t('要移除「%@」和它記的有效期限嗎？', list.title(kit, id)))) return;
      list.removeCustom(kit, id);
      Store.saveChecklist();
      back();
    }, 'danger wide'))) : null,
  ]);
}

// MARK: - 避難地圖

const shotURLs = new Map();
async function shotURL(id) {
  if (shotURLs.has(id)) return shotURLs.get(id);
  const blob = await ShotDB.get(id).catch(() => null);
  const url = blob ? URL.createObjectURL(blob) : null;
  if (url) shotURLs.set(id, url);
  return url;
}
function shotImage(id, alt, cls) {
  const img = h('img', { class: cls, alt, decoding: 'async' });
  shotURL(id).then((url) => { if (url) img.src = url; else img.replaceWith(h('div', { class: cls + ' missing' }, t('這張畫面已經刪除了。'))); });
  return img;
}

function sheltersPage() {
  const list = Store.places;
  const addPlace = (name) => { const id = list.add(name); Store.savePlaces(); if (id) go('/place/' + id); else render(); };
  return page(t('避難地圖'), [
    h('p', { class: 'intro' }, t('在官方地圖上找到住家、公司等地方附近的避難處所，把畫面存下來；沒有網路時也能看。警政署也建議預先存下生活圈附近的避難處所。')),
    list.places.length ? [
      sectionHeader(t('我的地方')),
      card(list.places.map((p) => entryRow({
        iconName: p.snapshots.length ? 'civil_map' : 'civil_location', iconClass: 'tint-civil', title: p.name,
        subtitle: p.snapshots.length ? t('%lld 張畫面', p.snapshots.length) : t('還沒有存下的畫面'), to: '/place/' + p.id,
      }))),
    ] : [
      sectionHeader(t('先加一個地方')),
      h('div', { class: 'chips' }, [t('住家'), t('公司'), t('學校')].map((name) => button(name, () => addPlace(name), 'chip'))),
    ],
    sectionHeader(t('新增地方')),
    card(addInput(t('例如：住家、公司、學校'), t('加入'), addPlace, Limits.placeName)),
    attributionFooter(),
  ]);
}

let renamingPlace = null;

function placePage(placeID) {
  const list = Store.places;
  const place = list.place(placeID);
  if (!place) return page('', [h('p', { class: 'empty' }, t('這個地方已經刪除了。'))]);
  const canAdd = list.canAddSnapshot(placeID);
  const fileInput = h('input', { type: 'file', accept: 'image/*', multiple: true, hidden: true, onchange: async (e) => {
    const files = Array.from(e.target.files || []);
    e.target.value = '';
    let failed = false;
    for (const file of files) {
      if (!list.canAddSnapshot(placeID)) break;
      try {
        const blob = await shrinkImage(file);
        const shot = { id: uuid(), takenAt: new Date().toISOString() };
        await ShotDB.put(shot.id, blob);
        list.addSnapshot(placeID, shot);
        Store.savePlaces();
      } catch { failed = true; }
    }
    placeMessage = failed ? 'failed' : null;
    render();
  } });
  const nameRow = renamingPlace === placeID
    ? card(addInput(t('名稱'), t('儲存'), (name) => { if (list.rename(placeID, name)) { Store.savePlaces(); renamingPlace = null; render(); } }, Limits.placeName))
    : null;
  return page(place.name, [
    nameRow,
    sectionHeader(t('開啟官方地圖')),
    card(Object.keys(ShelterSources).map((s) => entryRow({ iconName: ShelterSources[s].icon, iconClass: 'tint-civil', title: shelterTitle(s), subtitle: shelterSubtitle(s), href: ShelterSources[s].url, external: true }))),
    footer(t('在官方地圖找到這個地方附近的避難處所，用手機截圖，再回到這裡按「加入截圖」。開地圖需要網路；存下的畫面不需要。')),
    h('div', { class: 'gap' }),
    card(h('div', { class: 'row' }, fileInput, button(t('加入截圖'), () => fileInput.click(), 'primary wide' + (canAdd ? '' : ' disabled')))),
    placeMessage === 'failed' ? footer(t('存不下來，請再試一次。')) : null,
    canAdd ? null : footer(t('每個地方最多存 %lld 張，請先刪掉舊的畫面。', Limits.snapshots)),
    sectionHeader(t('存下的畫面')),
    place.snapshots.length
      ? h('div', { class: 'shots' }, place.snapshots.map((s) => h('a', { class: 'shot', href: `#/shot/${placeID}/${s.id}`, onclick: (e) => { e.preventDefault(); go(`/shot/${placeID}/${s.id}`); } },
        shotImage(s.id, t('%@的避難地圖', place.name), 'shot-thumb'), h('span', {}, dateTimeText(s.takenAt)))))
      : card(h('div', { class: 'row' }, h('span', { class: 'row-sub big' }, t('還沒有存下的畫面')))),
    h('div', { class: 'gap' }),
    card(
      h('div', { class: 'row' }, button(t('改名'), () => { renamingPlace = renamingPlace === placeID ? null : placeID; render(); }, 'wide')),
      h('div', { class: 'row' }, button(t('刪除這個地方'), async () => {
        if (!confirm(t('刪除「%@」和存下的 %lld 張畫面？', place.name, place.snapshots.length))) return;
        for (const s of place.snapshots) await ShotDB.remove(s.id).catch(() => {});
        list.remove(placeID);
        Store.savePlaces();
        back();
      }, 'danger wide'))),
  ]);
}
let placeMessage = null;

function shotPage(placeID, shotID) {
  const place = Store.places.place(placeID);
  const shot = place?.snapshots.find((s) => s.id === shotID);
  if (!place || !shot) return page('', [h('p', { class: 'empty' }, t('這張畫面已經刪除了。'))]);
  return page(place.name, [
    h('p', { class: 'row-sub center' }, dateTimeText(shot.takenAt)),
    h('div', { class: 'shot-full' }, shotImage(shot.id, t('%@的避難地圖', place.name), 'shot-image')),
    h('div', { class: 'gap' }),
    card(h('div', { class: 'row' }, button(t('刪除這張畫面'), async () => {
      if (!confirm(t('刪除這張畫面？'))) return;
      await ShotDB.remove(shot.id).catch(() => {});
      Store.places.removeSnapshot(placeID, shot.id);
      Store.savePlaces();
      back();
    }, 'danger wide'))),
  ]);
}

// MARK: - 指引

function guideBlock(block) {
  switch (block.kind) {
    case 'text': return h('p', { class: 'block-text' }, block.text);
    case 'bullets': return h('ul', { class: 'block-list' }, block.items.map((x) => h('li', {}, x)));
    case 'steps': return h('ol', { class: 'block-list' }, block.items.map((x) => h('li', {}, x)));
    case 'terms': return h('dl', { class: 'terms' }, block.pairs.map(([term, text]) => [h('dt', {}, term), h('dd', {}, text)]));
    case 'group': return h('div', { class: 'group' },
      h('p', { class: 'group-title' }, block.title),
      block.subtitle ? h('p', { class: 'group-sub' }, block.subtitle) : null,
      h('ul', { class: 'block-list' }, block.items.map((x) => h('li', {}, x))));
    case 'warning': return h('p', { class: 'warning' }, icon('civil_warning'), h('span', {}, block.text));
    case 'alarm': return alarmCard(block.alarm, false);
    case 'supplies': return entryRow({ iconName: KitIcon[block.kit], iconClass: 'tint-civil', title: kitTitle(block.kit), to: '/supplies/' + block.kit });
    case 'shelterMaps': return entryRow({ iconName: 'civil_map', iconClass: 'tint-civil', title: t('我存下的避難地圖'), to: '/shelters' });
    case 'radio': return h('div', { class: 'radio' }, WartimeRadio.map(([id, freqs]) => h('div', {},
      h('p', { class: 'group-title' }, radioRegionTitle(id)),
      // 不換行空格:「FM」和數字不能拆到兩行。
      h('p', {}, freqs.map((f) => f.replace(' ', ' ')).join('、')))));
    case 'hotline': return hotlineRow(block.id);
    case 'link': return entryRow({ title: block.title, href: block.url, external: true });
    case 'page': return entryRow({ iconName: GuidePages[block.page], iconClass: 'tint-civil', title: guideTitle(block.page), to: '/guide/' + block.page });
  }
  return null;
}

function guidePage(title, sections, extraFooter) {
  const hasAlarm = sections.some((s) => s.blocks.some((b) => b.kind === 'alarm'));
  const steps = sections.filter((s) => s.isStep);
  return page(title, [
    hasAlarm ? alarmNotice() : null,
    sections.map((s) => {
      const n = steps.indexOf(s);
      return [
        s.title ? h('h2', { class: 'guide-title' }, n >= 0 ? `${n + 1}. ${s.title}` : s.title) : h('div', { class: 'gap' }),
        h('div', { class: 'card guide' }, s.blocks.map(guideBlock)),
      ];
    }),
    extraFooter,
    attributionFooter(),
  ]);
}

function disastersPage() {
  return page(t('災害應對'), [
    card(Disasters.map((d) => h('a', { class: 'row link-row', href: '#/disaster/' + d, onclick: (e) => { e.preventDefault(); go('/disaster/' + d); } },
      h('span', { class: 'row-icon tint-civil' }, icon(DisasterIcon[d])),
      h('span', { class: 'row-text' }, h('span', { class: 'row-title' }, disasterTitle(d)), DisasterAlarms[d] ? h('span', { class: 'row-sub' }, t('有警報聲')) : null),
      icon('forward', 'row-chevron')))),
    footer(t('認識不同災害的應對原則，從你最關心的災害開始。')),
    attributionFooter(),
  ]);
}

function firstAidListPage() {
  return page(t('傷患處理'), [
    card(FirstAids.map((f) => entryRow({ iconName: FirstAidIcon[f], iconClass: 'tint-civil', title: firstAidTitle(f), to: '/firstaid/' + f }))),
    footer(t('災難發生時，每個人都可能受傷。先認識各種傷患處理的原則。')),
    card(entryRow({ title: t('參加防災士課程，完整培訓'), href: CivilLinks.firstAidCourse, external: true })),
    attributionFooter(),
  ]);
}

// MARK: - 緊急專線

function hotlineRow(id) {
  const number = Hotlines.find(([x]) => x === id)?.[1] || '';
  const title = hotlineTitle(id);
  return h('a', { class: 'row hotline', href: dialURL(number), 'aria-label': t('撥打%@ %@', title, number) },
    h('span', { class: 'row-title' }, title),
    h('span', { class: 'hotline-number' }, number),
    h('span', { class: 'row-icon tint-green' }, icon('civil_phone')));
}

function hotlinesPage() {
  return page(t('緊急專線'), [
    card(Hotlines.map(([id]) => hotlineRow(id))),
    footer(t('危機發生時，專線可能癱瘓或服務調整；遇到這種情況，請到附近派出所、村里辦公室取得正確訊息。')),
  ]);
}

// MARK: - 家人會合地點

let familyMessage = '';

/** 分享用的純文字(可以列印、傳訊息給家人)。 */
function familySummary(plan) {
  const lines = [t('緊急會合地點')];
  plan.meetingPoints.forEach((p, i) => { if (p) lines.push(`${i + 1}. ${p}`); });
  if (plan.contacts.length) {
    lines.push('', t('重要親友'));
    for (const c of plan.contacts) lines.push([c.name, c.phone, c.note].filter(Boolean).join('　'));
  }
  return lines.join('\n');
}

function familyPage() {
  const plan = Store.family;
  const field = (value, placeholder, onInput, type = 'text') => h('input', { type, value, placeholder, 'aria-label': placeholder, maxlength: Limits.text,
    oninput: (e) => { onInput(e.target.value); Store.saveFamily(); } });
  const share = async () => {
    const text = familySummary(plan.trimmed());
    try {
      if (navigator.share) { await navigator.share({ text }); return; }
    } catch (e) { if (e?.name === 'AbortError') return; }
    try { await navigator.clipboard.writeText(text); familyMessage = t('已複製，可以貼到訊息或記事。'); } catch { familyMessage = ''; }
    render();
  };
  return page(t('家人會合地點'), [
    sectionHeader(t('緊急會合地點')),
    card(plan.meetingPoints.map((p, i) => h('div', { class: 'row' }, field(p, t('會合地點 %lld', i + 1), (v) => { plan.meetingPoints[i] = v; })))),
    footer(t('和家人約定：通訊中斷時，到哪裡碰面。')),
    sectionHeader(t('重要親友')),
    card(
      plan.contacts.map((c) => h('div', { class: 'row contact' },
        field(c.name, t('姓名或稱呼'), (v) => { c.name = v; }),
        h('div', { class: 'contact-phone' },
          field(c.phone, t('電話'), (v) => { c.phone = v; }, 'tel'),
          dialURL(c.phone) ? h('a', { class: 'btn dial', href: dialURL(c.phone), 'aria-label': t('撥打電話') }, icon('civil_phone')) : null),
        field(c.note, t('備註'), (v) => { c.note = v; }),
        button(t('移除'), () => { plan.removeContact(c.id); Store.saveFamily(); render(); }, 'danger'))),
      h('div', { class: 'row' }, button(t('新增聯絡人'), () => { plan.addContact(); Store.saveFamily(); render(); }, 'wide' + (plan.contacts.length >= Limits.contacts ? ' disabled' : '')))),
    footer(t('只存在這支手機上。建議也抄一份紙本，放進緊急避難包。')),
    plan.isEmpty ? null : [h('div', { class: 'gap' }), card(h('div', { class: 'row' }, button(t('分享或列印'), share, 'primary wide'))),
      familyMessage ? footer(familyMessage) : null],
  ]);
}

// MARK: - 換頁

function notFound() { return homePage(); }

function routePage(route) {
  const [name, a, b] = route.split('/').filter(Boolean);
  switch (name) {
    case undefined: return homePage();
    case 'alarms': return alarmsPage();
    case 'supplies': return suppliesPage(a);
    case 'item': return itemPage(a, b);
    case 'shelters': return sheltersPage();
    case 'place': return placePage(a);
    case 'shot': return shotPage(a, b);
    case 'disasters': return disastersPage();
    case 'disaster': return Disasters.includes(a) ? guidePage(disasterTitle(a), disasterSections(a)) : notFound();
    case 'firstaid': return a ? (FirstAids.includes(a) ? guidePage(firstAidTitle(a), firstAidSections(a),
      card(entryRow({ title: t('參加防災士課程，完整培訓'), href: CivilLinks.firstAidCourse, external: true }))) : notFound()) : firstAidListPage();
    case 'guide': return GuidePages[a] ? guidePage(guideTitle(a), guideSections(a)) : notFound();
    case 'hotlines': return hotlinesPage();
    case 'family': return familyPage();
  }
  return notFound();
}

let lastRoute = null;

function render({ top = false, restore = false } = {}) {
  const route = currentRoute();
  if (route !== lastRoute) {
    // 換頁:停掉警報,清掉每一頁自己的暫存狀態
    if (Player.playing) Player.stop();
    Player.failed = false;
    if (!route.startsWith('/family')) familyMessage = '';
    if (!route.startsWith('/place')) { placeMessage = null; renamingPlace = null; }
  }
  const sameRoute = route === lastRoute;
  const keep = window.scrollY;
  const root = document.getElementById('app');
  root.replaceChildren(...routePage(route).flat(Infinity).filter(Boolean));
  const title = root.querySelector('h1')?.textContent;
  document.title = title && title !== t('民防準備') ? `${title} · ${t('民防準備')}` : t('民防準備');
  if (sameRoute && !top && !restore) window.scrollTo(0, keep);
  else if (restore && scrollMemory.has(route)) window.scrollTo(0, scrollMemory.get(route));
  else window.scrollTo(0, 0);
  if (Player.playing) Player.tick();
  lastRoute = route;
}

// MARK: - 開始

async function setLang(lang) {
  LANG = lang;
  try { localStorage.setItem('vgm.civil.lang', lang); } catch { /* 沒有 localStorage 就只記這一次 */ }
  document.documentElement.lang = localeTag();
  try {
    const res = await fetch(`strings.${lang}.json`);
    STRINGS = res.ok ? await res.json() : {};
  } catch { STRINGS = {}; }
}

let offlineReady = false;

async function start() {
  await setLang(pickLang());
  history.replaceState({ d: 0 }, '', location.hash || '#/');
  render();
  Store.sweepShots();
  if ('serviceWorker' in navigator) {
    try {
      await navigator.serviceWorker.register('sw.js');
      await navigator.serviceWorker.ready;
      offlineReady = true;
      if (currentRoute() === '/') render();
    } catch { /* 沒有 service worker(例如檔案直接開)就只是不能離線 */ }
  }
  // 請瀏覽器不要在空間不夠時清掉這個網站的資料(加到主畫面的通常會答應)。
  try { await navigator.storage?.persist?.(); } catch { /* 不支援 */ }
}

start();
