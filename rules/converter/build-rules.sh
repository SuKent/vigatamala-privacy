#!/bin/bash
# 下載 EasyList / EasyPrivacy 並轉成內建的 content blocker JSON。
#
# 產出會**進版控**——這是刻意的:免費層的擋廣告能力不該取決於使用者
# 有沒有網路、有沒有訂閱。想更新規則就重跑這支,把結果一起 commit。
#
# ── 授權 ──────────────────────────────────────────────────────────
# EasyList 與 EasyPrivacy 以 GPLv3 或 CC BY-SA 3.0 Unported **雙授權**發布,
# 由使用者擇一。本專案明示選擇 **CC BY-SA 3.0 Unported**(GPLv3 那條路在
# App Store 上不可行:需交付對應原始碼,且與商店條款有已知衝突)。
#
# 轉換產物是原清單的**改作物**(Adaptation)—— 我們不只換格式,還丟棄了
# 不支援的規則型別並截斷至上限,那已超出「技術性必要修改」。因此適用
# CC BY-SA 3.0 §4(b)(改作物須以同一授權散布、須附授權副本或 URI)
# 與 §4(c)(姓名標示、保留著作權通知、標示這是改作)。
#
# Safari content blocker JSON 是裸的頂層陣列,**沒有註解語法**,
# 無法把上游的 `! Licence:` 標頭寫回檔內。所以本腳本另外產生同名的
# `.NOTICE.txt` sidecar,承載那些必須「keep intact」的通知 ——
# 這是這個媒介下唯一能主張「reasonable to the medium」的做法。
# 詳見 Docs/RULES.md。
set -euo pipefail

cd "$(dirname "$0")/.."
CORE=Core/VigatamalaCore
OUT="$CORE/Sources/VigatamalaCore/CoreAssets/Rules"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# 本專案指定給下游的 Applicable License(CC BY-SA 3.0 §4(b) 用語)。
# 必須是 Unported —— 不可用任何管轄權移植版(/3.0/us/、/3.0/tw/…),
# 那是不同的授權文本,標錯等於指定了錯誤的 Applicable License。
LICENSE_URI="https://creativecommons.org/licenses/by-sa/3.0/legalcode"
ATTRIBUTION="The EasyList authors (https://easylist.to/)"

echo "→ 建置轉換器"
swift build --package-path "$CORE" --product RuleBundler -c release >/dev/null
BUNDLER="$CORE/$(swift build --package-path "$CORE" -c release --show-bin-path | sed "s|.*/$CORE/||")/RuleBundler"

# 從上游檔頭抽出必須保留的通知行。
# 只取 metadata 行(Title / Version / Last modified / Expires / Commit /
# Homepage / Licence),不整段照抄 —— 上游檔頭還有數十行使用說明與回報信箱,
# 那些不是著作權通知,抄過來只會讓 NOTICE 變得沒人看。
extract_notices() {
  grep -m 40 -E '^! *(Title|Version|Last modified|Expires|Commit|Homepage|Licence|License):' "$1" || true
}

fetch_and_convert() {
  local name=$1 url=$2 limit=$3 title=$4
  echo "→ 下載 $name"
  curl -fsSL --max-time 120 "$url" -o "$TMP/$name.txt"
  echo "   $(wc -l < "$TMP/$name.txt" | tr -d ' ') 行"
  "$BUNDLER" "$TMP/$name.txt" "$OUT/$name.json" "$limit"

  # ── sidecar 通知(CC BY-SA 3.0 §4(c))────────────────────────────
  cat > "$OUT/$name.NOTICE.txt" <<NOTICE
$title —— Safari content blocker 改作版

姓名標示(Attribution)
  $ATTRIBUTION

授權(Applicable License,CC BY-SA 3.0 §4(b))
  Creative Commons Attribution-ShareAlike 3.0 Unported
  $LICENSE_URI

  上游以 GPLv3 或 CC BY-SA 3.0 Unported 雙授權發布,由使用者擇一;
  本改作版明示採用 CC BY-SA 3.0 Unported。

這是什麼(改作標示,CC BY-SA 3.0 §4(c)(iv))
  本檔為「$title」的改作物:自 Adblock Plus 過濾語法轉換為
  Apple 的 Safari content blocker JSON 格式,過程中丟棄了該格式
  無法表達的規則型別,並截斷至 $limit 條上限。
  原作者未以任何方式為本改作版背書。

上游來源
  $url

上游檔頭的著作權通知(逐字保留)
$(extract_notices "$TMP/$name.txt" | sed 's/^! */  /')
NOTICE
  echo "   已產生 $name.NOTICE.txt"
}

fetch_and_convert easylist    "https://easylist.to/easylist/easylist.txt"    45000 "EasyList"
fetch_and_convert easyprivacy "https://easylist.to/easylist/easyprivacy.txt" 45000 "EasyPrivacy"

echo
echo "完成。產出:"
ls -lh "$OUT"/easylist.json "$OUT"/easyprivacy.json "$OUT"/*.NOTICE.txt | awk '{print "  " $9, $5}'
echo
echo "提醒:規則更新後請一併同步公開鏡像 repo —— ./Tools/sync-rules-mirror.sh"
