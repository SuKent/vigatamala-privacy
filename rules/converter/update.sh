#!/bin/bash
# GitHub Actions 每日執行:抓上游 → 轉換 → 健全性檢查 → 簽章 → 更新 rules/。
#
# 在 swift:6.1 容器(Ubuntu)內執行。轉換器與 App 內用的是同一份原始碼,
# 同一份輸入產出位元組相同的輸出(編碼器帶 .sortedKeys,Ed25519 是確定性
# 簽章)—— 所以「內容沒變就不會有 diff」,workflow 據此決定要不要 commit。
set -euo pipefail
cd "$(dirname "$0")/../.."
CONV=rules/converter
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

LICENSE_URI="https://creativecommons.org/licenses/by-sa/3.0/legalcode"
ATTRIBUTION="The EasyList authors (https://easylist.to/)"

echo "→ 建置轉換器"
swift build --package-path "$CONV" -c release
BIN="$(swift build --package-path "$CONV" -c release --show-bin-path)/RuleConverter"

sign() {
  # 沒設定金鑰就略過 —— App 會驗簽失敗、退回上游,不會壞,只是少了鏡像的好處。
  [ -n "${RULES_SIGNING_KEY:-}" ] || { echo "  (未設定 RULES_SIGNING_KEY,略過簽章)"; return 0; }
  printf '%s\n' "$RULES_SIGNING_KEY" > "$TMP/key.pem"
  openssl pkeyutl -sign -inkey "$TMP/key.pem" -rawin -in "$1" -out "$TMP/sig.bin"
  base64 -w0 "$TMP/sig.bin" > "$1.sig"
  printf '\n' >> "$1.sig"
  rm -f "$TMP/key.pem" "$TMP/sig.bin"
  echo "  已簽章 $1.sig"
}

notices() {
  grep -m 40 -E '^! *(Title|Version|Last modified|Expires|Commit|Homepage|Licence|License):' "$1" || true
}

process() {
  local name=$1 url=$2 limit=$3 title=$4
  echo "→ $name"
  curl -fsSL --retry 3 --retry-delay 10 --max-time 120 "$url" -o "$TMP/$name.txt"
  # 健全性:Adblock 清單的第一行必是 [Adblock…] 或 ! 註解(擋掉錯誤頁/攔截頁)
  head -1 "$TMP/$name.txt" | grep -qE '^(\[Adblock|!)' || {
    echo "✘ $name 的回應不是過濾清單,整批放棄"; exit 1; }
  "$BIN" "$TMP/$name.txt" "$TMP/$name.json" "$limit"
  local count
  count=$(grep -o '"action"' "$TMP/$name.json" | wc -l | tr -d ' ')
  [ "$count" -ge 5000 ] || { echo "✘ $name 只有 $count 條,不合理,整批放棄"; exit 1; }
  echo "  $count 條"

  cat > "rules/$name.NOTICE.txt" <<NOTICE
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
$(notices "$TMP/$name.txt" | sed 's/^! */  /')
NOTICE

  mv "$TMP/$name.json" "rules/$name.json"
  sign "rules/$name.json"
}

process easylist    "https://easylist.to/easylist/easylist.txt"    45000 "EasyList"
process easyprivacy "https://easylist.to/easylist/easyprivacy.txt" 45000 "EasyPrivacy"
echo "完成"
