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
- **Add/delete cards**: Click "+ Add card" in any lane, or use the delete button (×)
- **Card details**: Click any card to view/edit with highlight support
- **Highlights**: Use `<<text>>` to mark important parts with yellow background
- **Persistence**: All changes save to browser storage automatically
- **Four themes**: Blue Dark, Slate Dark, White Light, Beige Light (click 🎨 to cycle)
- **Fire meter**: Visual alarm showing unsaved changes (green → yellow → red)
- **Auto-export**: Option to save backups automatically to a local folder (Chrome/Edge)

## Card Details & Highlights

**In the lanes**, cards show only their **first line** — keeping the board clean and compact.

**Click any card** to open its detail view and see the full multi-line body. Here you can:
- See the complete card text (line 1, line 2, line 3, etc.)
- View highlights (yellow background text)
- Edit by clicking ✏️ **Edit**
- Save changes with 💾 **Save**

**Multi-line cards** let you write rich descriptions without cluttering the board:

```
Fix critical auth bug
  - Check password reset flow
  - Validate session tokens
  - Test with <<production data>>
```

In lanes: shows `Fix critical auth bug`  
In popup: shows full description with highlights

**To highlight text**, wrap it in double angle brackets:

```
Remember to call <<Mom>> on Sunday
```

Renders as: Remember to call **Mom** on Sunday (with yellow highlight)

Highlights persist across sessions and are included in exports.

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
| `Enter` | Save card text in the input dialog |
| `Escape` | Cancel card input |
| Click × | Delete card |

## Backup & Recovery

**Fire Meter**: The toolbar shows a progress bar that fills as you make changes. Colors shift from green (few changes) → yellow → orange → red (many changes). This visual cue encourages regular exports.

**Export**: Click the 📥 **Export** button to download your current state as a JSON file (e.g., `cardoo-backup-2026-07-31.json`). The fire meter resets after export. Commit the JSON to git or keep it as a backup.

**Import**: Click 📤 **Import** to restore from a previously exported backup file.

**Auto-Export Config** (Chrome/Edge only): Click ⚙️ **Config** and select a local folder. Backups will automatically save to that folder whenever you make changes. Useful for continuous protection without manual exports.

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
- **Chrome/Edge**: Auto-export to local folder (uses File System Access API)

---

Made with the "HTML as solution" philosophy: if it doesn't need a server or network, use the platform you already have.
