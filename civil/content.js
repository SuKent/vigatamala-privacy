// 「民防準備」離線網頁的指引內容(照 Android `civil/CivilContent.kt`,它又照 iOS `CivilDefenseText`、`CivilGuideContent`)。
//
// 依國防部全民防衛動員署《當危機來臨時:臺灣全民安全指引》網站(2026-10-06 讀取)整理,政府資料開放授權條款第 1 版,頁尾標出處;
// **不取自手冊 PDF**(PDF 版權頁禁止商業目的與修改),見 Docs/CIVIL-DEFENSE-WIDGET.md。
// 急救與避難的步驟照網站原意,不加我們自己的建議 —— 這裡錯一句的代價比少一句高。
// **每一句都跟 Swift、Kotlin 逐字相同**:t("…") 是 iOS 字串表的鍵,`python3 Tools/civil-web/build.py --check` 找不到就紅。
//
// 沒有求救通訊(網頁做不到附近直連)。內容照 iOS 1.7 的台灣版面。
'use strict';

const CivilLinks = {
  officialSite: 'https://prepare.mnd.gov.tw/',
  manualDownloads: 'https://prepare.mnd.gov.tw/download-pdf',
  firstAidCourse: 'https://rtp.nfa.gov.tw/dp/course',
  aedMap: 'https://tw-aed.mohw.gov.tw/map',
  eyClarifications: 'https://www.ey.gov.tw/Page/5519E969E8931E4E',
  mjibFactCheck: 'https://www.mjib.gov.tw/EditPage/?PageID=adf9b60f-98af-4b65-b996-4f74145a4cd0',
  volunteerSignup: 'https://rdrc.mnd.gov.tw/page/mra',
  // 首頁推薦的兩個官方 App:iOS 開 App Store、Android 開 Google Play(開發者是消防署、警政署,2026-11-06 核對)
  fireAgencyApp: { ios: 'https://apps.apple.com/tw/app/id1500403641', android: 'https://play.google.com/store/apps/details?id=com.nfa.report' },
  policeApp: { ios: 'https://apps.apple.com/tw/app/id544121843', android: 'https://play.google.com/store/apps/details?id=tw.gov.npa.callservice' },
  // Vigatamala(Apple ID 6801748724):iPhone、iPad 打開網頁時先推薦 App 裡的民防準備(2026-11-20 使用者「照建議」)
  vigatamalaApp: 'https://apps.apple.com/tw/app/id6801748724',
};

// 頁尾的出處。App 寫「內容經本 App 整理，並非官方 App」,網頁改成「本網站」(網頁才有的句子,譯文在 build.py)。
// 第二段「以權責機關最新資訊為準」是 iOS 2026-10-28 使用者要加的(國防部回覆陳情時寫明)。
function attribution() {
  return [
    t('資料來源：國防部全民防衛動員署《當危機來臨時：臺灣全民安全指引》網站（prepare.mnd.gov.tw），依政府資料開放授權條款第 1 版利用。內容經本網站整理，並非官方網站，也未經該署認可。'),
    t('防災資訊、避難場所與緊急應變措施，請以各權責機關發布的最新資訊為準。'),
  ];
}

// MARK: - 指引的結構(GuideSection、GuideBlock)

const B = {
  text: (text) => ({ kind: 'text', text }),
  bullets: (items) => ({ kind: 'bullets', items }),
  steps: (items) => ({ kind: 'steps', items }),
  terms: (pairs) => ({ kind: 'terms', pairs }),
  group: (title, subtitle, items) => ({ kind: 'group', title, subtitle, items }),
  warning: (text) => ({ kind: 'warning', text }),
  alarm: (alarm) => ({ kind: 'alarm', alarm }),
  supplies: (kit) => ({ kind: 'supplies', kit }),
  shelterMaps: () => ({ kind: 'shelterMaps' }),
  radio: () => ({ kind: 'radio' }),
  hotline: (id) => ({ kind: 'hotline', id }),
  link: (title, url) => ({ kind: 'link', title, url }),
  page: (page) => ({ kind: 'page', page }),
};
const section = (title, blocks, isStep = false) => ({ title, isStep, blocks });
const step = (title, blocks) => section(title, blocks, true);

// MARK: - 警報

/** 手冊網站災害應對頁上有官方錄音的五種警報。使用者:「警報聲不能用合成的」。 */
const CivilAlarms = ['airRaid', 'allClear', 'tsunami', 'nuclear', 'nuclearAllClear'];

const AlarmInfo = {
  airRaid: { file: 'civil-air-raid.mp3', icon: 'civil_airplane', allClear: 'allClear' },
  allClear: { file: 'civil-all-clear.mp3', icon: 'civil_all_clear', allClear: null },
  tsunami: { file: 'civil-tsunami.mp3', icon: 'civil_water', allClear: 'allClear' },
  nuclear: { file: 'civil-nuclear.mp3', icon: 'civil_nuclear', allClear: 'nuclearAllClear' },
  nuclearAllClear: { file: 'civil-nuclear-all-clear.mp3', icon: 'civil_all_clear', allClear: null },
};

