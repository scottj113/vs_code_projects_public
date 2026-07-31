# HTML as a Solution — Pattern Library

Proven, reusable patterns for building real applications as **a single local HTML file**,
opened by double-click and bookmarked like an app. No installer, no Electron, no Node, no
build step, no server.

Everything here is extracted from working software — [Cardoo](../cardoo/) and
[Northern Lights MD Viewer](../md_to_html_viewer/) — not from theory. If a pattern is
listed, it shipped.

**Target: Chromium (Chrome / Edge.)** The File System Access API is what makes this
architecture capable rather than merely convenient, and it is Chromium-only. Patterns note
their fallbacks where cheap, but Chrome/Edge is the assumption.

## Contents

**Foundations**
- [Theming System](#theming-system) — palettes, persistence, no flash on load
- [Single-File Deployment](#single-file-deployment) — inlining, embedding, vendoring
- [The `file://` Contract](#the-file-contract) — what this origin can and cannot do

**Data in and out**
- [Getting Data *Into* a `file://` Page](#getting-data-into-a-file-page) — four input doors
- [Getting Data *Out*: The Standalone Export](#getting-data-out-the-standalone-export)
- [Print Is an Output Target](#print-is-an-output-target-not-an-afterthought) — free PDF
- [File I/O](#file-io-chromium-only) — read, write safely, watch, partial writes

**State**
- [State Management](#state-management) — the save/render loop, key hygiene
- [Durable State: Export / Import](#durable-state-export--import) — survive a cleared cache
- [The Staleness Meter](#the-staleness-meter) — make unsaved work visible
- [Undo/Redo: Record Intent, Not Snapshots](#undoredo-record-intent-not-snapshots)

**Interface**
- [UI Primitives](#ui-primitives) — toast, clipboard, drag & drop, blob URLs, scroll-spy
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Scale the Content, Not the Chrome](#scale-the-content-not-the-chrome)

**Robustness**
- [Degrade, Don't Break](#degrade-dont-break) — feature detection and fallbacks
- [Sanitizing Untrusted HTML](#sanitizing-untrusted-html)
- [Gotcha: Inline `style.display` Toggles](#gotcha-inline-styledisplay-toggles)

**Practice**
- [Testing & Development](#testing--development)
- [Scalability Limits](#scalability-limits) — when to stop using this architecture
- [Checklist: Ports to New Projects](#checklist-ports-to-new-projects)
- [Where These Came From](#where-these-came-from)

---

## Theming System

### Architecture

**Goal**: Support multiple color schemes without build steps, and persist user choice across sessions.

**Solution**: CSS custom properties + `data-*` attributes + localStorage.

### Implementation

#### 1. Define Palettes (CSS)

Store all color values as custom properties. Use `data-pal` or `data-theme` attribute to switch:

```css
:root {
  --bg: #1a1a1a;
  --text: #fff;
  --accent: #0099ff;
}

:root[data-theme="light"] {
  --bg: #ffffff;
  --text: #000000;
  --accent: #0033cc;
}
```

Use the variables everywhere:

```css
body { background: var(--bg); color: var(--text); }
button { background: var(--accent); }
```

#### 2. Pre-Render Theme (Avoid Flash)

**Problem**: If you apply the theme in JavaScript after the page loads, users see a white flash before the dark theme kicks in.

**Solution**: Apply saved theme before first paint:

```html
<script>
/* Applied before first paint so a saved theme does not flash white. */
try {
  var theme = localStorage.getItem("myapp:theme");
  if (theme) {
    document.documentElement.setAttribute("data-theme", theme);
  }
} catch (e) {}
</script>
<style>
  /* All other CSS ... */
</style>
```

Place this script **before the `<style>` tag** so the theme is set before CSS applies.

#### 3. Persist Theme

When user picks a theme, save it and apply it:

```javascript
function setTheme(themeName) {
  document.documentElement.setAttribute("data-theme", themeName);
  localStorage.setItem("myapp:theme", themeName);
}
```

#### 4. System Preference Matching (Optional)

Detect OS light/dark mode:

```javascript
function systemPreference() {
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

function applyTheme() {
  var saved = localStorage.getItem("myapp:theme");
  var useSystem = localStorage.getItem("myapp:auto") === "true";
  var theme = useSystem ? systemPreference() : (saved || "dark");
  document.documentElement.setAttribute("data-theme", theme);
}
```

---

## Single-File Deployment

### Inline Everything

```html
<!doctype html>
<html>
<head>
  <style>
    /* All CSS, no external stylesheets */
  </style>
</head>
<body>
  <!-- HTML -->
  <script>
    /* All JavaScript, no external scripts */
  </script>
</body>
</html>
```

**Why**:
- No network requests (offline capable)
- One file to bookmark/share/email
- No whitelist needed for corporate proxies

### Embed Small Assets

**SVG favicon** (data URI):
```html
<link rel="icon" type="image/svg+xml" href="data:image/svg+xml,<svg>...</svg>">
```

**Base64 images** (if small):
```html
<img src="data:image/png;base64,iVBORw0KG..." />
```

**JSON data** (via global variable):
```html
<script>
  window.__DATA__ = { /* embedded data */ };
</script>
```

### When to Vendor External Code

If you need a library (e.g., Mermaid, Highlight.js), **download the dist file and vendor it**:

```
project/
  index.html
  vendor/
    mermaid.min.js
```

Load it locally:

```html
<script src="vendor/mermaid.min.js"></script>
```

**Why not npm**:
- No build step
- No dependency resolution or version conflicts
- One `.js` file to manage

For major updates, download the new version and replace it.

---

## The `file://` Contract

Everything here assumes the page is opened by double-clicking it, not served. That origin
is more restricted than `http://localhost`, and the restrictions are not obvious. Know
them before you design around them.

**Blocked outright:**

| Thing | Why it matters |
|---|---|
| `<script type="module">` | ES modules are fetched under CORS, which `file://` fails. **Vendor libraries as classic scripts.** This is the single most common way a local HTML app breaks. |
| `fetch()` / `XHR` on local files | You cannot load a sibling `.json` or `.css` at runtime. Inline it, or make the user hand it to you. |
| IndexedDB | Blocked in Chromium on `file://`. localStorage still works — which is why file handles can't be persisted across a refresh. |
| Service workers | No offline layer, no background anything. |
| Full filesystem paths | A page is never told where a dropped file lives. Only an external tool (see the sidecar route below) can supply a real path. |

**Works fine:** localStorage, `<script src="vendor/lib.js">` (classic), relative `<img>`,
CSS, `showOpenFilePicker` / `showDirectoryPicker` and the handles they return, drag & drop,
clipboard, Blob downloads, `window.open`, print.

**Design consequences:**

- **Vendor, don't import.** One `vendor/lib.min.js` next to the HTML, loaded with a plain
  `<script>` tag. No bundler, no package manager, no lockfile. Update by downloading the
  new dist file over the old one.
- **A relative path is a hard dependency.** If your HTML loads `vendor/mermaid.min.js`,
  moving the HTML file alone silently breaks diagrams. Say so in the README.
- **Permission is per-session.** A refresh drops every file handle, because there's nowhere
  to persist it. Re-arming after reload is a browser restriction, not a bug — tell the user
  that plainly instead of letting it look broken.

---

## Getting Data *Into* a `file://` Page

A bookmarked HTML file has no server, no query string from a router, and no way to reach
the filesystem on its own. Everything it knows has to arrive through one of four doors.
Northern Lights supports all four and treats them as a priority chain at boot:

```javascript
(function boot() {
  // 1. Sidecar global written by an external tool before the page loads.
  const bs = window.__APP_BOOTSTRAP__;
  if (bs && typeof bs.text === "string") { load(bs.text, bs.name, bs.path); return; }

  // 2. URL hash payload: #name=<uri-encoded>&data64=<base64, utf-8>
  const hash = location.hash.slice(1);
  const payload = hash.match(/(?:^|&)data64=([^&]*)/);
  if (payload) {
    const b64 = payload[1].replace(/-/g, "+").replace(/_/g, "/");
    const bytes = Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));
    load(new TextDecoder("utf-8").decode(bytes));
    history.replaceState(null, "", location.pathname);   // don't leave it in the URL
    return;
  }

  // 3. Last session, from localStorage.
  if (restore()) return;

  // 4. Nothing to show -- render the empty state and wait for a drop or a picker.
  render();
})();
```

**Why the hash and not the query string**: a `file://` URL's `?query` is unreliable across
browsers, but `#hash` always survives and never hits a network. It's the one channel that
works when you double-click an HTML file on a machine with no server.

**Two traps in the hash route**, both learned the hard way:

- **Don't use `URLSearchParams`** — it decodes `+` as a space, which silently corrupts
  base64 from the first `+` onward.
- **`atob` skips whitespace instead of throwing**, so a malformed payload decodes into
  plausible-looking garbage rather than failing. Validate, don't trust.

**The sidecar global (route 1)** is how an external tool hands you a file. An editor task
writes a tiny `bootstrap.js` containing `window.__APP_BOOTSTRAP__ = {...}`, the page
includes it with a `<script>` tag, and the data is simply *there* at boot. It's also the
only route that can pass a real filesystem path — drag & drop, the file picker, and paste
all deliberately withhold it, because browsers never reveal full paths to a page.

**Drag & drop and the file picker** are the two interactive doors, and they're the good
ones: in Chromium they hand over a *handle*, not just bytes, which is what makes re-reading
and saving possible at all.

---

## Getting Data *Out*: The Standalone Export

The counterpart to the pattern above, and the thing that makes a single-file app worth
building: it can emit a **second self-contained HTML file** that needs nothing to open —
no stylesheet, no font, no script, no viewer, no network.

The trick is freezing the *computed* CSS variables into the export, so it captures the
theme and text size the user was actually looking at:

```javascript
function exportHtml() {
  const vars = getComputedStyle(document.documentElement);
  const names = ["bg", "fg", "border", "accent", "code-bg", /* ...all of them... */];
  const frozen = ":root{" +
    names.map((n) => "--" + n + ":" + vars.getPropertyValue("--" + n).trim() + ";").join("") +
    "}";

  const body = documentEl.cloneNode(true);                 // clone, never mutate the live DOM
  for (const b of body.querySelectorAll(".copy-btn")) b.remove();   // strip interactive bits

  const page = '<!doctype html>\n<html lang="en"><head><meta charset="utf-8">' +
    "<title>" + esc(title) + "</title><style>" + frozen + baseCss + docCss + "</style>" +
    "</head><body><main>" + body.outerHTML + "</main></body></html>";

  downloadBlob(page, title + ".html", "text/html;charset=utf-8");
}
```

**What makes it work:**

- **Freeze computed values, don't copy the stylesheet.** `getComputedStyle` resolves
  whichever palette is active into literal hex, so you export one theme instead of all
  twelve plus the switching logic.
- **Clone the DOM before stripping.** Mutating the live document to prepare an export is
  how you ship a viewer that visibly breaks when the user clicks Export.
- **Emit zero `<script>` tags.** This is the whole point: the output opens on a locked-down
  machine, pastes into a wiki or SharePoint, survives a mail gateway, and renders
  identically forever. Anything dynamic must be pre-rendered — diagrams become inline SVG,
  interactive tables become plain tables.
- **Inline everything, reference nothing.** One file, no sibling assets to lose.

---

## Print Is an Output Target, Not an Afterthought

`Ctrl+P` is free PDF export — every browser has it — but only if you write the print
stylesheet. The rule: **screen reading preferences must not leak onto paper.**

```css
@media print {
  :root { color-scheme: light; }
  body  { background: #fff; overflow: visible; }

  /* Chrome is furniture. */
  #toolbar, #sidebar, #toast, #dropzone { display: none !important; }

  /* Undo the app shell's fixed/scrolling layout or you print page 1 only. */
  #shell    { position: static; display: block; }
  #scroller { overflow: visible; }

  /* Reset reading prefs: dark mode, 180% text and bold-all belong on screen. */
  .doc { color: #000; font-size: 11pt; font-weight: 400; }
  .doc img { filter: none; }

  /* Respect the page break. */
  .doc pre, .doc blockquote, .doc table { break-inside: avoid; }
  .doc h1, .doc h2, .doc h3 { break-after: avoid; }
}
```

The one people miss is the **fixed-position app shell**. A `position: fixed` container with
an inner scroller prints exactly one page — whatever happened to be in the viewport. Reset
it to static flow and the whole document prints.

---

## State Management

### Pattern: Structured Save/Load

```javascript
var state = { /* application state */ };

function saveState() {
  localStorage.setItem("myapp:state", JSON.stringify(state));
}

function loadState() {
  try {
    var saved = localStorage.getItem("myapp:state");
    if (saved) state = JSON.parse(saved);
  } catch (e) {
    console.warn("Could not load state:", e);
  }
}

function render() {
  // Rebuild DOM from state
}
```

**Init flow**:
```javascript
loadState();
render();
```

**Mutation flow**:
```javascript
function addItem(item) {
  state.items.push(item);
  saveState();
  render();
}
```

### Namespace Your Keys

Prefix every key with the app name (`myapp:theme`, `myapp:state`, `myapp:changes`).
localStorage is shared across the whole origin, so on `file://` — where *every* local HTML
file is same-origin in some browsers — unprefixed keys like `"theme"` will collide with
your other tools.

The prefix also buys you a real reset, which is the first thing to try when a user reports
something inexplicable:

```javascript
function clearCache() {
  if (!confirm("Reset all settings and stored data?")) return;
  const keys = [];
  for (let i = 0; i < localStorage.length; i++) {
    const k = localStorage.key(i);
    if (k && k.startsWith("myapp:")) keys.push(k);   // collect first...
  }
  keys.forEach((k) => localStorage.removeItem(k));   // ...then delete
  location.reload();
}
```

Collect the keys before deleting any — `localStorage.key(i)` re-indexes as you remove, so
deleting inside the loop skips half of them.

### Wrap Every Storage Call

`localStorage` throws on quota exhaustion and in some privacy modes. A single unguarded
`setItem` takes the whole app down:

```javascript
function persist() {
  try {
    if (state.text.length <= PERSIST_LIMIT) {
      localStorage.setItem("myapp:last", JSON.stringify(state));
    }
  } catch (_) { /* quota -- not worth surfacing */ }
}
```

Cap what you store, and let persistence fail silently. Losing the convenience of a restored
session is annoying; a blank screen is a bug report.

### localStorage Limits

- **Size**: ~5-10 MB (varies by browser)
- **Scope**: Per origin (domain + protocol)
- **Persistence**: Until user clears cache or quota is hit
- **No expiry**: Data persists across sessions indefinitely

For most single-file apps (note-taking, task boards, personal tools), this is more than enough.

**But localStorage is not a backup.** It dies with a cleared cache, a new browser, or a
different machine — silently, with no warning and no undo. Any app that holds work worth
keeping needs the next pattern.

---

## Durable State: Export / Import

**Goal**: Let the user get their state *out* of the browser as a real file — one they can
commit to git, drop in Dropbox, or mail to themselves — and back *in* later.

This is what makes a single-file app trustworthy. Without it you're asking someone to keep
real work in a place that a routine "clear browsing data" wipes out.

### Export

```javascript
function exportState() {
  const json = JSON.stringify(state, null, 2);   // 2-space indent: git-diffable
  const blob = new Blob([json], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "myapp-backup-" + new Date().toISOString().slice(0, 10) + ".json";
  a.click();
  URL.revokeObjectURL(url);                       // don't leak the blob
}
```

### Import

```javascript
function importState() {
  const input = document.createElement("input");
  input.type = "file";
  input.accept = ".json";
  input.onchange = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const imported = JSON.parse(evt.target.result);
        if (!isValidState(imported)) return alert("Invalid backup file");
        state = imported;
        saveState();
        render();
      } catch (err) {
        alert("Could not read file: " + err.message);
      }
    };
    reader.readAsText(file);
  };
  input.click();
}
```

**Rules that matter:**

- **Pretty-print the JSON** (`null, 2`). A minified blob is one unreadable line in a git
  diff; an indented one shows you exactly what changed between backups.
- **Date-stamp the filename.** Backups accumulate into a history for free, and you never
  overwrite yesterday's good copy with today's mistake.
- **Validate on import before assigning.** Check the shape (`imported.cards &&
  imported.laneOrder`) so a wrong file fails loudly instead of destroying live state.
- **Never auto-import.** Restoring is destructive; it should always be a deliberate click.

### Optional: auto-export to a folder (Chromium)

With a directory handle from `showDirectoryPicker()`, backups can write themselves on
every change — no clicking at all:

```javascript
async function autoExportToFolder() {
  if (!folderHandle) return;
  try {
    const name = "myapp-backup-" + new Date().toISOString().slice(0, 10) + ".json";
    const fileHandle = await folderHandle.getFileHandle(name, { create: true });
    const writable = await fileHandle.createWritable();
    await writable.write(JSON.stringify(state, null, 2));
    await writable.close();
  } catch (err) {
    console.warn("Auto-export failed:", err);   // never block the app on a backup
  }
}
```

Point it at a git repo and your state is versioned automatically. Treat it as a bonus,
not the mechanism — the permission doesn't survive a page refresh (see
[File I/O](#file-io-chromium-only)), so manual export stays the reliable path.

---

## The Staleness Meter

**Goal**: Make "you have unsaved work" *visible* without nagging.

The problem with export/import is purely human: it works perfectly and nobody remembers to
do it. A modal that interrupts you gets dismissed on reflex. The fix is an ambient signal —
something that sits in the toolbar and slowly changes while you work.

**The litmus test**: if this data vanished right now, would the user be upset, and would
it cost them real time to get back? Not "does the app hold data" — almost all of them do —
but whether losing it would actually hurt.

This has nothing to do with app size or complexity. Northern Lights is ~4,700 lines and
has no meter; Cardoo is a few hundred and can't ship without one. Wipe a Northern Lights
user's localStorage and they reload the `.md` file they still have on disk — worst case, a
table's column widths or sort order resets, and they re-drag a column border. Wipe
Cardoo's and it's an absolute deal-breaker: every card is gone, full stop, with nothing
else to reload it from — real inconvenience, real lost time, and for a personal task board
specifically, the loss isn't only the text. A card is often the only record that some
half-formed idea existed at all; unlike a `.md` file's content, a forgotten thought doesn't
come back from human memory just because you're annoyed enough to try.

The mechanism behind that gap: Northern Lights edits a real file, and every `Ctrl+S`
writes straight to it, so the save event *is* the backup — there's nothing to accumulate
risk on. Cardoo has no file; localStorage isn't a cache of anything else there, it's the
only copy. But **ask the litmus test first** — "would losing this actually hurt?" — the
source-of-truth check is just how you explain the answer once you have it, and it's easy
to reach for it too early and end up debating architecture instead of impact.

### Implementation

Count every mutation. Reset the count on export.

```javascript
function updateChangeCount() {
  changeCount++;
  localStorage.setItem("myapp:changes", changeCount);  // survives a refresh
  updateMeter();
}

function updateMeter() {
  const pct = Math.min(changeCount / RED, 1);
  fill.style.width = (pct * 100) + "%";
  fill.style.backgroundColor =
    changeCount < YELLOW ? "#0f0" : changeCount < RED ? "#ff0" : "#f00";

  // Fire the alert on the *transition* into red, not on every change past it.
  if (changeCount >= RED && !wasRed) { toast("Time to export your work!"); wasRed = true; }
  else if (changeCount < RED)        { wasRed = false; }
}
```

Call `updateChangeCount()` from every mutation, and zero it in `exportState()`.

### Why it works

- **It's ambient, not modal.** You notice it in peripheral vision, on your own schedule.
  Nothing to dismiss means nothing to learn to dismiss reflexively.
- **Most users never reach red** — and that's the point. You glance down at yellow, think
  "one click," and export. The meter's job is to lose its own race.
- **Alert on the transition only.** Toasting on every change past the threshold trains
  people to ignore toasts. Latch it with a `wasRed` flag.
- **Persist the count.** Store it alongside the state, or a refresh resets your only
  record of how much is at risk.

### Tuning

Set thresholds against *a session's worth of work*, not a fixed number. Cardoo uses
green 0–10 / yellow 11–20 / red 21+, which reaches yellow after ~15 minutes of steady
editing. Too sensitive and it's wallpaper; too lax and it's decoration. Aim for a meter
the user resets out of mild satisfaction rather than alarm.

Generalizes past backups: unsent changes, unsynced records, undeployed edits — anything
where the cost of forgetting is high and the cost of acting is one click.

---

## Undo/Redo: Record Intent, Not Snapshots

The obvious way to build undo is snapshotting the whole state before every mutation and
popping backward through the list. It works, and it's the wrong default for most of these
apps: it's all-or-nothing (undo *anything* means undo *everything* since, in order), it
grows one full copy of the state per action, and once you decide undo should only cover
*some* kinds of change, snapshots can't express that at all.

**The alternative: record what happened, not what everything looked like.**

```javascript
let undoStack = [];
let redoStack = [];
const MAX_HISTORY = 50;

function pushHistory(action) {
  undoStack.push(action);                    // e.g. { cardId, from: "To Do", to: "Done" }
  if (undoStack.length > MAX_HISTORY) undoStack.shift();
  redoStack = [];                             // a new action invalidates the old future
  updateButtons();
}

function undo() {
  const action = undoStack.pop();
  if (!action) return;
  if (applyInverse(action)) {                 // look the target up fresh; don't trust position
    redoStack.push(action);
    saveData();
    render();
  }
  updateButtons();
}

function redo() {
  const action = redoStack.pop();
  if (!action) return;
  if (applyForward(action)) {
    undoStack.push(action);
    saveData();
    render();
  }
  updateButtons();
}
```

**Why this beats a snapshot stack here:**

- **It scopes naturally.** Cardoo's undo covers drag-and-drop moves only, not
  add/delete/edit — those already have their own affordances (an × button, an edit
  dialog with its own save step), and a move is the one action people fat-finger. A
  snapshot stack can't express "undo *this kind* of change" at all; a recorded action can
  simply not be pushed for the kinds you've decided don't need it.
- **It's cheap.** A move record is three fields. A full-board snapshot is the whole JSON
  document, once per action, forever (until capped).
- **It degrades safely.** Look the target up by id at undo time — `applyInverse` finds the
  card fresh in the current data rather than trusting a remembered position — so if
  something else deleted it in between, the undo is just a no-op instead of corrupting
  state or resurrecting a stale copy.

**When a snapshot stack is still the right call**: if "undo" needs to mean *everything*,
uniformly, with no per-action-type scoping — a text editor undoing keystrokes, for
instance. Reach for recorded intent first; fall back to snapshots when the domain
genuinely doesn't factor into discrete, invertible actions.

### The `Ctrl+Z` Focus Guard

Binding `Ctrl+Z` globally breaks the browser's own undo inside any `<input>` or
`<textarea>` on the page — typing a correction into a text field and hitting `Ctrl+Z`
should erase the last few characters, not revert application state out from under you.

```javascript
document.addEventListener("keydown", (e) => {
  const tag = document.activeElement?.tagName || "";
  const inField = tag === "INPUT" || tag === "TEXTAREA";

  if (e.ctrlKey && !e.shiftKey && e.key.toLowerCase() === "z") {
    if (inField) return;          // let the browser handle text-editing undo
    e.preventDefault();
    undo();
  }
});
```

`Ctrl+R` has no native text-editing meaning, so redo bound to it can stay unconditional —
just `e.preventDefault()` to stop the browser's page-reload binding, the same precedent
Northern Lights already set for `Ctrl+R` as an in-app action.

---

## UI Primitives

The handful of components every one of these apps ends up needing. All proven in both
Cardoo and Northern Lights.

### Toast

The workhorse. One element, one function, no library:

```css
#toast {
  position: fixed; left: 50%; top: 62px; transform: translate(-50%, -8px);
  z-index: 100; background: var(--bg-raised); color: var(--fg);
  border: 1px solid var(--border-strong); border-radius: 8px;
  padding: 9px 15px; font-size: 13px; max-width: 70vw;
  opacity: 0; pointer-events: none; transition: opacity .16s, transform .16s;
}
#toast.show { opacity: 1; transform: translate(-50%, 0); }
#toast.err  { border-color: #d9534f; color: #d9534f; }
```
```javascript
let toastTimer = null;
function toast(msg, isError) {
  const el = document.getElementById("toast");
  el.textContent = msg;                          // textContent, never innerHTML
  el.classList.toggle("err", !!isError);
  el.classList.add("show");
  clearTimeout(toastTimer);                      // reset the clock on every call
  toastTimer = setTimeout(() => el.classList.remove("show"), isError ? 10400 : 4800);
}
```

**Details that came from use, not theory:**

- **Put it under the toolbar, not bottom-right.** These messages answer toolbar clicks;
  instructions like *"paste the path into the dialog"* are missed entirely in a corner.
- **Errors stay roughly twice as long.** Northern Lights ended up at 4.8s / 10.4s after the
  original 2.4s / 5.2s left instructions gone before they were read.
- **`pointer-events: none`** so it never eats a click meant for what's underneath.
- **`clearTimeout` every call**, or a second toast inherits the first one's remaining time.

### Copy to Clipboard, With a Real Fallback

`navigator.clipboard` rejects when the browser withholds permission. Handle it:

```javascript
navigator.clipboard.writeText(text).then(
  () => { btn.textContent = "Copied"; setTimeout(() => (btn.textContent = "Copy"), 1200); },
  () => toast("Clipboard blocked by the browser", true)
);
```

Confirm on the button itself — the user's eyes are already there.

### Drag & Drop, Including Folders

The non-obvious part: **a dropped folder never appears in `dataTransfer.files`.** It only
arrives as a directory handle, so you must check for that *before* reading files:

```javascript
dropZone.addEventListener("dragover", (e) => { e.preventDefault(); dropZone.classList.add("over"); });
dropZone.addEventListener("dragleave", () => dropZone.classList.remove("over"));
dropZone.addEventListener("drop", async (e) => {
  e.preventDefault();
  dropZone.classList.remove("over");

  const items = Array.from(e.dataTransfer.items || []);
  const handlePromises = items
    .filter((i) => i.kind === "file" && i.getAsFileSystemHandle)
    .map((i) => i.getAsFileSystemHandle());

  let handles = [];
  try { handles = (await Promise.all(handlePromises)).filter(Boolean); }
  catch (_) { handles = []; }                  // older engine, or a non-file drag source

  const dir = handles.find((h) => h.kind === "directory");
  if (dir) return loadDirectory(dir);          // ← must come first

  loadFiles(Array.from(e.dataTransfer.files), handles);
});
```

**`e.preventDefault()` on `dragover` is mandatory** — without it the drop never fires and
the browser navigates away to the file instead, which looks exactly like a crash.

**Prefer `getAsFileSystemHandle()` over `dataTransfer.files`.** Both give you the bytes,
but only the handle carries permission to *re-read* the file later, which is what makes
refresh and watch mode possible. Drop is the only route that arms live reload for free.

### Blob URL Lifecycle

Any `URL.createObjectURL()` holds its file in memory until you revoke it. Track them and
release as a set when the document changes:

```javascript
function releaseAssets() {
  if (!state.assets) return;
  for (const url of state.assets.values()) URL.revokeObjectURL(url);
  state.assets = null;
}
```

Call it before loading anything new. For one-shot downloads, revoke on a timer *after* the
click has been serviced (`setTimeout(..., 4000)`) — revoking immediately can cancel the
download in some builds.

### Scroll-Spy With `IntersectionObserver`

Highlight the section currently being read. No scroll handler, no throttling:

```javascript
let observer = null;
function observeHeadings(ids) {
  if (observer) observer.disconnect();          // always tear down before rebuilding
  if (!ids.length) return;

  const visible = new Set();
  observer = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (e.isIntersecting) visible.add(e.target.id); else visible.delete(e.target.id);
    }
    const first = ids.find((id) => visible.has(id));   // document order, not observer order
    links.forEach((a, id) => a.classList.toggle("active", id === first));
  }, { rootMargin: "-58px 0px -70% 0px", threshold: 0 });

  ids.forEach((id) => { const el = document.getElementById(id); if (el) observer.observe(el); });
}
```

**`rootMargin` does the real work.** `-58px` at the top discounts a fixed toolbar; `-70%`
at the bottom shrinks the detection band to the upper third of the viewport, so "current
section" means what you're reading rather than anything merely on screen.

**Resolve ties in document order.** Several headings are visible at once; picking the first
by `ids` order keeps the highlight from jumping around.

---

## Keyboard Shortcuts

### Pattern: Centralized Handler

```javascript
document.addEventListener("keydown", (e) => {
  if (e.ctrlKey && e.key === "s") {
    e.preventDefault();
    handleSave();
  }
  if (e.key === "Escape") {
    handleClose();
  }
  if (e.key === "+") {
    handleZoom(1.1);
  }
  if (e.key === "-") {
    handleZoom(0.9);
  }
});
```

**Tips**:
- Use `e.preventDefault()` to override browser defaults
- Check for modifier keys: `e.ctrlKey`, `e.shiftKey`, `e.altKey`
- Test that shortcuts don't interfere with input fields (check `e.target`)

---

## File I/O (Chromium Only)

### Read a File

```javascript
async function openFile() {
  const [handle] = await window.showOpenFilePicker();
  const file = await handle.getFile();
  const text = await file.text();
  return text;
}
```

### Save a File

```javascript
async function saveFile(handle, content) {
  const writable = await handle.createWritable();
  await writable.write(content);
  await writable.close();
}
```

### Watch for Changes

```javascript
async function watchFile(handle, onchange) {
  while (true) {
    const file = await handle.getFile();
    const stat = file.lastModified;
    if (stat > lastSeen) {
      onchange(await file.text());
      lastSeen = stat;
    }
    await new Promise(r => setTimeout(r, 1000));
  }
}
```

**Limitations**:
- Only in Chrome/Edge (not Firefox/Safari)
- Requires explicit user permission (via file picker)
- Permission is lost on page refresh (`file://` pages cannot store it in IndexedDB)

For cross-browser fallback, offer download/upload instead.

### Writing Safely: Check, Write, Adopt

Never write straight to a handle. Three guards, in order:

```javascript
async function writeFile(text) {
  if (!state.handle) return { ok: false, why: "no-handle" };
  try {
    // 1. Permission. requestPermission() needs user activation in THIS window --
    //    from a popup it throws, so the caller must fall back to saveAs().
    let p = await state.handle.queryPermission({ mode: "readwrite" });
    if (p !== "granted") {
      try { p = await state.handle.requestPermission({ mode: "readwrite" }); }
      catch (e) { return { ok: false, why: "no-activation" }; }
    }
    if (p !== "granted") return { ok: false, why: "denied" };

    // 2. Staleness. Someone else may have changed the file since you read it.
    const before = await state.handle.getFile();
    if (before.lastModified !== state.lastModified) return { ok: false, why: "stale" };

    const w = await state.handle.createWritable();
    await w.write(text);
    await w.close();

    // 3. Adopt your own write, or a watcher sees the new mtime a second later,
    //    calls it an external change, and reloads your edit back over itself.
    state.lastModified = (await state.handle.getFile()).lastModified;
    return { ok: true };
  } catch (e) {
    return { ok: false, why: "error", error: e };
  }
}
```

**Report, don't overwrite.** Returning `why: "stale"` lets the UI say *"this file changed
on disk — reload first"*. Silently winning that race destroys someone's work.

**Step 3 is the non-obvious one.** If you poll for changes (watch mode), your own save
looks exactly like an external edit. Adopt the mtime immediately or the app fights itself.

**Return a reason, never a bare boolean.** Each failure needs different UI: re-pick the
file, prompt for permission, offer Save As, warn about staleness.

### Editing Part of a File

When you write back only a section, the rest of the file must come through untouched —
including its line endings, or a one-line edit shows up as a whole-file diff in git:

```javascript
const splitLines = (t) => String(t).split(/\r\n|\r|\n/);
const eolOf = (t) => (/\r\n/.test(t) ? "\r\n" : /\r/.test(t) ? "\r" : "\n");

function spliceSection(text, range, replacement) {
  const lines = splitLines(text);
  const body  = String(replacement).replace(/\r\n?/g, "\n").split("\n");
  return lines.slice(0, range.start)
              .concat(body, lines.slice(range.end))
              .join(eolOf(text));          // ← re-join with the file's own EOL
}
```

Split on all three line-ending styles, work internally in `\n`, and re-join with whatever
the file already used. Same principle applies to any partial write: read whole, splice
precisely, preserve everything you didn't mean to touch.

---

## Degrade, Don't Break

Half these capabilities are Chromium-only. The rule: **feature-detect once, hide what
isn't there, and make sure the core still works without it.**

```javascript
const canPick = typeof window.showOpenFilePicker === "function";

if (!canPick) {
  btnOpenFolder.hidden = true;      // hide, don't disable -- a dead button is worse
  btnWatch.hidden = true;
  fileInput.click();                // fall back to <input type="file">
}
```

Layer the fallbacks so every browser reaches the same core experience:

| Capability | Best | Fallback |
|---|---|---|
| Open a file | `showOpenFilePicker()` → handle, re-readable | `<input type="file">` → bytes only |
| Open a folder | `showDirectoryPicker()` | multi-select several files |
| Save | `createWritable()` → writes in place | `<a download>` → lands in Downloads |
| Auto-backup | directory handle | manual Export button |

**Never silently write a download as a substitute for saving.** A file in Downloads looks
like a saved file until someone checks the one they meant to edit.

**Also cap any filesystem walk.** A directory picker aimed at a project root will happily
descend into `node_modules` and appear to hang:

```javascript
const SKIP_DIR = /^(?:\.|node_modules$|dist$|build$|out$|target$|vendor$|__pycache__$)/i;
const MAX_FILES = 500;
const MAX_DEPTH = 8;
```

---

## Scale the Content, Not the Chrome

Browser zoom (`Ctrl` `+`) magnifies everything — toolbar, sidebar, text — so you end up
with *fewer* words on screen than you started with. An app can do better by scaling only
the document, through one CSS variable:

```css
:root { --doc-size: 15.5px; --doc-zoom: 1; }
.doc  { font-size: var(--doc-size); }
.doc h1 { font-size: 2em; }        /* everything inside sized in em -> scales together */
```
```javascript
function setFontSize(px) {
  root.style.setProperty("--doc-size", px + "px");
  root.style.setProperty("--doc-zoom", (px / BASE).toFixed(4));
  localStorage.setItem("myapp:fontSize", px);
}
```

Size every element inside the document in `em` and the whole article scales from one
variable while the furniture stays put.

**The `--doc-zoom` companion** exists for embedded content that can't inherit `em` sizing —
generated SVG with hard-coded font sizes, for instance. Apply CSS `zoom` to those
(`zoom: var(--doc-zoom)`), not `transform: scale()`, because `zoom` still reserves the
correct layout space while `transform` leaves a hole.

**Leave `Ctrl` `+`/`-` alone.** Bind bare `+`/`-` for document scaling so browser zoom stays
available for the whole interface. Two different jobs, two different keys.

---

## Sanitizing Untrusted HTML

If your app renders content the user didn't type — pasted markup, a dropped file, anything
with a raw-HTML escape hatch — you need an allow-list. Not a blocklist: those lose.

```javascript
const OK_TAGS  = new Set("a b blockquote br code dd dl dt em h1 h2 h3 img li ol p pre strong table tbody td th thead tr ul".split(" "));
const OK_ATTRS = new Set("href src alt title class id colspan rowspan align width height".split(" "));
const URL_ATTRS = new Set(["href", "src", "cite"]);

function sanitize(root) {
  const walker = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT);
  const doomed = [];
  let el;
  while ((el = walker.nextNode())) {
    if (!OK_TAGS.has(el.tagName.toLowerCase())) { doomed.push(el); continue; }
    for (const attr of Array.from(el.attributes)) {
      const name = attr.name.toLowerCase();
      if (!OK_ATTRS.has(name)) { el.removeAttribute(attr.name); continue; }
      if (URL_ATTRS.has(name)) el.setAttribute(attr.name, safeUrl(attr.value));
    }
  }
  // Unwrap rather than delete, so text inside a merely-unknown tag survives.
  for (const node of doomed) {
    if (/^(script|style|iframe|object|embed|form|input|link|meta|base)$/i.test(node.tagName)) node.remove();
    else node.replaceWith(...node.childNodes);
  }
}

const safeUrl = (raw) => /^(?:https?:|mailto:|#|\/|\.{0,2}\/)/i.test(raw.trim()) ? raw : "#";
```

**Three things that matter:**

- **Allow-list tags *and* attributes.** Stripping `<script>` is not enough — `onclick`,
  `onerror`, and `javascript:` URLs all execute without one.
- **Unwrap unknown tags, remove dangerous ones.** An unrecognized `<foo>` wrapping a
  paragraph should lose the tag, not the paragraph.
- **Collect while walking, mutate after.** Editing the tree during a `TreeWalker` traversal
  skips nodes.

Default to escaping, and make raw HTML an explicit opt-in the user has to turn on.

---

## Gotcha: Inline `style.display` Toggles

Showing and hiding elements with `el.style.display = "block"` is the most natural thing to
write in a no-framework app, and it carries two traps. Both cost real debugging time in
Cardoo, and both produce symptoms that point somewhere else entirely.

### 1. An inline `display` overrides your stylesheet

```css
.modal { display: flex; flex-direction: column; }   /* layout depends on this */
```
```javascript
modal.style.display = "block";   // ← silently kills the flex container
```

Inline styles beat stylesheet rules. The modal renders as a plain block, every `flex: 1`
child collapses to its intrinsic height, and nothing in the CSS looks wrong. Symptom: a
textarea that refuses to grow no matter what you do to its own rules.

**Fix**: set the display value the layout actually needs.

```javascript
modal.style.display = "flex";
```

Or sidestep it entirely — toggle a class and keep all display values in CSS:

```css
.modal { display: flex; }
.modal[hidden] { display: none; }
```
```javascript
modal.hidden = true;   // or classList.toggle("open")
```

### 2. Inline hide-state persists until something clears it

If one function hides an element, every other function that shows the panel must put it
back:

```javascript
function toggleEdit() {
  editor.style.display  = "block";
  viewer.style.display  = "none";    // hidden here...
}

function showPanel(text) {
  viewer.textContent    = text;      // ...still hidden, so this renders into nothing
  editor.style.display  = "none";
  viewer.style.display  = "block";   // ← REQUIRED, and easy to forget
}
```

Symptom: your render code is provably correct, the DOM contains exactly the right nodes,
and the user sees nothing — until a page refresh "fixes" it. That refresh isn't fixing
your rendering; it's wiping the stale inline style.

**Tell**: *"it only works after I reload"* almost always means leftover inline state, not
a rendering bug. Reloading clears inline styles and re-runs init from storage — so it
masks exactly this class of bug. Before chasing the renderer, inspect the element and
check whether it's simply hidden.

**Rule**: any function that reveals a panel must set the display state of *every* element
it manages, not just the one it's turning on.

---

## Testing & Development

### No Build, No Dev Server Needed

1. **Edit** `index.html`
2. **Refresh** the browser
3. **Done**

For local development, you can:

- Open the file directly: `file:///path/to/index.html`
- Or run a tiny HTTP server (not required, but useful for some APIs):
  ```bash
  # Python 3
  python3 -m http.server 8000
  # Then open http://localhost:8000
  ```

### Browser DevTools

- **Console**: `console.log(state)` to inspect application state
- **Storage**: Open DevTools → Application → localStorage to see persisted data
- **Network**: Confirm no external requests (all-in-one file)
- **Performance**: Monitor rendering on large datasets

### Debugging Tips

Print state at key points:

```javascript
function render() {
  console.log("Render called, state:", state);
  // ... actual render code
}
```

Use browser dev tools to inspect localStorage:

```javascript
// In console
JSON.parse(localStorage.getItem("myapp:state"))
```

---

## Scalability Limits

When to consider a different approach:

| Metric | Limit | Solution |
|--------|-------|----------|
| File size | >500 KB | Split into modules (but lose zero-dependency benefit) |
| localStorage data | >5 MB | Use IndexedDB (more complex) |
| Card/item count | >1000 | Virtual scrolling (or accept slower rendering) |
| Features | >200 | Architecture becoming hard to follow; consider a framework |
| Team size | >1 person | Hard to coordinate changes in one file; use version control branches |

Cardoo is intentionally simple because it's for **one person** managing **<100 items**. If you need multi-user sync or massive datasets, a different approach (client framework + backend server) makes sense.

---

## Checklist: Ports to New Projects

To use this pattern in a new single-file HTML project:

**Structure**
- [ ] One self-contained `.html` file, no external dependencies
- [ ] Inline all CSS/JS; vendor any library as a **classic** script (no ES modules)
- [ ] Nothing in the package is executable (no installer, script, or launcher)
- [ ] No `fetch`/XHR of local files — nothing loads at runtime that isn't inlined

**State**
- [ ] localStorage for persistence, keys namespaced `myapp:`
- [ ] Every storage call wrapped in `try/catch` (quota, privacy mode)
- [ ] `state` + `saveState()` + `render()` pattern
- [ ] **Export / Import to JSON** — never leave the only copy in localStorage
- [ ] **Staleness meter** — apply the litmus test: if this data vanished right now, would
      the user be upset and lose real time? If yes, add one; if losing it is a shrug, skip it
- [ ] **Undo/redo** for whichever actions are easy to fat-finger — as recorded intent,
      scoped to those actions, not a full-state snapshot of everything
- [ ] A "reset everything" that clears the namespace and reloads

**Appearance**
- [ ] Theming via CSS custom properties + `data-*` attributes
- [ ] Pre-render theme script before CSS to avoid flash
- [ ] Scale content via a CSS var, leave `Ctrl` `+`/`-` to browser zoom

**UI**
- [ ] Toast for transient feedback (under the toolbar, errors last longer)
- [ ] Drag & drop with `preventDefault` on `dragover`, folders checked first
- [ ] Revoke every `createObjectURL` you make

**In and out**
- [ ] Decide your input doors: drop, picker, paste, `#hash`, sidecar global
- [ ] `@media print` stylesheet — free PDF export, but only if you write it
- [ ] Standalone HTML export with computed vars frozen and zero `<script>` tags

**Robustness**
- [ ] Feature-detect capabilities; hide what's missing, keep the core working
- [ ] File writes: check permission → check staleness → write → adopt mtime
- [ ] Allow-list sanitizing if any content is untrusted
- [ ] Show/hide by class or `hidden`, not inline `style.display`
- [ ] Cap any filesystem walk (skip list, depth, file count)

**Ship**
- [ ] Test in browser DevTools (no build tools needed)
- [ ] Document in README.md + DESIGN.md

---

## Where These Came From

Two working apps, both a single bookmarked HTML file:

- **[Cardoo](../cardoo/)** (~250 lines) — kanban board. Source of the state/render loop,
  export/import, the staleness meter, and the `style.display` gotcha.
- **[Northern Lights MD Viewer](../md_to_html_viewer/)** (~4,700 lines, 60 features) —
  markdown viewer and editor. Source of the `file://` input routes, standalone export,
  print stylesheet, safe file writes, capability degradation, content scaling, and
  sanitizing.

The scale gap is the useful part: the same patterns carry a 250-line toy and a 4,700-line
application without a build step appearing anywhere in between.

**The thesis**: your browser stopped being a document viewer a long time ago. It has a
rendering engine, a fast JS runtime, storage that persists between visits, and — in
Chromium — permission to read and write a file once you point it at one. That is
everything an app needs, and it is already installed. Software with this feature set
normally ships as a 150 MB Electron bundle whose weight is almost entirely the engine you
already have.

**The trade is real but narrow.** A page can't run in the background, reach the filesystem
unprompted, or add itself to a right-click menu. For a reader, a task board, a calculator,
a log viewer — tools you *open* — that costs nothing. For a file manager or a daemon it
would be the wrong architecture. Know which one you're building.
