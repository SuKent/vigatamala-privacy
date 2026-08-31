# Vigatamala 阻擋規則

[繁體中文](/rules.zh-Hant) · [简体中文](/rules.zh-Hans) · [English](/rules.en) · [日本語](/rules.ja) · [한국어](/rules.ko)

這裡存放 Vigatamala iOS 瀏覽器使用的廣告與追蹤器阻擋規則。

這兩份清單**不隨 App 打包**,而是由使用者在 App 內下載 ——
也就是說,下面這些檔案就是 App 實際會取用的那一份轉換產物,
任何人也都可以直接下載、檢視或自行使用(見下方授權)。

## 下載

| 檔案 | 說明 |
|---|---|
| [easylist.json](https://privacy.link2us.link/rules/easylist.json) | EasyList 的 content blocker 改作版 |
| [easylist.NOTICE.txt](https://privacy.link2us.link/rules/easylist.NOTICE.txt) | 姓名標示與上游著作權通知 |
| [easyprivacy.json](https://privacy.link2us.link/rules/easyprivacy.json) | EasyPrivacy 的 content blocker 改作版 |
| [easyprivacy.NOTICE.txt](https://privacy.link2us.link/rules/easyprivacy.NOTICE.txt) | 同上 |
| [easylist.json.sig](https://privacy.link2us.link/rules/easylist.json.sig) | Ed25519 簽章(App 端驗證用) |
| [easyprivacy.json.sig](https://privacy.link2us.link/rules/easyprivacy.json.sig) | 同上 |

## 這是什麼

上面兩份 JSON 是 [EasyList](https://easylist.to/) 與 EasyPrivacy 的**改作物**:
我們把 Adblock Plus 過濾語法轉換成 Apple 的 Safari content blocker JSON 格式,
過程中:

- 丟棄了該格式無法表達的規則型別(scriptlet 注入、進階選項等);
- 截斷至 65,000 條 —— 這是**我們自己選的**保守上限(顧及舊機型的編譯時間與
  記憶體),不是格式的極限。以今天的上游來說這個上限**沒有真的砍到東西**
  (easylist 60,928 條、easyprivacy 55,895 條,都在上限之內)。
  WebKit 目前會在解析階段拒收超過 150,000 條的清單,但那個數字是 WebKit 的
  實作細節(Apple 文件並未載明,2020 年底才從 50,000 調高),而且是對著
  「編譯程序約 150 MB 的記憶體預算」訂出來的上界 —— 能編得起來的條數與
  值得編的條數不是同一件事,我們不打算靠近那條線。

因此它**不等於**上游清單,阻擋效果也不完全相同。
想要完整原版請直接用[上游來源](https://easylist.to/)。

## 授權

上游以 GPLv3 或 CC BY-SA 3.0 Unported 雙授權發布,由使用者擇一。
**本改作版明示採用 CC BY-SA 3.0 Unported。**

- 姓名標示:The EasyList authors (https://easylist.to/)
- 授權全文:<https://creativecommons.org/licenses/by-sa/3.0/legalcode>
- 原作者**不**為本改作版本背書。

每份規則旁的 `.NOTICE.txt` 逐字保留了上游檔頭的著作權通知
(Title / Version / Last modified / Commit / Homepage / Licence),
因為 content blocker JSON 是裸的頂層陣列、沒有註解語法,寫不回檔內。
那些 NOTICE 也記錄了每次轉換所依據的上游版本與 commit,可以逐版稽核。

**授權範圍僅限 `rules/` 目錄**;本站其餘內容(隱私政策等)版權保留。

## 完整性驗證

規則檔以 Ed25519 簽章(`.sig` 為 base64 的 64-byte raw 簽章),
Vigatamala App 內嵌對應公鑰,鏡像來源必須驗簽通過才會被採用。

## 怎麼重現

`rules/converter/` 是可獨立建置的轉換器(與 App 內用的是同一份原始碼,
同一份輸入產出位元組相同的輸出):

```bash
cd rules/converter
swift build -c release
.build/release/RuleConverter <輸入.txt> <輸出.json> 65000
```

本 repo 的規則由 GitHub Actions 每日自動同步(見 `.github/workflows/`),
用的正是這份轉換器。