/** 節奏圖:網站文字寫的規定(響、停、語音)。語音段的長度取自官方錄音。 */
function alarmPattern(alarm) {
  const tone = (s) => ({ kind: 'tone', s }), pause = (s) => ({ kind: 'pause', s }), voice = (s) => ({ kind: 'voice', s });
  switch (alarm) {
    case 'airRaid': {
      // 15 秒長鳴、5 秒短鳴兩聲,每聲間隔 5 秒;重複 3 次(最後一輪後面沒有間隔),共 115 秒。
      const out = [];
      for (let round = 0; round < 3; round++) {
        out.push(tone(15), pause(5), tone(5), pause(5), tone(5));
        if (round < 2) out.push(pause(5));
      }
      return out;
    }
    case 'allClear': return [tone(90)];
    case 'tsunami': return [tone(5), pause(5), tone(5), voice(15)];
    case 'nuclear': {
      const out = [];
      for (let i = 0; i < 25; i++) out.push(tone(1), pause(1));
      out.push(voice(9));
      return out;
    }
    case 'nuclearAllClear': return [tone(50), voice(4)];
  }
  return [];
}
const alarmSeconds = (alarm) => alarmPattern(alarm).reduce((sum, seg) => sum + seg.s, 0);

function alarmTitle(alarm) {
  switch (alarm) {
    case 'airRaid': return t('防空警報');
    case 'allClear': return t('解除警報');
    case 'tsunami': return t('海嘯警報');
    case 'nuclear': return t('核子事故警報');
    case 'nuclearAllClear': return t('核子事故解除警報');
  }
}

/** 聲音怎麼響(網站的「認識…警報聲」)。 */
function alarmRule(alarm) {
  switch (alarm) {
    case 'airRaid': return t('先一聲 15 秒長鳴，接著兩聲 5 秒短鳴，每聲間隔 5 秒；重複 3 次。');
    case 'allClear': return t('持續長聲 90 秒。防空警報與海嘯警報的解除都是這個聲音。');
    case 'tsunami': return t('鳴 5 秒、停 5 秒、鳴 5 秒，接著語音廣播 2 次：「海嘯警報、海嘯警報，請所有民眾迅速往高處疏散」。沒有語音設備的地方：鳴 5 秒、停 5 秒，重複數次。');
    case 'nuclear': return t('響 1 秒、停 1 秒，重複 25 次，接著語音廣播：「這是核能電廠事故警報，請進入室內不要驚慌，依照警察機關或電視、電臺中政府的指示行動。」');
    case 'nuclearAllClear': return t('一長音 50 秒，接著語音廣播：「這是核能電廠事故解除警報。」');
  }
}

/** 聽到時怎麼做(網站的「如何行動」)。 */
function alarmActions(alarm) {
  switch (alarm) {
    case 'airRaid': return [
      t('保持冷靜，拿起緊急避難包。'),
      t('在室內：進入地下室或離窗戶較遠的房間，不要搭電梯。'),
      t('在車上：靠邊停車，下車進入附近室內避難。'),
      t('在戶外空曠處：找堅固的掩蔽處；找不到就到附近較低的地方趴下。'),
      t('在戶外、附近有建築物：進入有「防空避難」標示的地方，或聽從指引避難。'),
      t('做出防空避難姿勢：室內靠牆坐下、戶外趴下，背對爆炸方向；身體微拱，雙手抱頭遮住眼睛耳朵，嘴巴微張。'),
      t('聽到解除警報，才能解除防空避難姿勢。'),
    ];
    case 'allClear': return [
      t('防空警報：聽到後才能解除防空避難姿勢。'),
      t('海嘯警報：聽到後才代表警報解除。'),
      t('災情嚴重時，帶著緊急避難包，依救災人員指示前往避難處所。'),
    ];
    case 'tsunami': return [
      t('保持冷靜，拿起緊急避難包。'),
      t('馬上往高處（3 層樓以上）、遠離海岸的方向逃生；不要開車，以免塞車被困。'),
      t('在堅固的高樓內避難時，緊閉門窗。'),
      t('來不及逃到高處時，抓住大樹、鋼筋等牢固的東西。'),
      t('聽到持續長聲 90 秒，才代表海嘯警報解除。'),
    ];
    case 'nuclear': return [
      t('停止外出，立刻進入室內，關閉門窗，空調改成室內循環。'),
      t('看電視、聽收音機，注意政府發布的消息與指示。'),
      t('政府會視情況發放碘片，依指示服用；碘片是藥品，不要擅自服用。'),
      t('災情嚴重時，帶著緊急避難包，依救災人員指示疏散。'),
    ];
    case 'nuclearAllClear': return [t('最危險的情況已解除，請依照政府指示行動。')];
  }
}

// MARK: - 物資清單

const SupplyKits = ['household', 'goBag'];
const KitIcon = { household: 'civil_home', goBag: 'backpack' };

function kitTitle(kit) { return kit === 'household' ? t('日常居家儲備') : t('緊急避難包'); }
function kitSubtitle(kit) { return kit === 'household' ? t('放在家裡，災難時在家使用') : t('若家裡不安全，帶著它去避難'); }

/** 網站的「準備原則」。 */
function kitPrinciples(kit) {
  return kit === 'household'
    ? [t('以家庭為單位，準備至少 7 天份。'),
       t('標記物品有效日期；每半年檢查，快過期的食物先吃，壞了的換掉。'),
       t('放在通風陰涼處，防災物資和日常物資分開放，不要全部集中在一處。')]
    : [t('以個人為單位，準備至少 1 到 3 天份，裝進背得動的後背包。'),
       t('標記物品有效日期；每半年檢查，快過期的食物先吃，壞了的換掉。'),
       t('放在逃生時最順手的地方，例如住家玄關附近。')];
}

const SupplySections = ['waterFood', 'hygiene', 'living', 'care', 'custom'];
function sectionTitle(s) {
  switch (s) {
    case 'waterFood': return t('水和食物');
    case 'hygiene': return t('衛生與醫療用品');
    case 'living': return t('生活防災用品');
    case 'care': return t('照護用品（依需求準備）');
    case 'custom': return t('自己加的品項');
  }
}

