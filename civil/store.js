// 「民防準備」離線網頁的資料與規則(照 Android `civil/CivilModels.kt`,它又照 iOS Core `SupplyChecklist`、`ShelterPlaces`)。
//
// 只存在這個瀏覽器裡,不上傳:清單、會合地點、地方的名稱在 localStorage;截圖在 IndexedDB(一張幾百 KB,localStorage 放不下)。
// 存檔的形狀跟 iOS、Android 一樣(`household`/`goBag` → `items`/`custom`/`lastChecked`),之後要做匯入匯出時對得上。
// 有效期限是曆法日(「2027-03-01」),不是某個時刻:用字串存、用 UTC 的日數比,換時區不會差一天。
'use strict';

const Limits = {
  /** 「快到期」:30 天內(含)到期就提示(iOS 2026-10-06 使用者定案)。 */
  soonWindow: 30,
  /** 網站建議每半年檢查一次;超過這個天數沒按「檢查完成」就提醒。 */
  checkInterval: 183,
  customName: 40,
  /** 一個品項最多記幾批。 */
  batches: 20,
  meetingPoints: 3,
  contacts: 20,
  text: 80,
  placeName: 30,
  /** 一個地方最多幾張截圖。 */
  snapshots: 12,
};

// MARK: - 日期

function todayISO() {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
function epochDay(iso) {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso || '');
  if (!m) return null;
  return Math.round(Date.UTC(+m[1], +m[2] - 1, +m[3]) / 86400000);
}
const isISODate = (s) => epochDay(s) !== null;
const daysLeft = (today, day) => epochDay(day) - epochDay(today);
function uuid() {
  if (crypto.randomUUID) return crypto.randomUUID();
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = crypto.getRandomValues(new Uint8Array(1))[0] & 15;
    return (c === 'x' ? r : (r & 3) | 8).toString(16);
  });
}
const clip = (s, n) => Array.from(String(s ?? '')).slice(0, n).join('');

// MARK: - 存檔

const Keys = { supplies: 'vgm.civil.supplies.v1', family: 'vgm.civil.family.v1', places: 'vgm.civil.places.v1' };

function readJSON(key) {
  try { const s = localStorage.getItem(key); return s ? JSON.parse(s) : null; } catch { return null; }
}
/** 寫不進去(私密瀏覽、空間滿了)回 false,畫面要告訴使用者沒存到。 */
function writeJSON(key, value) {
  try { localStorage.setItem(key, JSON.stringify(value)); return true; } catch { return false; }
}

// MARK: - 物資清單

function cleanBatch(b) {
  if (!b || typeof b.id !== 'string' || !b.id || !isISODate(b.expires)) return null;
  const out = { id: b.id, expires: b.expires };
  if (Number.isFinite(b.quantity)) out.quantity = Math.max(1, Math.floor(b.quantity));
  return out;
}
function cleanRecord(r) {
  const items = {};
  for (const [id, s] of Object.entries(r?.items || {})) {
    const batches = (Array.isArray(s?.batches) ? s.batches : []).map(cleanBatch).filter(Boolean);
    const state = { isReady: s?.isReady === true, batches };
    if (state.isReady || batches.length) items[id] = state;
  }
  const custom = (Array.isArray(r?.custom) ? r.custom : [])
    .filter((c) => c && typeof c.id === 'string' && c.id).map((c) => ({ id: c.id, name: String(c.name ?? '') }));
  return { items, custom, lastChecked: isISODate(r?.lastChecked) ? r.lastChecked : null };
}

