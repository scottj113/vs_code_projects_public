# Northern Lights MD Viewer — Feature Roadmap

Complete feature inventory with status, timeline, and metadata.

## Feature Status Legend

| Code | Meaning |
|------|---------|
| ✓ | Done |
| 🔄 | In Progress |
| → | Blocked |
| ○ | Not Started |
| ? | On Hold |

## Release Features

| Feature | Type | Status | % | Added | Completed | Planned v | Released v | Priority | Importance | Reason | Notes |
|---------|------|--------|---|-------|-----------|----------|-----------|---------|-----------|--------|-------|
| **CORE PARSING** | | | | | | | | | |
| Markdown rendering (GFM) | core | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | critical | Foundation | Full GFM support + tables, task lists, strikethrough |
| Mermaid diagrams | render | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 1 | critical | Feature | Offline diagram rendering with dark mode |
| Syntax highlighting | render | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 1 | high | Quality | JS/TS, Python, HTML/XML, CSS, JSON, Bash, SQL, YAML, TOML/INI, diffs |
| Footnotes + definition lists | parse | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 2 | medium | Feature | Extended markdown support |
| YAML frontmatter | parse | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 3 | low | Compatibility | Support for metadata in markdown |
| **READING & NAVIGATION** | | | | | | | | | |
| Contents sidebar w/ scroll-spy | nav | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | critical | UX | Auto-highlight current section while reading |
| Document set (folder browsing) | nav | ✓ | 100% | 7/26 | 7/27 | v1.0 | v1.0 | 2 | high | Workflow | Browse multiple markdown files in a project |
| Jump to heading via contents | nav | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | critical | UX | Smooth scroll to any heading |
| Keyboard navigation | nav | ✓ | 100% | 7/27 | 7/28 | v1.0 | v1.0 | 2 | high | UX | Full keyboard shortcut support |
| **CUSTOMIZATION** | | | | | | | | | |
| Text size adjustment (65%-260%) | appearance | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | critical | Accessibility | Document zoom without scaling UI |
| 12 color palettes (light/dark) | appearance | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 1 | critical | UX | 2 modes × 2 families × 3 depths, contrast-validated |
| Bold all text toggle | appearance | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 2 | high | Accessibility | Glare/low-contrast mitigation |
| Dark mode + image dimming | appearance | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 1 | critical | UX | Images auto-dim in dark mode, diagrams re-theme |
| Theme persistence | state | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | critical | UX | Remember palette & text size across sessions |
| Match system preference | appearance | ✓ | 100% | 7/26 | 7/27 | v1.0 | v1.0 | 2 | medium | UX | Auto-follow OS light/dark mode |
| Bumper lanes (margin control) | layout | ✓ | 100% | 7/26 | 7/27 | v1.0 | v1.0 | 2 | high | Comfort | 5 margin widths (0%, 10%, 20%, 30%, 40%) for reading comfort |
| **EDITING** | | | | | | | | | |
| Section editing | edit | ✓ | 100% | 7/27 | 10/10 | v1.0 | v3.0 | 1 | critical | Workflow | Contents pencil turns on edit mode (Edit button lit), scrolls to the section and frames it in red; the frame follows you into whichever section you click or arrow into. Click a block for its Markdown; auto-saves to the file. Esc, the Edit button, or the same pencil again ends it. Replaced the v1 pop-out window editor |
| Save edits back to file | edit | ✓ | 100% | 7/27 | 10/10 | v1.0 | v3.0 | 1 | critical | Workflow | Every in-place edit saves straight to the file; Ctrl+S forces a save (overwrites a file changed on disk, or Save As when unlinked) |
| Pencil icon on headings | edit | ✓ | 100% | 7/27 | 7/28 | v1.0 | v1.0 | 2 | high | UX | Quick-edit affordance in contents sidebar |
| File change detection | edit | ✓ | 100% | 7/28 | 7/29 | v1.0 | v1.0 | 2 | medium | Safety | Warn if file changed on disk while editing |
| Section-only replacement | edit | ✓ | 100% | 7/27 | 7/28 | v1.0 | v1.0 | 1 | critical | Safety | Preserve rest of file, line endings, formatting |
| **FILE I/O** | | | | | | | | | |
| Drag & drop files | input | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | critical | UX | Open markdown by dragging onto viewer |
| File picker (Ctrl+O) | input | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | critical | UX | Browse and select files |
| Paste markdown (Ctrl+V) | input | ✓ | 100% | 7/25 | 7/25 | v1.0 | v1.0 | 2 | high | UX | Paste text directly onto page |
| Project folder path storage | state | ✓ | 100% | 7/28 | 7/28 | v1.0 | v1.0 | 2 | medium | UX | Remember folder location for editing |
| Drop multiple files | input | ✓ | 100% | 7/26 | 7/27 | v1.0 | v1.0 | 2 | medium | UX | Create document set from multi-file drag |
| **LIVE RELOAD** | | | | | | | | | |
| Refresh file (Ctrl+R) | sync | ✓ | 100% | 7/28 | 7/28 | v1.0 | v1.0 | 1 | critical | Workflow | Re-read file from disk on demand |
| Watch mode (auto-refresh) | sync | ✓ | 100% | 7/28 | 7/28 | v1.0 | v1.0 | 1 | critical | Workflow | Auto-reload whenever file changes |
| Enable live reload button | sync | ✓ | 100% | 7/28 | 7/28 | v1.0 | v1.0 | 2 | high | UX | Arm live reload after opening without it |
| **EXPORT** | | | | | | | | | |
| Standalone HTML export | export | ✓ | 100% | 7/29 | 7/29 | v1.0 | v1.0 | 1 | critical | Feature | Single self-contained .html file with all styles inlined |
| PDF export (Ctrl+P) | export | ✓ | 100% | 7/29 | 7/29 | v1.0 | v1.0 | 1 | critical | Feature | Clean PDF printing with proper formatting |
| Preserve text size on export | export | ✓ | 100% | 7/29 | 7/29 | v1.0 | v1.0 | 2 | high | Quality | Export keeps chosen text scale |
| Mermaid diagrams as SVG | export | ✓ | 100% | 7/29 | 7/29 | v1.0 | v1.0 | 2 | high | Quality | Diagrams render as static SVG in export |
| Strip interactive elements | export | ✓ | 100% | 7/29 | 7/29 | v1.0 | v1.0 | 2 | medium | Functionality | Remove copy buttons, scripts in export |
| **VS CODE INTEGRATION** | | | | | | | | | |
| Keyboard shortcut task (Ctrl+M Down) | integration | ✓ | 100% | 7/29 | 7/30 | v1.0 | v1.0 | 2 | high | Workflow | Open current file from VS Code |
| Welcome popup | integration | ✓ | 100% | 7/29 | 7/30 | v1.0 | v1.0 | 2 | medium | UX | Explain read-only workflow on first open |
| Bootstrap data embedding | integration | ✓ | 100% | 7/29 | 7/30 | v1.0 | v1.0 | 1 | critical | Tech | Solve file:// security restrictions |
| **UI & UX** | | | | | | | | | |
| Responsive toolbar | ui | ✓ | 100% | 7/24 | 7/25 | v1.0 | v1.0 | 1 | high | UX | All controls in fixed top bar |
| Copy code blocks | ui | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 2 | high | UX | One-click copy for code snippets |
| Markdown cheat sheet | ui | ✓ | 100% | 7/27 | 7/27 | v1.0 | v1.0 | 3 | low | Help | Quick reference popup for markdown syntax |
| Clear cache & settings | ui | ✓ | 100% | 7/28 | 7/28 | v1.0 | v1.0 | 2 | medium | UX | Reset all preferences to factory defaults |
| Source path display | ui | ✓ | 100% | 7/28 | 7/28 | v1.0 | v1.0 | 2 | medium | UX | Show filename/path, copy to clipboard |
| HTML sanitizing | ui | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 1 | critical | Security | Allow-list for HTML tags/attributes |
| Raw HTML toggle | ui | ✓ | 100% | 7/25 | 7/26 | v1.0 | v1.0 | 2 | medium | Feature | Opt-in to render raw HTML |
| **BRANDING** | | | | | | | | | |
| Aurora SVG favicon | brand | ✓ | 100% | 7/24 | 7/30 | v1.0 | v1.0 | 3 | low | Brand | Embedded data URI, no separate file |
| Product rename (md_to_html_viewer → northern-lights) | brand | ✓ | 100% | 7/30 | 7/30 | v1.0 | v1.0 | 2 | medium | Brand | Rebranded with new name |
| **v2.0 — TABLE FEATURES** | | | | | | | | | |
| Adjustable column widths | tables | ✓ | 100% | 7/31 | 8/1 | v2.0 | v2.0 | 2 | high | Feature | Drag column headers to resize, auto-fit to available width |
| Collapsible columns | tables | ✓ | 100% | 7/31 | 8/1 | v2.0 | v2.0 | 2 | high | Feature | Hide/show columns with smart badges showing hidden names |
| Row filtering/search | tables | ✓ | 100% | 7/31 | 8/1 | v2.0 | v2.0 | 2 | high | Feature | Text match search across all columns, live filter |
| Table state persistence | tables | ✓ | 100% | 7/31 | 8/1 | v2.0 | v2.0 | 2 | medium | UX | Remember column widths, visibility, filter state |
| Show all / Reset controls | tables | ✓ | 100% | 8/1 | 8/1 | v2.0 | v2.0 | 2 | medium | UX | Restore all columns or reset to original layout with confirmation |
| Three-mode logo | brand | ✓ | 100% | 8/1 | 8/1 | v2.0 | v2.0 | 3 | medium | Feature | Auto-animate, color-only, or mono-only with smooth transitions |
| **v3.0 — NAVIGATION** | | | | | | | | | |
| File name as browser tab title | nav | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 3 | medium | UX | Browser tab shows the open .md file's name |
| Document tabs | nav | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 1 | high | Workflow | Thin tab row under the toolbar (shown at 2+ docs); one tab per opened file, re-opening reuses its tab; `[` / `]` to switch, × or middle-click to close; per-tab scroll position; up to 12, oldest closes first |
| Edit in place (Ctrl+E) | edit | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 1 | critical | Workflow | Typora-style: in edit mode, click any block and it becomes its Markdown source right where it sits; click away (or Ctrl+Enter) to apply, Esc to cancel, ↑/↓ at the edges walk into neighbouring blocks. Only that block's lines are spliced, so formatting, line endings and the rest of the file stay byte-identical. Auto-saves each edit when the file is linked; otherwise ● marks unsaved edits until Ctrl+S. Section-scoped version on the contents pencils |
| Split view: Markdown pane | edit | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 2 | high | Workflow | While editing, a ‹/› Markdown icon on the editable block opens a read-only pane with that block's source and file line numbers (live as you type; whole section during section edit). Ctrl+\ toggles. Never open by default; closes when editing ends |
| View Markdown source | nav | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 2 | medium | UX | ⋮ menu: the whole file as read-only Markdown with line numbers instead of the rendered page; editing and the split pane are off while it shows. Keeps your place both ways; contents jump to heading lines |
| Resizable contents sidebar | layout | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 3 | medium | UX | Drag the sidebar edge (160px to half the window), double-click to reset; width remembered and applied before first paint. Shares one drag routine with the split view divider |
| Find in document (Ctrl+F) | nav | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 1 | high | UX | Highlights every match (current in orange), "3 of 12", scrollbar ticks; Enter/Shift+Enter, F3; match case, whole word, regex. Reaches into collapsed <details>; skips hidden columns, diagrams, buttons; searches the Markdown in source view. Starts at the match nearest where you are reading |
| Find and replace (Ctrl+H) | edit | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 1 | high | Workflow | Works on the Markdown source, never the rendered text. Turns edit mode on and opens the Markdown pane showing the exact occurrence; its block is outlined. Replace / All (Ctrl+Alt+Enter), $1 with regex; each replace saves to the file; Undo for the last one. Off in source view |
| ALL-CAPS headings | appearance | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 3 | medium | Style | Aa menu or bare H: headings shown in capitals with a touch of tracking. Display only (the file keeps its casing); remembered, applied before first paint, kept in standalone export |
| Connect folder | sync | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 1 | high | Workflow | 📁 toolbar button: pick the project folder once per session (read/write). Relinks open tabs to their files — by VS Code path, else folder + name, else a unique name; never a guess — restoring save/refresh/watch; unsaved edits kept. Documents opened later link themselves. Relative images (Markdown or raw <img>) load from the folder; exports keep the original paths |
| Tabs remembered across sessions | state | ✓ | 100% | 10/10 | 10/10 | v3.0 | | 1 | high | Workflow | Tab text saved to localStorage (2M-char budget); restored tabs show in italics as saved copies until the file is opened again (file handles can't survive a refresh on file://) |

## Legend: Feature Type Codes

| Code | Meaning |
|------|---------|
| core | Core parsing/rendering |
| parse | Markdown parsing variant |
| render | Special rendering (syntax, diagrams, etc.) |
| nav | Navigation & browsing |
| appearance | Visual customization |
| state | Persistent state/preferences |
| layout | Layout options |
| edit | Editing capability |
| input | Input/file handling |
| sync | Live reload & file watching |
| export | Export & output |
| integration | External integrations (VS Code) |
| ui | UI elements & UX |
| security | Security & sanitizing |
| brand | Branding & identity |
| tables | Table-specific features |
| tech | Technical infrastructure |

## Summary Stats

- **Total Features:** 60
- **Status Breakdown:** 60 ✓ | 0 🔄 | 0 → | 0 ○
- **Completion:** 100%
- **v1.0 Features:** 54 (7/24–7/31)
- **v2.0 Features:** 6 (table enhancements + logo modes, 7/31–8/1)
- **Development Timeline:** ~9 days (7/24–8/1)
- **Architecture:** Single-file HTML application (~3,500 LOC)
- **Dependencies:** Mermaid (vendored, MIT licensed)
- **Installation:** None required — bookmark the HTML file

## Next Steps (Backlog)

Potential future enhancements (not committed). All must stay single-file and offline — no server, even optional.

### Recommended next
- **GitHub-style callouts** — render `> [!NOTE]`, `[!TIP]`, `[!WARNING]`, `[!IMPORTANT]` as colored boxes instead of plain blockquotes. Small.
- **Markdown tables as datasets** — give every ordinary GFM table the v3 sort and CSV/JSON export, not just `<script data-id>` tables.

### Reading & navigation
- Collapsible sections — click a heading to fold it; "collapse all to H2" for skimming.
- Copy link to heading — hover a heading, click to copy `#section-name`.
- Reading progress bar — thin bar under the toolbar (word count and reading time already exist).
- Focus mode — hide toolbar and sidebar, dim all but the current section.
- Wikilinks and backlinks in a document set — `[[Other Doc]]` jumps to that file; "linked from" list at the bottom.

### Data layer (Phase 3)
- Group-by and totals row — sum, average, count.
- Range and type filters — min/max for numbers, date from/to, pick-list for low-cardinality fields.
- Chart from a table — small inline-SVG bar/line chart, kept as static SVG in exports.

### Quality
- Optional lint tab — broken internal links, unclosed code fences, skipped heading levels, ragged tables. Only shows when opened.
- Math rendering (`$...$`, `$$...$$`) — costs ~300 KB vendored KaTeX; opt-in or skip.

### Earlier ideas
- Docx export (if good conversion path found)
- Collaborative features (design stage)
- Plugin system (research phase)
- Mobile-responsive improvements

---

**Last Updated:** 10/10/2026  
**Maintainer:** Scott  
**License:** See LICENSE file in distro/