/** 網站上的建議品項。⚠️ id 是存檔鍵(勾選與有效期限掛在它底下),定了就不要改(跟 iOS、Android 同一組)。 */
const SupplyTemplates = {
  household: [
    ['waterFood', ['water', 'readyMeals', 'energySnacks', 'simpleMeals', 'seasoning']],
    ['hygiene', ['masks', 'tissues', 'wipes', 'sanitaryPads', 'waterFilter', 'firstAidKit', 'medicines', 'spareGlasses']],
    ['living', ['flashlight', 'ledLantern', 'radio', 'batteries', 'chargingCable', 'powerBank', 'handCrank', 'workGloves', 'plasticBags', 'clingWrap', 'gasStove', 'clothTape']],
    ['care', ['babySupplies', 'petSupplies', 'elderSupplies']],
  ],
  goBag: [
    ['waterFood', ['water', 'readyMeals', 'energySnacks']],
    ['hygiene', ['masks', 'tissues', 'wipes', 'sanitaryPads', 'towel', 'waterFilter', 'woundCare', 'medicines', 'glasses', 'thermometer']],
    ['living', ['flashlight', 'whistle', 'radio', 'shelterMap', 'raincoat', 'thermalBlanket', 'heatProtection', 'idCopy', 'healthCardCopy', 'passbookCopy', 'cash',
      'batteries', 'chargingCable', 'powerBank', 'handCrank', 'workGloves', 'plasticBags', 'helmet', 'penPaper', 'utensils', 'lighter', 'multiTool', 'shoes']],
    ['care', ['babySupplies', 'petSupplies', 'elderSupplies']],
  ],
};

function templateTitle(id) {
  switch (id) {
    case 'water': return t('飲用水');
    case 'readyMeals': return t('不用煮的主食');
    case 'energySnacks': return t('能量點心');
    case 'simpleMeals': return t('簡單煮的主食');
    case 'seasoning': return t('基本調味料');
    case 'masks': return t('口罩');
    case 'tissues': return t('衛生紙');
    case 'wipes': return t('消毒濕紙巾、酒精噴霧');
    case 'sanitaryPads': return t('女性生理用品');
    case 'waterFilter': return t('簡易式淨水設備');
    case 'firstAidKit': return t('急救箱');
    case 'medicines': return t('常用藥物、個人處方藥');
    case 'spareGlasses': return t('備用眼鏡、拋棄式隱形眼鏡');
    case 'towel': return t('小條毛巾');
    case 'woundCare': return t('外傷藥膏、基本包紮用品');
    case 'glasses': return t('眼鏡、拋棄式隱形眼鏡');
    case 'thermometer': return t('體溫計');
    case 'flashlight': return t('手電筒、頭燈（含電池）');
    case 'ledLantern': return t('LED 手提燈（含電池）');
    case 'radio': return t('可攜式收音機');
    case 'whistle': return t('哨子');
    case 'shelterMap': return t('避難地圖與聯絡資訊（紙本）');
    case 'raincoat': return t('輕便的雨衣與外套');
    case 'thermalBlanket': return t('輕便保暖毯或小型睡袋');
    case 'heatProtection': return t('防中暑用品');
    case 'idCopy': return t('身分證影本');
    case 'healthCardCopy': return t('健保卡影本');
    case 'passbookCopy': return t('存摺影本');
    case 'cash': return t('少量現金');
    case 'batteries': return t('乾電池');
    case 'chargingCable': return t('充電線');
    case 'powerBank': return t('充飽電的行動電源');
    case 'handCrank': return t('小型手搖發電機');
    case 'workGloves': return t('工作手套（防切割、耐磨）');
    case 'plasticBags': return t('塑膠袋');
    case 'clingWrap': return t('保鮮膜');
    case 'gasStove': return t('卡式爐、卡式瓦斯罐');
    case 'clothTape': return t('布質膠帶');
    case 'helmet': return t('頭盔');
    case 'penPaper': return t('簡單紙筆');
    case 'utensils': return t('可重複使用的餐具');
    case 'lighter': return t('打火機、火柴');
    case 'multiTool': return t('瑞士刀、開罐器等小工具');
    case 'shoes': return t('輕便耐走的鞋子');
    case 'babySupplies': return t('嬰兒用品');
    case 'petSupplies': return t('寵物用品');
    case 'elderSupplies': return t('年長者用品');
  }
  return null;
}

