# Regression suite for md_to_html_viewer.
#
#   .\tools\Test-Viewer.ps1
#   .\tools\Test-Viewer.ps1 -Only 'section editor','editor window'
#
# Runs six passes in headless Edge: the main suite (parsing, sanitizing,
# palettes, controls, chrome), the drag & drop handle path, a dropped document
# set, the section editor and its own window, and the sidecar bootstrap used by
# the VS Code task. Exits non-zero if anything fails.
#
# PowerShell + Edge only. No node, no npm.

[CmdletBinding()]
param(
  # Names of passes to run; the rest are skipped. A pass costs a browser launch,
  # so iterating on one of them should not mean paying for all six.
  [string[]] $Only = @()
)

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
# Reading a set of documents rather than one file: a multi-file drop, and a
# dropped folder. The directory handle is faked to the shape Chromium returns --
# an async values() yielding nested handles -- because a headless run cannot
# perform a real OS folder drag.
$libraryHarness = $preamble + @'
(async () => {
  const P = document.getElementById("probe");
  const el = (id) => document.getElementById(id);
  let pass = 0, fail = 0;
  const check = (n, cond, note) => {
    if (cond) { pass++; } else { fail++; P.textContent += "  FAIL  " + n + (note ? "  -- " + note : "") + "\n"; }
  };
  const fire = (files, items) => {
    const ev = new Event("drop", { bubbles: true, cancelable: true });
    Object.defineProperty(ev, "dataTransfer", { value: { files: files, items: items, types: ["Files"] } });
    window.dispatchEvent(ev);
  };
  await waitFor(() => document.getElementById("btn-display"));

  check("document list hidden with nothing loaded", el("docs").hidden);

  // --- multi-file drop -------------------------------------------------
  // Two headings apiece: buildToc reports "No headings" for anything less, so a
  // single-heading fixture could not tell a rebuilt sidebar from an empty one.
  const md = (name, body) =>
    new File(["# " + body + "\n\n## " + body + " Detail\n\ntext of " + body], name,
             { type: "text/markdown" });
  fire([md("zeta.md", "Zeta"), md("readme.md", "Readme"), md("alpha.md", "Alpha")],
       [{ kind: "file", getAsFileSystemHandle: async () => { throw new Error("none"); } }]);

  check("multi-drop shows the document list",
    await waitFor(() => !el("docs").hidden));
  check("counts every document", el("docs-count").textContent === "(3)",
    el("docs-count").textContent);
  check("README sorts first",
    el("docs-list").querySelector("a").textContent.indexOf("readme.md") === 0,
    el("docs-list").querySelector("a").textContent);
  check("opens the first document",
    await waitFor(() => el("doc").textContent.includes("Readme")));
  check("first entry marked active",
    el("docs-list").querySelectorAll("a")[0].classList.contains("active"));

  // --- switching -------------------------------------------------------
  const links = el("docs-list").querySelectorAll("a");
  links[links.length - 1].click();
  check("clicking a document switches to it",
    await waitFor(() => el("doc").textContent.includes("Zeta")));
  check("active marker follows the selection",
    await waitFor(() => el("docs-list").querySelectorAll("a")[links.length - 1].classList.contains("active")));
  check("headings rebuild for the new document",
    el("toc-list").textContent.includes("Zeta"), el("toc-list").textContent.slice(0, 40));

  // --- dropped folder --------------------------------------------------
  const fileEntry = (name, body) => ({
    kind: "file", name: name,
    getFile: async () => ({ lastModified: 0, name: name, text: async () => "# " + body }),
  });
  const dirEntry = (name, kids) => ({
    kind: "directory", name: name,
    values: async function* () { for (const k of kids) yield k; },
  });
  const tree = dirEntry("project", [
    fileEntry("readme.md", "Root Readme"),
    fileEntry("notes.txt", "Notes"),
    fileEntry("logo.png", "NotMarkdown"),
    dirEntry("docs", [fileEntry("guide.md", "Guide"), fileEntry("api.md", "Api")]),
    dirEntry("node_modules", [fileEntry("junk.md", "Junk")]),
    dirEntry(".git", [fileEntry("hidden.md", "Hidden")]),
  ]);
  fire([], [{ kind: "file", getAsFileSystemHandle: async () => tree }]);

  check("folder drop loads its documents",
    await waitFor(() => el("doc").textContent.includes("Root Readme")));
  // readme.md, notes.txt, docs/guide.md, docs/api.md -- .txt counts, images do not.
  check("walks nested folders", el("docs-count").textContent === "(4)",
    el("docs-count").textContent);
  const names = Array.from(el("docs-list").querySelectorAll("a")).map(a => a.textContent);
  check("skips node_modules", !names.some(n => n.includes("junk")), names.join("|"));
  check("skips dot directories", !names.some(n => n.includes("hidden")), names.join("|"));
  check("ignores non-markdown files", !names.some(n => n.includes("logo")), names.join("|"));
  check("shows the folder a document came from",
    names.some(n => n.includes("docs")), names.join("|"));
  check("root documents sort above nested ones",
    names[0].indexOf("readme.md") === 0, names[0]);

  // --- a single document replaces the set ------------------------------
  fire([md("solo.md", "Solo")],
       [{ kind: "file", getAsFileSystemHandle: async () => { throw new Error("none"); } }]);
  check("single document renders",
    await waitFor(() => el("doc").textContent.includes("Solo")));
  check("single document clears the list",
    await waitFor(() => el("docs").hidden));

  P.textContent += "\n" + pass + " passed, " + fail + " failed\n";
})();
</script>
'@

