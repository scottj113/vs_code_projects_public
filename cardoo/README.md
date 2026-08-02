# Cardoo — Personal Kanban

A minimal Kanban board for personal task management. One HTML file, no installation, no dependencies.

## Quick Start 

1. Open `cardoo.html` in your browser
2. Bookmark it in your toolbar
3. Start moving cards between lanes

That's it.

## Features

- **Four lanes**: Pondering → To Do → In Progress → Done
- **Drag & drop**: Move cards between lanes with your mouse
- **Hold-to-reorder**: Hold a dragged card between two others for ~1s to drop it in that exact spot
- **Add/delete cards**: Click "+ Add card" in any lane, or use the delete button (×)
- **Card details**: Click any card to view/edit — same large editor for adding and editing
- **Hover preview**: Hover a card for ~¾s to peek at its full text without opening it
- **Formatting**: `<<highlight>>`, `[[bold]]`, and consecutive `*` lines become a bullet list
- **🎨 Appearance**: one popup for theme, highlight color, text size, and bumper lanes
- **Undo/redo**: `Ctrl+Z` / `Ctrl+Y` for card moves and deletes
- **Persistence**: All changes save to browser storage automatically
- **Fire meter**: Visual alarm showing unsaved changes (green → yellow → red), with a one-click save icon right next to it
- **💾 Backup**: Export/Import plus optional Auto Backup to a local folder (Chrome/Edge), every 20 changes or 20 minutes
- **Help**: Click ❓ Help for a quick in-app reference to all of this

## Card Details & Formatting

**In the lanes**, cards show only their **first line**, as plain text — keeping the board clean and compact. All formatting below renders in the detail view and the hover preview, not in the lane.

**Click any card** to open its detail view and see the full multi-line body. Here you can:
- See the complete card text (line 1, line 2, line 3, etc.), formatted
- Edit by clicking ✏️ **Edit**
- Save changes with 💾 **Save**

**Hover any card** for about ¾ second to see the same formatted preview without opening the editor — move the mouse off and it disappears.

**Multi-line cards** let you write rich descriptions without cluttering the board:

```
Fix critical auth bug
  - Check password reset flow
  - Validate session tokens
  - Test with <<production data>>
```

In lanes: shows `Fix critical auth bug`
In the detail view/hover preview: shows the full description, formatted

**Highlight** text by wrapping it in double angle brackets:

```
Remember to call <<Mom>> on Sunday
```

Pick the highlight color from six bright/neon options in the 🎨 **Appearance** popup — your choice persists across sessions.

**Bold** text by wrapping it in double square brackets:

```
This is [[really]] important
```

Combine both by nesting either order — `[[<<text>>]]` or `<<[[text]]>>` — to get bold *and* highlighted together.

**Bullet lists**: two or more *consecutive* lines starting with `*` become a real bullet list:

```
* First item
* Second item
* Third item
```

A single `*` line on its own doesn't qualify and stays as literal text — you need at least two in a row.

All formatting persists across sessions and is included in exports.

## Appearance

Click 🎨 **Appearance** to open one popup with everything visual — pick a setting and the popup stays open, so you can adjust more than one thing in a single visit. It closes on an outside click or `Esc`.

**Theme** — four palettes, click one to switch directly:

- **Blue Dark** — Cool, professional (default)
- **Slate Dark** — Minimal, dark, easy on eyes
- **White Light** — Bright, clean, minimal
- **Beige Light** — Warm, comfortable for long sessions

**Highlight color** — six bright/neon options for `<<highlighted>>` text.

**Text size** — `A−`/`A+` resize card, detail, and preview text in 10% steps, independent of your browser's zoom (which resizes the whole page, toolbar included). Click the percentage between them to jump back to 100%. Keyboard: `+`/`-` to resize, `0` to reset — no Ctrl, so your browser's own zoom keys are untouched.

**Bumper lanes** — adds side margins (0–20%, one click per level) to compress the board into a narrower, more centered column on wide screens.

All four choices persist across sessions and load instantly without flash.

## Keyboard

| Key | Action |
|-----|--------|
| `Ctrl+Z` | Undo the last move or delete |
| `Ctrl+Y` | Redo what you just undid |
| `+` / `-` | Resize card/detail/preview text |
| `0` | Reset text size to 100% |
| `Esc` | Close an open Appearance/Backup popup |
| Click × | Delete card (undoable) |

Undo/redo covers **card moves and deletes** — not adding or editing text. Actions undo in
true reverse-chronological order regardless of type — move a card, delete a different one,
and `Ctrl+Z` twice undoes the delete first, then the move, exactly as they happened.

## Backup & Recovery

**Fire Meter**: The toolbar shows a progress bar that fills as you make changes. Colors shift from green (few changes) → yellow → orange → red (many changes). A small 📥 save icon sits right next to it — one click exports immediately and resets the meter, no need to open the Backup popup.

Click 💾 **Backup** to open the popup for everything else:

**Export**: Downloads your current state as a JSON file. The toast names the exact file it just saved (e.g., `cardoo-backup-2026-08-02T15-30-45.json`) so you can find it — each export gets a unique, second-granularity filename, so nothing ever overwrites an earlier backup.

**Import**: Restore from a previously exported backup file.

**Auto Backup** (Chrome/Edge only): A ✅/❌ next to the label shows whether it's currently on. Click **Choose Folder** to arm it — Cardoo then writes a timestamped backup file there automatically, either after every 20 changes or after 20 minutes if there's at least one change still unsaved, whichever comes first. The 20-minute timer means a handful of edits followed by walking away still gets backed up instead of sitting unprotected indefinitely.

A browser refresh always turns Auto Backup back off — the browser can't remember folder access across one — so it shows ❌ again and a **Resume Auto Backup** button appears for a one-click re-arm instead of hunting for the folder again. Once a folder's chosen, **Choose Folder** relabels to "✓ Folder Selected" and disables itself; reopening the popup re-enables it if you want to pick a different folder.

If you ever clear your browser cache, import your backup to recover all your cards instantly.

## How It Works

Everything runs in the browser. No server, no database, no app to install.

- **Data storage**: Browser `localStorage` (persists across sessions)
- **Backups**: Export to JSON and commit to git for recovery after cache clear
- **Architecture**: Single HTML file with embedded CSS and JavaScript
- **Philosophy**: Zero overhead. Open the file, use the tool.

## Customization

See [DESIGN.md](DESIGN.md) for information about extending the theme, adding lanes, or modifying the card structure.

## Browser Support

- **All browsers**: Drag & drop, add/delete, export/import, fire meter
- **Chrome/Edge**: Auto Backup to a local folder (uses File System Access API)

---

Built on [Photon](../photon/) — HTML as a Solution: if it doesn't need a server or a
network, use the platform you already have.