/** 品項底下的一行說明(網站上那一行)。沒有說明的回 null。 */
function templateDetail(id, kit) {
  switch (id) {
    case 'water': return kit === 'household' ? t('每人每日至少 3 公升') : t('2 瓶，每瓶 600 毫升');
    case 'readyMeals': return t('如罐頭、即食飯、米餅、口糧餅乾');
    case 'energySnacks': return t('如營養棒、果乾、堅果、巧克力、糖果');
    case 'simpleMeals': return t('環境允許時可簡單烹煮，如調理包、米、泡麵、乾麵條');
    case 'seasoning': return t('如油、鹽、糖');
    case 'sanitaryPads': case 'spareGlasses': case 'glasses': return t('如有需要');
    case 'firstAidKit': return t('藥膏、繃帶、紗布等醫療用品');
    case 'towel': return t('簡單個人清潔用');
    case 'flashlight': return t('小範圍照明，移動時方便使用');
    case 'ledLantern': return t('照明範圍廣，可照亮整個空間');
    case 'radio': return t('沒有網路時仍可接收資訊');
    case 'whistle': return t('用來發出求救訊號');
    case 'shelterMap': return t('與家人約定的會合地點、重要親友聯絡方式、政府專線');
    case 'raincoat': return t('防雨、保暖');
    case 'thermalBlanket': return t('如太空毯、鋁箔毯');
    case 'heatProtection': return t('如帽子、雨傘、防曬乳');
    case 'idCopy': case 'healthCardCopy': case 'passbookCopy': return t('紙本或數位皆可；紙本用防水夾鏈袋裝好');
    case 'batteries': return t('準備時注意電池型號');
    case 'chargingCable': return t('手機等設備充電用');
    case 'powerBank': return t('停電時的備用電源');
    case 'handCrank': return t('行動電源沒電時緊急充電');
    case 'workGloves': return t('搬東西、清理時保護雙手');
    case 'plasticBags': return t('隔離垃圾、防水包裹物品');
    case 'clingWrap': return t('包裹食物、覆蓋傷口');
    case 'gasStove': return t('停電時可簡單烹煮');
    case 'clothTape': return t('隔絕、固定或簡易修補');
    case 'helmet': return t('保護頭部，建議掛在背包外');
    case 'penPaper': return t('方便記錄或溝通');
    case 'babySupplies': return t('奶粉、奶瓶、紙尿褲等');
    case 'petSupplies': return t('寵物食品、排泄用品、牽繩、飼主聯絡資訊等');
    case 'elderSupplies': return t('銀髮友善食品、假牙清潔劑、助聽器電池等');
  }
  return null;
}

/** 有效期限的狀態文字:「已過期 3 天」「今天到期」「12 天後到期」。 */
function expiryStatus(daysLeft) {
  if (daysLeft < 0) return t('已過期 %lld 天', -daysLeft);
  if (daysLeft === 0) return t('今天到期');
  return t('%lld 天後到期', daysLeft);
}

// MARK: - 避難地圖

/** 官方地圖。網頁不處理避難所資料:開官方地圖,使用者自己截圖再加進來。 */
const ShelterSources = {
  airRaidShelters: { url: 'https://adr.npa.gov.tw/map', icon: 'civil_shield' },
  disasterShelters: { url: 'https://bear.emic.gov.tw/MY2/map', icon: 'civil_shelter' },
};
function shelterTitle(s) { return s === 'airRaidShelters' ? t('防空避難所地圖') : t('避難收容處所地圖'); }
function shelterSubtitle(s) { return s === 'airRaidShelters' ? t('內政部警政署：防空避難處所') : t('消防署全民防災 e 點通：避難收容處所、救濟站、物資配售站'); }

// MARK: - 指引頁

const GuidePages = { misinformation: 'civil_fact_check', mental: 'civil_mental', contribute: 'civil_contribute' };
function guideTitle(p) {
  switch (p) {
    case 'misinformation': return t('假資訊防範');
    case 'mental': return t('心理準備');
    case 'contribute': return t('貢獻一份力');
  }
}
function guideSubtitle(p) {
  switch (p) {
    case 'misinformation': return t('分辨正確資訊，保護自己');
    case 'mental': return t('做好心理準備，臨危不亂');
    case 'contribute': return t('防災士、民防團隊、志願役');
  }
}

/** 手冊網站「災害應對」的八種災害。 */
const Disasters = ['airRaid', 'militaryInvasion', 'nuclear', 'humanThreat', 'earthquake', 'typhoon', 'tsunami', 'landslide'];
const DisasterIcon = {
  airRaid: 'civil_airplane', militaryInvasion: 'civil_invasion', nuclear: 'civil_nuclear', humanThreat: 'civil_run',
  earthquake: 'civil_quake', typhoon: 'civil_typhoon', tsunami: 'civil_water', landslide: 'civil_mountain',
};
const DisasterAlarms = { airRaid: ['airRaid', 'allClear'], nuclear: ['nuclear', 'nuclearAllClear'], tsunami: ['tsunami', 'allClear'] };
function disasterTitle(d) {
  switch (d) {
    case 'airRaid': return t('空襲');
    case 'militaryInvasion': return t('軍事侵略');
    case 'nuclear': return t('核子事故');
    case 'humanThreat': return t('人為危安事件');
    case 'earthquake': return t('地震');
    case 'typhoon': return t('颱風');
    case 'tsunami': return t('海嘯');
    case 'landslide': return t('土石流與堰塞湖崩塌');
  }
}

/** 手冊網站「傷患處理」的六個項目。 */
const FirstAids = ['burns', 'bleeding', 'carrying', 'chemical', 'radiation', 'unconscious'];
const FirstAidIcon = { burns: 'civil_fire', bleeding: 'civil_drop', carrying: 'civil_people', chemical: 'civil_haze', radiation: 'civil_nuclear', unconscious: 'civil_heart' };
function firstAidTitle(f) {
  switch (f) {
    case 'burns': return t('燒燙傷');
    case 'bleeding': return t('大量出血');
    case 'carrying': return t('搬運傷患');
    case 'chemical': return t('毒化物質災害');
    case 'radiation': return t('輻射災害');
    case 'unconscious': return t('失去意識（CPR／AED）');
  }
}

/** 政府重要緊急專線。號碼是公開的事實,不取自手冊 PDF 的版面。 */
const Hotlines = [['police', '110'], ['emergency', '112'], ['fire', '119'], ['mentalHealth', '1925'], ['longTermCare', '1966'], ['coastGuard', '118'], ['finance', '1998'], ['cityHall', '1999']];
function hotlineTitle(id) {
  switch (id) {
    case 'police': return t('警政專線');
    case 'emergency': return t('緊急救難');
    case 'fire': return t('消防專線');
    case 'mentalHealth': return t('安心專線');
    case 'longTermCare': return t('長照服務');
    case 'coastGuard': return t('海巡專線');
    case 'finance': return t('金融服務');
    case 'cityHall': return t('縣市政府');
  }
  return id;
}

