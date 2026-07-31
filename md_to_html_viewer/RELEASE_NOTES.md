# Release Notes

## v2.0 — Table Mastery & Logo Magic

**Released:** 8/1/2026  
**Development:** 2 days (7/31–8/1)  
**Status:** Shipping

### What's New

#### Interactive Tables (v2 flagship feature)
- **Resizable columns** — Drag column headers left/right to adjust width
- **Collapsible columns** — Click × to hide, badge appears showing hidden column name
- **Row filtering** — Live search box filters all rows by text match
- **Auto-fit columns** — Distribute available width evenly across all visible columns
- **Show all / Reset** — Restore hidden columns or reset table to original layout (with confirmation)
- **Persistent state** — All column widths, visibility, and preferences saved in localStorage

Perfect for wide tables (20+ columns) and data-heavy documents.

#### Three-Mode Logo
- **Auto mode** (default) — Aurora smoothly pulses between neon and monochrome (4s cycle)
- **Color mode** — Frozen on vibrant neon colors
- **Mono mode** — Frozen on elegant grayscale
- Click the logo to cycle through modes. Preference saved across sessions.

### v2.0 Feature Count
- **6 new features** added in v2
- **60 total features** (54 v1.0 + 6 v2.0)
- **100% complete**

### Documentation Updated
- **HOW_TO.md** — New "Working with Tables" section with full usage guide
- **FEATURES.md** — Updated feature inventory with completion dates
- **distro/README.md** — Enhanced "What it does" section
- **This file** — Release notes for v2.0

### Commits This Release
- Table features: drag resize, collapse/show, filtering, auto-fit, reset
- Show/hide indicators for collapsed columns
- Auto-fit and Reset buttons with confirmation dialogs
- Column name truncation in badges (Pri..., Sta..., Des...)
- Aurora logo added to toolbar header
- Three-mode logo toggle (auto/color/mono) with smooth animation
- Documentation updates across all guide files

### Under the Hood
- No new dependencies added
- Single-file HTML remains at ~3,500 LOC
- CSS animation for logo pulse effect
- localStorage for table state persistence per table
- Event delegation for table interactivity

### Testing
- ✓ Tested with 20-column table (real-world use case)
- ✓ Responsive column width adjustment
- ✓ Hide/show persists across page reload
- ✓ Filter performance with 100+ rows
- ✓ Logo animation smooth at 60fps
- ✓ All modes persist correctly

### Known Limitations
- Columns cannot be reordered (by design—keeps complexity low)
- Table state cleared on browser cache clear (by design—cleans everything)
- Filter state not persistent (intentional—temporary exploration)

### What Users Said
> "this thing is seriously a professional tool now. its not a joke. not a toy."

### Next Steps

**v2.0 Status:** Shipping ✓

**v3.0 Backlog** (Data Layer Architecture)
- Embedded data sources: JSON, CSV, XML stored in HTML or as data-URI
- Custom table schema support (field names, types, constraints)
- Data-driven tables (load from embedded dataset instead of markdown)
- Column sorting (click header to sort, multi-column support)
- Advanced filtering (by value, range, type, not just text search)
- Export filtered/sorted data to CSV
- Export filtered/sorted data to JSON
- Backward compatibility with v2 markdown tables
- Table metadata in YAML frontmatter or `<table data-source="...">` attribute

**Future Considerations**
- Markdown validator tab — Optional tab for users who want to lint/validate their MD syntax. Shows issues like broken tables, unclosed code blocks, etc. Only used if user opens it—no intrusive warnings.
- Search across embedded datasets
- In-memory data transformation pipeline
- Aggregation/pivot capabilities
- Chart generation from table data
- Mobile responsive improvements
- Multi-pattern text highlighting
- Docx export

---

**Project stats:**  
Development started: 7/24/2026  
v1.0 shipped: 7/31/2026  
v2.0 shipped: 8/1/2026  
Total development: 9 days  
Shipping product: Single HTML file, zero installation, bookmark & use
