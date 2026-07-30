# VS Code Integration Setup

This guide shows how to set up the Eye Love Markdown Viewer to open directly from VS Code with editing support.

## What It Does

Press **Ctrl+M then Down** (a keyboard chord) to open the current markdown file in the viewer. The file is loaded with full editing capability, so you can:
- Edit sections with Ctrl+E
- Save edits directly back to the file with Ctrl+S
- Watch the file for live reload

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

## How It Works

The PowerShell script (`open-in-viewer.ps1`):

1. Finds the viewer HTML file (in either `distro/` or `md_to_html_viewer/distro/`)
2. Reads your markdown file
3. Embeds the content directly in the HTML (bypassing `file://` URL restrictions)
4. Copies vendor files (Mermaid) to the temp folder
5. Opens the temp HTML in your default browser

The bootstrap data is embedded *inline*, not in a separate `.js` file, so it works even on `file://` URLs where cross-file script loading is blocked by browser security.

## Using It

When you open a file from VS Code:

1. The file loads with its path and content
2. Edit sections with **Ctrl+E**
3. Press **Ctrl+S** to save
4. If you haven't saved this file before, a picker opens to confirm the location
5. Future saves go straight to disk

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
- Make sure PowerShell 5.1+ is available (check `pwsh --version` in terminal)
- Check VS Code's Terminal panel for error messages
- Verify the `.vscode/open-in-viewer.ps1` file exists

**Viewer opens but file is empty:**
- Check that your markdown file is saved (unsaved files cannot be read by the script)
- Try opening the file directly with drag-and-drop instead to test

**Editing doesn't work:**
- Make sure you pick a file location when first saving (the picker appears once)
- After picking, future saves should work without the picker
- Check the editor status line — it tells you what Ctrl+S will do

**Live reload isn't working after opening from VS Code:**
- Click **Enable live reload** in the toolbar
- Select the file again in the picker
- Now Refresh (Ctrl+R) and Watch will work

## Keyboard Reference

| Key | Action |
|-----|--------|
| `Ctrl+M Down` | Open current file in viewer |
| `Ctrl+E` | Edit the current section |
| `Ctrl+S` | Save the edit |
| `Ctrl+R` | Reload the file from disk |
| `B` | Toggle bold all text |
| `D` | Toggle dark mode |

See [HOW_TO.md](HOW_TO.md) for the complete keyboard reference.

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
