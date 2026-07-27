# Regression suite for md_to_html_viewer.
#
#   .\tools\Test-Viewer.ps1
#
# Runs three passes in headless Edge: the main suite (parsing, sanitizing,
# palettes, controls, chrome), the drag & drop handle path, and the sidecar
# bootstrap used by open-md.cmd. Exits non-zero if anything fails.
#
# PowerShell + Edge only. No node, no npm.

$ErrorActionPreference = 'Stop'
$run = Join-Path $PSScriptRoot 'Invoke-ViewerPage.ps1'

# Shared preamble. window.onerror misses async failures inside loadFiles(), so
# unhandledrejection has to be listened for separately or a broken promise just
# looks like "nothing happened".
$preamble = @'
<pre id="probe"></pre>
<script>
window.addEventListener("error", (e) => {
  const P = document.getElementById("probe");
  if (P) P.textContent += "[PAGE ERROR] " + e.message + " @" + e.lineno + "\n";
});
window.addEventListener("unhandledrejection", (e) => {
  const P = document.getElementById("probe");
  const r = e.reason;
  if (P) P.textContent += "[REJECTION] " + (r && (r.stack || r.message) || r) + "\n";
});
// --virtual-time-budget fast-forwards TIMERS but not real work: a File.text()
// read still costs wall-clock time, so a fixed sleep elapses instantly in
// virtual time and asserts before the work lands. Poll for the condition and
// count iterations rather than trusting the clock (Date.now() jumps too).
async function waitFor(fn, tries) {
  for (let i = 0; i < (tries || 150); i++) {
    try { if (fn()) return true; } catch (e) { /* not ready yet */ }
    await new Promise(r => setTimeout(r, 40));
  }
  return false;
}
'@

