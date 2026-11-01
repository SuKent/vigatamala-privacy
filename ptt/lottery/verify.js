// PTT 推文抽獎驗證頁（2026-11-02 使用者：「做一個驗證網頁」）。
// 算法與 App 的 Core `PTTLottery.draw` 相同：第 k 名 = SHA-256(UTF-8「種子-k」) 前 8 個位元組（大端）
// 除以還沒中獎的人數取餘數 r，還沒中獎的編號由小到大第 r+1 個。
// 全部在瀏覽器裡算：不連網、不存任何東西、貼上的內容一律用 textContent 顯示（不經 innerHTML）。
// 純函式掛在 globalThis.PTTLotteryVerify，`verify.test.mjs` 拿 App 產生的回文樣本對照。
(function () {
  "use strict";

  var MAX_INPUT = 300000;   // 貼上的字數上限（200 名、幾千人的回文約 10 萬字）
  var MAX_ENTRIES = 100000;
  var MAX_WINNERS = 1000;

  // PTT 色碼（*[1;33m）與終端機的 ANSI 碼（ESC[1;33m）都拿掉。
  function stripColors(text) {
    return text.replace(/\*\[[0-9;]*m/g, "").replace(/\u001b\[[0-9;]*m/g, "");
  }

  async function pick(k, seed) {
    var bytes = new TextEncoder().encode(seed + "-" + k);
    var digest = new Uint8Array(await crypto.subtle.digest("SHA-256", bytes));
    var value = 0n;
    for (var i = 0; i < 8; i++) value = (value << 8n) | BigInt(digest[i]);
    return value;
  }

  // 回傳中獎編號（1 起算），照名次排。
  async function draw(seed, entryCount, winnerCount) {
    var remaining = [];
    for (var n = 1; n <= entryCount; n++) remaining.push(n);
    var winners = [];
    for (var k = 1; k <= winnerCount; k++) {
      var value = await pick(k, seed);
      var r = Number(value % BigInt(remaining.length));
      winners.push({ rank: k, number: remaining.splice(r, 1)[0], hex: value.toString(16).padStart(16, "0"), r: r, left: remaining.length + 1 });
    }
    return winners;
  }

  // 從回文讀出種子、人數、名額、參加名單、中獎名單。讀不到的欄位是 null。
  function parseReply(raw) {
    var text = stripColors(raw).replace(/\r\n?/g, "\n").replace(/　/g, " ");
    var result = { seed: null, entryCount: null, winnerCount: null, participants: null, winners: [], problems: [] };
    var seed = text.match(/種子\s*[：:]\s*(\S+)/);
    if (seed) result.seed = seed[1];
    var range = text.match(/編號\s*1\s*[～~\-]\s*(\d+)\s*[）)]/);
    if (range) result.entryCount = parseInt(range[1], 10);
    var quota = text.match(/中獎名額\s*[：:]\s*(\d+)\s*名/);
    if (quota) result.winnerCount = parseInt(quota[1], 10);

    var lines = text.split("\n");
    var section = null;
    var participants = [];
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      var header = line.match(/【([^】]+)】/);
      if (header) { section = header[1].trim(); continue; }
      if (section === "中獎名單") {
        var w = line.match(/第\s*(\d+)\s*名\s+編號\s+(\d+)\s+(\S+)/);
        if (w) result.winners.push({ rank: parseInt(w[1], 10), number: parseInt(w[2], 10), userID: w[3] });
      } else if (section === "參加名單") {
        var pair = /(\d+)\s+([A-Za-z0-9_]+)/g, m;
        while ((m = pair.exec(line)) !== null) participants.push({ number: parseInt(m[1], 10), userID: m[2] });
      }
    }
    if (participants.length) result.participants = participants;
    return result;
  }

  // 核對：照種子重算，跟回文上的中獎名單逐名比，順便檢查名單本身。
  async function verifyReply(raw) {
    var p = parseReply(raw);
    var report = { parsed: p, computed: [], checks: [], ok: false };
    function check(ok, text) { report.checks.push({ ok: ok, text: text }); }

    if (!p.seed) { check(false, "找不到「種子：」那一行。請把整篇抽獎回文貼上（含【驗證方式】）。"); return report; }
    var count = p.entryCount != null ? p.entryCount : (p.participants ? p.participants.length : null);
    if (count == null) { check(false, "找不到參加人數（「編號 1～N」）或【參加名單】。"); return report; }
    var winnersWanted = p.winnerCount != null ? p.winnerCount : p.winners.length;
    if (!winnersWanted) { check(false, "找不到中獎名額或【中獎名單】。"); return report; }
    if (count < 1 || count > MAX_ENTRIES) { check(false, "參加人數不合理：" + count); return report; }
    if (winnersWanted > count || winnersWanted > MAX_WINNERS) { check(false, "中獎名額（" + winnersWanted + "）比參加人數多或太多。"); return report; }

    if (p.participants) {
      var numbersOK = p.participants.length === count && p.participants.every(function (e, i) { return e.number === i + 1; });
      check(numbersOK, numbersOK
        ? "參加名單編號 1～" + count + " 連續、沒有缺號或重號。"
        : "參加名單的編號不是 1～" + count + " 連續（讀到 " + p.participants.length + " 個）。可能是貼上時少了幾行。");
    } else {
      check(true, "沒有貼到【參加名單】，只能核對中獎編號，不能核對帳號。");
    }
    if (p.winnerCount != null && p.winners.length) {
      check(p.winners.length === p.winnerCount, "中獎名單有 " + p.winners.length + " 名，回文寫的名額是 " + p.winnerCount + " 名。");
    }

    report.computed = await draw(p.seed, count, winnersWanted);
    var byNumber = {};
    if (p.participants) p.participants.forEach(function (e) { byNumber[e.number] = e.userID; });
    report.computed.forEach(function (c) { c.userID = byNumber[c.number] || null; });

    if (p.winners.length) {
      var allMatch = p.winners.length === report.computed.length;
      report.computed.forEach(function (c) {
        var listed = p.winners.find(function (w) { return w.rank === c.rank; });
        c.listed = listed || null;
        c.match = !!listed && listed.number === c.number && (!c.userID || listed.userID === c.userID);
        if (!c.match) allMatch = false;
      });
      check(allMatch, allMatch
        ? "照種子重算的 " + report.computed.length + " 名，跟回文上的中獎名單（名次、編號、帳號）完全一樣。"
        : "照種子重算的結果跟回文上的中獎名單不一樣（見下表標紅的名次）。");
    } else {
      check(true, "沒有貼到【中獎名單】，下表是照種子算出來的結果。");
    }
    report.ok = report.checks.every(function (c) { return c.ok; });
    return report;
  }

  var api = { stripColors: stripColors, pick: pick, draw: draw, parseReply: parseReply, verifyReply: verifyReply,
              MAX_INPUT: MAX_INPUT, MAX_ENTRIES: MAX_ENTRIES, MAX_WINNERS: MAX_WINNERS };
  globalThis.PTTLotteryVerify = api;

  if (typeof document === "undefined") return;

  // ── 畫面 ──
  function el(tag, cls, text) {
    var node = document.createElement(tag);
    if (cls) node.className = cls;
    if (text != null) node.textContent = text;
    return node;
  }

  function renderTable(target, rows, showListed) {
    var table = el("table");
    var head = el("tr");
    ["名次", "編號", "帳號"].concat(showListed ? ["回文上寫的"] : []).concat(["SHA-256 前 8 位元組", "÷ 剩幾人", "餘數 r"])
      .forEach(function (h) { head.appendChild(el("th", null, h)); });
    table.appendChild(head);
    rows.forEach(function (c) {
      var tr = el("tr", showListed ? (c.match ? "match" : "mismatch") : null);
      tr.appendChild(el("td", null, String(c.rank)));
      tr.appendChild(el("td", null, String(c.number)));
      tr.appendChild(el("td", "mono", c.userID || "—"));
      if (showListed) tr.appendChild(el("td", "mono", c.listed ? "編號 " + c.listed.number + " " + c.listed.userID : "（沒有這一名）"));
      tr.appendChild(el("td", "mono", c.hex));
      tr.appendChild(el("td", null, String(c.left)));
      tr.appendChild(el("td", null, String(c.r)));
      table.appendChild(tr);
    });
    var wrap = el("div", "table-wrap");
    wrap.appendChild(table);
    target.appendChild(wrap);
  }

  function showError(target, text) {
    target.replaceChildren();
    var box = el("div", "verdict bad");
    box.appendChild(el("strong", null, text));
    target.appendChild(box);
  }

  function setup() {
    if (!(globalThis.crypto && crypto.subtle && typeof BigInt === "function")) {
      showError(document.getElementById("reply-result"), "這個瀏覽器不支援需要的計算（Web Crypto 或 BigInt），請換一個新一點的瀏覽器。");
      return;
    }
    var replyInput = document.getElementById("reply");
    var replyResult = document.getElementById("reply-result");
    document.getElementById("verify-reply").addEventListener("click", async function () {
      var raw = replyInput.value;
      if (!raw.trim()) { showError(replyResult, "請先貼上抽獎回文。"); return; }
      if (raw.length > MAX_INPUT) { showError(replyResult, "貼上的內容太長（超過 " + MAX_INPUT + " 字）。"); return; }
      var report = await verifyReply(raw);
      replyResult.replaceChildren();
      var verdict = el("div", "verdict " + (report.ok ? "good" : "bad"));
      verdict.appendChild(el("strong", null, report.ok ? "✔ 對得上" : "✘ 對不上"));
      var list = el("ul");
      report.checks.forEach(function (c) { list.appendChild(el("li", c.ok ? "ok" : "ng", (c.ok ? "✔ " : "✘ ") + c.text)); });
      verdict.appendChild(list);
      replyResult.appendChild(verdict);
      if (report.computed.length) {
        replyResult.appendChild(el("p", "note", "種子：" + report.parsed.seed + "　參加 " + report.computed[0].left + " 人"));
        renderTable(replyResult, report.computed, report.parsed.winners.length > 0);
      }
    });
    document.getElementById("clear-reply").addEventListener("click", function () {
      replyInput.value = "";
      replyResult.replaceChildren();
    });

    var manualResult = document.getElementById("manual-result");
    document.getElementById("verify-manual").addEventListener("click", async function () {
      var seed = document.getElementById("seed").value.trim();
      var entries = parseInt(document.getElementById("entries").value, 10);
      var winners = parseInt(document.getElementById("winners").value, 10);
      if (!seed || /\s/.test(seed) || seed.length > 200) { showError(manualResult, "請輸入回文上的種子（不含空白）。"); return; }
      if (!(entries >= 1 && entries <= MAX_ENTRIES)) { showError(manualResult, "參加人數要在 1～" + MAX_ENTRIES + "。"); return; }
      if (!(winners >= 1 && winners <= Math.min(entries, MAX_WINNERS))) { showError(manualResult, "中獎名額要在 1～" + Math.min(entries, MAX_WINNERS) + "。"); return; }
      var rows = await draw(seed, entries, winners);
      manualResult.replaceChildren();
      manualResult.appendChild(el("p", "note", "照種子算出的中獎編號，請對照回文【參加名單】上的帳號："));
      renderTable(manualResult, rows, false);
    });
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", setup);
  else setup();
})();
