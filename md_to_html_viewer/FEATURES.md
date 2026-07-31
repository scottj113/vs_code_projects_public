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

| Feature | Type | Status | % | Added | Completed | Priority | Importance | Reason | Notes |
|---------|------|--------|---|-------|-----------|----------|-----------|--------|-------|
| **CORE PARSING** | | | | | | | | | |
| Markdown rendering (GFM) | core | ✓ | 100% | 7/24 | 7/25 | 1 | critical | Foundation | Full GFM support + tables, task lists, strikethrough |
| Mermaid diagrams | render | ✓ | 100% | 7/25 | 7/26 | 1 | critical | Feature | Offline diagram rendering with dark mode |
| Syntax highlighting | render | ✓ | 100% | 7/25 | 7/26 | 1 | high | Quality | JS/TS, Python, HTML/XML, CSS, JSON, Bash, SQL, YAML, TOML/INI, diffs |
| Footnotes + definition lists | parse | ✓ | 100% | 7/25 | 7/26 | 2 | medium | Feature | Extended markdown support |
| YAML frontmatter | parse | ✓ | 100% | 7/25 | 7/26 | 3 | low | Compatibility | Support for metadata in markdown |
| **READING & NAVIGATION** | | | | | | | | | |
| Contents sidebar w/ scroll-spy | nav | ✓ | 100% | 7/24 | 7/25 | 1 | critical | UX | Auto-highlight current section while reading |
| Document set (folder browsing) | nav | ✓ | 100% | 7/26 | 7/27 | 2 | high | Workflow | Browse multiple markdown files in a project |
| Jump to heading via contents | nav | ✓ | 100% | 7/24 | 7/25 | 1 | critical | UX | Smooth scroll to any heading |
| Keyboard navigation | nav | ✓ | 100% | 7/27 | 7/28 | 2 | high | UX | Full keyboard shortcut support |
| **CUSTOMIZATION** | | | | | | | | | |
| Text size adjustment (65%-260%) | appearance | ✓ | 100% | 7/24 | 7/25 | 1 | critical | Accessibility | Document zoom without scaling UI |
| 12 color palettes (light/dark) | appearance | ✓ | 100% | 7/25 | 7/26 | 1 | critical | UX | 2 modes × 2 families × 3 depths, contrast-validated |
| Bold all text toggle | appearance | ✓ | 100% | 7/25 | 7/26 | 2 | high | Accessibility | Glare/low-contrast mitigation |
| Dark mode + image dimming | appearance | ✓ | 100% | 7/25 | 7/26 | 1 | critical | UX | Images auto-dim in dark mode, diagrams re-theme |
| Theme persistence | state | ✓ | 100% | 7/24 | 7/25 | 1 | critical | UX | Remember palette & text size across sessions |
| Match system preference | appearance | ✓ | 100% | 7/26 | 7/27 | 2 | medium | UX | Auto-follow OS light/dark mode |
| Bumper lanes (margin control) | layout | ✓ | 100% | 7/26 | 7/27 | 2 | high | Comfort | 5 margin widths (0%, 10%, 20%, 30%, 40%) for reading comfort |
| **EDITING** | | | | | | | | | |
| Section editing (Ctrl+E) | edit | ✓ | 100% | 7/27 | 7/28 | 1 | critical | Workflow | Edit one section without touching the rest |
| Save edits back to file (Ctrl+S) | edit | ✓ | 100% | 7/27 | 7/28 | 1 | critical | Workflow | Write changes back to disk with permission grant |
| Pencil icon on headings | edit | ✓ | 100% | 7/27 | 7/28 | 2 | high | UX | Quick-edit affordance in contents sidebar |
| File change detection | edit | ✓ | 100% | 7/28 | 7/29 | 2 | medium | Safety | Warn if file changed on disk while editing |
| Section-only replacement | edit | ✓ | 100% | 7/27 | 7/28 | 1 | critical | Safety | Preserve rest of file, line endings, formatting |
| **FILE I/O** | | | | | | | | | |
| Drag & drop files | input | ✓ | 100% | 7/24 | 7/25 | 1 | critical | UX | Open markdown by dragging onto viewer |
| File picker (Ctrl+O) | input | ✓ | 100% | 7/24 | 7/25 | 1 | critical | UX | Browse and select files |
| Paste markdown (Ctrl+V) | input | ✓ | 100% | 7/25 | 7/25 | 2 | high | UX | Paste text directly onto page |
| Project folder path storage | state | ✓ | 100% | 7/28 | 7/28 | 2 | medium | UX | Remember folder location for editing |
| Drop multiple files | input | ✓ | 100% | 7/26 | 7/27 | 2 | medium | UX | Create document set from multi-file drag |
| **LIVE RELOAD** | | | | | | | | | |
| Refresh file (Ctrl+R) | sync | ✓ | 100% | 7/28 | 7/28 | 1 | critical | Workflow | Re-read file from disk on demand |
| Watch mode (auto-refresh) | sync | ✓ | 100% | 7/28 | 7/28 | 1 | critical | Workflow | Auto-reload whenever file changes |
| Enable live reload button | sync | ✓ | 100% | 7/28 | 7/28 | 2 | high | UX | Arm live reload after opening without it |
| **EXPORT** | | | | | | | | | |
| Standalone HTML export | export | ✓ | 100% | 7/29 | 7/29 | 1 | critical | Feature | Single self-contained .html file with all styles inlined |
| PDF export (Ctrl+P) | export | ✓ | 100% | 7/29 | 7/29 | 1 | critical | Feature | Clean PDF printing with proper formatting |
| Preserve text size on export | export | ✓ | 100% | 7/29 | 7/29 | 2 | high | Quality | Export keeps chosen text scale |
| Mermaid diagrams as SVG | export | ✓ | 100% | 7/29 | 7/29 | 2 | high | Quality | Diagrams render as static SVG in export |
| Strip interactive elements | export | ✓ | 100% | 7/29 | 7/29 | 2 | medium | Functionality | Remove copy buttons, scripts in export |
| **VS CODE INTEGRATION** | | | | | | | | | |
| Keyboard shortcut task (Ctrl+M Down) | integration | ✓ | 100% | 7/29 | 7/30 | 2 | high | Workflow | Open current file from VS Code |
| Welcome popup | integration | ✓ | 100% | 7/29 | 7/30 | 2 | medium | UX | Explain read-only workflow on first open |
| Bootstrap data embedding | integration | ✓ | 100% | 7/29 | 7/30 | 1 | critical | Tech | Solve file:// security restrictions |
| **UI & UX** | | | | | | | | | |
| Responsive toolbar | ui | ✓ | 100% | 7/24 | 7/25 | 1 | high | UX | All controls in fixed top bar |
| Copy code blocks | ui | ✓ | 100% | 7/25 | 7/26 | 2 | high | UX | One-click copy for code snippets |
| Markdown cheat sheet | ui | ✓ | 100% | 7/27 | 7/27 | 3 | low | Help | Quick reference popup for markdown syntax |
| Clear cache & settings | ui | ✓ | 100% | 7/28 | 7/28 | 2 | medium | UX | Reset all preferences to factory defaults |
| Source path display | ui | ✓ | 100% | 7/28 | 7/28 | 2 | medium | UX | Show filename/path, copy to clipboard |
| HTML sanitizing | ui | ✓ | 100% | 7/25 | 7/26 | 1 | critical | Security | Allow-list for HTML tags/attributes |
| Raw HTML toggle | ui | ✓ | 100% | 7/25 | 7/26 | 2 | medium | Feature | Opt-in to render raw HTML |
| **BRANDING** | | | | | | | | | |
| Aurora SVG favicon | brand | ✓ | 100% | 7/24 | 7/30 | 3 | low | Brand | Embedded data URI, no separate file |
| Product rename (md_to_html_viewer → northern-lights) | brand | ✓ | 100% | 7/30 | 7/30 | 2 | medium | Brand | Rebranded with new name |
| **v2.0 — TABLE FEATURES** | | | | | | | | | |
| Adjustable column widths | tables | ✓ | 100% | 7/31 | 7/31 | 2 | high | Feature | Drag column headers to resize |
| Collapsible columns | tables | ✓ | 100% | 7/31 | 7/31 | 2 | high | Feature | Hide/show individual columns |
| Row filtering/search | tables | ✓ | 100% | 7/31 | 7/31 | 2 | high | Feature | Text match search across all columns |
| Table state persistence | tables | ✓ | 100% | 7/31 | 7/31 | 2 | medium | UX | Remember column widths and visibility |

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

- **Total Features:** 57
- **Status Breakdown:** 57 ✓ | 0 🔄 | 0 → | 0 ○
- **Completion:** 100%
- **v1.0 Features:** 54
- **v2.0 Features:** 3 (table enhancements)
- **Development Timeline:** ~1 week (7/24–7/31)
- **Architecture:** Single-file HTML application (~3,400 LOC)
- **Dependencies:** Mermaid (vendored)
- **Installation:** None required

## Next Steps (Backlog)

Potential future enhancements (not committed):
- Multi-pattern text highlighting (experimental)
- Docx export (if good conversion path found)
- Collaborative features (design stage)
- Plugin system (research phase)
- Mobile-responsive improvements

---

**Last Updated:** 7/31/2026  
**Maintainer:** Scott  
**License:** See LICENSE file in distro/
