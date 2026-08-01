# Photon

*HTML as a Solution — real applications as a single local HTML file. No installer, no
Electron, no Node, no build step, no server.*

You double-click the file. It opens in your browser. You bookmark it to the toolbar and it
behaves like an app — because it is one.

## The thesis

Your browser stopped being a document viewer a long time ago. It has a rendering engine, a
fast JavaScript runtime, storage that persists between visits, and — in Chrome and Edge —
permission to read and write a file once you point it at one. That is everything an
application needs, and it is already installed on the machine.

Software with this feature set normally ships as a 150 MB Electron bundle: an installer, an
auto-updater, and a private copy of Chromium. Nearly all of that weight is the engine. You
already have the engine. This is only the part that would have been wrapped inside it.

Electron carries mass — a whole second browser, bundled and shipped, every time. An app
built this way carries none: no duplicated engine, nothing installed that wasn't already
running. Hence the name.

## What it buys

- **Nothing to install and nothing to approve.** No installer, no script, no launcher —
  nothing in the package is executable. There's nothing for a mail gateway to strip,
  SmartScreen to warn about, or policy to block, and nothing to raise a ticket for. The
  people who most need a given tool are often exactly the people who can't get one
  approved.
- **No build step.** Edit the file, refresh the browser, done. No `node_modules`, no
  toolchain, no lockfile, no dependency that rots.
- **Portable by copy.** Email it, drop it on a USB stick, commit it. It goes with the file.
- **Nothing leaves the machine.** No network calls, so no account, no telemetry, and no
  question about whether the content was confidential.
- **It doesn't rot.** Nothing to update, no API to deprecate. A file that worked in 2025
  opens in 2035.

## Where it's the wrong answer

The trade is real but narrow. A page can't run in the background, reach the filesystem
unprompted, or add itself to a right-click menu.

For tools you *open* — a reader, a task board, a calculator, a log viewer, a converter —
that costs nothing: you hand it a file, it shows you the file. For a file manager, a
daemon, or anything needing multi-user sync or a shared database, this is the wrong
architecture. Know which one you're building before you start.

## Target: Chromium

**Chrome and Edge.** The File System Access API — open a file and keep permission to
re-read and write it — is what makes this architecture *capable* rather than merely
convenient, and it's Chromium-only. Patterns note cheap fallbacks where they exist, but
Chromium is the assumption, not a preference to be relitigated per project.

## The library

**[PATTERNS.md](./PATTERNS.md)** — the working pattern library. ~1,300 lines, 20 sections,
every one extracted from shipped code:

| | |
|---|---|
| **Foundations** | theming with no flash on load, inlining and vendoring, the `file://` contract |
| **Data in / out** | the four input doors, standalone HTML export, print as free PDF, safe file writes |
| **State** | the save/render loop, export/import to survive a cleared cache, the staleness meter |
| **Interface** | toast, clipboard, drag & drop, blob URLs, scroll-spy, content scaling |
| **Robustness** | capability degradation, allow-list sanitizing, the `style.display` gotcha |

### The rule

**A pattern goes in when it works in shipped code.** Not when it seems like it should
work, and not as reasoning about why something works — as the thing that works, with the
gotcha that cost time to find. Anything unverified is marked as such or left out.

That rule is the whole value. A pattern file you have to second-guess is worse than none.

## Reference implementations

Two working apps, deliberately different in scale, to show the patterns carry both:

- **[Cardoo](../cardoo/)** — ~250 lines. Kanban board: drag & drop, card details with
  highlights, four themes, export/import, staleness meter.
- **[Northern Lights MD Viewer](../md_to_html_viewer/)** — ~4,700 lines, 60 features.
  Markdown viewer and editor: full GFM parser, syntax highlighting, Mermaid diagrams,
  twelve contrast-validated palettes, section editing that writes back to disk, live
  reload, folder browsing, standalone HTML and PDF export.

The gap between them is the useful part: same patterns, no build step appearing anywhere in
between.

## Using this

Building a new single-file tool:

1. Read [PATTERNS.md](./PATTERNS.md) first — most of what you need is already solved there.
2. Work through the [checklist](./PATTERNS.md#checklist-ports-to-new-projects).
3. When something new is proven working, **add it back to the library.**
