#!/bin/bash
# PTT 相容表（ptt/compat.json）簽章 → ptt/compat.json.sig2（2026-10-18，Vigatamala 1.6.1 build 28 起的 App 讀）。
#
# 格式同規則的 .sig2：第一行 UTC 時間戳、第二行 base64 的 Ed25519 簽章，簽章對象是「時間戳的字＋檔案原始位元組」。
# App 拒收：簽章不對、時間戳比手上那一份舊、format 不是它認得的。金鑰同規則（RULES_SIGNING_KEY）。
# 內容規格與「只放字、不放按鍵」的理由在 App repo 的 Docs/PTT-SITE-COMPAT.md「遠端相容表」。
set -euo pipefail
cd "$(dirname "$0")/.."
[ -n "${RULES_SIGNING_KEY:-}" ] || { echo "✘ 未設定 RULES_SIGNING_KEY，拒絕簽章（不簽等於發布一份 App 會拒收的表）。"; exit 1; }

# 先擋寫錯的表：App 也會檢查，但在這裡紅比讓所有人的 App 默默拒收好查。
python3 - <<'PY'
import json, sys
d = json.load(open("ptt/compat.json", encoding="utf-8"))
assert d.get("format") == 1, "format 必須是 1"
aliases = d.get("aliases", [])
assert isinstance(aliases, list) and len(aliases) <= 200, "aliases 最多 200 組"
for a in aliases:
    site, app = a.get("site"), a.get("app")
    for s in (site, app):
        assert isinstance(s, str) and len(s) <= 80 and len("".join(s.split())) >= 2, f"換字不合格：{a}"
        assert not any(ord(c) < 0x20 or ord(c) == 0x7F for c in s), f"有控制字元：{a}"
    assert site != app, f"兩邊一樣：{a}"
notice = d.get("notice")
if notice is not None:
    assert "zh-Hant" in notice.get("text", {}), "公告一定要有 zh-Hant"
    for v in notice["text"].values():
        assert isinstance(v, str) and 0 < len(v) <= 400, "公告每則 1–400 字"
print(f"✔ 格式正確：{len(aliases)} 組換字，公告 {'有' if notice else '無'}")
PY

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '%s\n' "$RULES_SIGNING_KEY" > "$TMP/key.pem"
{ printf '%s' "$STAMP"; cat ptt/compat.json; } > "$TMP/message.bin"
openssl pkeyutl -sign -inkey "$TMP/key.pem" -rawin -in "$TMP/message.bin" -out "$TMP/sig.bin"
printf '%s\n%s\n' "$STAMP" "$(base64 -w0 "$TMP/sig.bin")" > ptt/compat.json.sig2
echo "✔ 已簽章 ptt/compat.json.sig2（$STAMP）"
