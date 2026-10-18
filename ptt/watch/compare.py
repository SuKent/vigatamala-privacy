#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""PTT 站方原始碼（pttbbs）兩個版本之間，App 會受影響的改動（2026-10-18 起）。

為什麼有這支：App 的 PTT 小工具靠站方畫面上的字認畫面、靠按鍵操作。站方 2026-10-13 一次改了
選單標題、列表頁尾、選單按鍵，App 讀信、進看板、查詢使用者全部卡在「沒有預期的畫面」——
而且是一個一個被使用者踩到。這支把那天人工做的比對變成可以重跑的檢查。

用法（要能連 GitHub）：
    python3 Tools/ptt-compat/compare.py <上次比對的 commit> [<這次的 commit，預設 master>]
上次比對到哪一版記在 Docs/PTT-SITE-COMPAT.md 的「比對紀錄」，比完把這次的 commit 寫回去。

規則鏡像（公開 repo、沒有 App 原始碼）每天跑的那一份（Q24）：
    python3 compare.py <起點> master --anchors anchors.json --exit-code
    --anchors：App 用到的站方字串改從清單檔讀（只有字，沒有檔名行號）；
    --exit-code：第 1–3 項有差異時離開碼 1（給排程判斷要不要開 issue）。
清單檔從這裡產生、放到鏡像的 ptt/watch/anchors.json：
    python3 Tools/ptt-compat/compare.py --export-anchors <輸出檔>

做四件事，每一項都印結果：
1. App 的站方字串：PTT 程式裡標了 i18n-exempt 的字（站方協定原文）切成中日韓連續片段，
   在舊版有、新版沒有的列出來（多半要改）；整串在舊版原始碼裡找得到、新版找不到的也列出來。
2. 標題與頁尾：redraw_title／vs_hdr／showtitle、選單的 .title 與 .desc【】、i_read_caption、
   vs_footer 的 caption，新舊版不一樣的列出來 —— 這些是執行時才組出來的字，第 1 項找不到。
3. 按鍵：各檔 `cmd_t xxx[]` 按鍵表的「鍵 → 函式「標籤」」，拿掉、改了、新增的列出來（例：選單的 q 變成回上一層）。
   標籤也比，因為改版後的頁尾是用標籤組出來的（「(a)增加看板」）。
