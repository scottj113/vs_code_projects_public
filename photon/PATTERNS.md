# Photon — Pattern Library

*HTML as a Solution.* A brief to read before building a new single-file tool: the rules
these apps live by, the decisions behind them, and the gotchas that cost real time to
find. Everything here came out of working software — [Cardoo](../cardoo/) and
[Northern Lights](../northern-lights/) — not theory.

**What's deliberately not here:** general web knowledge. How to write a toast, call the
clipboard API, or wire a keydown listener is common knowledge for any developer (or
Claude). This file is the part that isn't: what was *decided*, and what *bit*.

**The rule for adding to it:** a pattern goes in when it works in shipped code, with the
gotcha that cost time to find. Anything unverified is marked as such or left out. A
pattern file you have to second-guess is worse than none.

## Contents

1. [The Rules](#1-the-rules) — non-negotiables, and what `file://` can and can't do
2. [Decisions](#2-decisions) — choices already made, and why
3. [Gotchas](#3-gotchas) — symptom, cause, fix
4. [Testing Without a Server](#4-testing-without-a-server)
5. [Checklist: Starting a New Tool](#5-checklist-starting-a-new-tool)

---

## 1. The Rules

- **One `.html` file**, opened by double-click (`file://`), bookmarked like an app.
  Inline the CSS and JS. Small assets go in as data URIs.
- **No server — ever, even an optional local one.** The point isn't the `.html`
  container; it's that nothing has to be *up*: no account, no uptime, nothing for
  SmartScreen or a mail gateway to evaluate. A server in the loop, even off by default,
  turns the app back into an ordinary web app with a backend. Sync across machines is
  *export a file, move it yourself* (git, USB, email). That's the whole sync story.
- **No build step.** Edit, refresh, done. No `node_modules`, no lockfile.
- **Vendor libraries as classic scripts** — `vendor/lib.min.js` beside the HTML, loaded
  with a plain `<script src>`. ES modules don't load on `file://` (see below). A relative
  path is a hard dependency: moving the HTML alone breaks it, so say so in the README.
- **Nothing executable in the package.** No installer, script or launcher.
- **No network calls.** Nothing leaves the machine.
- **Target Chromium (Chrome / Edge).** The File System Access API — open a file and keep
  permission to re-read and write it — is what makes this architecture capable. Note a
  cheap fallback where one exists; don't relitigate the target per project.
- **Know when it's the wrong answer.** A page can't run in the background, reach the
  filesystem unprompted, or sit in a right-click menu. Fine for tools you *open* (a
  reader, a board, a converter); wrong for a daemon, a file manager, or anything needing
  multi-user sync or a shared database.

### The `file://` contract

| Blocked | Consequence |
|---|---|
| `<script type="module">` | Fetched under CORS, which `file://` fails. **The single most common way these apps break.** Vendor as classic scripts. |
| `fetch()` / XHR of local files | Can't load a sibling `.json` or `.css`. Inline it, or make the user hand it over. |
| IndexedDB (Chromium) | **File handles can't be stored, so every refresh drops them.** localStorage still works. |
| OPFS (`navigator.storage.getDirectory()`) | SecurityError. Matters mostly for testing (see §4). |
| Service workers | No offline layer, no background anything. |
| Full file paths | A page is never told where a dropped or picked file lives. Only an external tool (the sidecar route) can pass one. |

**Works:** localStorage, classic `<script src>`, relative `<img>`, CSS, the file and
directory pickers and the handles they return, drag & drop, clipboard, Blob downloads,
`window.open`, print.

**Permission is per session.** Re-arming file access after a reload is a browser rule,
not a bug — say so in the UI instead of letting it look broken.

---

## 2. Decisions

### Getting data in: a priority chain at boot

Four doors, tried in order: **(1)** a sidecar global (`window.__APP_BOOTSTRAP__`) written
by an editor task into a tiny `bootstrap.js` — the only route that can supply a real
path; **(2)** a `#hash` payload (`#name=…&md64=<base64>`), because a `file://` query
string is unreliable but the hash always survives; **(3)** last session from
localStorage; **(4)** empty state, waiting for a drop or the picker. Drop and the picker
are the good interactive doors: in Chromium they hand over a *handle*, not just bytes.

### Save vs. Backup — name them precisely

- **Save**: instant, automatic, local (localStorage). Survives a restart. *Not* a cleared
  cache — it's the only copy.
- **Backup**: a separate durable copy somewhere else (a downloaded file, a synced folder).

Never call the backup "autosave": seeing "Autosaved" reads as *my work is protected*.
Reserve "save" for the always-on local thing.

When the app edits a real file (Northern Lights), every write *is* the backup and
neither concept is needed. When localStorage is the only copy (Cardoo), both are.

### Export / import

- **Pretty-print** (`JSON.stringify(state, null, 2)`) so backups diff cleanly in git.
- **Timestamp filenames to the second**, colons swapped for dashes (Windows):
  `app-backup-2026-10-10T14-03-22.json`. Day-level names overwrite each other.
- **Validate the shape before assigning** on import, so a wrong file fails loudly.
- **Never auto-import.** Restoring is destructive; always a deliberate click.
- **One destination.** With an auto-backup folder armed, manual Export writes there too,
  falling back to a download only when no folder is armed. Two places backups can land
  is one too many.
- **Export resets the staleness meter in the same success path** — one click produces the
  file and clears the nag. Never a separate "mark as backed up" step. (Called "gold",
  twice, after using it in Cardoo.)

### The staleness meter

An ambient toolbar bar that fills green → yellow → red as unexported changes pile up.
Count every mutation, persist the count, reset it on export, and toast only on the
*transition* into red (latch with a flag) — toasting on every change trains people to
ignore toasts. Tune thresholds to a session's worth of work: Cardoo uses 0–10 / 11–20 /
21+, which reaches yellow after ~15 minutes of steady editing.

**Litmus test for whether an app needs one:** *if this data vanished right now, would the
user be upset and lose real time?* Not app size. Northern Lights (4,700 lines) has none —
wipe its storage and you reload the `.md` you still have. Cardoo (a few hundred lines)
can't ship without one — a card is often the only record a thought ever existed.

### Undo: record intent, not snapshots

Push small action records (`{ type: "move", id, from, to }`), not copies of the state.

- **It scopes.** Undo can cover only the actions people fat-finger (Cardoo: moves, later
  deletes) — a snapshot stack can't express "only this kind of change".
- **One shared stack, dispatching on `type`,** so `Ctrl+Z` respects true chronological
  order across action kinds. Separate stacks can't interleave correctly.
- **Log only the item acted on**, never siblings an array splice merely renumbered.
- **Look the target up by id at undo time,** so an item deleted in between makes the undo
  a no-op instead of corrupting state.
- Snapshots are still right when undo must mean *everything*, uniformly (keystrokes).

### Per-item "last changed"

One field on the record (`card.lastChange = { type, timestamp, … }`), set inside the
function that performs the change — not appended to a log, not reconstructed from a diff.
Only the record actually mutated gets it. Records from before the feature have none:
render nothing, don't invent history.

### Session memory: remember the content, not the handle

Handles can't survive a refresh on `file://` (no IndexedDB), and a directory handle dies
just the same. So an app reopening several files (Northern Lights' tabs) stores their
**text** in localStorage under a total budget (~2M chars of the ~5M shared by every local
file), current item first, oldest dropped when full.

- **Mark restored items as copies** (italics + tooltip) until a fresh open reattaches a
  handle — otherwise someone reads stale text unknowingly.
- **Key items by identity** (real path, else folder + name) so reopening a file refreshes
  its saved item instead of duplicating it. That's also how a restored item gets its live
  link back.
- **Rebuild the list before the boot doors run**, so a file arriving from the editor joins
  the remembered ones rather than replacing them.
- **Also save on `pagehide`** — scroll position moves without any event you'd persist on.
- **Let the list follow `render()`**: same key → update, new key → open/focus. A new way to
  open files can't forget to register itself.
- **Reattach with one folder pick per session.** A directory handle granted read/write
  reaches every file under it, so one `showDirectoryPicker({ mode: "readwrite" })` relinks all
  restored items — match by real path, else folder + name, else a name unique in the tree,
  and never guess between two. Use `dir.resolve(fileHandle)` to place a file you already
  hold, and resolve relative images against the document's own folder (on `file://` the
  browser resolves them against the viewer). Northern Lights: **Connect folder**.

### Writing files: check, write, adopt

```javascript
async function writeFile(text, handle) {          // capture the target before any await
  let p = await handle.queryPermission({ mode: "readwrite" });
  if (p !== "granted") {
    try { p = await handle.requestPermission({ mode: "readwrite" }); }  // needs a gesture
    catch (e) { return { ok: false, why: "no-activation" }; }
  }
  if (p !== "granted") return { ok: false, why: "denied" };
  const before = await handle.getFile();
  if (before.lastModified !== known) return { ok: false, why: "stale" };  // changed on disk
  const w = await handle.createWritable(); await w.write(text); await w.close();
  adopt((await handle.getFile()).lastModified);   // or a watcher "reloads" your own save
  return { ok: true };
}
```

- **Return a reason, never a boolean** — each failure needs different UI (re-pick,
  permission, Save As, staleness warning).
- **Report staleness; don't silently win the race.** An explicit `Ctrl+S` may overwrite
  (the keypress is the confirmation); an automatic save must not.
- **Save As is the reliable fallback**: choosing a file in `showSaveFilePicker` *is* the
  write grant. Adopt the handle it returns, and later saves are silent.
- **Never substitute a download for a save.** A copy in Downloads looks saved until
  someone checks the file they meant to edit.

### Partial writes: touch only the lines you changed

Read whole, splice precisely, re-join with the file's own line ending — otherwise a
one-line edit is a whole-file git diff:

```javascript
const splitLines = (t) => String(t).split(/\r\n|\r|\n/);
const eolOf = (t) => (/\r\n/.test(t) ? "\r\n" : /\r/.test(t) ? "\r" : "\n");
// lines.slice(0, start).concat(newLines, lines.slice(end)).join(eolOf(text))
```

This is why Northern Lights' in-place editing has the parser stamp each block with its
source lines (`data-src="12-15"`) and splices only those, and why bundled WYSIWYG editors
were rejected: they re-serialize the whole file. Track an edited region by line range, not
by heading id — retitling a heading is an ordinary edit, and it changes the id.

### Output: standalone export and print

- **Standalone HTML export**: freeze `getComputedStyle` CSS variables into `:root{}` (one
  theme as literal values, not all of them plus the switcher), **clone the DOM before
  stripping** interactive bits (mutating the live page breaks the viewer on Export), and
  emit **zero `<script>` tags** — diagrams pre-rendered to SVG — so it opens anywhere,
  forever.
- **Print is free PDF, if you write `@media print`**: hide the furniture, reset reading
  preferences (dark mode, 180% text, bold-all belong on screen), and un-fix the app shell
  (see Gotchas).

### Rendering content people wrote elsewhere

- **The target is how GitHub renders it**, since that's what authors check against.
  Follow CommonMark/GFM rules rather than inventing friendlier ones (see the raw-HTML
  gotchas).
- **Raw HTML through an allow-list** — tags *and* attributes, `javascript:` URLs
  neutered, unknown tags unwrapped (keep their text), dangerous ones removed. Never a
  blocklist.

### Reading comfort

- **Scale the content, not the chrome**: one `--doc-size` variable, everything inside the
  document in `em`. Bind bare `+` / `-`; leave `Ctrl +/-` to browser zoom for the whole UI.
  For embedded content that can't inherit `em` (SVG with fixed font sizes) use CSS
  `zoom: var(--doc-zoom)`, not `transform: scale()` — `zoom` reserves layout space.
- **Bumper lanes**: narrow the content column with percentage margins. Size the steps to
  the content: 10% steps to 50% suit prose; a kanban board needed 5% steps to 20%. Match
  the app's existing control style (segmented group vs. cycling button).

### Degrade, don't break

Feature-detect once, **hide** what's missing (a dead button is worse than none), keep the
core working: picker → `<input type="file">`; directory picker → multi-select; in-place
write → `<a download>`; folder auto-backup → manual Export.

### Small UI calls that came from use

- **Toast under the toolbar, not bottom-right** — messages answer toolbar clicks, and
  instructions in a corner get missed. Errors stay about twice as long (Northern Lights
  settled on 4.8 s / 10.4 s after 2.4 s / 5.2 s vanished before being read).
  `pointer-events: none`, and `clearTimeout` on every call.
- **Confirm a copy on the button itself** — the eyes are already there.
- **Scroll-spy with `IntersectionObserver`**: a negative `rootMargin` (`-58px 0px -70% 0px`)
  discounts the toolbar and limits "current" to the top third; break ties in document
  order so the highlight doesn't jump.
- **Hover previews**: `pointer-events: none` (or the preview steals `mouseleave` and gets
  stuck open), and cancel on drag-start, click and delete, not only `mouseleave`.
- **Optional panels belong to their mode.** Northern Lights' Markdown split pane exists only
  while editing — never open by default, offered by an icon on the editable block, closed
  when editing ends — and read-only source view switches all editing off. One way of
  looking at the file at a time; no state combinations to reconcile.

---

## 3. Gotchas

Each one cost real debugging time. Several were only found by **looking at the rendered
result** — screenshots catch what reading the CSS doesn't.

### `file://` and browser APIs

- **The hash route: don't use `URLSearchParams`.** It decodes `+` as a space, silently
  corrupting base64 from the first `+` on. And **`atob` skips whitespace instead of
  throwing**, so a malformed payload decodes into plausible garbage. Parse by hand,
  validate.
- **User activation is per window, and `window.open()` spends it.** After opening a
  popup, neither page can raise the file-permission prompt (the handle belongs to the
  opener; the gesture happened elsewhere). Ask for permission *before* opening the window,
  in the same click — or have the popup use Save As, whose dialog is itself the grant.
- **Writes from timers need the grant locked in first.** An autosave has no gesture of its
  own; call `requestPermission({ mode: "readwrite" })` explicitly while a click is still
  live, or the timed write throws SecurityError.
- **Don't `await` anything before a picker.** `showOpenFilePicker` / `showSaveFilePicker`
  need the click's activation. Fire side effects (like copying a path to the clipboard for
  the dialog's File name box) without awaiting them.
- **A dropped folder never appears in `dataTransfer.files`** — only as a directory handle
  from `getAsFileSystemHandle()`. Check handles first. And call `getAsFileSystemHandle()`
  **synchronously inside the drop handler**: `DataTransfer` is neutered once the handler
  returns, so start the promises there and await them later.
- **`preventDefault()` on `dragover` is mandatory**, or the drop never fires and the
  browser navigates to the file — which looks exactly like a crash.
- **Prefer the drop's handle over its bytes.** Only the handle can re-read the file, so
  drop is the one route that arms live reload for free.
- **A file watcher reloads your own save** unless you adopt the new `lastModified`
  immediately after writing. Also hold reloads off while an edit is open or unsaved — a
  re-render would destroy it.
- **Revoke every `createObjectURL`** when its document goes away — but for one-shot
  downloads, revoke on a timer (~4 s); revoking immediately can cancel the download. With
  several open documents sharing images, revoke only when nothing references the map.
- **Cap every filesystem walk** — a directory picker aimed at a project root descends into
  `node_modules` and appears to hang. Skip list (`.*`, `node_modules`, `dist`, `build`,
  `vendor`…), depth ~8, ~500 files.
- **Clear-cache must stop the unload save**, or the `pagehide` handler writes everything
  straight back during the reload that follows.
- **Browser-owned keys never reach the page**: `Ctrl+Tab`, `Ctrl+W`. Use unmodified keys
  (`[` `]`), guarded so they don't fire while typing in a field.
- **`Ctrl+Z` / `Ctrl+Y` bound globally break undo inside text fields.** Skip the app
  binding when focus is in an `INPUT`/`TEXTAREA`. (`Ctrl+R` has no text meaning, so it can
  stay unconditional with `preventDefault`.)

### Security

- **Sanitize in an inert `<template>`, never after insertion.** A live document acts on
  some elements the instant they arrive: `<meta http-equiv="refresh">` navigates away,
  `<base>` re-roots every link, `<iframe>`/`<link>` start fetching — before a post-insert
  sanitizer can remove them. Found when a test file's meta refresh sent the viewer to
  another site:
  ```javascript
  const tpl = document.createElement("template");
  tpl.innerHTML = html;          // template content runs nothing, loads nothing
  sanitize(tpl.content);
  target.replaceChildren(tpl.content);
  ```
- **Allow-list attributes, not just tags** — `onerror`, `onclick` and `javascript:` URLs
  execute without any `<script>`.
- **Collect while walking, mutate after.** Editing the tree mid-`TreeWalker` skips nodes.

### Parsing authored content

- **HTML comments end at `-->`, not at a blank line.** A multi-paragraph comment ended at
  the blank line reaches the page unclosed while its `-->` gets escaped as text — and the
  browser comments out *the entire rest of the document*. Likewise `<pre>`, `<script>`,
  `<style>` run to their closing tag. Follow CommonMark's HTML-block rules.
- **A line starting with an inline tag is not an HTML block.** Only block tags (`div`,
  `p`, `table`, `details`…) or a tag alone on its line start one; otherwise
  `<b>Note:</b> **bold**` loses its Markdown and its paragraph.
- **Pass through only real entity names.** `&nbsp;` `&copy;` must render, but an unknown
  name passed through raw gets read by the browser's legacy rules: `&notanentity;` shows
  as "¬anentity;". Ask the browser's own decoder (a `<textarea>`): a real entity decodes
  completely, leaving no trailing `;`.
- **Multiple inline markers: one alternating regex**, left to right — splitting on each
  marker in turn re-fragments the first pass. **Combined/nested forms first in the
  alternation**: regex takes the first alternative that matches, not the longest.
- **Block-level detection needs a minimum run** — one line starting with `*` shouldn't
  become a one-item list. Require 2+ consecutive lines.

### CSS and the DOM

- **A class rule's `display` beats the `hidden` attribute.** `button.btn { display:
  inline-flex }` made Northern Lights' Edit button impossible to hide — it showed on the
  empty screen from the day it was added, and a test reading `.hidden` said all was well.
  Check what's *visible*. Any element with a `display` rule needs its own
  `[hidden] { display: none }`, or toggle a body class instead.
- **Inline `style.display` overrides the stylesheet.** `modal.style.display = "block"`
  silently kills a flex layout (symptom: a textarea that won't grow). And **inline
  hide-state persists**: every function that reveals a panel must set the display of every
  element it manages. Tell: *"it only works after I reload"* — reload wipes inline state.
  Prefer classes or `hidden`.
- **Author CSS beats presentational attributes.** `img { height: auto }` overrode
  `<img height="64">` (logos rendered at 400 px); `td { text-align: left }` overrode
  `align="right"`, including Markdown's `---:` columns. Scope defaults with
  `:not([height])`, `:not([align])`.
- **Padding on inline elements doesn't grow the line box** — a padded `<mark>` crowds the
  next line. Fix by `line-height`, or scope smaller padding to the one tight container
  rather than shrinking the shared rule.
- **`scroll-behavior: smooth` animates programmatic scrolls too.** Restoring a position
  with `scrollTop = y` glides the whole way down. Use `scrollTo({ top, behavior:
  "instant" })`.
- **`scroll-margin-top` applies to `scrollIntoView()`.** Fine for jumps; wrong when you
  need exact alignment — compute `scrollTop + el.top - scroller.top` instead.
- **Percentage margins (bumper lanes), three traps:** `width: 100%` + `margin: 0 10%`
  asks for 120% — reset `width: auto`; `flex-shrink: 0` children overflow instead of
  compressing — use `min-width: 0; flex: 1 1 0`; an old `max-width` + `margin: auto`
  leaves stray margin at "0%" — remove it.
- **A fixed-position app shell prints one page** — whatever was in the viewport. Make it
  `position: static` and the scroller `overflow: visible` under `@media print`.
- **A theme applied after load flashes.** Read the saved theme in a tiny `<script>`
  *before* the stylesheet and set `data-theme` on `<html>`.
- **Namespace localStorage keys** (`app:theme`). On `file://` every local HTML file can
  share one origin, so a bare `"theme"` collides with your other tools. Wrap every storage
  call in `try/catch` (quota, privacy modes). When deleting by prefix, collect keys first
  — `localStorage.key(i)` re-indexes as you remove.

---

## 4. Testing Without a Server

No build, no dev server: edit, refresh. For automated checks, drive **headless Edge over
the DevTools protocol from Node** — Node 18+ has `fetch` and `WebSocket` built in, so it
needs no packages:

1. Launch `msedge --headless=new --remote-debugging-port=9333 --user-data-dir=<temp>`.
   A throwaway profile keeps tests out of the user's real localStorage.
2. Find the page via `http://127.0.0.1:9333/json`, connect its `webSocketDebuggerUrl`,
   `Page.navigate` to the `file:///…` URL, then `Runtime.evaluate` assertions.
3. **Simulate input with real events**: a drop is `new DataTransfer()` + `File` objects +
   a dispatched `DragEvent("drop")`; keys are dispatched `KeyboardEvent`s. Turn on
   `Emulation.setFocusEmulationEnabled` or headless `blur` events won't fire.
4. **File handles**: OPFS is blocked on `file://`, so stand in an object with
   `queryPermission`, `getFile` and `createWritable` backed by memory. Code that only
   calls those methods can't tell the difference.
5. **To reach internals**, test a scratch *copy* with a one-line hook
   (`window.__app = { state }`) injected — never ship test code in the real file.
6. **Screenshot** with `Page.captureScreenshot` — in 1600 px slices for long pages — and
   look at them. Whole bug classes (the hidden-button override, attribute-vs-CSS,
   a sanitizer gap) only showed up there.

Don't build tests around a loopback HTTP server: the environment may block it, and the
app never runs that way.

---

## 5. Checklist: Starting a New Tool

**Shape**
- [ ] One `.html` file; CSS/JS inline; libraries vendored as **classic** scripts
- [ ] No server of any kind, no network calls, nothing executable
- [ ] Decide the input doors (drop, picker, paste, `#hash`, sidecar) and their boot order
- [ ] Feature-detect Chromium-only APIs; hide what's missing

**State**
- [ ] localStorage keys namespaced, every call in `try/catch`, a reset that clears the
      namespace
- [ ] Apply the litmus test: would losing this data hurt? If yes — Save vs. Backup named
      precisely, Export/Import (pretty JSON, second-level timestamps, validated, never
      automatic), one destination, staleness meter reset by Export itself
- [ ] Undo for the fat-fingerable actions: recorded intent, one stack, target only
- [ ] Editing real files: check → write → adopt; reasons not booleans; Save As fallback;
      splice only touched lines, keep the file's line endings
- [ ] Several files open: remember content not handles; mark restored copies

**Appearance**
- [ ] Theme via CSS variables + `data-*`, applied before first paint
- [ ] Content scaling via one variable; `Ctrl +/-` left to the browser
- [ ] Every element with a `display` rule that can be `hidden` has a `[hidden]` rule
- [ ] No author CSS overriding `width`/`height`/`align` attributes you need to honour

**Output**
- [ ] `@media print`, with the app shell un-fixed
- [ ] Standalone export: computed vars frozen, DOM cloned, zero scripts

**Untrusted content**
- [ ] Allow-list tags and attributes; sanitize in a `<template>` before insertion
- [ ] Authored formats follow their spec (CommonMark/GFM), not friendlier rules

**Ship**
- [ ] Headless smoke test of the core flows, plus screenshots you actually look at
- [ ] README states the vendor-path dependency and the Chromium target
- [ ] Anything new that proved itself goes back into this file

---

*Sources: Cardoo — state and backup design, the staleness meter, undo, change logs, the
`style.display` and inline-padding gotchas, inline markup parsing, the bumper-lane traps.
Northern Lights — the `file://` doors, file writing, export and print, sanitizing and
raw-HTML parsing, session memory, in-place editing, content scaling, and the headless
testing method.*
