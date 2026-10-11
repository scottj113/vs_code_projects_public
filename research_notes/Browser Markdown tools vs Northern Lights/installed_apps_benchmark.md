# Installed (desktop) Markdown editors vs Northern Lights: reference benchmark

Researched 2026-10-10. Baseline: Northern Lights MD Viewer, a single self-contained HTML file opened from file:// in Chrome/Edge. It needs no install, no server and no network. Every app below **requires installation** of a native or Electron executable, unless noted otherwise.

Labels used in these notes:
- "(unverified)" means the point comes from general knowledge and I did not confirm it against a source this session. Check it before quoting it.
- Version numbers and dates are as of mid-2026 sources and may already be out of date.

## 1. Per-app capabilities (editing model, diagrams/math, extensibility, search/links, export, theming, large files, fidelity, git)

### Takeaway
On authoring breadth, the installed apps beat Northern Lights. The main gaps are true inline WYSIWYG (Typora, MarkText, Obsidian Live Preview), LaTeX math (all of them), Pandoc/DOCX export (Typora, Zettlr, MPE) and plugins plus backlinks/graph (Obsidian). VS Code is the closest match to Northern Lights' source-first, git-friendly model. Its built-in preview now renders math and Mermaid too. Rich-text editors (Typora, Joplin Rich Text) can rewrite Markdown that you never touched. Northern Lights' line-splicing edits avoid that by design.

### Cited Findings