# ---------------------------------------------------------------- pass 4
# The sidecar path the VS Code task uses, with characters that would break a URL
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

# ---------------------------------------------------------------- pass 5
# The section editor. A fake file handle stands in for the disk, so the write
# itself is asserted rather than assumed -- what actually lands in the file is
# the only thing that matters here.
#
# window.open is stubbed to null for most of it. That forces the in-page pane,
# whose DOM the --dump-dom harness can reach; a real popup's document lives in
# another window and never appears in the dump. The popup path is exercised at
# the end, through the opener's reference to it.
$editorHarness = $preamble + @'
(async () => {
  const P = document.getElementById("probe");
  const wait = (ms) => new Promise(r => setTimeout(r, ms));
  const el = (id) => document.getElementById(id);
  let pass = 0, fail = 0;
  const check = (n, cond, note) => {
    if (cond) { pass++; } else { fail++; P.textContent += "  FAIL  " + n + (note ? "  -- " + note : "") + "\n"; }
  };
  await waitFor(() => el("btn-display"));

  // Frontmatter shifts every line below it; the footnote definition used to
  // shift everything below IT; the blockquote heading must not end a section;
  // the fenced "# not a heading" must not start one; and "Alpha" appears twice
  // so the de-duplicated id has to be the thing that is looked up.
  const SRC = [
    "---", "title: Fixture", "---", "",
    "# Alpha", "",
    "Intro text.[^n]", "",
    "[^n]: a footnote definition, which shifts nothing", "",
    "## Bravo", "",
    "Bravo body.", "",
    "> ### Quoted", ">", "> not editable", "",
    "```", "# not a heading", "```", "",
    "## Charlie", "",
    "Charlie body.", "",
    "# Alpha", "",
    "Second Alpha body.",
  ].join("\r\n");

  // The file on "disk". A save must adopt its own write, or watch reloads over
  // the top of it -- the sentinel makes any such reload visible in the page.
  // Starts read-only, as a real dropped handle does. Opening the editor is the
  // only moment the upgrade can be asked for -- window.open() spends the click
  // that would have paid for it -- so the counters below are the real subject.
  let body = SRC, mtime = 5000, perm = "prompt", asks = 0;
  const written = [];
  const handle = {
    kind: "file", name: "notes.md",
    queryPermission: async () => perm,
    requestPermission: async () => { asks++; perm = "granted"; return perm; },
    getFile: async () => ({
      lastModified: mtime, name: "notes.md",
      text: async () => body + "\r\n\r\nRELOADED SENTINEL",
    }),
    createWritable: async () => ({
      write: async (t) => { written.push(t); body = t; mtime += 1000; },
      close: async () => {},
    }),
  };

  // Nothing in this stretch may fall back to a save dialog: that is the whole
  // point of asking at open time.
  let dialogs = 0;
  const realSave = window.showSaveFilePicker;
  window.showSaveFilePicker = async () => {
    dialogs++;
    const e = new Error("should not have been reached"); e.name = "AbortError"; throw e;
  };

  const file = new File([SRC], "notes.md", { type: "text/markdown", lastModified: mtime });
  const ev = new Event("drop", { bubbles: true, cancelable: true });
  Object.defineProperty(ev, "dataTransfer", { value: {
    files: [file], types: ["Files"],
    items: [{ kind: "file", getAsFileSystemHandle: async () => handle }],
  }});
  window.dispatchEvent(ev);
  check("fixture loaded with a handle",
    await waitFor(() => el("doc").textContent.includes("Bravo body")));

  // ---- table of contents ----
  const rows = document.querySelectorAll("#toc-list .toc-row");
  const pencils = document.querySelectorAll("#toc-list .toc-edit");
  check("every heading gets a row", rows.length === 5, "rows=" + rows.length);
  check("only placeable headings get a pencil", pencils.length === 4, "pencils=" + pencils.length);
  check("blockquote heading has no pencil",
    !document.querySelector('#toc-list .toc-edit[data-edit="quoted"]'));
  check("toc links still navigate", !!document.querySelector('#toc-list a[data-id="bravo"]'));

  // ---- open a section in the in-page pane ----
  const realOpen = window.open;
  window.open = () => null;

  document.querySelector('#toc-list .toc-edit[data-edit="bravo"]').click();
  check("pane opens instantly when there is no window", !!el("editor-dock"));
  const ta = el("editor-ta");
  check("textarea present", !!ta);

  const bravo = ta ? ta.value : "";
  check("section starts at its heading", bravo.startsWith("## Bravo"), JSON.stringify(bravo.slice(0, 24)));
  check("section carries its body", bravo.includes("Bravo body."));
  check("blockquote heading does not end the section", bravo.includes("> ### Quoted"));
  check("fenced hash does not start a section", bravo.includes("# not a heading"));
  check("section stops at the next same-level heading", !bravo.includes("Charlie body."));
  check("editor names the section",
    document.querySelector(".mdv-where").textContent === "## Bravo");

  // ---- a parent section owns its subsections ----
  document.querySelector('#toc-list .toc-edit[data-edit="alpha"]').click();
  const alpha = el("editor-ta").value;
  check("parent section includes subsections",
    alpha.includes("## Bravo") && alpha.includes("## Charlie"));
  check("parent section stops at the next h1", !alpha.includes("Second Alpha body."));
  check("duplicate heading resolves by id",
    !alpha.startsWith("# Alpha\r"), "should be the first Alpha");

  // ---- edit and save ----
  document.querySelector('#toc-list .toc-edit[data-edit="bravo"]').click();
  const ta2 = el("editor-ta");
  ta2.value = ta2.value.replace("Bravo body.", "Bravo EDITED.");
  ta2.dispatchEvent(new Event("input", { bubbles: true }));
  check("dirty marker appears", !document.querySelector(".mdv-dirty").hidden);

  el("btn-watch").click();   // armed across the save: it must not fire on our own write
  ta2.dispatchEvent(new KeyboardEvent("keydown", { key: "s", ctrlKey: true, bubbles: true }));
  check("save reaches the disk", await waitFor(() => written.length === 1));

  const out = written[0];
  check("edit landed in the file", out.includes("Bravo EDITED."));
  check("old text is gone", !out.includes("Bravo body."));
  check("frontmatter survives", out.startsWith("---\r\ntitle: Fixture"));
  check("footnote definition survives", out.includes("[^n]: a footnote"));
  check("neighbouring sections survive",
    out.includes("## Charlie") && out.includes("Second Alpha body."));
  check("heading is not glued to the previous section", out.includes("\r\n\r\n## Charlie"));
  check("CRLF preserved", /\r\n/.test(out) && !/[^\r]\n/.test(out));
  check("line count unchanged by the edit",
    out.split("\r\n").length === SRC.split("\r\n").length,
    out.split("\r\n").length + " vs " + SRC.split("\r\n").length);
  check("document re-renders with the edit",
    await waitFor(() => el("doc").textContent.includes("Bravo EDITED")));
  check("dirty marker clears after saving", document.querySelector(".mdv-dirty").hidden);
  check("granted access on first save means no further dialogs", dialogs === 0, "dialogs=" + dialogs);
  check("permission is asked for once per handle on first save", asks === 1, "asks=" + asks);

  // The watcher has been polling throughout. If the save had not adopted its
  // own write, a reload would have pulled the sentinel into the document.
  await waitFor(() => false, 12);
  check("save does not trigger the watcher", !el("doc").textContent.includes("RELOADED SENTINEL"));
  el("btn-watch").click();

  // ---- an unchanged section does not touch the file ----
  document.querySelector('#toc-list .toc-edit[data-edit="charlie"]').click();
  el("editor-ta").dispatchEvent(new KeyboardEvent("keydown", { key: "s", ctrlKey: true, bubbles: true }));
  await waitFor(() => document.querySelector(".mdv-status").textContent.includes("No changes"));
  check("saving an untouched section writes nothing", written.length === 1,
    "writes=" + written.length);

  // ---- the file moved under us ----
  mtime += 9000;
  const ta3 = el("editor-ta");
  ta3.value = ta3.value + "\nlate addition";
  ta3.dispatchEvent(new Event("input", { bubbles: true }));
  ta3.dispatchEvent(new KeyboardEvent("keydown", { key: "s", ctrlKey: true, bubbles: true }));
  check("stale file is reported",
    await waitFor(() => document.querySelector(".mdv-status").textContent.includes("changed on disk")));
  check("stale file is not overwritten", written.length === 1, "writes=" + written.length);

  // ---- closing ----
  document.querySelector(".mdv-close").click();
  check("close removes the pane", !el("editor-dock"));

  // ---- a document with no file behind it ----
  // Pasted text, or any drop the browser refused a handle for. Saving must not
  // quietly write a copy into the Downloads folder: that looks like success
  // until you check the file you thought you were editing.
  // Count the download rather than performing it: a real one keeps headless
  // Edge alive waiting on the transfer and --dump-dom never fires.
  let downloads = 0;
  const realClick = HTMLAnchorElement.prototype.click;
  HTMLAnchorElement.prototype.click = function () {
    if (this.download) { downloads++; return; }
    return realClick.call(this);
  };

  const paste = new ClipboardEvent("paste", { bubbles: true, cancelable: true });
  Object.defineProperty(paste, "clipboardData", { value: {
    getData: () => "# Loose\n\nnot backed by a file.",
    files: [], types: ["text/plain"],
  }});
  window.dispatchEvent(paste);
  check("pasted document renders",
    await waitFor(() => el("doc").textContent.includes("not backed by a file")));

  // Save As is the universal fallback, so it has to be stubbed to be tested.
  // Cancelled first, then accepted.
  let pickerCalls = 0, pickerOpts = null;
  window.showSaveFilePicker = async (opts) => {
    pickerCalls++; pickerOpts = opts;
    const err = new Error("cancelled"); err.name = "AbortError"; throw err;
  };

  el("mi-edit").click();
  check("editor opens for a pasted document", !!el("editor-ta"));
  check("editor says up front how Ctrl+S will behave",
    document.querySelector(".mdv-status").textContent.includes("ask where to save"),
    JSON.stringify(document.querySelector(".mdv-status").textContent));

  const ta4 = el("editor-ta");
  ta4.value = "# Loose\n\nedited without a file.";
  ta4.dispatchEvent(new Event("input", { bubbles: true }));
  ta4.dispatchEvent(new KeyboardEvent("keydown", { key: "s", ctrlKey: true, bubbles: true }));

  check("no file means Save As, not a dead end", await waitFor(() => pickerCalls === 1));
  check("Save As suggests the document's own name",
    pickerOpts && pickerOpts.suggestedName === "document.md", JSON.stringify(pickerOpts));
  check("cancelling Save As is reported",
    await waitFor(() => document.querySelector(".mdv-status").textContent.includes("cancelled")));
  check("nothing was downloaded behind the user's back", downloads === 0, "downloads=" + downloads);
  check("the edit still lands in the view",
    await waitFor(() => el("doc").textContent.includes("edited without a file")));

  const act = document.querySelector(".mdv-act");
  check("a download is offered after cancelling",
    act && !act.hidden && act.textContent === "Download instead");
  act.click();
  check("the download happens only when asked for", downloads === 1, "downloads=" + downloads);

  // Now let the picker succeed: the handle it returns must be adopted, so the
  // next save goes straight to disk with no dialog.
  const adopted = [];
  let adoptedMtime = 700;
  const newHandle = {
    kind: "file", name: "chosen.md",
    queryPermission: async () => "granted",
    getFile: async () => ({ lastModified: adoptedMtime, name: "chosen.md", text: async () => adopted[adopted.length - 1] || "" }),
    createWritable: async () => ({
      write: async (t) => { adopted.push(t); adoptedMtime += 100; },
      close: async () => {},
    }),
  };
  window.showSaveFilePicker = async () => { pickerCalls++; return newHandle; };

  el("editor-ta").dispatchEvent(new KeyboardEvent("keydown", { key: "s", ctrlKey: true, bubbles: true }));
  check("Save As writes the document", await waitFor(() => adopted.length === 1));
  check("Save As wrote the edited text", adopted[0].includes("edited without a file."));
  check("the toolbar takes the new name",
    await waitFor(() => el("doc-name").textContent === "chosen.md"), el("doc-name").textContent);
  check("live reload becomes available after Save As", !el("btn-refresh").hidden);

  const callsBefore = pickerCalls;
  const ta5 = el("editor-ta");
  ta5.value = ta5.value + "\n\nsecond pass.";
  ta5.dispatchEvent(new Event("input", { bubbles: true }));
  ta5.dispatchEvent(new KeyboardEvent("keydown", { key: "s", ctrlKey: true, bubbles: true }));
  check("the adopted handle saves silently", await waitFor(() => adopted.length === 2));
  check("no second dialog", pickerCalls === callsBefore, "calls=" + pickerCalls);
  check("the second save kept the first", adopted[1].includes("second pass."));

  window.showSaveFilePicker = realSave;
  HTMLAnchorElement.prototype.click = realClick;
  document.querySelector(".mdv-close").click();

  // ---- the popup path, through the opener's reference ----
  window.open = realOpen;
  let popup = null;
  window.open = function () { popup = realOpen.apply(window, arguments); return popup; };
  window.dispatchEvent(new KeyboardEvent("keydown", { key: "e", ctrlKey: true, bubbles: true }));
  await waitFor(() => el("editor-dock") || (popup && popup.document.getElementById("editor-ta")));

  let host = "none";
  try { if (popup && popup.document.getElementById("editor-ta")) host = "window"; } catch (e) { host = "blocked"; }
  if (el("editor-dock")) host = "pane";
  check("Ctrl+E opens the editor in one host or the other", host === "window" || host === "pane", host);
  P.textContent += "  (editor host in headless: " + host + ")\n";

  P.textContent += "\n" + pass + " passed, " + fail + " failed\n";
})();
</script>
'@

