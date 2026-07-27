# TODO

Last swept 2026-07-27. Working tree clean, suite green (101 checks, ~3s).

Everything from the 2026-07-26 list is done:

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

### 1. The file picker is still unverified in a headed browser

`showOpenFilePicker()` on `file://` can only be tested headless, where there is no
UI to show a dialog, so it aborts instantly and proves nothing. **Drag & drop is
verified** and is now the primary way live reload gets armed, so this only affects
the `Enable live reload` button used after a paste or a page refresh.

To check: open the viewer, paste some Markdown, click **Enable live reload**. A
file dialog should appear. If it doesn't, the toast names the actual error.

### 2. Toolbar crowding, if more controls arrive

Four buttons at rest, five once a file is open. That is comfortable now, but the
next addition should go inside an existing popover rather than onto the bar.

### 3. Possible future work — none of it requested

- Mermaid is 3.5 MB of the 3.6 MB download. Loading it lazily on first diagram
  would make diagram-free documents open faster, at the cost of a code path that
  can fail.
- The syntax highlighter covers JS/TS, Python, HTML/XML, CSS, JSON, Bash, SQL,
  YAML, TOML/INI and diffs. Anything else renders as plain text.
- No print preview for the `Export` output; it is only exercised by eye.