class Checklist {
  constructor(raw) {
    this.household = cleanRecord(raw?.household);
    this.goBag = cleanRecord(raw?.goBag);
  }
  record(kit) { return kit === 'household' ? this.household : this.goBag; }
  state(kit, id) { return this.record(kit).items[id] || { isReady: false, batches: [] }; }
  templateIDs(kit) { return SupplyTemplates[kit].flatMap(([, ids]) => ids); }
  /** 這份清單現在有哪些品項(網站範本 + 自訂),依顯示順序。 */
  itemIDs(kit) { return [...this.templateIDs(kit), ...this.record(kit).custom.map((c) => c.id)]; }
  has(kit, id) { return this.itemIDs(kit).includes(id); }
  title(kit, id) { return this.record(kit).custom.find((c) => c.id === id)?.name ?? templateTitle(id) ?? id; }
  isCustom(kit, id) { return this.record(kit).custom.some((c) => c.id === id); }
  readyCount(kit) { const ids = this.itemIDs(kit); return [ids.filter((id) => this.state(kit, id).isReady).length, ids.length]; }
  earliest(kit, id) { const b = this.state(kit, id).batches; return b.length ? b.reduce((a, x) => (x.expires < a ? x.expires : a), b[0].expires) : null; }

  update(kit, id, change) {
    const record = this.record(kit);
    const next = change(structuredClone(this.state(kit, id)));
    // 沒勾、沒期限的品項不留空殼,存檔只記有內容的。
    if (!next.isReady && !next.batches.length) delete record.items[id]; else record.items[id] = next;
  }
  setReady(kit, id, ready) { if (this.has(kit, id)) this.update(kit, id, (s) => ({ ...s, isReady: ready })); }
  /** 記一批有效期限。已經記滿就不動,回 false。 */
  addBatch(kit, id, expires, quantity) {
    if (!this.has(kit, id) || !isISODate(expires) || this.state(kit, id).batches.length >= Limits.batches) return false;
    const batch = { id: uuid(), expires };
    if (quantity > 0) batch.quantity = quantity;
    this.update(kit, id, (s) => ({ ...s, batches: [...s.batches, batch].sort((a, b) => (a.expires < b.expires ? -1 : a.expires > b.expires ? 1 : 0)) }));
    return true;
  }
  updateBatch(kit, id, batch) {
    this.update(kit, id, (s) => {
      if (!s.batches.some((b) => b.id === batch.id)) return s;
      const fixed = { id: batch.id, expires: batch.expires };
      if (batch.quantity > 0) fixed.quantity = Math.max(1, batch.quantity);
      return { ...s, batches: s.batches.map((b) => (b.id === batch.id ? fixed : b)).sort((a, b) => (a.expires < b.expires ? -1 : a.expires > b.expires ? 1 : 0)) };
    });
  }
  removeBatch(kit, id, batchID) { this.update(kit, id, (s) => ({ ...s, batches: s.batches.filter((b) => b.id !== batchID) })); }
  /** 新增自訂品項。名稱去掉前後空白、截到上限;空白或與既有自訂品項同名就不加。 */
  addCustom(kit, name) {
    const trimmed = clip(String(name).trim(), Limits.customName).trim();
    const record = this.record(kit);
    if (!trimmed || record.custom.some((c) => c.name === trimmed)) return null;
    const item = { id: 'custom-' + uuid(), name: trimmed };
    record.custom.push(item);
    return item.id;
  }
  /** 移除自訂品項,連同它的勾選與有效期限。網站範本的品項不能移除。 */
  removeCustom(kit, id) {
    const record = this.record(kit);
    if (!record.custom.some((c) => c.id === id)) return;
    record.custom = record.custom.filter((c) => c.id !== id);
    delete record.items[id];
  }
  markChecked(kit, day) { this.record(kit).lastChecked = day; }

