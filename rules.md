# Vigatamala 阻擋規則

這裡存放 Vigatamala iOS 瀏覽器內建的廣告與追蹤器阻擋規則 ——
也就是實際打包進 App 的那一份轉換產物。

## 下載

| 檔案 | 說明 |
|---|---|
| [easylist.json](https://privacy.link2us.link/rules/easylist.json) | EasyList 的 content blocker 改作版 |
| [easylist.NOTICE.txt](https://privacy.link2us.link/rules/easylist.NOTICE.txt) | 姓名標示與上游著作權通知 |
| [easyprivacy.json](https://privacy.link2us.link/rules/easyprivacy.json) | EasyPrivacy 的 content blocker 改作版 |
| [easyprivacy.NOTICE.txt](https://privacy.link2us.link/rules/easyprivacy.NOTICE.txt) | 同上 |

## 這是什麼

上面兩份 JSON 是 [EasyList](https://easylist.to/) 與 EasyPrivacy 的**改作物**:
我們把 Adblock Plus 過濾語法轉換成 Apple 的 Safari content blocker JSON 格式,
過程中:

- 丟棄了該格式無法表達的規則型別(scriptlet 注入、進階選項等);
- 截斷至 45,000 條 —— `WKContentRuleList` 的硬性上限,超過會編譯失敗。

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

## 怎麼重現

`rules/converter/` 附上了完整的轉換器與建置腳本。
