# VS Code Integration: Bootstrap Data Embedding

## Problem Solved

The VS Code welcome popup was not appearing when opening files from VS Code because the bootstrap script (`md-bootstrap.js`) failed to load due to browser security restrictions on `file://` origins.

**Browser Error:** "Unsafe attempt to load URL file:///C:/path/to/md-bootstrap.js from frame with URL file://..."

**Root Cause:** Browsers block loading external scripts from `file://` URLs for security reasons (no cross-origin script loading on file:// origins).

## Solution Implemented

Instead of loading bootstrap data from an external file, the data is now **embedded directly in the HTML** as an inline script.

### How It Works

1. **VS Code Task** (`.vscode/tasks.json`):
   - Calls PowerShell script `open-in-viewer.ps1`
   - Passes the markdown file path and workspace folder

2. **PowerShell Script** (`open-in-viewer.ps1`):
   - Reads the markdown file content
   - Finds the viewer HTML (`distro/northern-lights.html`)
   - Copies vendor files (Mermaid) to temp directory
   - Manually builds a JSON object with: `{name, path, text, autoConnect}`
   - Escapes JSON special characters safely
   - Embeds the JSON in a `<script>` tag before the closing `</body>`
   - Writes the modified HTML to a temp file
   - Opens the temp HTML in the default browser

3. **Viewer HTML** (`northern-lights.html`):
   - Boot function checks for `window.__MD_BOOTSTRAP__` (set by the embedded script)
   - If present, loads the file content and path immediately
   - Shows the VS Code welcome popup (since `state.path` is set)

### Example Output

The embedded script looks like:

```html
<script>
window.__MD_BOOTSTRAP__ = {
  "name": "document.md",
  "path": "c:\\Users\\Scott\\Documents\\document.md",
  "text": "# Document Content\n\nMarkdown goes here...",
  "autoConnect": false
}
</script>
</body>
</html>
```

## Why Manual JSON Instead of `ConvertTo-Json`?

PowerShell 5.1's `ConvertTo-Json` has performance issues with large strings (hangs for 30+ seconds on 6KB+ markdown files). 

The manual approach:
- ✓ Runs instantly
- ✓ Safely escapes all special characters (backslashes, quotes, newlines, tabs)
- ✓ Works reliably with files of any size
- ✓ No external dependencies

Escaping order matters:
1. Backslashes first (`\\` → `\\\\`)
2. Quotes second (`"` → `\"`)
3. Newlines last (`\n` → literal newline in JSON)

## Files Changed

1. **`.vscode/open-in-viewer.ps1`** (new)
   - Generic PowerShell script that anyone can use
   - Works from any folder (probes for viewer HTML)
   - Handles vendor files and bootstrap embedding

2. **`.vscode/tasks.json`** (updated)
   - Now calls the PowerShell script instead of inline command
   - Added explanatory comments

3. **`distro/northern-lights.html`** (minimal change)
   - Replaced `<script src="md-bootstrap.js">` with a comment
   - No functional change to viewer itself (already supported embedded bootstrap)

4. **`VS_CODE_SETUP.md`** (new)
   - Setup instructions for users
   - How to bind to keyboard shortcuts
   - How to use in other projects

## Testing

Confirmed working:
- ✓ Bootstrap JSON created correctly
- ✓ JSON embedded in HTML properly
- ✓ Works with large markdown files (tested with 6KB+)
- ✓ Special characters (quotes, backslashes, tabs) handled correctly
- ✓ Vendor files (Mermaid) copied to temp directory

## Security Notes

- Script only reads the file you specify
- Script only writes to the Windows temp directory
- Runs inline PowerShell (no downloaded executable)
- No sensitive data is sent anywhere
- All escaping is done safely in PowerShell before embedding

## Next Steps for Users

1. Copy `.vscode/` folder (or tasks.json + open-in-viewer.ps1) to your project
2. Add keyboard shortcut binding to your VS Code keybindings.json
3. Press Ctrl+M then Down to open any markdown file in the viewer
4. Edit sections with Ctrl+E, save with Ctrl+S

For detailed instructions, see `VS_CODE_SETUP.md`.