/** 戰時斷網後要收聽的廣播頻率,依地區(手冊網站「軍事侵略」)。 */
const WartimeRadio = [
  ['north', ['AM 1494', 'FM 94.3', 'FM 101.3', 'FM 104.9', 'FM 106.5', 'FM 100.1', 'FM 101.7', 'FM 103.5']],
  ['central', ['FM 94.5', 'FM 98.1', 'FM 103.5', 'FM 103.9', 'FM 104.5', 'FM 105.1']],
  ['south', ['FM 93.1', 'FM 99.3', 'FM 101.3', 'FM 101.7', 'FM 104.9', 'FM 107.3', 'FM 107.7']],
  ['east', ['FM 88.9', 'FM 94.3', 'FM 97.3', 'FM 100.3', 'FM 100.5', 'FM 101.3', 'FM 102.9', 'FM 103.7', 'FM 104.3', 'FM 104.5', 'FM 105.3', 'FM 106.3']],
  ['penghu', ['AM 846', 'AM 1269', 'FM 99.1', 'FM 105.3']],
  ['kinmenMatsu', ['FM 88.9', 'FM 91.5', 'FM 107.3']],
];
function radioRegionTitle(id) {
  switch (id) {
    case 'north': return t('北部');
    case 'central': return t('中部');
    case 'south': return t('南部');
    case 'east': return t('東部');
    case 'penghu': return t('澎湖');
    case 'kinmenMatsu': return t('金門、馬祖');
  }
  return id;
}

// MARK: - 災害應對

function grabGoBag() {
  return step(t('保持冷靜，拿起緊急避難包'), [
    B.text(t('平時就準備好緊急避難包，災難發生時才能馬上用。')),
    B.supplies('goBag'),
  ]);
}
const shelterText = () => t('住家毀壞時，可以疏散到避難收容處所暫時居住。');
const reliefStationText = () => t('到救濟站登記身分資料，可以獲得暫時居住的空間、物資、通訊管道及心理輔導資源。');
function evacuate(reliefStation) {
  return step(t('若災情嚴重，帶著緊急避難包避難'), [
    B.text(t('若災情嚴重，帶著緊急避難包，依照救災人員指示疏散前往避難處所。')),
    reliefStation ? B.terms([[t('救濟站'), reliefStationText()]]) : B.terms([[t('避難收容處所'), shelterText()]]),
    B.shelterMaps(),
  ]);
}

