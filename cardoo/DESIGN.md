# Cardoo Design & Pattern

## Philosophy: HTML as a Solution

Cardoo is built on a core premise: **if it doesn't need a server or network, the browser is the complete platform.**

### Why Single File?

- **No install**: Double-click, it works
- **No build step**: No dependencies to manage, no `package.json`, no `node_modules`
- **No approval friction**: Can't be stripped by mail gateways, doesn't need SmartScreen approval
- **No update burden**: Bookmark it and it stays stable; upgrade when you want
- **Portable**: Email it, move it, share it—it goes with the file

This trades some capabilities for radical simplicity:
- ✗ Cannot run in the background or respond to system events
- ✗ Cannot reach into your filesystem unprompted
- ✗ Cannot be pinned to your start menu
- **✓ For a task board, these don't matter.** You hand it your focus, it shows you your work.

### Why Not Electron?

A task board normally arrives as a 150 MB Electron bundle. Nearly all that weight is Chromium itself. You already have Chromium in your browser—Cardoo is only the application code.

---

## Architecture

```
cardoo.html  —  entire application (HTML + CSS + JS)
              no external dependencies
              ~200 lines of code
```

### Data Structure

```javascript
{
  cards: {
    "Pondering": [
      { id: "1722517200000", text: "Buy milk" },
      { id: "1722517300000", text: "Fix bug in auth" }
    ],
    "To Do": [ ... ],
    "In Progress": [ ... ],
    "Done": [ ... ]
  },
  laneOrder: {
    "Pondering": ["1722517200000", "1722517300000"],
    "To Do": [ ... ],
    ...
  }
}
```

**Why two structures?**
- `cards` by lane lets you find a card by ID and text
- `laneOrder` preserves the order of cards within each lane (arrays preserve order, object properties don't guarantee it)

**Storage**: Serialized to JSON in `localStorage` under the key `cardoo`.

### State & Rendering

1. **Load**: Read from localStorage on startup
2. **Render**: Build DOM from state on every change
3. **Save**: Write state to localStorage after every mutation

This is simple and fast for small datasets (a personal task board is rarely more than 50-100 cards total).

### Events

- **Drag start**: Add `dragging` class
- **Drag over**: Add `drag-over` class to target lane
- **Drop**: Move card from source lane to target lane, save, re-render
- **Click card ×**: Delete card, save, re-render
- **Click "+ Add card"**: Open input dialog, wait for text, create card, save, re-render

All mutations flow through `saveData()` → `render()`, keeping state and DOM in sync.

---

## Extending Cardoo

### Add a New Lane

In `cardoo.html`, modify the `LANES` array:

```javascript
const LANES = ['Pondering', 'To Do', 'In Progress', 'Review', 'Done'];
```

On next startup, `initData()` creates that lane if it doesn't exist in localStorage.

### Customize the Theme

Cardoo uses a **single CSS palette** (dark theme with grays and subtle borders). To customize:

Find the `:root` style rules and adjust:

```css
:root {
  --bg: #1a1a1a;      /* Main background */
  --bg-lane: #2a2a2a; /* Lane background */
  --bg-card: #3a3a3a; /* Card background */
  --border: #444;
  --border-hover: #555;
  --text: #fff;
  --text-muted: #888;
}
```

**No build step needed**—just edit the CSS and reload.

### Light Theme (Future)

To add light mode, you could:

1. Add a second palette to `:root`, e.g. `:root[data-theme="light"]`
2. Add a toggle button in the UI
3. Store the choice in localStorage
4. Apply `data-theme` to `<html>` on startup

(This is how Northern Lights does it with 12 palettes.)

### Add Card Properties

Currently cards have `id` and `text`. To add properties (e.g., priority, tags, due date):

1. Update the data structure:
   ```javascript
   { id: "...", text: "...", priority: "high", tags: ["bug"] }
   ```

2. Update `render()` to display the new properties

3. Update input dialog to collect them

4. Update save logic to persist them

---

## Inspiration: Northern Lights MD Viewer

Cardoo follows the same deployment model as [Northern Lights](../northern-lights/), a mature single-file Markdown viewer with:

- **60 features** shipped in ~9 days
- **4,700 lines** of well-organized code
- **Zero dependencies** (vendored Mermaid library only)
- **12 contrast-validated color palettes**
- **Full file I/O** (read/edit/save to disk)
- **Live reload** and watch mode

Northern Lights proves that single-file HTML applications can ship production-grade features without the overhead of a build process or installer. Cardoo applies the same philosophy to a simpler domain: personal task management.

---

## Reusable Patterns

The portable parts of Cardoo — theming, the state/render loop, export/import, the
staleness meter, the UI primitives — are documented in [Photon](../photon/), the shared
"HTML as a Solution" pattern library:

**[../photon/PATTERNS.md](../photon/PATTERNS.md)**

Cardoo is one of its two reference implementations. When something here is proven to work
and would carry to another single-file app, it belongs in that library rather than in this
file.

---

## Performance & Limits

- **DOM rendering**: Re-rendering the entire board on each change is fast for <100 cards
- **localStorage**: ~5-10 MB available in most browsers, more than enough for years of tasks
- **Drag & drop**: Native HTML5 API, no libraries needed

For a personal task board, this is a deliberate trade: simplicity over scalability.

---

## Next Steps (Not Committed)

Potential future enhancements:

- [ ] Light theme + theme toggle
- [ ] Card descriptions / notes
- [ ] Due dates and reminders
- [ ] Undo/redo
- [ ] Export to JSON (backup)
- [ ] Keyboard-only mode (Vim-like navigation)
- [ ] Multiple boards / workspaces

None of these require leaving the single-file model.