# ---------------------------------------------------------------- pass 6
# The editor in a window of its own. A synthetic click carries no user
# activation, so the popup is blocked in a normal headless run and pass 5 only
# ever sees the in-page pane -- this one runs with the blocker off so the
# second document really is built, styled and saved from.
$popupHarness = $preamble + @'
(async () => {
  const P = document.getElementById("probe");
  let pass = 0, fail = 0;
  const check = (n, cond, note) => {
    if (cond) { pass++; } else { fail++; P.textContent += "  FAIL  " + n + (note ? "  -- " + note : "") + "\n"; }
  };
  await waitFor(() => document.getElementById("btn-display"));

  let body = "# One\r\n\r\nfirst body.\r\n\r\n# Two\r\n\r\nsecond body.\r\n";
  const written = [];
  let mtime = 4000;
  const handle = {
    kind: "file", name: "popup.md",
    queryPermission: async () => "granted",
    getFile: async () => ({ lastModified: mtime, name: "popup.md", text: async () => body }),
    createWritable: async () => ({
      write: async (t) => { written.push(t); body = t; mtime += 1000; },
      close: async () => {},
    }),
  };
  const ev = new Event("drop", { bubbles: true, cancelable: true });
  Object.defineProperty(ev, "dataTransfer", { value: {
    files: [new File([body], "popup.md", { type: "text/markdown", lastModified: mtime })],
    types: ["Files"],
    items: [{ kind: "file", getAsFileSystemHandle: async () => handle }],
  }});
  window.dispatchEvent(ev);
  await waitFor(() => document.getElementById("doc").textContent.includes("first body"));

  let popup = null;
  const realOpen = window.open;
  window.open = function () { popup = realOpen.apply(window, arguments); return popup; };
  document.querySelector('#toc-list .toc-edit[data-edit="two"]').click();
  // Opening is async now: write access is asked for first, while the click is
  // still worth something. Waiting is not optional -- asserting early leaves a
  // window open behind the failure and the run hangs instead of reporting.
  await waitFor(() => { try { return popup && popup.document.getElementById("editor-ta"); }
                        catch (e) { return false; } });

  check("a window was opened", !!popup);
  check("no in-page pane when a window is available", !document.getElementById("editor-dock"));

  let pdoc = null;
  try { pdoc = popup && popup.document; } catch (e) { /* cross-origin */ }
  check("the popup document is scriptable from file://", !!pdoc);
  if (!pdoc) {
    if (popup && !popup.closed) popup.close();   // or headless never exits
    P.textContent += "\n" + pass + " passed, " + fail + " failed\n";
    return;
  }

  const ta = pdoc.getElementById("editor-ta");
  check("editor built in the popup", !!ta);
  check("popup carries the right section", ta && ta.value.startsWith("# Two"));
  check("popup styles injected", !!pdoc.getElementById("mdv-editor-css"));
  check("popup follows the palette",
    !!pdoc.documentElement.style.getPropertyValue("--bg"),
    pdoc.documentElement.getAttribute("style"));
  check("popup is titled", /Editor/.test(pdoc.title), pdoc.title);

  // Theme changes must reach the second document too.
  const before = pdoc.documentElement.style.getPropertyValue("--bg");
  window.dispatchEvent(new KeyboardEvent("keydown", { key: "d", bubbles: true }));
  check("popup repaints when the viewer's theme changes",
    pdoc.documentElement.style.getPropertyValue("--bg") !== before);

  // Ctrl+S inside the popup, not the opener.
  ta.value = "# Two\r\n\r\nsecond body, rewritten.";
  ta.dispatchEvent(new Event("input", { bubbles: true }));
  ta.dispatchEvent(new KeyboardEvent("keydown", { key: "s", ctrlKey: true, bubbles: true }));
  check("Ctrl+S in the popup writes the file", await waitFor(() => written.length === 1));
  check("only the edited section changed",
    written[0] && written[0].includes("first body.") && written[0].includes("rewritten."));
  check("opener re-renders from the popup's save",
    await waitFor(() => document.getElementById("doc").textContent.includes("rewritten")));

  // Closing the window has to clear the app's stale references, or the next
  // open writes into a textarea belonging to a document that is gone and
  // nothing appears anywhere. unload is not dependable for a window closed by
  // script, which is why the app re-checks .closed instead of trusting it.
  // The reopen is pointed at the in-page pane: opening a second editor window
  // in the same run leaves headless Edge running past its virtual-time budget
  // and --dump-dom never fires. (Two plain about:blank windows are fine, so it
  // is something about reusing the name with a built-out document -- not worth
  // chasing, since the stale reference is stale in either host.)
  popup.close();
  check("closing the window releases the editor", await waitFor(() => popup.closed));
  window.open = () => null;

  document.querySelector('#toc-list .toc-edit[data-edit="one"]').click();
  check("editor reopens after its window was closed", !!document.getElementById("editor-ta"));
  check("the reopened editor is usable",
    (document.getElementById("editor-ta") || {}).value === "# One\n\nfirst body.\n",
    JSON.stringify((document.getElementById("editor-ta") || {}).value));

  P.textContent += "\n" + pass + " passed, " + fail + " failed\n";
})();
</script>
'@