function disasterSections(d) {
  const notice = t('如何察覺');
  switch (d) {
    case 'airRaid': return [
      section(notice, [B.bullets([t('手機收到防空警報簡訊'), t('聽到防空警報聲')]), B.alarm('airRaid')]),
      grabGoBag(),
      step(t('前往避難場所'), [
        B.text(t('根據您的位置，前往合適的場所避難。')),
        B.terms([
          [t('室內'), t('進入地下室或離窗戶較遠的房間，不要搭電梯，避免受困。')],
          [t('車上'), t('靠邊停車，下車進入附近室內避難。')],
          [t('戶外空曠處（附近沒有建築物）'), t('找堅固的掩蔽處躲藏；找不到時，選擇附近較低的地方就地趴下。')],
          [t('戶外非空曠處（附近有建築物）'), t('自行進入有「防空避難」標示的地方，或聽從指引避難。')],
        ]),
        B.shelterMaps(),
      ]),
      step(t('保持防空避難姿勢'), [
        B.text(t('在室內就靠牆「坐下」、在戶外就「趴下」，背對爆炸方向，做出防空避難姿勢並保持。')),
        B.terms([
          [t('身體微拱'), t('縮小受波及的身體面積，保護內臟。')],
          [t('雙手抱頭、遮住眼睛耳朵'), t('防止強光、碎片或音波傷害感官。')],
          [t('嘴巴微張'), t('平衡爆炸時的壓力，減少對耳膜和肺部的傷害。')],
        ]),
      ]),
      step(t('等待防空警報解除'), [
        B.text(t('聽到「防空警報解除聲」，才能解除防空避難姿勢。')),
        B.alarm('allClear'),
      ]),
      evacuate(true),
    ];
    case 'militaryInvasion': return [
      section(notice, [
        B.text(t('觀察到下列軍事威脅態樣：')),
        B.bullets([
          t('重要基礎設施遭破壞、多數海纜遭破壞、大規模網路癱瘓。'),
          t('敵國巡航繞臺，要求登檢我國船隻。'),
          t('敵國在我周邊進行實彈操演，或利用軍演名義單方面劃設禁航區。'),
          t('敵國無人機出現在我國領空。'),
          t('對岸單方面宣布停止兩岸交通、商業活動。'),
          t('敵國發動攻擊、武裝侵略或滲透破壞。'),
        ]),
      ]),
      step(t('保持冷靜，確認備戰物資充足'), [
        B.text(t('確認日常居家儲備和緊急避難包準備充足，隨時應對戰爭發生。')),
        B.supplies('household'), B.supplies('goBag'),
      ]),
      step(t('若戰爭發生，留意四周軍隊活動'), [
        B.text(t('發現疑似軍隊活動，請儘速離開；若無法及時離開，請立刻隱蔽在安全、遠離門窗的地方。')),
        B.warning(t('請勿拍照錄影、上傳我軍軍事動態，以免置我軍於危險。')),
      ]),
      step(t('戰爭時若失去網路，收聽廣播接收資訊'), [
        B.text(t('依所在地區收聽廣播電台，或到附近派出所、村里辦公室取得資訊。')),
        B.radio(),
      ]),
      step(t('戰爭時若失去住家，到親友家或救濟站避難'), [
        B.text(t('戰爭期間若失去住家，請到親友家，或政府開設的救濟站。')),
        B.terms([[t('救濟站'), reliefStationText()]]),
        B.shelterMaps(),
      ]),
      step(t('戰爭時若物資短缺，到物資配售站'), [
        B.text(t('戰爭期間若民生物品短缺，請到政府開設的物資配售站補給。政府會全力維持民生經濟，透過物資配售機制維持全民生活所需。')),
        B.shelterMaps(),
      ]),
      step(t('戰爭期間，勿相信投降假消息'), [
        B.warning(t('請牢記，任何有關國家戰敗或政府宣布投降的訊息，都是假資訊！')),
        B.page('misinformation'),
      ]),
    ];
    case 'nuclear': return [
      section(notice, [B.bullets([t('手機收到核子事故警報簡訊'), t('聽到核子事故警報聲')]), B.alarm('nuclear')]),
      step(t('停止外出，立刻進入室內關閉門窗'), [B.text(t('馬上關閉門窗、將空調調整為室內循環，減少與輻射接觸的機會。'))]),
      step(t('看電視、聽收音機，注意政府資訊'), [B.text(t('密切關注政府透過電視、收音機、巡迴廣播車等管道發布的最新消息和指示。'))]),
      step(t('聽從指示服用碘片，若災情嚴重請帶著緊急避難包配合疏散'), [
        B.text(t('政府會視情況發放碘片，請依指示服用。')),
        B.warning(t('碘片屬於藥品，請勿擅自服用。')),
        B.text(t('若災情嚴重，請帶著緊急避難包，依照救災人員指示疏散前往避難處所。')),
        B.terms([[t('避難收容處所'), shelterText()]]),
        B.supplies('goBag'), B.shelterMaps(),
      ]),
      step(t('等待核子事故警報解除'), [
        B.text(t('「核子事故解除聲」代表最危險的情況已解除，請按照政府指示行動。')),
        B.alarm('nuclearAllClear'),
      ]),
    ];
    case 'humanThreat': return [
      section(notice, [B.bullets([t('發現周遭不尋常的行為、聲音、氣味或人群躁動')])]),
      step(t('遠離'), [B.text(t('立即遠離危害及威脅，不要圍觀、不要停留。果斷放下隨身行李或重物，以利快速移動，選擇安全路線迅速離開現場。'))]),
      step(t('掩護'), [B.text(t('無法撤離時，立刻掩護，躲在堅固物體後方，壓低身體。遠離玻璃、出入口與人群，避免成為明顯目標。配合警方行動，服從現場指令是保命關鍵。'))]),
      step(t('通報'), [
        B.text(t('確保安全後，立即通報可疑人事物：撥打 110 或 119，也可以使用公共場所的緊急求助設備。勿傳播未經證實的資訊，避免干擾執法行動。')),
        B.hotline('police'), B.hotline('fire'),
      ]),
    ];
    case 'earthquake': return [
      section(notice, [B.bullets([t('手機收到地震警報簡訊'), t('感受到地震出現')])]),
      step(t('保持冷靜，就地掩護避難，等到搖晃停止'), [
        B.text(t('根據您的位置，選擇掩護方式。')),
        B.group(t('室內'), null, [t('蹲下或趴下，避免被震倒。'), t('躲到堅固的桌下或牆角，不要慌亂跑到戶外增加風險。'), t('保護頭頸，等待搖晃停止。')]),
        B.group(t('戶外'), null, [t('避開掉落物，到空曠處蹲下，不要嘗試跑進室內增加風險。'), t('停下腳步不奔跑，避免被震倒。'), t('保護頭頸，等待搖晃停止。')]),
        B.group(t('車上'), null, [t('馬上減速，開啟警示燈。'), t('避開掉落物，到空曠處停車，不要嘗試跑出車外增加風險。'), t('在車內等待搖晃停止。')]),
      ]),
      evacuate(false),
    ];
    case 'typhoon': return [
      section(notice, [B.bullets([t('手機收到颱風警報簡訊'), t('新聞出現颱風警報')])]),
      step(t('保持冷靜，確認物資，在家不外出'), [
        B.text(t('確認日常居家儲備和緊急避難包準備充足，儘早回家，不要外出。')),
        B.supplies('household'), B.supplies('goBag'),
      ]),
      evacuate(false),
    ];
    case 'tsunami': return [
      section(notice, [B.bullets([t('手機收到海嘯警報簡訊'), t('聽到海嘯警報聲')]), B.alarm('tsunami')]),
      grabGoBag(),
      step(t('馬上跑到高處逃生，過程中請勿開車'), [
        B.text(t('快速往高處（3 層樓以上）、遠離海岸的方向避難！')),
        B.warning(t('逃生時請勿開車，以免塞車無法逃生；請立即下車避難，不要待在車內，以免被沖走。')),
      ]),
      step(t('若在高樓內避難，請緊閉門窗'), [B.text(t('到堅固的高樓內避難時，請緊閉門窗，防止水壓與漂流物衝入室內。'))]),
      step(t('若來不及逃到高處，趕緊抓住牢固物'), [B.text(t('若來不及逃到高處，請趕緊抓住牢固的東西（例如大樹、鋼筋），減少被沖走的機會。'))]),
      step(t('等待海嘯警報解除'), [B.text(t('聽到持續長聲 90 秒，才代表海嘯警報解除。')), B.alarm('allClear')]),
      evacuate(false),
    ];
    case 'landslide': return [
      section(notice, [
        B.bullets([t('手機收到警報簡訊'), t('聽到村里廣播系統或警報聲')]),
        B.group(t('發現周邊環境異常，例如：'), null, [
          t('樹木、電線桿傾斜，坡面滲水或滑動。'),
          t('地面突然出現裂縫，或水流改道。'),
          t('聽見山區傳來異常巨響、隆隆聲、樹木斷裂聲。'),
          t('河水混濁，有大量土砂及漂流木往下流動。'),
        ]),
      ]),
      grabGoBag(),
      step(t('立刻往高處逃生'), [
        B.text(t('發現環境異常，立刻往高處逃生。')),
        B.warning(t('不要沿著土石流或溪流流動的方向跑；遠離溪流、山坡、排水溝、橋梁與邊坡。')),
      ]),
      evacuate(false),
    ];
  }
  return [];
}

