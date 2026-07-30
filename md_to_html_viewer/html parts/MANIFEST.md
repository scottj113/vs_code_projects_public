# md_to_html_viewer.html — split into 5 parts

Source: `../distro/md_to_html_viewer.html` (2390 lines, 93,915 bytes)

Split on the file's own structural boundaries rather than at equal line counts, so
each part is a coherent unit and no section-comment block is cut in half.

| Part | Lines | Bytes | Contains |
|:--|--:|--:|:--|
| `part-1.html` | 1–619 | 21,717 | `<!doctype>`, `<head>`, the pre-paint preference script, and the whole application stylesheet (`<style id="app-css">`) |
| `part-2.html` | 620–1080 | 20,910 | Document stylesheet (`<style id="doc-css">`), the Mermaid tag, `</head>`, all body markup, the bootstrap sidecar tag, the main `<script>` opening, **0. Small helpers**, **1. Syntax highlighting** |
| `part-3.html` | 1081–1516 | 17,413 | **2. Markdown parser** — block pass then inline pass |
| `part-4.html` | 1517–1848 | 12,997 | **3. Sanitizer**, **4. Application state + rendering pipeline** |
| `part-5.html` | 1849–2390 | 20,878 | **5. Input paths**, **6. Wiring**, `</script>`, `</body>`, `</html>` |

## Reassembling

Concatenation in order reproduces the original **byte for byte** — verified with
`cmp`, not just by eye.

```bash
cat part-1.html part-2.html part-3.html part-4.html part-5.html > md_to_html_viewer.html
```

```powershell
Get-Content part-1.html,part-2.html,part-3.html,part-4.html,part-5.html -Raw `
  | Set-Content md_to_html_viewer.html -NoNewline
```

## Notes

- **Individual parts are fragments, not valid HTML.** Only part 1 opens the document
  and only part 5 closes it; parts 2–4 sit inside an unterminated `<script>`.
- This folder is scratch and is **not tracked by git**. It is not in `distro/`
  deliberately — `Build-Distro.ps1` verifies the package against a strict four-file
  allow-list and would fail on anything extra.
- The source is unchanged; nothing here feeds back into the build.
