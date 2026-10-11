# VS Code Integration Setup

Open any markdown file in VS Code as a live preview in the viewer with one keystroke.

## What It Does

Press **Ctrl+M then Down** to open the current file in the Northern Lights MD Viewer.

1. **Ctrl+M Down** → the file opens in the viewer
2. Click **📁 Connect folder** and pick your project folder (once per opened page)
3. Now either:
   - **Edit in VS Code** and turn on **Watch** — the viewer follows every save, or
   - **Edit in the viewer** (✎ Edit / Ctrl+E) — each edit saves straight back to the file

The viewer can't save or watch until step 2: the browser never tells a page where a file
lives, so it needs you to point it at the folder. Without connecting, Ctrl+S in the viewer
opens Save As with the file's path already copied for you to paste.

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
- **Open the viewer** (`northern-lights.html`) in your browser
- **Drag your markdown file** onto the viewer
- Edit in VS Code with **Watch** on, or edit right in the viewer — a dropped file is linked
  to disk already, no folder needed

## How It Works

The PowerShell script (`open-in-viewer.ps1`):

1. Finds the viewer HTML file (in either `distro/` or `northern-lights/distro/`)
2. Reads your markdown file
3. Embeds the content directly in the HTML (bypassing `file://` URL restrictions)
4. Copies vendor files (Mermaid) to the temp folder
5. Opens the temp HTML in your default browser

The bootstrap data is embedded *inline*, not in a separate `.js` file, so it works even on `file://` URLs where cross-file script loading is blocked by browser security.

## Using It

1. Open a markdown file in VS Code
2. Press **Ctrl+M** then **Down** 
3. Viewer opens in your browser with the file displayed
4. Click **📁 Connect folder** and pick the project folder
5. Edit in VS Code with **Watch** on — or edit in the viewer, which saves to the same file

## Using From Other Folders

To use this from a different project or folder:

1. Copy `.vscode/tasks.json` and `.vscode/open-in-viewer.ps1` to your project's `.vscode/` folder
2. Make sure `northern-lights.html` is accessible from your project root:
   - Either at `./distro/northern-lights.html`
   - Or at `../northern-lights/distro/northern-lights.html` (if the viewer is a sibling folder)
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

**Watch / saving doesn't work:**
- The viewer needs a live link to the file: click **📁 Connect folder** and pick the folder
  the file is in (or a folder above it)
- The link lasts until the page is refreshed or closed — Ctrl+M Down opens a new page, so
  connect once per opened page
- Chromium only (Chrome, Edge)

## Keyboard Shortcuts (From VS Code)

| Key | Action |
|-----|--------|
| `Ctrl+M Down` | Open current file in viewer |
| `Ctrl+R` | Refresh (reload file from disk) |
| `Ctrl+E` | Edit mode — click a block to edit it in place |
| `Ctrl+S` | Save now |

See the [viewer README](distro/README.md#keyboard) for every shortcut.

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
- Makes no network requests of its own — Mermaid is bundled in `vendor/`
  (images your Markdown links to on the web are fetched like any web page's)

## Need Help?

- See the [viewer README](distro/README.md) for features, usage and shortcuts
- If the PowerShell script fails, check your terminal for error messages
