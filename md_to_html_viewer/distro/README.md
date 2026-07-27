# Markdown Viewer

A single HTML file that renders Markdown in your browser. No install, no web server,
no build step, no toolchain. Download the folder, double-click the HTML file, drop a
`.md` on it.

## Use it

1. Download this folder (GitHub → **Code → Download ZIP**, or `git clone`), or unzip
   the package someone sent you.
2. Double-click `md_to_html_viewer.html`. It opens in your browser.
3. Get a document in by any of:
   - **Drag & drop** a `.md` anywhere on the window. Drop the Markdown *and* its
     images together and relative image links resolve.
   - **Open** button (`Ctrl+O`).
   - **Paste** Markdown text straight onto the page (`Ctrl+V`).


### From VS Code

`.vscode/tasks.json` in this repo defines an **Open in MD Viewer** task that opens
whatever file is in the active editor tab. Bind it in your user `keybindings.json`:

```json
{ "key": "ctrl+m down", "command": "workbench.action.tasks.runTask",
  "args": "Open in MD Viewer" }
```

That is a **chord**: press `Ctrl+M`, release, then `Down`. Only `Ctrl`, `Shift` and
`Alt` can combine with a key in a single stroke, so `m` and `Down` cannot both be
part of one press. It also takes over `Ctrl+M`, which VS Code otherwise uses to
toggle tab focus mode.

The task is workspace-scoped. To use it in any folder — an Obsidian vault, say —
copy the task into your user-level tasks file via **Ctrl+Shift+P → Tasks: Open User
Tasks**.

The task runs a short PowerShell command inline, so nothing executable has to be
installed or trusted. The document arrives without re-read access, so
live reload starts disarmed and each press opens a new tab. If you'd rather stay on
one file and watch it, dragging the file from VS Code's Explorer onto the viewer
window arms live reload automatically and replaces the current document instead.

**Arming live reload quickly.** Clicking **Enable live reload** copies the source
path to your clipboard before opening the dialog, so you can paste it straight into
the File name box (`Ctrl+V`, `Enter`) instead of navigating the tree. The picker
cannot be pointed at a file directly — browsers deliberately forbid preselecting
one — but after the first pick in a session the dialog reopens in the same folder.

> **Keep `vendor/` next to the HTML file.** Mermaid is loaded by relative path, so
> moving the HTML out of this folder on its own breaks diagram rendering. Everything
> else still works.

### How a document gets in

All four routes render identically. They differ in one thing: whether the browser
also hands over permission to **re-read the file**, which is what `↻ Refresh` and
`Watch` need.

```mermaid
flowchart TD
    MD["your .md file"]

    MD --> Drop["Drag and drop"]
    MD --> Open["Open button"]
    MD --> Paste["Paste text"]
    MD --> Cmd["VS Code task"]

    Drop --> Handle["Content + re-read access"]
    Open --> Handle
    Paste --> Plain["Content only"]
    Cmd --> Plain

    Handle --> Live["Refresh and Watch ready"]
    Plain --> Arm["Toolbar offers<br/>Enable live reload"]
    Arm -->|"one click, re-pick the file"| Handle

    Live -.->|"page refresh drops access"| Plain
```

That dotted line is the one surprise: a page refresh always discards re-read
access, because `file://` pages cannot store it. Re-arming is a browser
restriction, not a bug — see below.

## What it does

- **GitHub-Flavored Markdown** — tables, task lists, strikethrough, autolinks, fenced
  code, plus footnotes, definition lists, and YAML front matter.
- **Mermaid diagrams** — ` ```mermaid ` fences render as diagrams, offline.
- **Syntax highlighting** for JS/TS, Python, HTML/XML, CSS, JSON, Bash, SQL, YAML,
  TOML/INI, and diffs.
- **Contents sidebar** with scroll-spy, and per-block copy buttons.
- **Source path** — click the filename in the toolbar for a selectable field and a
  **Copy** button. Opening via the VS Code task shows the full
  path; drag & drop, the file picker and paste can only show the filename, because
  browsers never reveal full paths to a web page.
- **Text size** — `A−` / `A+` scale the document from 65% to 260%. Unlike browser
  zoom this leaves the toolbar and sidebar alone, so you get more words on screen
  rather than a magnified interface. Diagrams and code blocks scale with the text.
- **Bold all** — `B` thickens the body text for glare or low-contrast screens.
  **Bold** stays visibly heavier than its surroundings.
- **Twelve palettes** — pick a **mode** (Light / Dark), a **colour family**, and a
  **depth**. Light offers White and Beige (built on warm ivory neutrals);
  Dark offers Blue and Slate. Depth steps the background darker within the chosen
  family. Family and depth are remembered per mode, so flipping Light ⇄ Dark
  returns you to the look you last chose for it. Tick **Match system** to let the
  OS choose the mode — picking a mode by hand releases it again. Dark mode also
  desaturates and dims images so white-background screenshots stop glaring;
  diagrams re-render in their own dark theme.

  Every palette is contrast-validated rather than eyeballed: body text holds 12:1
  or better in all twelve, and table rules stay visible against every background.
- **Export** to a standalone HTML file, or `Ctrl+P` for a clean PDF. Exports keep
  your chosen text size; printing always reverts to clean 11pt on white.
- **Refresh / Watch** (Chromium browsers) — `↻` re-reads the file from disk in one
  click. **Watch** flips to a pulsing **Live** dot and auto-reloads whenever the file
  changes, so you can edit in your usual editor and just look at the browser.

> **Drag & drop arms live reload automatically** in Chromium browsers — a dropped
> file carries re-read access with it, so `↻` and **Watch** light up immediately.
> Loading by **paste** or reopening a remembered document can't carry that access,
> so the toolbar offers **Enable live reload** instead: one click, re-pick the file,
> and watching starts. The grant can't be saved across a page refresh (`file://`
> pages are blocked from IndexedDB), so re-arming after a reload is a browser
> restriction, not a bug.

Raw HTML in Markdown is escaped by default. The **HTML** button opts in, and even then
everything passes through a tag/attribute allow-list, so scripts and event handlers are
stripped.

## Keyboard

| Key | Does |
|:--|:--|
| `+` / `-` | Bigger / smaller text |
| `0` | Reset text size to 100% |
| `B` | Toggle bold-all |
| `D` | Toggle light / dark mode |
| `Ctrl+O` | Open a file |
| `Ctrl+R` | Re-read the file from disk |
| `Ctrl+F` | Browser's own find — deliberately not overridden |
| `Ctrl` `+` / `-` | Browser zoom, which scales the whole interface |

Text-size keys are intentionally unmodified so `Ctrl` `+`/`-` stays with browser zoom.
All preferences persist across sessions.

## Browser support

Any current browser. Drag & drop, paste, and the file picker work everywhere. The
**Reload** and **Watch** buttons use the File System Access API and appear only in
Chromium browsers (Chrome, Edge); elsewhere they're hidden and everything else works.

## Updating Mermaid

No package manager. Download the single dist file straight into `vendor/`, replacing
what's there:

```
https://unpkg.com/mermaid@11/dist/mermaid.min.js
```

## Layout

```
md_to_html_viewer.html    the whole viewer — parser, highlighter, UI
vendor/mermaid.min.js     vendored Mermaid (MIT)
README.md  LICENSE
```

That is the entire package. **Nothing in it is executable** — no installer, no
script, no launcher. Mail gateways don't strip it and SmartScreen has nothing to
warn about, which matters because the machines most likely to need this tool are
the ones most locked down.

Mermaid is MIT licensed; see the header of `vendor/mermaid.min.js`.