// MARK: - 傷患處理

function firstAidSections(f) {
  switch (f) {
    case 'burns': return [section(t('處理原則'), [B.terms([
      [t('沖'), t('用大量冷水沖洗傷口。')],
      [t('脫'), t('脫去傷口部位的衣物。')],
      [t('泡'), t('持續用冷水浸泡傷口。')],
      [t('蓋'), t('用乾淨紗布或毛巾蓋在傷口上。')],
      [t('送'), t('送醫治療。')],
    ])])];
    case 'bleeding': return [
      section(t('立刻撥打 119'), [B.hotline('fire'), B.text(t('等待救護人員抵達期間，依照出血部位進行緊急止血。'))]),
      section(t('依出血部位止血'), [
        B.group(t('手腳'), t('建議用止血帶'), [
          t('先用乾淨布料壓住傷口，用手或綁帶持續加壓，減少血流。'),
          t('如果止不住，把止血帶綁在傷口上方 5 到 8 公分處（口訣：高又緊），並記錄止血帶的使用時間，同時儘速尋求醫療專業人員協助。'),
        ]),
        B.group(t('頸部'), t('不可用止血帶'), [
          t('用布料輕壓傷口周圍止血；不可綁止血帶或包住整個脖子，不可用力壓迫傷口。'),
          t('注意讓傷者保持呼吸道暢通。'),
        ]),
        B.group(t('頭部'), t('不可用止血帶'), [
          t('用乾淨布料壓住傷口，避開骨折部位加壓，不可使用止血帶。'),
          t('持續評估傷者的清醒狀態。'),
        ]),
        B.group(t('胸、腹部'), t('不可用止血帶'), [
          t('如果有異物插進傷口（如鐵條、玻璃）：不可以拔除異物，用乾淨布料墊在異物周圍，讓它固定不晃動，並輕輕壓住傷口周圍止血。'),
          t('如果沒有異物插進傷口：直接用乾淨布料輕輕壓住傷口。'),
          t('不可用力壓迫傷口、不可使用止血帶。'),
        ]),
      ]),
    ];
    case 'carrying': return [
      section(t('處理原則'), [B.bullets([
        t('非必要情況不要移動傷患，避免造成更嚴重的傷害。'),
        t('現場仍有危險（如火勢蔓延），需要立刻處置才能保命時，才考慮移動傷患。'),
        t('如果必須移動傷患，越多人搬運越安全。'),
      ])]),
      section(t('常見搬運方法'), [
        B.group(t('扶持法（至少 1 人）'), t('適用：傷勢不重，無骨折、無心臟病的傷患'), [
          t('救援者扶住傷患的腰與手臂，協助步行。'),
          t('可以 1 人，或 2 人一左一右協助。'),
        ]),
        B.group(t('椅子運送法（至少 2 人）'), t('適用：傷患可以坐著，且沒有明顯脊椎傷'), [
          t('讓傷患坐在穩固的椅子上，兩人搬運。'),
          t('上樓時，兩人分別在椅子前側和後側搬運。'),
          t('下樓時，兩人站在椅子兩側搬運。'),
        ]),
        B.group(t('揹負法（至少 1 人）'), t('適用：長距離移動，但不可下樓或下坡'), [
          t('救援者背起傷患，用雙手托住傷患的大腿穩固。'),
          t('救援者需體力足夠，避免摔倒造成傷害。'),
        ]),
        B.group(t('擔架運送法（至少 2 人）'), t('適用：空間狹窄、上下樓梯、需要抬起傷患通過障礙'), [
          t('讓傷患平躺在硬式擔架或布條上。'),
          t('前進時讓傷患「腳朝前」。'),
          t('遇到上坡、上樓、進救護車或病房時，讓傷患「頭朝前」。'),
        ]),
      ]),
    ];
    case 'chemical': return [section(t('處理原則'), [B.terms([
      [t('避'), t('用手帕、濕布遮住口鼻，往上風處離開。')],
      [t('脫'), t('到達安全區域後，脫去外衣、遮蔽物。')],
      [t('沖'), t('先用乾布擦拭、去除明顯的汙染物；若有清水，再用大量清水從頭到腳沖洗。')],
      [t('蓋'), t('用乾淨外衣覆蓋，注意保暖。')],
      [t('送'), t('立即就醫或送醫。')],
    ])])];
    case 'radiation': return [section(t('處理原則'), [B.bullets([
      t('減少曝露在輻射汙染區域的時間，儘量避免在該區進食或逗留。'),
      t('洗淨手臉、更換衣物，降低吃進或吸入放射性物質的機會。'),
      t('多喝水、增加代謝；如有不適，請立即就醫。'),
    ])])];
    case 'unconscious': return [
      section(t('處理原則'), [
        B.steps([
          t('雙手拍傷患肩膀、大聲呼叫，看有沒有反應。'),
          t('如果沒有反應，請旁人打 119。'),
          t('等待救護人員抵達期間，先確認傷患還有沒有正常呼吸。'),
        ]),
        B.hotline('fire'),
      ]),
      section(t('沒有呼吸：CPR＋AED 急救'), [
        B.text(t('請人趕快去拿 AED，並持續進行 CPR＋AED 急救，直到救護人員抵達。')),
        B.terms([
          [t('拿到 AED 前'), t('先進行 CPR（心肺復甦術）。')],
          [t('拿到 AED 後'), t('馬上打開電源，依照 AED 的語音指示急救。')],
        ]),
        B.text(t('AED（自動體外心臟去顫器）多設置在公共場所，需要時可以取用。')),
        B.link(t('查看 AED 設備位置'), CivilLinks.aedMap),
      ]),
      section(t('還有呼吸：復原姿勢'), [
        B.text(t('不需要 CPR＋AED。讓傷患側躺，採「復原姿勢」，減少窒息風險，等待救護人員抵達。')),
        B.text(t('讓傷患側躺、頭轉向一邊，用一隻手托著頭；離地面較遠的那隻腿彎起來放在前面，固定身體維持側躺，注意保持呼吸道暢通。')),
      ]),
    ];
  }
  return [];
}

