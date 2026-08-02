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
- **6 highlight colors**: Click 🖍️ Highlight to pick from six bright/neon options
- **Undo/redo**: `Ctrl+Z` / `Ctrl+Y` for card moves and deletes
- **Persistence**: All changes save to browser storage automatically
- **Four themes**: Blue Dark, Slate Dark, White Light, Beige Light (click 🎨 to cycle)
- **Fire meter**: Visual alarm showing unsaved changes (green → yellow → red)
- **Recovery Backup**: Optional automatic backups to a local folder (Chrome/Edge), every 20 changes or 20 minutes
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

Pick the highlight color from six bright/neon options with the 🖍️ **Highlight** button — your choice persists across sessions.

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

## Themes

Click the 🎨 **Theme** button to cycle through four carefully chosen palettes:

- **Blue Dark** — Cool, professional (default)
- **Slate Dark** — Minimal, dark, easy on eyes
- **White Light** — Bright, clean, minimal
- **Beige Light** — Warm, comfortable for long sessions

Your choice persists across sessions. Themes load instantly without flash.

## Keyboard

| Key | Action |
|-----|--------|
| `Ctrl+Z` | Undo the last move or delete |
| `Ctrl+Y` | Redo what you just undid |
| Click × | Delete card (undoable) |

Undo/redo covers **card moves and deletes** — not adding or editing text. Actions undo in
true reverse-chronological order regardless of type — move a card, delete a different one,
and `Ctrl+Z` twice undoes the delete first, then the move, exactly as they happened.

## Backup & Recovery

**Fire Meter**: The toolbar shows a progress bar that fills as you make changes. Colors shift from green (few changes) → yellow → orange → red (many changes). This visual cue encourages regular exports.

**Export**: Click the 📥 **Export** button to download your current state as a JSON file (e.g., `cardoo-backup-2026-07-31.json`). The fire meter resets after export. Commit the JSON to git or keep it as a backup.

**Import**: Click 📤 **Import** to restore from a previously exported backup file.

**Recovery Backup Config** (Chrome/Edge only): Click ⚙️ **Config** and select a local folder. Once armed, Cardoo writes a timestamped backup file there automatically — either after every 20 changes, or after 20 minutes if there's at least one change still unsaved, whichever comes first. The 20-minute timer means a handful of edits followed by walking away still gets backed up instead of sitting unprotected indefinitely. Each save gets its own uniquely-named file (down to the second), so nothing overwrites an earlier backup — you can restore from any point, not just the most recent save.

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
- **Chrome/Edge**: Recovery Backup to a local folder (uses File System Access API)

---

Built on [Photon](../photon/) — HTML as a Solution: if it doesn't need a server or a
network, use the platform you already have.