  /** 已過期與 30 天內到期的每一批,最急的在前。已經不在清單上的品項不提示。 */
  alerts(today) {
    const out = [];
    for (const kit of SupplyKits) {
      for (const id of this.itemIDs(kit)) {
        for (const b of this.state(kit, id).batches) {
          const left = daysLeft(today, b.expires);
          if (left <= Limits.soonWindow) out.push({ kit, id, batchID: b.id, expires: b.expires, daysLeft: left });
        }
      }
    }
    return out.sort((a, b) => a.daysLeft - b.daysLeft || (a.kit < b.kit ? -1 : a.kit > b.kit ? 1 : 0) || (a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
  }
  /** 超過半年沒檢查的清單。從沒按過「檢查完成」的不算 —— 剛開始用的人不該一進來就被提醒。 */
  checkOverdue(today) {
    return SupplyKits.filter((kit) => {
      const last = this.record(kit).lastChecked;
      return last && epochDay(today) - epochDay(last) >= Limits.checkInterval;
    });
  }
  toJSON() { return { household: this.household, goBag: this.goBag }; }
}

// MARK: - 家人會合地點與親友

class FamilyPlan {
  constructor(raw) {
    const points = (Array.isArray(raw?.meetingPoints) ? raw.meetingPoints : []).slice(0, Limits.meetingPoints).map((p) => clip(p, Limits.text));
    while (points.length < Limits.meetingPoints) points.push('');
    this.meetingPoints = points;
    this.contacts = (Array.isArray(raw?.contacts) ? raw.contacts : []).slice(0, Limits.contacts)
      .filter((c) => c && typeof c.id === 'string' && c.id)
      .map((c) => ({ id: c.id, name: clip(c.name, Limits.text), phone: clip(c.phone, Limits.text), note: clip(c.note, Limits.text) }));
  }
  get isEmpty() { return this.meetingPoints.every((p) => !p.trim()) && this.contacts.every(isBlankContact); }
  addContact() { if (this.contacts.length < Limits.contacts) this.contacts.push({ id: uuid(), name: '', phone: '', note: '' }); }
  removeContact(id) { this.contacts = this.contacts.filter((c) => c.id !== id); }
  trimmed() { const p = new FamilyPlan(this); p.contacts = p.contacts.filter((c) => !isBlankContact(c)); return p; }
  toJSON() { return { meetingPoints: this.meetingPoints, contacts: this.contacts }; }
}
const isBlankContact = (c) => !c.name.trim() && !c.phone.trim() && !c.note.trim();

/** 撥號用的網址:只留數字與 + * #,沒有數字就是 null。使用者輸入的是自由文字(「02-2311-1501 分機 3」),不能整段塞進 tel:。 */
function dialURL(text) {
  const kept = Array.from(String(text)).filter((c) => /[0-9+*#]/.test(c)).join('');
  if (!/[0-9]/.test(kept)) return null;
  return 'tel:' + kept.replace(/#/g, '%23');
}

// MARK: - 避難地圖

class PlaceList {
  constructor(raw) {
    this.places = (Array.isArray(raw?.places) ? raw.places : [])
      .filter((p) => p && typeof p.id === 'string' && p.id)
      .map((p) => ({
        id: p.id,
        name: String(p.name ?? ''),
        snapshots: (Array.isArray(p.snapshots) ? p.snapshots : [])
          // 網頁的畫面都是使用者自己加的截圖(App 是在小工具裡開地圖存下來,記著是哪一張地圖)
          .filter((s) => s && typeof s.id === 'string' && s.id)
          .map((s) => ({ id: s.id, takenAt: String(s.takenAt ?? '') })),
      }));
  }
  place(id) { return this.places.find((p) => p.id === id) || null; }
  cleaned(name) { const c = clip(String(name).trim(), Limits.placeName).trim(); return c || null; }
  /** 新增地方。空白或同名就不加,回新的 id 或 null。 */
  add(name) {
    const clean = this.cleaned(name);
    if (!clean || this.places.some((p) => p.name === clean)) return null;
    const place = { id: uuid(), name: clean, snapshots: [] };
    this.places.push(place);
    return place.id;
  }
  rename(id, name) {
    const clean = this.cleaned(name);
    if (!clean || this.places.some((p) => p.id !== id && p.name === clean)) return false;
    const p = this.place(id); if (p) p.name = clean;
    return !!p;
  }
  remove(id) { this.places = this.places.filter((p) => p.id !== id); }
  canAddSnapshot(id) { const p = this.place(id); return !!p && p.snapshots.length < Limits.snapshots; }
  addSnapshot(id, shot) { const p = this.place(id); if (p && p.snapshots.length < Limits.snapshots) p.snapshots.unshift(shot); }
  removeSnapshot(id, shotID) { const p = this.place(id); if (p) p.snapshots = p.snapshots.filter((s) => s.id !== shotID); }
  get referencedShots() { return new Set(this.places.flatMap((p) => p.snapshots.map((s) => s.id))); }
  toJSON() { return { places: this.places }; }
}

// MARK: - 截圖(IndexedDB)

const ShotDB = {
  _db: null,
  open() {
    if (this._db) return this._db;
    this._db = new Promise((resolve, reject) => {
      try {
        const req = indexedDB.open('vgm-civil', 1);
        req.onupgradeneeded = () => req.result.createObjectStore('shots');
        req.onsuccess = () => resolve(req.result);
        req.onerror = () => reject(req.error);
      } catch (e) { reject(e); }
    });
    return this._db;
  },
  async run(mode, fn) {
    const db = await this.open();
    return new Promise((resolve, reject) => {
      const tx = db.transaction('shots', mode);
      const req = fn(tx.objectStore('shots'));
      tx.oncomplete = () => resolve(req?.result);
      tx.onerror = () => reject(tx.error);
      tx.onabort = () => reject(tx.error);
    });
  },
  put(id, blob) { return this.run('readwrite', (s) => s.put(blob, id)); },
  get(id) { return this.run('readonly', (s) => s.get(id)); },
  remove(id) { return this.run('readwrite', (s) => s.delete(id)); },
  keys() { return this.run('readonly', (s) => s.getAllKeys()); },
};

/** 截圖縮到長邊 2400 px 存成 JPEG(原圖一張常常好幾 MB,瀏覽器的空間有限)。 */
async function shrinkImage(file) {
  const url = URL.createObjectURL(file);
  try {
    const img = await new Promise((resolve, reject) => {
      const i = new Image();
      i.onload = () => resolve(i);
      i.onerror = reject;
      i.src = url;
    });
    const scale = Math.min(1, 2400 / Math.max(img.naturalWidth, img.naturalHeight));
    const w = Math.max(1, Math.round(img.naturalWidth * scale)), h = Math.max(1, Math.round(img.naturalHeight * scale));
    const canvas = document.createElement('canvas');
    canvas.width = w; canvas.height = h;
    canvas.getContext('2d').drawImage(img, 0, 0, w, h);
    return await new Promise((resolve, reject) => canvas.toBlob((b) => (b ? resolve(b) : reject(new Error('toBlob'))), 'image/jpeg', 0.85));
  } finally {
    URL.revokeObjectURL(url);
  }
}

// MARK: - 整個存檔

const Store = {
  checklist: new Checklist(readJSON(Keys.supplies)),
  family: new FamilyPlan(readJSON(Keys.family)),
  places: new PlaceList(readJSON(Keys.places)),
  /** 最後一次寫入失敗(私密瀏覽、空間滿了):畫面最上方說一聲。 */
  saveFailed: false,
  saveChecklist() { this.saveFailed = !writeJSON(Keys.supplies, this.checklist); },
  saveFamily() { this.saveFailed = !writeJSON(Keys.family, this.family); },
  savePlaces() { this.saveFailed = !writeJSON(Keys.places, this.places); },
  /** 存檔裡已經沒有的截圖(寫到一半就關掉頁面留下的)清掉。 */
  async sweepShots() {
    try {
      const used = this.places.referencedShots;
      for (const key of await ShotDB.keys()) if (!used.has(key)) await ShotDB.remove(key);
    } catch { /* 沒有 IndexedDB 就沒有要清的 */ }
  },
};
