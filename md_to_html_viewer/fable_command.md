# Fresh briefing for Fable: VS Code task file editing issue

## The problem

When a user opens a markdown file from VS Code using the built-in task (Ctrl+M then Down), they can edit sections with the section editor, but **saves go to the wrong folder** (Documents/OneDrive) instead of replacing the original file.

The same flow works perfectly with drag & drop — edit a section, Ctrl+S saves straight to the original file with no dialogs.

## Why drag & drop works

When you drag a file from Windows File Explorer onto the viewer, the browser gets a real **file handle** from the OS. This handle has write permission. When editing and saving:
1. Click pencil or Ctrl+E → section editor opens
2. Edit the markdown
3. Ctrl+S → `writeFile()` uses the handle and writes directly to the file
4. File is replaced, done

## Why the VS Code task doesn't work

The VS Code task (in `.vscode/tasks.json`) does this:
1. Reads the file into memory
2. Creates a JSON bootstrap payload with: `{name, path, text, autoConnect}`
3. Copies the viewer HTML to a **temp directory** 
4. Opens the temp HTML in Edge
5. The temp HTML loads the bootstrap and renders the file

**The problem:** The browser never gets a file **handle** — only a **path string**. The File System Access API (which is what lets you write files from a webpage) requires a handle. You can't convert a path string to a handle on `file://` origins.

When saving, the code checks `if (!state.handle)` and falls back to `showSaveFilePicker()`, which opens a generic save dialog that defaults to the user's Documents folder.

## What was tried

### 1. Auto-open file picker on page load
**Idea:** When the page loads, automatically open `showOpenFilePicker()` to let the user select the file, establishing a handle.

**Result:** Failed. The File System Access API requires "user activation" (a click or key press), but page load doesn't provide that. The picker throws an error silently.

### 2. Wait for first user interaction, then open picker
**Idea:** Set up event listeners for click/keydown. When the user clicks anywhere on the page, trigger the file picker with their activation.

**Result:** Toast says "Click anywhere to select your file", but the picker still doesn't work reliably. Unknown why — might be the activation is consumed by the event listener itself, or the picker is opening in the wrong window.

### 3. Show "Open file" button in editor status
**Idea:** When editing a bootstrap file (no handle), show a button the user can click to open the picker manually.

**Result:** Same issue — button appears, user can click it, but the picker doesn't establish a working handle. Saves still go to Documents.

### 4. Require file selection at save time
**Idea:** When the user tries to save (Ctrl+S) without a handle, block the save and show an "Open file" button. When they click it, open the picker, then immediately retry the save.

**Result:** Still doesn't work. The picker runs but doesn't establish a usable handle.

## Step back: what's really happening?

The core issue is that **the file picker is opening but not actually giving us write access to the file**.

When the picker succeeds:
```javascript
const [handle] = await window.showOpenFilePicker({...});
state.handle = handle;
state.dirAnchor = handle;
```

The code sets the handle. But then when `writeFile()` tries to use it:
```javascript
if (typeof state.handle.queryPermission === "function") {
  let p = await state.handle.queryPermission({ mode: "readwrite" });
```

Something goes wrong. Either:
- `queryPermission` returns "denied" 
- Or `requestPermission` throws a SecurityError
- Or the handle is read-only
- Or the user is just not selecting the right file

**Key observation:** The Probe-FileWrite tests (`tools/Probe-FileWrite.html`) show that `showOpenFilePicker` + `requestPermission` + write works in Edge 150 on `file://` origins. So it *should* work. But it's not working from the viewer's context.

## Questions for investigation

1. **Is the picker actually opening?** Add logging to see if `showOpenFilePicker()` is being called and what it returns.

2. **What error is happening?** The catch blocks say "Could not locate file" but don't show the actual error. Need better error reporting.

3. **Is the handle actually being set?** After selecting a file in the picker, verify `state.handle` is truthy and has the expected properties.

4. **Why does drag & drop work but picker doesn't?** Compare the handle objects. Are they different types? Different permissions?

5. **Is this an iframe or window-origin issue?** The viewer runs in a temp file on `file://`. The picker is called from that same origin. Should be fine, but worth checking.

6. **Could this be browser version specific?** We tested on Edge 150. User might be on a different version.

## Possible solutions to explore

1. **Debug the picker:** Add `console.log()` at every step of the picker flow. Understand where it's failing.

2. **Test locally with Probe-FileWrite:** Does the user's browser pass the Probe-FileWrite tests? Specifically test 2 (open picker + upgrade) and test 5 (permission then window.open).

3. **Different approach:** Instead of trying to get the picker to work, could we:
   - Have the task do something different (not just pass a path)?
   - Store the path in localStorage, then on edit prompt for it?
   - Use a completely different mechanism?

4. **Fallback:** Accept that the VS Code task will never work perfectly, document the drag & drop workaround as the primary method, and make the task throw a clear error saying "Use drag & drop instead."

## Current commit state

Latest commit: `399bf13` — "Document VS Code task file editing issue for investigation"

Branch: `document-library`

The section editor is complete and working. Section editing via drag & drop works flawlessly. The *only* unsolved issue is the VS Code task file flow.

## Notes for Fable

- This is a browser security / File System Access API constraint, not a logic bug in the viewer
- Probe-FileWrite.html proves the APIs work in Edge 150 — we're not hitting a fundamental browser limitation
- Something about how the picker is being called from the viewer's context is failing, but we don't know what
- The error messages aren't clear enough to diagnose the real problem
- Consider starting with better logging/debugging rather than trying more workarounds