4. 改到的檔與提交清單（給人看要不要再讀 diff）。
⚠️ 站方正式站跑的版本不一定等於 GitHub 上的 master；比完仍要在實機（或看診斷紀錄的 unexpected）確認。
"""
import io, json, os, re, sys, tarfile, urllib.request

TOKEN = os.environ.get("GITHUB_TOKEN")   # 排程裡帶上，避免 GitHub API 未驗證的次數上限

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
APP_DIRS = ["Core/VigatamalaCore/Sources/VigatamalaCore/PTT", "Vigatamala-Browser/PTT"]
CJK_RUN = re.compile(r"[　-〿㐀-鿿＀-￯]{2,}")
LIT = re.compile(r'#"(.*?)"#|"((?:[^"\\\n]|\\.)*)"')


def fetch(ref):
    """抓 pttbbs 某個 commit 的原始碼，.c/.h/.cc 轉成 UTF-8（站方大多是 Big5）。回傳 {相對路徑: 內容}。"""
    url = f"https://codeload.github.com/ptt/pttbbs/tar.gz/{ref}"
    data = urllib.request.urlopen(url, timeout=60).read()
    files = {}
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
        for m in tar.getmembers():
            if not m.isfile() or not m.name.endswith((".c", ".h", ".cc")):
                continue
            raw = tar.extractfile(m).read()
            try:
                text = raw.decode("utf-8")
            except UnicodeDecodeError:
                text = unescape_big5(raw.decode("cp950", errors="replace"))
            files[m.name.split("/", 1)[1]] = text
    return files


def unescape_big5(text):
    """Big5 原始碼裡第二個位元組是 0x5C（反斜線）的字（功、閱…）後面要多寫一個 `\\` 跳脫，
    解碼後變成「功\\能」。站方 10-13 改版把檔案轉成 UTF-8 後寫成「功能」——不拿掉就會被當成改字。"""
    out, i = [], 0
    while i < len(text):
        ch = text[i]
        out.append(ch)
        if ord(ch) > 0x7F and text[i + 1:i + 2] == "\\":
            try:
                b = ch.encode("cp950")
            except UnicodeEncodeError:
                b = b""
            if len(b) == 2 and b[1] == 0x5C:
                i += 2
                continue
        i += 1
    return "".join(out)


def resolve(ref):
    headers = {"Accept": "application/vnd.github+json"}
    if TOKEN:
        headers["Authorization"] = f"Bearer {TOKEN}"
    req = urllib.request.Request(f"https://api.github.com/repos/ptt/pttbbs/commits/{ref}", headers=headers)
    d = json.load(urllib.request.urlopen(req, timeout=30))
    return d["sha"], d["commit"]["committer"]["date"]


def app_anchors():
    out = []
    for d in APP_DIRS:
        for f in sorted(os.listdir(os.path.join(REPO, d))):
            if not f.endswith(".swift"):
                continue
            lines = open(os.path.join(REPO, d, f), encoding="utf-8").read().split("\n")
            for i, line in enumerate(lines):
                if "i18n-exempt" not in line and not (i and "i18n-exempt" in lines[i - 1]):
                    continue
                code = "" if line.strip().startswith("//") else line.split("//")[0]
                for m in LIT.finditer(code):
                    s = m.group(1) if m.group(1) is not None else m.group(2)
                    if s and CJK_RUN.search(s):
                        out.append((f, i + 1, s))
    return out


def titles_and_captions(files):
    pat = [
        r'(?:redraw_title|vs_hdr|showtitle|vs_hdr2|vs_hdr2bar)\(\s*"([^"]+)"',
        r'\.title\s*=\s*"([^"]+)"',
        r'\.desc\s*=\s*"[^"]*?【\s*([^】]*?)\s*】',
        r'caption\s*=\s*"([^"]+)"',
        r'vs_footer\(\s*"\s*([^"]*?)\s*"',
        r'return\s+"([^"]+)";\s*$',
    ]
    # 字 → 出現在哪些檔。比的是字（換了檔案不算改，例：舉辦樂透從 gamble.c 搬到 lottery.c）。
    found = {}
    for path, text in files.items():
        if not path.startswith("mbbsd/"):
            continue
        for p in pat:
            for m in re.finditer(p, text, re.M):
                v = m.group(1).strip()
                if CJK_RUN.search(v):
                    found.setdefault(v, set()).add(os.path.basename(path))
    return found


def key_tables(files):
    tables = {}
    for path, text in files.items():
        if not path.startswith("mbbsd/"):
            continue
        for m in re.finditer(r"(?:static\s+)?const\s+cmd_t\s+(\w+)\s*\[\]\s*=\s*\{(.*?)\n\};", text, re.S):
            entries = {}
            for e in re.finditer(r"\{\s*([^,{}]+?)\s*,(.*?)\}", m.group(2), re.S):
                key = e.group(1).strip()
                # 只收看得出是按鍵的欄位：'x'、KEY_*、Ctrl('x')、Meta('x')（psb.c 的按鈕表等別的結構不算）。
                if not re.fullmatch(r"'(?:\\.|.)'|KEY_\w+|(?:Ctrl|Meta)\('.'\)", key):
                    continue
                rest = re.sub(r'"(?:[^"\\]|\\.)*"', '""', e.group(2))
                names = [n for n in re.findall(r"\b([a-z_][a-z0-9_]*)\b", rest)
                         if n not in ("true", "false", "NULL")]
                # 標籤（第一個字串）也要比：改版後的頁尾由 vs_cmd_bar 用「(" 鍵 ")" 標籤」組出來，
                # App 認我的最愛靠的「(a)增加看板」就是這樣來的 —— 標籤改字，頁尾的錨就跟著不見。
                label = re.search(r'"((?:[^"\\]|\\.)*)"', e.group(2))
                entries[key] = (names[0] if names else "?") + (f"「{label.group(1)}」" if label and label.group(1) else "")
            tables[f"{os.path.basename(path)} {m.group(1)}"] = entries
    return tables


def main():
    args = sys.argv[1:]
    def option(name):
        if name in args:
            i = args.index(name)
            value = args[i + 1]
            del args[i:i + 2]
            return value
        return None
    export = option("--export-anchors")
    anchors_file = option("--anchors")
    exit_code = "--exit-code" in args
    if exit_code:
        args.remove("--exit-code")
    if export:
        strings = sorted({s for _, _, s in app_anchors()})
        json.dump(strings, open(export, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print(f"✔ {len(strings)} 個站方字串 → {export}")
        return
    if not args:
        print(__doc__)
        sys.exit(2)
    old_ref, new_ref = args[0], (args[1] if len(args) > 1 else "master")
    anchors = ([("anchors.json", i + 1, s) for i, s in enumerate(json.load(open(anchors_file, encoding="utf-8")))]
               if anchors_file else app_anchors())
    old_sha, old_date = resolve(old_ref)
    new_sha, new_date = resolve(new_ref)
    print(f"舊：{old_sha[:10]}（{old_date}）→ 新：{new_sha[:10]}（{new_date}）")
    old, new = fetch(old_sha), fetch(new_sha)
    old_all, new_all = "\n".join(old.values()), "\n".join(new.values())

    print("\n== 1. App 的站方字串：舊版有、新版沒有")
    lost = 0
    for f, line, s in anchors:
        gone = [fr for fr in CJK_RUN.findall(s) if fr in old_all and fr not in new_all]
        # 整串也比：片段都還在、但整句改了（多一個空白、換了括號裡的鍵）時，只比片段看不出來。
        # 只在舊版原始碼裡找得到整串時才算（App 的錨常是站方拼起來的一段，整串本來就不在原始碼裡）。
        whole = s.strip()
        whole_gone = len(whole) > 1 and whole in old_all and whole not in new_all
        if gone or whole_gone:
            lost += 1
            why = f"不見了：{'、'.join(gone)}" if gone else "片段都在，但整串不見了"
            print(f"  ✘ {f}:{line}  {s[:60]}  → {why}")
    print(f"  共 {lost} 處" if lost else "  ✔ 沒有")

    print("\n== 2. 標題與頁尾（執行時組出來的字）")
    to, tn = titles_and_captions(old), titles_and_captions(new)
    titles_changed = set(to) != set(tn)
    for v in sorted(set(to) - set(tn)):
        print(f"  － 只在舊版：「{v}」（{'、'.join(sorted(to[v]))}）")
    for v in sorted(set(tn) - set(to)):
        print(f"  ＋ 只在新版：「{v}」（{'、'.join(sorted(tn[v]))}）")
    if set(to) == set(tn):
        print("  ✔ 沒有差異")

    print("\n== 3. 按鍵表（cmd_t）")
    ko, kn = key_tables(old), key_tables(new)
    changed = False
    for name in sorted(set(ko) | set(kn)):
        a, b = ko.get(name, {}), kn.get(name, {})
        removed = sorted(set(a) - set(b)); added = sorted(set(b) - set(a))
        diff = sorted(k for k in set(a) & set(b) if a[k] != b[k])
        if removed or added or diff:
            changed = True
            print(f"  {name}：")
            if removed: print("    拿掉：" + ", ".join(f"{k}→{a[k]}" for k in removed))
            if diff: print("    換了：" + ", ".join(f"{k}: {a[k]}→{b[k]}" for k in diff))
            if added: print("    新增：" + ", ".join(f"{k}→{b[k]}" for k in added))
    if not changed:
        print("  ✔ 沒有差異")

    print("\n== 4. 改到的檔")
    touched = sorted(p for p in set(old) | set(new) if old.get(p) != new.get(p))
    print("  " + " ".join(touched) if touched else "  （沒有）")
    print(f"\n比完把 {new_sha} 與日期寫回 Docs/PTT-SITE-COMPAT.md 的「比對紀錄」。")
    if exit_code and (lost or titles_changed or changed):
        sys.exit(1)


if __name__ == "__main__":
    main()