# ---------------------------------------------------------------- pass 1
# Mermaid renders async; allow ~2.5s of virtual time before asserting.
$mainHarness = $preamble + @'
(async () => {
  const P = document.getElementById("probe");
  const wait = (ms) => new Promise(r => setTimeout(r, ms));
  const el = (id) => document.getElementById(id);
  let pass = 0, fail = 0;
  const check = (n, cond, note) => {
    if (cond) { pass++; } else { fail++; P.textContent += "  FAIL  " + n + (note ? "  -- " + note : "") + "\n"; }
  };

  // Mermaid renders async; wait for the SVG rather than guessing a duration.
  await waitFor(() => document.querySelector(".mermaid-block svg"));
  const doc = el("doc");
  const H = doc.innerHTML;
  const has = (n, s) => check(n, H.includes(s), "missing: " + s);

  // ---- block + inline parsing ----
  has("frontmatter", '<details class="frontmatter">');
  has("h1 anchor", '<h1 id="heading-one"><a class="anchor"');
  has("setext h1", 'id="setext-heading"');
  has("bold", "<strong>bold</strong>");
  has("italic", "<em>italic</em>");
  has("bold+italic", "<em><strong>both</strong></em>");
  has("code span", "<code>code span</code>");
  has("strikethrough", "<del>struck</del>");
  has("highlight", "<mark>marked</mark>");
  check("snake_case not italicised", !H.includes("<em>case</em>"));
  has("backslash escape", "*literal asterisk*");
  has("external link opens new tab", 'target="_blank"');
  has("in-page anchor has no target", '<a href="#heading-one">Anchor</a>');
  has("autolink", 'href="https://bare.example.com"');
  has("bare url linkified", "auto.example.com");
  has("nested lists", "<ul><li>level one<ul><li>nested two<ol>");
  has("ordered list start", '<ol start="3">');
  has("task list checked", '<input type="checkbox" disabled="" checked=""');
  has("table alignment", '<th align="center">Center</th>');
  has("escaped pipe in code cell", "<code>x|y</code>");
  has("definition list", "<dt>Term A</dt>");
  has("blockquote", "<blockquote>");
  has("footnote reference", 'class="fnref"');
  has("footnote body", 'id="fn-note"');
  check("unknown footnote left as text", doc.textContent.includes("[^ghost]"));
  has("js highlighting", '<span class="tok-kw">const</span>');
  has("python highlighting", '<span class="tok-kw">def</span>');
  has("code language label", '<span class="code-lang">js</span>');
  has("copy button", 'class="code-copy"');
  has("indented code block", "indented code block");
  has("horizontal rule", "<hr>");

  // ---- mermaid ----
  check("mermaid renders to svg", /<div class="mermaid-block"[^>]*>\s*<svg/.test(H));
  check("no mermaid error box", !H.includes("mermaid-error"));

  // ---- safety, raw HTML off ----
  check("no javascript: url survives", !/href="javascript:/.test(H));
  has("javascript: defanged to #", '<a href="#">click me</a>');
  check("no live script element", !/<script/i.test(H));
  has("raw html escaped to text", "&lt;img src=x onerror=");

  // ---- chrome ----
  check("TOC built", el("toc-list").querySelectorAll("a").length >= 7);
  check("TOC nesting", !!el("toc-list").querySelector(".lv2"));
  check("word count shown", /\d+ words/.test(el("doc-meta").textContent));
  // Counts controls only: the filename is a button too, but it is the document
  // label made interactive rather than another control competing for space.
  const bar = el("bar").querySelectorAll(":scope > button.btn, :scope > .pop-wrap > button.btn").length;
  check("toolbar stays at 4 controls", bar === 4, "got " + bar);

  // ---- source path panel ----
  el("doc-name").click(); await wait(80);
  check("path panel opens from the filename", !el("pop-path").hidden);
  // Arrived via #md64, which carries a name but no path, so the panel falls
  // back to the filename and explains why the rest is missing.
  check("path field falls back to filename", el("path-field").value === "fixture.md",
    el("path-field").value);
  check("explains a missing path", el("path-note").textContent.includes("Filename only"),
    el("path-note").textContent);
  check("copy enabled when there is something to copy", !el("btn-copy-path").disabled);
  window.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));
  await wait(60);

  // ---- text size + bold ----
  const V = (n) => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
  const artPx = () => parseFloat(getComputedStyle(doc).fontSize);
  const codePx = () => parseFloat(getComputedStyle(doc.querySelector("pre code")).fontSize);
  el("btn-display").click(); await wait(80);
  const base = artPx(), baseCode = codePx();
  for (let i = 0; i < 3; i++) el("btn-bigger").click();
  await wait(80);
  check("text scales up", artPx() > base);
  check("code scales with text",
    Math.abs((codePx() / baseCode) - (artPx() / base)) < 0.01,
    "text " + (artPx()/base).toFixed(3) + " vs code " + (codePx()/baseCode).toFixed(3));
  check("mermaid zoom tracks text", Math.abs(parseFloat(V("--doc-zoom")) - artPx() / 15.5) < 0.01);
  for (let i = 0; i < 60; i++) el("btn-smaller").click();
  await wait(80);
  check("clamps at minimum", el("btn-smaller").disabled);
  el("btn-font-reset").click(); await wait(80);
  check("reset returns to 100%", artPx() === 15.5);
  el("chk-bold").click(); await wait(80);
  check("bold raises body weight", V("--doc-weight") === "600");
  check("bold keeps strong heavier", V("--doc-strong") === "800");
  el("chk-bold").click(); await wait(80);

  // ---- all 12 palettes, contrast measured from resolved styles ----
  const rgb = (s) => (s.match(/[\d.]+/g) || []).slice(0, 3).map(Number);
  const lin = (c) => { c /= 255; return c <= 0.03928 ? c/12.92 : Math.pow((c+0.055)/1.055, 2.4); };
  const lum = (s) => { const [r,g,b] = rgb(s); return 0.2126*lin(r)+0.7152*lin(g)+0.0722*lin(b); };
  const ratio = (a,b) => { const x=lum(a), y=lum(b); const [h,l] = x>y?[x,y]:[y,x]; return (h+0.05)/(l+0.05); };
  const seg = (id,v) => document.querySelector(id + ' button[data-v="' + v + '"]');
  const fams = { light: ["white","beige"], dark: ["blue","slate"] };
  let worstBody = 99, worstRule = 99, seen = 0;
  for (const mode of ["light","dark"]) {
    seg("#seg-mode", mode).click(); await wait(50);
    for (const fam of fams[mode]) {
      seg("#seg-family", fam).click(); await wait(40);
      for (const lvl of ["1","2","3"]) {
        seg("#seg-level", lvl).click(); await wait(40);
        seen++;
        check("palette " + fam + "-" + lvl,
          document.documentElement.getAttribute("data-pal") === fam + "-" + lvl);
        const bg = getComputedStyle(document.body).backgroundColor;
        worstBody = Math.min(worstBody, ratio(getComputedStyle(doc.querySelector("p")).color, bg));
        worstRule = Math.min(worstRule, ratio(getComputedStyle(doc.querySelector("td")).borderTopColor, bg));
      }
    }
  }
  check("all 12 palettes reachable", seen === 12, "saw " + seen);
  check("body contrast >= 10:1 in every palette", worstBody >= 10, worstBody.toFixed(2) + ":1");
  check("table rules visible in every palette", worstRule >= 1.2, worstRule.toFixed(2) + ":1");

  // ---- family options swap with mode ----
  const visible = () => Array.from(document.querySelectorAll("#seg-family button"))
    .filter(b => !b.hidden).map(b => b.dataset.v).join(",");
  seg("#seg-mode", "dark").click(); await wait(50);
  check("dark shows blue,slate", visible() === "blue,slate", visible());
  seg("#seg-mode", "light").click(); await wait(50);
  check("light shows white,beige", visible() === "white,beige", visible());

  // ---- per-mode memory ----
  seg("#seg-family", "white").click(); seg("#seg-level", "3").click(); await wait(60);
  seg("#seg-mode", "dark").click(); seg("#seg-family", "slate").click();
  seg("#seg-level", "2").click(); await wait(60);
  seg("#seg-mode", "light").click(); await wait(60);
  check("light choice remembered", document.documentElement.getAttribute("data-pal") === "white-3",
    document.documentElement.getAttribute("data-pal"));
  seg("#seg-mode", "dark").click(); await wait(60);
  check("dark choice remembered", document.documentElement.getAttribute("data-pal") === "slate-2",
    document.documentElement.getAttribute("data-pal"));

  // ---- Match system ----
  el("chk-auto").click(); await wait(80);
  check("auto ticks on", el("chk-auto").checked);
  const osDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  check("auto follows the OS",
    document.documentElement.getAttribute("data-pal").startsWith(osDark ? "slate" : "white"),
    "os dark=" + osDark + " pal=" + document.documentElement.getAttribute("data-pal"));
  check("auto shows which mode won", el("auto-hint").textContent.includes(osDark ? "dark" : "light"));
  const pinned = document.documentElement.getAttribute("data-pal");
  el("chk-auto").click(); await wait(80);
  check("unticking pins what was on screen",
    document.documentElement.getAttribute("data-pal") === pinned, pinned);
  // Choosing a mode explicitly must release auto.
  el("chk-auto").click(); await wait(60);
  seg("#seg-mode", "dark").click(); await wait(60);
  check("explicit mode releases auto", !el("chk-auto").checked);
  check("auto persisted in storage",
    JSON.parse(localStorage.getItem("mdv:appearance")).auto === false);

  // ---- popovers ----
  document.body.click(); await wait(60);
  check("popover closes on outside click", el("pop-display").hidden);
  el("btn-more").click(); await wait(60);
  check("more menu opens", !el("pop-more").hidden);
  el("btn-display").click(); await wait(60);
  check("opening one closes the other", el("pop-more").hidden && !el("pop-display").hidden);
  window.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));
  await wait(60);
  check("closes on Escape", el("pop-display").hidden);

  // ---- sync pill, no handle (doc arrived via #md64) ----
  check("sync pill visible", !el("sync").hidden);
  check("offers Enable live reload", !el("btn-connect").hidden);
  check("refresh hidden without a handle", el("btn-refresh").hidden);
  check("connect explains itself", el("btn-connect").title.includes("cannot retain file access"));

  P.textContent += "\n" + pass + " passed, " + fail + " failed\n";
})();
</script>
'@

