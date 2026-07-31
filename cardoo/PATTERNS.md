# Reusable Patterns

This document captures design patterns from Cardoo and Northern Lights that are portable to other single-file HTML projects.

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

- [ ] One self-contained `.html` file, no external dependencies
- [ ] Theming via CSS custom properties + `data-*` attributes
- [ ] Pre-render theme script before CSS to avoid flash
- [ ] localStorage for state persistence
- [ ] **Export / Import to JSON** — never leave the only copy in localStorage
- [ ] **Staleness meter** if the app holds work worth keeping
- [ ] Centralized event handlers for keyboard shortcuts
- [ ] `state` + `saveState()` + `render()` pattern
- [ ] Show/hide by class or `hidden`, not inline `style.display`
- [ ] Test in browser DevTools (no build tools needed)
- [ ] Document in README.md + DESIGN.md

---

**Related**: See [Northern Lights MD Viewer](../md_to_html_viewer/) for a more complex example with 60 features in a single file.
