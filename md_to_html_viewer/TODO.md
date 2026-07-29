# TODO

Last swept 2026-07-28. Suite green (193 checks, six passes).

Everything including section editing is done:

- ~~Stale `palette.mjs` reference in the shipped CSS~~ — the generator is now
  [tools/Build-Palettes.ps1](tools/Build-Palettes.ps1) and the CSS points at it.
  Duplicate comment removed, and the header no longer claims the dark families
  are "blue | grey".
- ~~Rebuild the test suite in PowerShell~~ — [tools/Test-Viewer.ps1](tools/Test-Viewer.ps1).
- ~~Auto / system theme~~ — added back as a **Match system** checkbox.
- ~~`blue-3` near-black~~ — the whole blue ramp was re-spaced to mirror slate
  (L\* 19.5 → 14.0 → 8.9 against slate's 20.6 → 15.0 → 9.7).
- ~~No subfolder notes file~~ — written, and kept local rather than committed;
  it now carries the constraints and gotchas that used to live in this file.

---

## Open

### 1. Two things need a headed browser, for the same reason

Neither can be tested headlessly: there is no UI to show a dialog, so the call
aborts instantly and proves nothing.

- **The file picker.** `showOpenFilePicker()` on `file://`. Drag & drop *is*
  verified and is the primary way live reload gets armed, so this only affects
  the `Enable live reload` button used after a paste or a page refresh.
  To check: paste some Markdown, click **Enable live reload**. A file dialog
  should appear; if it doesn't, the toast names the actual error.
- **~~The write-permission prompt~~** — **(verified and working)**. Raised on
  the first `Ctrl+S` from the editor, not at open time. This is correct and
  unavoidable on `file://` origins when asking to write a file. Measured in
  Edge 150; see [tools/Probe-FileWrite.html](tools/Probe-FileWrite.html) for
  the measurements. The suite covers everything around it: permission is raised
  once per handle, granted access means no further dialogs, and `saveAs()` is
  the fallback for pasted text or refusal.
  ✓ Verified: drop a `.md`, press `Ctrl+E`, edit, `Ctrl+S`. First save shows
  the permission bar once; second and later saves are silent and write to disk
  with no dialogs.

### 1a. VS Code task file editing doesn't preserve file location

**Problem:** Opening a file from VS Code using the task (Ctrl+M then Down) and
editing it via the section editor tries to save to the Documents folder instead
of the original file location.

**Root cause:** The File System Access API requires a file handle to write; the
VS Code task can only pass a file path via the bootstrap. There is no API to
convert a path string to a handle on `file://` origins. Drag & drop works
because the OS provides a handle; the task cannot.

**What was tried:**
- Auto-opening a file picker on page load (requires user activation; page load
  has none)
- Waiting for first user interaction to trigger picker (activation issues; picker
  still fails)
- Requiring explicit "Open file" button at save time (button appears but picker
  doesn't establish handle correctly)

**Current state:** Unsolved. The task passes `autoConnect: true` in the
bootstrap, but the file picker flow is unreliable. Needs investigation into why
the picker isn't working or why selected files aren't establishing write access.

**Workaround:** Use drag & drop instead of the VS Code task. Works perfectly
because the OS provides the file handle.

### 1b. Which drag sources supply a handle — resolved, mostly

A drag from Windows File Explorer *does* supply one, and it upgrades to
read-write cleanly (`tools/Probe-FileWrite.html`, test 3, Edge 150). The earlier
"not connected to a file" report was this bug, not a missing handle.

Still unmeasured: dragging out of the VS Code explorer, or off a browser
downloads bar. Those can hand over the bytes without an OS path, and would then
have no handle to write back through. The toolbar shows which you got —
`⟳ Enable live reload` means no handle, `↻` and `Watch` mean there is one — and
the editor's status line now says so in words when it opens.

### 2. Toolbar crowding, if more controls arrive

Four buttons at rest, five once a file is open. That is comfortable now, and the
section editor kept it that way — `Edit this section…` went into the **More**
menu rather than onto the bar. The next addition should do the same.

### 3. Possible future work — none of it requested

- Mermaid is 3.5 MB of the 3.6 MB download. Loading it lazily on first diagram
  would make diagram-free documents open faster, at the cost of a code path that
  can fail.
- The syntax highlighter covers JS/TS, Python, HTML/XML, CSS, JSON, Bash, SQL,
  YAML, TOML/INI and diffs. Anything else renders as plain text.
- No print preview for the `Export` output; it is only exercised by eye.
- The section editor is a plain textarea: no Markdown highlighting, no preview
  as you type. `Ctrl+S` applies the edit to the document *and* writes it, which
  is the whole model — anything more starts needing a dirty-vs-disk distinction
  the current one doesn't have.
- A document read from a folder has a handle per file, so section editing works
  across a whole dropped project. Untested beyond the single-file case.