**Typora (paid, closed source)**
- Editing model: "live preview" with no separate preview pane or mode switcher (true inline WYSIWYG). It also has a source mode. — [typora.io](https://typora.io/)
- Rendering features:
  - Math via MathJax (mhchem, AMSmath) with optional auto-numbered equations.
  - Diagrams: Mermaid, flowchart.js and sequence diagrams.
  - Outline panel and `[TOC]`.
  - Focus mode, typewriter mode and word count.
  - Themes fully customisable with CSS, plus a theme gallery.
  — [typora.io](https://typora.io/)
- Images: drag-and-drop with relative paths, and resizing via `<img>`. Tables can be resized by mouse drag. — [typora.io](https://typora.io/)
- Export: PDF with bookmarks, DOCX, OpenOffice, LaTeX, MediaWiki and EPUB. — [typora.io](https://typora.io/)
- Fidelity:
  - Typora has no built-in Markdown reformat or lint. Its docs suggest a custom export command that runs Prettier. — [Typora support: Convert & Reformat Markdown](https://support.typora.io/Markdown-Export)
  - Long-running issue #750: Typora silently rewrote quotes in code-fence info strings to `&#39;`/`&quot;`, even in files that were opened and closed without edits. This broke R Markdown. It was fixed in 2017, came back in 2019–2020, and was closed as fixed in May 2020. Nobody verified the 2020 fix. — [typora-issues #750](https://github.com/typora/typora-issues/issues/750)
- Latest version: 1.14.9. — [typora.io](https://typora.io/)

**Obsidian (free, closed source, Electron)**
- Editing model has three options:
  - Reading view.
  - Live Preview (the default): renders in place and shows raw syntax at the cursor.
  - Source mode: every line exactly as written.
  — [Obsidian Help: Views and editing mode](https://obsidian.md/help/edit-and-read)
- Extensibility: an official directory of community plugins and themes. Every version is scanned for vulnerabilities and malware and shows a safety scorecard. Only popular, featured or flagged items get manual review. "Enabled plugins may generate network traffic outside Obsidian and GitHub's control." — [Obsidian Help: Security considerations for teams](https://obsidian.md/help/teams/security)
- Large files:
  - A 40k-line file caused multi-second freezes with a linked preview open.
  - A long block without blank-line breaks gets re-rendered whole.
  - Plugins and CSS snippets make it worse.
  — [Obsidian forum: UI performance issues with large files](https://forum.obsidian.md/t/ui-performance-issues-with-large-files/13782/1)
- An open feature request reports slowdowns, probably from indexing, on files over 1 MB. — [Obsidian forum: very large markdown files](https://forum.obsidian.md/t/improve-support-for-very-large-markdown-files-greater-than-1-mb/114238)
- v1.7.6 (Nov 2024) fixed a parser memory bug that could crash Obsidian on large files. — [Obsidian changelog 1.7.6](https://obsidian.md/changelog/2024-11-12-desktop-v1.7.6/)

**MarkText (free, MIT (unverified), Electron)**
- Typora-like real-time preview, broad export and theming, and an Electron footprint. — [Star History, May 2026](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026)
- Maintenance:
  - The project was dormant after v0.17.1 (March 2022).
  - v0.19.0 shipped 28 May 2026, the "first release in over four years". — [Star History, May 2026](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026)
  - The Tkaixiang community fork was merged back after the original developer returned (13 May 2026). — [Tkaixiang/marktext](https://github.com/Tkaixiang/marktext)
  - The jacobwhall fork was archived in Aug 2025. — [jacobwhall/marktext](https://github.com/jacobwhall/marktext)
  - Treat MarkText's revived maintenance as young and unproven.

**Zettlr (free, open source, Electron)**
- Editing model: the user chooses how much WYSIWYG to see, from raw code to rich text. Custom CSS is supported. — [zettlr.com](https://www.zettlr.com/)
- LaTeX math and Mermaid render in the editor. — [zettlr.com](https://www.zettlr.com/)
- Pandoc-based export profiles: one-click papers from templates, Beamer, reveal.js and PowerPoint. — [zettlr.com](https://www.zettlr.com/)
- Citations: Zotero, JabRef and Juris-M integration, with 9,000+ citation styles. — [zettlr.com](https://www.zettlr.com/)
- Export to PDF and Word, plus Zettelkasten-style linked notes. v4.5.0 shipped 8 May 2026. — [Star History, May 2026](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026)

**VS Code built-in Markdown (free, MIT core (unverified), Electron)**
- Source + side-by-side preview, with two-way scroll sync. — [VS Code docs: Markdown](https://code.visualstudio.com/docs/languages/markdown)
- Built in:
  - KaTeX math (`$`/`$$`).
  - Mermaid fenced blocks, with pan and zoom.
  - Outline view, "Go to Header in Workspace", and header completions across the workspace.
  - Local link validation (off by default).
  - Image paste/drag that copies files into the workspace.
  - Path completion.
  - F2 header rename that updates links; optional link updates on file move.
  — [VS Code docs: Markdown](https://code.visualstudio.com/docs/languages/markdown)
- Spellcheck is not built in. It needs a Marketplace extension. The "Doc Writer" profile bundles a spell checker and a Markdown linter. — [VS Code docs: Markdown](https://code.visualstudio.com/docs/languages/markdown)
- Markdown Preview Enhanced (extension):
  - Math, Mermaid and PlantUML.
  - PDF export via Puppeteer or Prince, Pandoc formats and ebook export.
  - Code-chunk execution, presentation mode, TOC and file import.
  - Some export features need Chrome and/or Pandoc installed.
  — [MPE docs](https://shd101wyy.github.io/markdown-preview-enhanced/)

**2025–2026 notables**
- **Logseq:**
  - The DB version ("Logseq", 2.0 beta, reportedly 13 July 2026) moves from Markdown files to SQLite as the source of truth.
  - The file-based app becomes "Logseq OG" and is in maintenance mode.
  — [kompozy review](https://kompozy.io/reviews/logseq-2-0); [Logseq DB discussion](https://discuss.logseq.com/t/whats-new-with-logseq-db-may-16th-2026/35020)
  - "Markdown Mirror" writes a read-only Markdown copy to disk. Two-way sync is still on a feature branch. — [Logseq DB changelog](https://discuss.logseq.com/t/logseq-db-changelog/30013/37)
  - **No longer a plain-Markdown-file editor.**
- **Joplin:**
  - Notes are stored as Markdown, but the Rich Text (WYSIWYG) editor rewrites them:
    - Reference links become inline links.
    - An empty header row is added to tables.
    - HTML may be lost.
    - Most Markdown plugins are unsupported.
    — [Joplin Help: Rich Text editor](https://joplinapp.org/help/apps/rich_text_editor)
  - The Markdown editor has been CodeMirror 6 since v2.13 (late 2023). — [AlternativeTo](https://alternativeto.net/news/2023/12/joplin-2-13-released-with-enhanced-text-editor-interoperability-and-new-markdown-editor)
  - Version 3.6.21 (June 2026, per a third-party download site). — [journaldugeek](https://www.journaldugeek.com/telecharger/bureautique/editeur_de_texte/joplin.html)
  - Joplin is a note database with Markdown inside, not a file-in-place editor (unverified).
- **iA Writer:**
  - Minimalist focus writer. Windows is $29.99 one-off with a 14-day trial; Mac is $49.99. — [rywalker.com analysis](https://rywalker.com/research/ia-writer); [nubiapage review](https://nubiapage.com/ia-writer-review-2026/)
  - The Windows version trails Mac/iOS on features. — [nubiapage review](https://nubiapage.com/ia-writer-review-2026/)
  - Prices come from third-party sources.
- **Yank Note:**
  - Built-in version control, encryption, terminal, runnable code, Reveal.js, plugins and AI copilot.
  - v3.90.0, May 2026.
  — [Star History](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026)
- **MarkFlowy:** built on Tauri (a binary under 20 MB, so not Electron), ProseMirror core, AI assistants. v0.80.1, May 2026. — [Star History](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026)

### Inferences
- Short comparison against Northern Lights (NL):

  | App | Editing model | Math | Mermaid | Plugins | Cross-file search | Backlinks/graph | DOCX | Fidelity risk |
  |---|---|---|---|---|---|---|---|---|
  | Typora | Inline WYSIWYG | Yes | Yes | No (CSS themes only) | Folder/file-tree search (unverified) | No | Yes (bundled Pandoc-style export) | Medium: re-serialises the document |
  | Obsidian | Live Preview / Source / Reading | Yes (unverified) | Yes (unverified) | Yes (large ecosystem) | Yes | Yes (core) (unverified) | Via community Pandoc plugin (unverified) | Low: source edits are verbatim (unverified) |
  | MarkText | Inline WYSIWYG | Yes (unverified) | Yes (unverified) | No | Yes (unverified) | No | No (HTML/PDF) (unverified) | Medium (unverified) |
  | Zettlr | Adjustable, CodeMirror-based | Yes | Yes | No | Yes (unverified) | Linked notes | Yes (Pandoc) | Low |
  | VS Code (+ ext.) | Source + preview | Yes | Yes | Yes (Marketplace) | Yes | Via extensions such as Foam (unverified) | Via MPE/Pandoc | None: plain text editor |
  | NL | Read-first + click-to-edit block, source split | No | Yes (offline) | No | No | No | No | None: splices only the changed lines |
- Typora is a WYSIWYG editor that re-emits the whole document on save (unverified). That plus the history of #750 make it the weakest for git diffs. NL's block splice is a real differentiator against Typora, MarkText and the Joplin Rich Text editor.
- On readability controls, I saw no evidence that any of these apps offers both of NL's controls together: scaling document text only (65–260%) without the UI, and a separate reading-margin control. Most rely on themes/CSS or app-wide zoom; Typora and iA Writer have line-width settings (unverified).
- Interactive tables (sort/filter/hide, CSV/JSON export) were not found as built-in features in any reviewed app. Obsidian's newer "Bases" feature (unverified) works on note properties, not on Markdown tables.

### Gaps
- I did not benchmark large-file performance for Typora, MarkText or Zettlr. Only Obsidian forum reports were found.
- I did not confirm whether current Typora (1.14.x) still normalises list markers, emphasis characters or table spacing on save. No source was found this session beyond #750 and the "no built-in reformat" doc.
- I did not verify Obsidian core features (backlinks, graph, PDF export, math/Mermaid) against official docs this session. They are widely known but marked unverified.
- I could not get official pages for Ghostwriter (KDE) status. Nothing came back.

## 2. Deployment and IT-approval profile (installer vs portable, per-user/no-admin, price/licence, telemetry/network, size)

### Takeaway
Every alternative ships executable code that IT must approve. They usually come with auto-updaters and network endpoints, and often a per-seat cost (Typora, iA Writer, Obsidian commercial). NL is a single static HTML file with no executable and no network. In most environments that falls under "document" rather than "software". That is its main deployment advantage.

### Cited Findings
- **Typora:**
  - Price and licence: $14.99 one-time, with a 15-day trial on up to 3 devices. — [typora.io](https://typora.io/)
  - Platforms: Windows 10/11 (x64, x86, ARM), macOS and Linux (.deb/apt/tarball). — [typora.io](https://typora.io/)
  - Install: the setup program has a current-user-only option that needs no admin, with a `/CURRENTUSER` CLI flag. — [Typora on Windows](https://support.typora.io/Typora-on-Windows)
  - Enterprise silent-install packages exist (WAPT). — [WAPT store](https://wapt.tranquil.it/store/en/tis-typora)
  - No official portable build was found.
- **Obsidian:**
  - Licence: free, including for work. A commercial licence is optional, at $50/user/year. Sync is $4–5/user/month; Publish is $8–10/site/month. — [Obsidian pricing](https://obsidian.md/pricing)
  - Network: HTTPS 443 calls depend on the features in use:
    - update checks (GitHub / releases.obsidian.md)
    - account/licence (api.obsidian.md)
    - Sync and Publish
    - a "plugin deprecations" check every 12 hours
    - embedded online content
  - These "can be disabled via a domain firewall or application lockdown". The teams security page does not mention telemetry. — [Obsidian Help: Security for teams](https://obsidian.md/help/teams/security)
  - Install: there is no official portable build, and users have requested one since v0.9. — [forum: portable mode](https://forum.obsidian.md/t/obsidian-run-in-portable-mode/915)
  - Forum reports conflict on admin rights:
    - One request says installing needs admin rights. — [forum: single-user install](https://forum.obsidian.md/t/windows-allow-single-user-installation-if-a-portable-app-isnt-in-the-cards/13586)
    - Others say the stock install lands in `%LOCALAPPDATA%\Obsidian`, which is per-user. — [forum](https://forum.obsidian.md/t/run-in-portable-mode/915/81)
    - A separate request asks for an all-users (ALLUSERS=1) install for enterprise management. — [forum](https://forum.obsidian.md/t/request-for-all-users-or-system-wide-installation-on-windows/51897)
  - Third-party PortableApps-style repackages exist, but Obsidian doesn't endorse them. — [forum](https://forum.obsidian.md/t/network-connections-network-traffic/12294/11)
- **Zettlr:**
  - Licence: free and open source, donation-funded. — [zettlr.com](https://www.zettlr.com/)
  - Portable: a PortableApps.com build exists (Zettlr Portable 4.6.0, July 2026). — [PortableApps.com](https://portableapps.com/node/82182)
- **MarkText:**
  - Free and Electron-based. Maintenance only resumed in May 2026. — [Star History](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026)
- **VS Code + MPE:**
  - The Pandoc and Puppeteer/Chrome exports in MPE pull in extra installed tools. — [MPE docs](https://shd101wyy.github.io/markdown-preview-enhanced/)
- **iA Writer:**
  - Windows is $29.99 one-off, available from the Microsoft Store or the official site. — [rywalker.com](https://rywalker.com/research/ia-writer)
- **MarkFlowy:**
  - Tauri binary under 20 MB, against Electron apps that are typically 100 MB+ (unverified for the Electron figure). It integrates cloud AI assistants (DeepSeek/ChatGPT), so expect network calls when they are used. — [Star History](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026)

### Inferences
- IT approval friction, rough ranking from least to most:
  1. NL: no install.
  2. Zettlr Portable / VS Code user installer (per-user, no admin) (VS Code part unverified).
  3. Typora, using the current-user option, plus a paid licence.
  4. Obsidian: closed source, plugin ecosystem with its own network traffic, and unclear official per-user/MSI story.
  5. MPE exports: extra Pandoc/Chrome dependencies.
- Most Electron apps auto-update by default (VS Code, Obsidian, Typora: unverified for each). Locked-down estates often have to manage or disable this.
- VS Code is often already approved in technical organisations, which lowers its marginal approval cost. Its Marketplace extensions (MPE, Markdown All in One) may each still need vetting. This is an inference; no source was checked.

### Gaps
- I found no official telemetry documentation for Typora, MarkText, Zettlr or Joplin this session.
- VS Code telemetry settings (`telemetry.telemetryLevel`) and the user vs system installer were not fetched this session (unverified).
- No measured install sizes were gathered for any Electron app.
- Obsidian's current Windows installer behaviour (per-user vs machine, MSI availability) is not documented officially. The forum evidence conflicts.

## 3. Capability gap analysis: what Northern Lights lacks, and what is rare in the installed apps

### Takeaway
NL's biggest gaps against the best installed apps:
- LaTeX math
- true inline WYSIWYG
- spellcheck
- plugins
- cross-file search with backlinks/graph
- image paste/management
- DOCX/Pandoc export

NL's rare strengths:
- zero install and no network
- line-preserving block splicing (clean git diffs)
- interactive tables with CSV/JSON export
- separate document-text scaling and reading-margin controls
- 12 contrast-validated palettes
- a built-in Markdown syntax fixer
- script-free standalone HTML export

### Cited Findings
- **Math** is standard elsewhere:
  - Typora (MathJax) — [typora.io](https://typora.io/)
  - Zettlr (LaTeX) — [zettlr.com](https://www.zettlr.com/)
  - VS Code built-in (KaTeX) — [VS Code docs](https://code.visualstudio.com/docs/languages/markdown)
  - Joplin (KaTeX) — [Joplin Help](https://joplinapp.org/help/apps/rich_text_editor)
  - NL has no math rendering.
- **Mermaid** is now table stakes. Typora, Zettlr, VS Code built-in, MPE and Joplin all have it. NL's offline Mermaid gives parity, not an advantage. — sources as above.
- **Inline WYSIWYG** is in Typora and MarkText; Obsidian Live Preview comes close. — [typora.io](https://typora.io/); [Star History](https://newsletter.star-history.com/p/star-history-monthly-standalone-markdown-editor-may-2026); [Obsidian Help](https://obsidian.md/help/edit-and-read)
- **Image paste/drag into the workspace** is in VS Code built-in and Typora (drag-drop with relative paths). — [VS Code docs](https://code.visualstudio.com/docs/languages/markdown); [typora.io](https://typora.io/)
- **Workspace header search, link refactoring on rename/move and link validation:** VS Code built-in. — [VS Code docs](https://code.visualstudio.com/docs/languages/markdown)
- **DOCX / academic export:**
  - Typora: DOCX, LaTeX, EPUB. — [typora.io](https://typora.io/)
  - Zettlr: Pandoc, citations, PowerPoint/Beamer. — [zettlr.com](https://www.zettlr.com/)
  - MPE: Pandoc and ebook. — [MPE](https://shd101wyy.github.io/markdown-preview-enhanced/)
- **Focus/typewriter modes and word counts:** Typora. — [typora.io](https://typora.io/); iA Writer's core proposition — [rywalker.com](https://rywalker.com/research/ia-writer)
- **Spellcheck** is absent even in VS Code core (it needs an extension). That makes it a common gap, not unique to NL. — [VS Code docs](https://code.visualstudio.com/docs/languages/markdown)
- **Fidelity:** WYSIWYG/rich-text editors rewrite Markdown that was not touched:
  - Joplin documents the conversions (reference links to inline, added table headers, HTML loss). — [Joplin Help](https://joplinapp.org/help/apps/rich_text_editor)
  - Typora has had silent-rewrite bugs. — [typora-issues #750](https://github.com/typora/typora-issues/issues/750)
  - This supports NL's "splice only the edited lines" as a distinctive strength.
- **Markdown linting/fixing:** Typora explicitly has no built-in reformat or lint and points to external Prettier. — [Typora support](https://support.typora.io/Markdown-Export). VS Code needs a linter extension. — [VS Code docs](https://code.visualstudio.com/docs/languages/markdown). NL's built-in fixer is uncommon.
- **Plain-file storage:** Logseq's 2026 move to SQLite shows some tools are leaving plain files. NL edits the original .md in place via the File System Access API. — [kompozy](https://kompozy.io/reviews/logseq-2-0)

### Inferences
- NL's gaps, in priority order for a "viewer that edits" positioning:
  1. Math (KaTeX would be the obvious vendored add).
  2. Spellcheck. Chrome's native spellcheck may already work in a textarea or contenteditable edit box (unverified).
  3. Cross-file search within a connected folder.
  4. Image paste into the folder.
  5. DOCX export. This probably conflicts with the no-server/no-install ethos unless done in pure JS (unverified).
  6. Outline drag-reordering of sections. Obsidian has this via plugins or core outline (unverified).
  7. Backlinks/graph and plugins. These are a knowledge-base feature set outside NL's scope.
- NL capabilities that are rare or absent in the reviewed apps (based on the feature lists reviewed, not exhaustive testing):
  - zero install, offline, nothing executable
  - block-level click-to-edit with line splicing
  - interactive tables (sort/filter/hide, CSV/JSON export)
  - text-only scaling without UI zoom, plus a margin control
  - contrast-validated palette set
  - built-in syntax fixer
  - script-free standalone HTML export
  - raw HTML rendered GitHub-style via an allow-list sanitizer. VS Code's preview also sanitises HTML (unverified).
- VS Code is the strongest direct competitor for technical users. It already covers source + preview, math, Mermaid, workspace search and git. NL's case against it is zero install, a reading-first UX, palettes/readability controls and interactive tables.

### Gaps
- I did not test any app hands-on. Claims of "absence" come from official feature pages, not from exhaustive plugin searches. Obsidian and VS Code plugins may provide interactive tables, CSV export or reading-margin controls.
- Not checked: whether Obsidian or Typora offer a text-only zoom separate from UI zoom.