$torture = @'
---
title: Torture Test
author: Scott
---

# Heading One

Intro with **bold**, *italic*, ***both***, `code span`, ~~struck~~, ==marked==,
a snake_case_name, and an escaped \*literal asterisk\*.

Setext Heading
==============

## Links

[External](https://example.com "Title") Â· [Anchor](#heading-one) Â· <https://bare.example.com> Â·
bare https://auto.example.com/x?a=1&b=2 link.

A footnote[^note] and an unknown[^ghost].

[^note]: The footnote body.

## Lists

- level one
  - nested two
    1. ordered three
    2. second
- [x] done task
- [ ] pending task

3. starts at three
4. four

## Table

| Left | Center | Right |
|:-----|:------:|------:|
| a    | b      | c     |
| `x\|y` | cell | 42 |

## Definition list

Term A
: First definition

## Blockquote

> Quoted **text**.

## Code

```js
const re = /a\/b/g;
```

```python
def f(x):
    return x
```

```mermaid
graph TD
  A[Start] --> B{Choice}
```

    indented code block

## Safety

[click me](javascript:alert(1)) must be defanged.

<img src=x onerror="alert(1)"> <script>alert(2)</script>

***

Final paragraph.
'@

# ---------------------------------------------------------------- pass 2
# A real OS drag can't be synthesised headlessly, but the code path can: fire a
# drop carrying items whose getAsFileSystemHandle() resolves the way Chromium's
# does. Drops need ~900ms to settle, not 700.
$dropHarness = $preamble + @'
(async () => {
  const P = document.getElementById("probe");
  const wait = (ms) => new Promise(r => setTimeout(r, ms));
  const el = (id) => document.getElementById(id);
  let pass = 0, fail = 0;
  const check = (n, cond, note) => {
    if (cond) { pass++; } else { fail++; P.textContent += "  FAIL  " + n + (note ? "  -- " + note : "") + "\n"; }
  };
  await waitFor(() => document.getElementById("btn-display"));

  check("getAsFileSystemHandle exists on file://",
    typeof DataTransferItem.prototype.getAsFileSystemHandle === "function");

  const withHandleFile = new File(["# Dropped\n\nrevision 0"], "dropped.md", { type: "text/markdown" });
  const plainFile = new File(["# Plain\n\nno handle here"], "plain.md", { type: "text/markdown" });
  let n = 0;
  const fakeHandle = {
    kind: "file", name: "dropped.md",
    getFile: async () => ({
      lastModified: Date.now() + (++n) * 1000,
      name: "dropped.md",
      text: async () => "# Dropped\n\nrevision " + n,
    }),
  };
  const makeDrop = (withHandle) => {
    const ev = new Event("drop", { bubbles: true, cancelable: true });
    Object.defineProperty(ev, "dataTransfer", { value: {
      files: [withHandle ? withHandleFile : plainFile],
      items: [{ kind: "file", getAsFileSystemHandle: withHandle
        ? async () => fakeHandle
        : async () => { throw new Error("not supported"); } }],
      types: ["Files"],
    }});
    return ev;
  };

  window.dispatchEvent(makeDrop(true));
  check("dropped doc renders",
    await waitFor(() => el("doc").textContent.includes("Dropped")));
  check("drop arms live reload", el("btn-connect").hidden);
  check("refresh available after drop", !el("btn-refresh").hidden);
  check("watch available after drop", !el("btn-watch").hidden);
  check("toast confirms live reload", el("toast").textContent.includes("live reload ready"));

  el("btn-watch").click(); await wait(80);
  check("watch arms from a drop", el("btn-watch").getAttribute("aria-pressed") === "true");
  const before = el("doc").textContent;
  check("auto-reloads while live",
    await waitFor(() => el("doc").textContent !== before));
  el("btn-refresh").click();
  check("manual refresh works while live",
    await waitFor(() => el("btn-refresh").classList.contains("spin")));
  el("btn-watch").click(); await wait(80);
  check("watch toggles back off", el("btn-watch").getAttribute("aria-pressed") === "false");

  window.dispatchEvent(makeDrop(false));
  check("degrades without handle support",
    await waitFor(() => el("doc").textContent.includes("no handle here")),
    "doc=" + JSON.stringify(el("doc").textContent.slice(0, 40)));
  check("clears stale handle", !el("btn-connect").hidden);
  check("hides refresh again", el("btn-refresh").hidden);

  P.textContent += "\n" + pass + " passed, " + fail + " failed\n";
})();
</script>
'@

# ---------------------------------------------------------------- pass 3
# The sidecar path open-md.cmd uses, with characters that would break a URL
# payload and a body far past any URL length limit.
$sidecarHarness = $preamble + @'
(async () => {
  const P = document.getElementById("probe");
  const wait = (ms) => new Promise(r => setTimeout(r, ms));
  let pass = 0, fail = 0;
  const check = (n, cond, note) => {
    if (cond) { pass++; } else { fail++; P.textContent += "  FAIL  " + n + (note ? "  -- " + note : "") + "\n"; }
  };
  await waitFor(() => document.getElementById("doc").textContent.includes("Sidecar Test"));
  await waitFor(() => document.querySelector(".mermaid-block svg"));
  const doc = document.getElementById("doc");
  check("sidecar document loaded", doc.textContent.includes("Sidecar Test"));
  check("filename from sidecar", document.getElementById("doc-name").textContent === "sidecar.md");
  // The sidecar is the one route that can supply a full path.
  document.getElementById("doc-name").click();
  await new Promise(r => setTimeout(r, 80));
  const pf = document.getElementById("path-field").value;
  check("full path shown from sidecar", pf === "C:\\vault\\notes\\sidecar.md", pf);
  check("no missing-path warning", document.getElementById("path-note").textContent === "",
    document.getElementById("path-note").textContent);
  check("plus and slash survive", doc.textContent.includes("+++") && doc.textContent.includes("///"));
  check("percent and hash survive", doc.textContent.includes("%20") && doc.textContent.includes("#frag"));
  check("unicode survives", doc.textContent.includes("cafÃ©") && doc.textContent.includes("æ—¥æœ¬èªž"));
  check("large payload complete", doc.textContent.includes("filler item 299"));
  check("mermaid renders from sidecar", /<div class="mermaid-block"[^>]*>\s*<svg/.test(doc.innerHTML));
  P.textContent += "\n" + pass + " passed, " + fail + " failed\n";
})();
</script>
'@

$total = 0; $failed = 0
function Show-Pass([string] $label, [string] $output) {
  "=== $label ==="
  $output
  ''
  $script:total += [int]([regex]::Match($output, '(\d+) passed').Groups[1].Value)
  $f = [int]([regex]::Match($output, '(\d+) failed').Groups[1].Value)
  $script:failed += $f
  if ($output -match 'PAGE ERROR|REJECTION|not found|EMPTY') { $script:failed++ }
}

Show-Pass 'main suite' (& $run -Harness $mainHarness -Markdown $torture -Name 'suite' -BudgetMs 45000)
Show-Pass 'drag and drop' (& $run -Harness $dropHarness -Name 'drop' -BudgetMs 40000)

# Build the sidecar fixture, then stage md-bootstrap.js beside the page.
$lines = @('# Sidecar Test', '',
  'Plus +++ slashes /// percent %20 hash #frag quotes "double" backslash \.', '',
  'Unicode: cafÃ© â€” æ—¥æœ¬èªž â€” ðŸŽ‰', '',
  '```mermaid', 'graph LR', '  A[Sidecar] --> B[Rendered]', '```', '')
# ~300 items is already ~15 KB, far past any practical URL length limit, and
# renders in a fraction of the time 2000 took.
$lines += (0..299 | ForEach-Object { "- filler item $_ to blow past any URL length limit" })
$sidecarMd = $lines -join "`n"

# The sidecar has to sit beside the staged page before it loads, so create the
# directory here rather than relying on the runner having been called already.
$stage = Join-Path $env:TEMP 'mdv-sidecar'
$null = New-Item -ItemType Directory -Force -Path $stage
$payload = @{ name = 'sidecar.md'; path = 'C:\vault\notes\sidecar.md'; text = $sidecarMd } |
  ConvertTo-Json -Compress -Depth 3
[IO.File]::WriteAllText((Join-Path $stage 'md-bootstrap.js'),
  'window.__MD_BOOTSTRAP__=' + $payload + ';', (New-Object Text.UTF8Encoding($false)))
Show-Pass 'sidecar bootstrap' (& $run -Harness $sidecarHarness -Name 'sidecar' -BudgetMs 25000)

"TOTAL: $total passed, $failed failed"
if ($failed -gt 0) { exit 1 }