$total = 0; $failed = 0
# The pass is a scriptblock, not a string: -Only has to skip the browser launch,
# and an argument would already have run by the time this was called.
function Show-Pass([string] $label, [scriptblock] $pass) {
  if ($Only.Count -and $Only -notcontains $label) { return }
  $output = & $pass
  "=== $label ==="
  $output
  ''
  $script:total += [int]([regex]::Match($output, '(\d+) passed').Groups[1].Value)
  $f = [int]([regex]::Match($output, '(\d+) failed').Groups[1].Value)
  $script:failed += $f
  if ($output -match 'PAGE ERROR|REJECTION|not found|EMPTY|did not exit') { $script:failed++ }
}

Show-Pass 'main suite' { & $run -Harness $mainHarness -Markdown $torture -Name 'suite' -BudgetMs 45000 }
Show-Pass 'drag and drop' { & $run -Harness $dropHarness -Name 'drop' -BudgetMs 40000 }
Show-Pass 'document set'  { & $run -Harness $libraryHarness -Name 'library' -BudgetMs 40000 }
Show-Pass 'section editor' { & $run -Harness $editorHarness -Name 'editor' -BudgetMs 40000 }
Show-Pass 'editor window' { & $run -Harness $popupHarness -Name 'popup' -BudgetMs 40000 `
  -BrowserArgs '--disable-popup-blocking' }

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
Show-Pass 'sidecar bootstrap' { & $run -Harness $sidecarHarness -Name 'sidecar' -BudgetMs 25000 }

"TOTAL: $total passed, $failed failed"
if ($failed -gt 0) { exit 1 }
