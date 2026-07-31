# VS Code Integration Setup

Open any markdown file in VS Code as a live preview in the viewer with one keystroke.

## What It Does

Press **Ctrl+M then Down** to open the current file in the Eye Love Markdown Viewer. The viewer is **read-only**—edit in VS Code, then refresh to see changes:

1. **Ctrl+M Down** → File opens in viewer
2. **Edit in VS Code** (your text editor)
3. **Ctrl+R** (or click Refresh) → See your changes
4. **Optional:** Click **Watch** for auto-refresh as you save

## Prerequisites

- Windows with PowerShell 5.1+ (included with Windows 10+)
- VS Code

## Setup: One-Time Configuration

### Step 1: Copy the Task

The task is defined in `.vscode/tasks.json` in this repo. To use it:

1. Open VS Code
2. Press **Ctrl+Shift+P** → **Tasks: Open User Tasks** (or **Tasks: Configure Task** if prompted)
3. Copy the entire `tasks.json` from this project into your user-level file (or just the `tasks` array entry)

**OR** if you only want to use it in this project:

1. Copy the `.vscode/` folder from this project into your workspace root
2. No further configuration needed for this folder

### Step 2: Bind the Keyboard Shortcut

1. Press **Ctrl+K Ctrl+S** to open Keyboard Shortcuts
2. Click the file icon in the top right (or use **Ctrl+Shift+P → Preferences: Open Keyboard Shortcuts (JSON)**)
3. Add this to your `keybindings.json`:

```json
{ "key": "ctrl+m down", "command": "workbench.action.tasks.runTask", 
  "args": "Open in MD Viewer" }
```

**Note:** This is a *chord* — press Ctrl+M, release both keys, then press Down. This is necessary because only Ctrl/Shift/Alt can combine with another key in a single press.

### Step 3: Test It

1. Open any `.md` file in VS Code
2. Press **Ctrl+M** then **Down**
3. The viewer opens in your default browser with that file loaded

### Alternative: Without the Task

If you prefer not to use the PowerShell task:
- **Open the viewer** (`md_to_html_viewer.html`) in your browser
- **Drag your markdown file** onto the viewer
- **Edit in VS Code**, then click **Refresh** (Ctrl+R) to see changes

## How It Works

The PowerShell script (`open-in-viewer.ps1`):

1. Finds the viewer HTML file (in either `distro/` or `md_to_html_viewer/distro/`)
2. Reads your markdown file
3. Embeds the content directly in the HTML (bypassing `file://` URL restrictions)
4. Copies vendor files (Mermaid) to the temp folder
5. Opens the temp HTML in your default browser

The bootstrap data is embedded *inline*, not in a separate `.js` file, so it works even on `file://` URLs where cross-file script loading is blocked by browser security.

## Using It

1. Open a markdown file in VS Code
2. Press **Ctrl+M** then **Down** 
3. Viewer opens in your browser with the file displayed
4. **A popup explains the workflow** — dismiss it or follow along
5. Edit the file in VS Code as normal
6. Click **Refresh** (Ctrl+R) in the viewer to see your changes
7. **Optional:** Click **Watch** to enable auto-refresh (it'll ask you to pick the file once)

## Using From Other Folders

To use this from a different project or folder:

1. Copy `.vscode/tasks.json` and `.vscode/open-in-viewer.ps1` to your project's `.vscode/` folder
2. Make sure `md_to_html_viewer.html` is accessible from your project root:
   - Either at `./distro/md_to_html_viewer.html`
   - Or at `../md_to_html_viewer/distro/md_to_html_viewer.html` (if the viewer is a sibling folder)
3. Add the keyboard shortcut to your `keybindings.json` if you haven't already
4. Now **Ctrl+M then Down** works in this folder too

## Troubleshooting

**Task doesn't run:**
- Make sure PowerShell 5.1+ is available (already included with Windows 10+)
- Check VS Code's Terminal panel for error messages
- Verify the `.vscode/open-in-viewer.ps1` file exists

**Viewer opens but file is empty:**
- Check that your markdown file is saved (unsaved files cannot be read)
- Try drag-and-drop to test if the viewer works in general

**Watch/auto-refresh doesn't work:**
- The viewer needs to re-read the file, which requires file permission
- Click **Enable live reload** (if shown) or **Watch**, then select the file in the picker
- Once selected, auto-refresh will work for future changes

## Keyboard Shortcuts (From VS Code)

| Key | Action |
|-----|--------|
| `Ctrl+M Down` | Open current file in viewer |
| `Ctrl+R` | Refresh (reload file from disk) |

For editing, drag-and-drop the file instead—then you get `Ctrl+E` (edit section) and `Ctrl+S` (save).

See [HOW_TO.md](HOW_TO.md) for all keyboard shortcuts.

## Technical Details

### Why Embed Bootstrap Data?

Browsers block loading external scripts from `file://` URLs for security reasons. By embedding the bootstrap data directly in the HTML:
- ✓ Works on `file://` URLs
- ✓ No cross-origin issues
- ✓ All data is self-contained in the temp file
- ✓ Works even on locked-down systems

### Security

The script:
- Only reads the file you specify
- Only writes to the Windows temp directory
- Runs inline PowerShell (no downloaded executable)
- Uses UTF-8 safe string escaping

The viewer itself:
- Runs entirely in your browser
- Never sends data to any server
- Only requests Mermaid (if you use diagrams) from unpkg.com
- Everything else is local

## Need Help?

- Check [HOW_TO.md](HOW_TO.md) for general viewer usage
- See [README.md](distro/README.md) for features and capabilities
- If the PowerShell script fails, check your terminal for error messages
