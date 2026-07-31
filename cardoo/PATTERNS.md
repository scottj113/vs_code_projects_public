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

- [ ] One `index.html` file, no external dependencies
- [ ] Theming via CSS custom properties + `data-*` attributes
- [ ] Pre-render theme script before CSS to avoid flash
- [ ] localStorage for state persistence
- [ ] Centralized event handlers for keyboard shortcuts
- [ ] `state` + `saveState()` + `render()` pattern
- [ ] Test in browser DevTools (no build tools needed)
- [ ] Document in README.md + DESIGN.md

---

**Related**: See [Northern Lights MD Viewer](../md_to_html_viewer/) for a more complex example with 60 features in a single file.
