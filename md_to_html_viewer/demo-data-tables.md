# Northern Lights v3: Data-Driven Tables Demo

This document demonstrates the v3 data layer architecture with embedded datasets and interactive exports.

## Sales Q3 2026 Data

Below is an embedded dataset table with sorting, filtering, and export capabilities.

<table data-source="sales_q3"></table>

This table contains Q3 2026 sales data with the following features:

- **Filter by field** — Type in any filter field to narrow results
- **Sort by column** — Click column headers to sort ascending/descending
- **Export as CSV** — Download filtered/sorted data as `.csv`
- **Export as JSON** — Download filtered/sorted data as `.json`

### Filter Syntax

Use prefixes to control filtering behavior:

- **No prefix or `+token`** — Keep rows matching the token
  - Type: `West` or `+West` → shows only West region
  - Type: `Completed` → shows only Completed status
  
- **`-token`** — Remove rows matching the token (inverted filter)
  - Type: `-East` → shows everything except East region
  - Type: `-Pending` → removes all Pending rows
  
- **Multiple filters** — AND logic across columns
  - Region: `-East` AND Status: `Completed` → Completed rows that aren't East

### Sort Examples

Or sort by:
- **Revenue** (highest sales first)
- **Date** (chronologically)
- **Units** (volume)

## Technical Details

This data table is powered by the v3 DataSystem module:

```javascript
const data = DataSystem.loadDatasets();
DataSystem.filter(datasetId, fieldName, searchTerm);
DataSystem.sort(datasetId, fieldName, direction);
const csv = DataSystem.exportCSV(datasetId);
const json = DataSystem.exportJSON(datasetId);
```

**No external API calls** — all data is embedded in the HTML.  
**No dependencies** — data operations use only browser JavaScript.  
**Persistent filtering** — filter state is remembered while the page is open.

---

**v3.0 Status:** Data layer Phase 2 (Export functionality) ✓  
**Next:** Add Markdown reference syntax for embedded datasets
