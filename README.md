# vs_code_projects_public

Public projects, one folder each. Each is self-contained and carries its own
README and license.

## [md_to_html_viewer](md_to_html_viewer/)

A single HTML file that renders Markdown in your browser. No install, no web
server, no build step, no toolchain. Double-click it and drop a `.md` on it.

**Rendering**

- **GitHub-Flavored Markdown** — tables, task lists, strikethrough, autolinks and
  fenced code, plus footnotes, definition lists and YAML front matter.
- **Mermaid diagrams** — ` ```mermaid ` fences render as real diagrams, offline.
- **Syntax highlighting** — JS/TS, Python, HTML/XML, CSS, JSON, Bash, SQL, YAML,
  TOML/INI and diffs.
- **Contents sidebar** with scroll-spy, and a copy button on every code block.

**Reading**

- **Twelve palettes** — light or dark, four colour families, three depths. Every
  one is contrast-validated rather than eyeballed: body text holds 12:1 or better
  in all twelve. **Match system** hands the choice to the OS.
- **Text size** from 65% to 260%, scaling the document without magnifying the
  interface, so you get more words on screen rather than bigger furniture.
- **Bold all** for glare and low-contrast screens, and dark mode dims images so
  white-background screenshots stop glaring.

**Getting documents in and out**

- **Four input routes** — drag & drop, file picker, paste, or a VS Code task on a
  keyboard chord. Drop a `.md` together with its images and relative links resolve.
- **Live reload** — re-read the file from disk on a click, or **Watch** it and let
  the page follow your editor. Chromium browsers; everything else degrades quietly.
- **Export** to a standalone HTML file, or `Ctrl+P` for a clean PDF.

**Staying out of your way**

- **Raw HTML is escaped by default.** Opting in still filters everything through a
  tag and attribute allow-list, so scripts and event handlers are stripped.
- **Nothing in the package is executable** — no installer, no script, no launcher.
  Mail gateways don't strip it and SmartScreen has nothing to warn about, which
  matters because the machines most likely to need this are the most locked down.

[Full documentation →](md_to_html_viewer/distro/README.md) ·
[Download the package](md_to_html_viewer/md_to_html_viewer.zip)