// MARK: - 假資訊防範、心理準備、貢獻一份力

function guideSections(p) {
  switch (p) {
    case 'misinformation': return [
      section(t('假資訊防範原則'), [
        B.text(t('保持戒心，不輕易轉發，儘可能多方查證資訊的真實性。可以參考：')),
        B.link(t('行政院即時新聞澄清專區'), CivilLinks.eyClarifications),
        B.link(t('法務部假訊息查證參考資訊'), CivilLinks.mjibFactCheck),
      ]),
      section(t('保護個資，減少假資訊擴散'), [
        B.text(t('許多假資訊透過盜用的帳號散布，保護個資能減少假資訊擴散：')),
        B.terms([
          [t('不明的東西不要碰'), t('陌生的網站連結、QR code、檔案下載、App、免費 Wi-Fi 等都別亂用。')],
          [t('連線不用就關掉'), t('Wi-Fi 和藍牙沒用時就關掉，使用公共 Wi-Fi 時開啟加密保護。')],
          [t('敏感資料用完就刪'), t('身分證、帳號等機密資料用完就刪，避免外洩。')],
          [t('不用中國 App 與監視設備'), t('避免使用中國製 App（包含 DeepSeek、WeChat、TikTok 抖音、小紅書、微博、百度等），以及有攝影或監視功能的中國製設備（掃地機器人、監視器等），以免被有心人士用來散播假消息，甚至幫助軍事侵略。')],
          [t('定期更新與備份'), t('常更新密碼和軟體、備份資料，密碼不要太簡單，防止資安漏洞。')],
        ]),
      ]),
      section(null, [B.warning(t('請牢記，倘若臺灣遭受軍事侵略，任何有關國家戰敗或政府宣布投降的消息都是假消息！'))]),
    ];
    case 'mental': return [
      section(t('讓自己做好準備'), [
        B.bullets([
          t('平時做好準備，例如準備物資、熟記基本自救方法，降低對未知危機的恐懼。'),
          t('平時維持良好的飲食、睡眠與運動習慣，保持健康並抒發壓力。'),
          t('控制新聞或網路資訊的攝取量，避免過多資訊增加焦慮。'),
          t('多和家人朋友聊聊你的感受，降低孤獨與焦慮。'),
          t('感到焦慮和害怕是正常的；有需要時，請勇於尋求專業心理機構協助。'),
        ]),
        B.hotline('mentalHealth'),
      ]),
      section(t('讓孩子一起做好準備'), [B.bullets([
        t('和孩子一起準備防災物資、學習基本自救方法，培養正確的危機應對能力。'),
        t('鼓勵孩子多方查證資訊、保持戒心，養成辨識資訊的能力。'),
        t('誠實解釋、大方討論我們面臨的危機，包含軍事侵略，讓孩子了解真實狀況，才能真正保護自己。'),
        t('傾聽孩子的焦慮，邀請他們參與對話，降低孩子的心理壓力。'),
        t('平時和孩子多規劃家庭活動，準備面對危機之餘，也要適時放鬆心情。'),
      ])]),
    ];
    case 'contribute': return [
      section(t('成為民間互助力量'), [
        B.group(t('參加防災士課程'), null, [t('培養防災技能與知識，有助危機時保護自己和身邊的人。')]),
        B.link(t('防災士課程'), CivilLinks.firstAidCourse),
        B.group(t('加入民防團隊或組織'), null, [t('協助地方政府維護社會安全。可以打電話或親自到附近的警察局（派出所）、消防局（消防分隊）或所在地區的民防組織，洽詢如何加入。')]),
      ]),
      section(t('加入國軍幫忙'), [
        B.group(t('主動報名志願役'), null, [t('想為國防出一份力，歡迎加入國軍志願役！可以線上報名，或到各地招募站現場報名。')]),
        B.link(t('線上報名志願役'), CivilLinks.volunteerSignup),
        B.group(t('後備軍人與替代役備役男'), null, [t('收到召集令時，請依照指定的時間、地點報到。')]),
      ]),
    ];
  }
  return [];
}
