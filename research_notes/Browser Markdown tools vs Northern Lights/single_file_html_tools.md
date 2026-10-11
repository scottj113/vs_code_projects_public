# Single-file / zero-install HTML Markdown tools vs Northern Lights

Research date: 2026-10-10. About 18 searches and page fetches. Several GitHub pages returned no commit dates, so maintenance status is often partial; those spots are flagged.

## Which single-file HTML Markdown tools exist and are maintained, and what is their deployment, saving, editing, diagram, theming, maintenance and license profile?

### Takeaway
No one tool combines Northern Lights' features: editing external .md files, writing back to the original file via the File System Access API, Mermaid that works offline, and reading-ergonomics controls. The candidates fall into four groups:
- **Self-rendering document scripts** (Markdeep, TeXMe, md-page, strapdown). These render one page and do not edit or save.
- **Self-contained wikis** (TiddlyWiki, Feather Wiki). These keep their content inside the HTML file, not in .md files.
- **New, small single-file viewers/editors** (EdgeMD Viewer, Kapur). These are thin, and some quietly load from a CDN.
- **Generators** (orz-mdhtml). These need Node to build the file, and the output still loads from a CDN.

### Cited Findings

**TiddlyWiki 5 (single-file wiki + official Markdown plugin)**
- Latest release is v5.4.1, released 10 July. The release page footer says © 2026, so it is actively maintained. — [GitHub releases](https://github.com/Jermolene/TiddlyWiki5/releases)
- The official Markdown plugin uses **markdown-it**, with plugins for definition lists, footnotes, ins, mark, sub and sup. More markdown-it plugins can be loaded, and Markdown can be made the default tiddler type. The plugin folder contains `markdown-it-katex.js`, which suggests KaTeX math support (inferred from the file list, not stated in the readme). — [TiddlyWiki5 markdown plugin](https://github.com/Jermolene/TiddlyWiki5/tree/master/plugins/tiddlywiki/markdown)
- Saving via the File System Access API is documented on the official site but labelled "somewhat experimental", and it works in most Chromium browsers. TiddlyStow is an alternative: a standalone page that loads a local wiki file and writes it back to the same file in Chrome-based browsers. — [tiddlywiki.com: Saving with File System Access API](https://tiddlywiki.com/static/Saving%2520on%2520Browser%2520with%2520File%2520System%2520Access%2520API.html); [tiddlywiki.com: TiddlyStow](https://tiddlywiki.com/static/Saving%2520on%2520Browser%2520with%2520TiddlyStow.html)
- The community native-saver plugin works only in desktop Chromium (Chrome/Edge). Users report it asks for permission again each time the file is reopened. — [talk.tiddlywiki.org thread](https://talk.tiddlywiki.org/t/tw5-major-updates-to-chromium-native-file-system-saver-plugin/2288)

**Feather Wiki**
- It describes itself as "A 55.598 kilobyte quine": an HTML file that contains a self-replicating JS app plus the user's content. A "Bones" variant loads its CSS/JS from separate files. — [Codeberg repo](https://codeberg.org/Alamantus/FeatherWiki)
- Markdown is parsed by a customised md.js. Saving works two ways: a "Save Wiki Locally" download button, or a PUT to a WebDAV-capable server. The repo page does not mention the File System Access API. — [Codeberg repo](https://codeberg.org/Alamantus/FeatherWiki)
- The last version-bump commit is dated 2026-07-18, and there are 23 releases. License is **AGPL-3.0-or-later**; user content belongs to the user. — [Codeberg repo](https://codeberg.org/Alamantus/FeatherWiki)
- The official site describes it as a "tiny tool for simple, self-contained wikis". Auto-Save and Import/Export are extensions, not built in. — [feather.wiki](https://feather.wiki/)

**Markdeep (Morgan McGuire)**
- To use it, you add one script line to a plain-text `.md.html` file. It loads `markdeep.min.js` from a local copy or a CDN and works when double-clicked over file://. If neither the local copy nor the internet is available, it falls back to showing ASCII. It supports diagrams (ASCII-art style) and LaTeX math with equation numbering. The idea is to edit in any text editor and view in the browser. — [casual-effects.com/markdeep](https://casual-effects.com/markdeep/)
- The newest version I could verify is 1.16, packaged by Guix in April 2024; the site links to a "latest" path with no version number. A third-party directory lists the license as BSD-2-Clause, which I did not verify against the repo. — [Guix patch](https://patches.guix-patches.cbaines.net/comment/266311/); [AlternativeTo](https://alternativeto.net/software/markdeep/about)

**TeXMe (Susam Pal)**
- Lets you write self-rendering Markdown + LaTeX documents inside a `<textarea>` in an HTML file. It loads from the jsDelivr or unpkg CDN; the current version is 1.2.2. It can work offline if you self-host TeXMe, marked and MathJax locally. Math is rendered with MathJax. License is MIT. There is no editor and no saving. — [GitHub susam/texme](https://github.com/susam/texme)

**md-page (Oscar Morrison)**
- Adds a single script tag that turns Markdown written in the page into a webpage. The script is served from rawcdn.githack.com (pinned to a commit), so it needs network access unless you vendor it. MIT license, about 1.3k stars, 82 commits; no last-commit date was visible. — [GitHub oscarmorrison/md-page](https://github.com/oscarmorrison/md-page)

**Editor.md (pandao)**
- A split-pane Markdown editor component with flowchart and sequence-diagram syntax and KaTeX math; Mermaid is not mentioned. The license copyright reads "2015-2019 Pandao", which suggests it is effectively unmaintained. No releases are listed. Saving is designed around posting a form to a server. — [GitHub pandao/editor.md](https://github.com/pandao/editor.md)

**EdgeMD Viewer (0xedgelessblade)**
- Distraction-free viewer/editor in a single HTML file. It has a slide-out editor (Cmd+E) with real-time preview, Cmd+S writes back to the original .md via the File System Access API with access remembered, and there is a Zen mode. It is light theme only; dark mode is on the roadmap. — [GitHub edge-md-viewer](https://github.com/0xedgelessblade/edge-md-viewer)
- It advertises "Zero Dependencies", but it **loads marked.js and DOMPurify from cdnjs** (with SRI hashes), so it needs network access. It has 6 stars and only 2 commits. MIT license. It was added to the localhtmltools directory on 2026-05-14. — [GitHub edge-md-viewer](https://github.com/0xedgelessblade/edge-md-viewer); [localhtmltools listing](https://localhtmltools.lachlanallison.com/tool/edge-md-viewer/)

**Kapur Markdown Editor**
- Listed as a "single HTML file, zero dependencies, works offline" editor with syntax highlighting, live preview, GFM, open/save and HTML export. I only saw the directory listing; the source was not checked. — [localhtmltools listing](https://localhtmltools.lachlanallison.com/tool/kapur-markdown-editor/)

**orz-mdhtml (npm, v0.9.3)**
- A Node 18+ CLI (`npx orz-mdhtml`) that turns a .md file into a self-editing `.md.html` file. The output has a CodeMirror source editor with incremental live preview. On file:// in Chrome/Edge it saves in place via the File System Access API; elsewhere it downloads a copy. The Markdown source is embedded in the HTML and the whole document is re-serialised on save. It has KaTeX, Mermaid, charts and QR plugins, and 11 themes. — [orz-mdhtml SKILL.md (jsDelivr)](https://cdn.jsdelivr.net/npm/orz-mdhtml@0.9.3/orz-mdhtml-skills/SKILL.md)
- Even the `--inline` build (about 750 KB) still loads themes, editor and Mermaid/KaTeX from a CDN. Its own docs say "self-contained means a single file, not offline use", and warn that each file runs embedded JS, so open only trusted files. No license is stated in that doc. — [orz-mdhtml SKILL.md](https://cdn.jsdelivr.net/npm/orz-mdhtml@0.9.3/orz-mdhtml-skills/SKILL.md)

**Excluded or deprioritised (not single-file or need a server/build):** MARKus needs Node/Express; penflow is a Svelte PWA with a build step; MDPreview is a hosted web app (MIT, jonathanau/mdpreview) that works offline only once loaded. — [search summary sources: github.com/sil3ncer1/markus](https://github.com/sil3ncer1/markus); [github.com/SangeloDev/penflow](https://github.com/SangeloDev/penflow); [mdpreview](https://mdpreview.onrender.com/markdown-editor). "Writemark" (featured on the HN front page, July 2026) is a dependency-free web component for inline Markdown editing, not a standalone viewer. — [Nostr mirror of HN post](https://nostr.ae/nevent1qqst59epl6fj6kfllu2j6wzxpftt3g937v26dp4kp9fk68z0lf4jefczyzygnwgts60cdgh975tfqgtvjvn2xfduknhw6pr4e6y4v5qrpdhqjqsdqja)

**Platform constraint shared by everyone:** Firefox and Safari do not support the File System Access API, while most Chromium browsers on Windows, macOS, ChromeOS, Linux and Android do. This is from a 2024 article, so check it is still current. — [Chrome Developers: File System Access](https://developer.chrome.com/articles/file-system-access/)

### Inferences
- **The only candidates that edit an external .md file and save it back in place are EdgeMD Viewer and orz-mdhtml output.** orz-mdhtml embeds the .md inside the HTML, so its "file" is the .md.html, not your repo's .md. Neither is offline-clean.
- **TiddlyWiki and Feather Wiki solve a different problem:** a personal wiki stored inside one HTML file. They do not view or edit a folder of .md files in a git repo, so the clean-git-diff workflow does not apply to them.
- **Markdeep, TeXMe, md-page and strapdown** are document formats: you write the .md inside an HTML wrapper. They have no editor, saving, tabs or folder browsing.
- **Maintenance:** TiddlyWiki (2026 release) and Feather Wiki (July 2026 commit) are clearly alive. Editor.md looks dormant since about 2019. EdgeMD is a 2-commit hobby project. For Markdeep, TeXMe and md-page I could not confirm recent activity.

### Gaps
- strapdown.js, Showdown-based editors, "Notebook.html" and mdBook were not checked individually (tool-call budget). mdBook needs a build step plus a static output folder, so it is out of scope anyway.
- No last-commit dates were found for Markdeep, TeXMe, md-page, Editor.md or EdgeMD.
- Kapur's source and author were not examined. Its "zero dependencies" claim is unverified; EdgeMD's similar claim turned out to be false.
- I did not verify whether Feather Wiki's Markdown is in all builds or only some (it has multiple build variants).
- TiddlyWiki Mermaid support: community plugins likely exist, but I did not verify them.

## In what concrete respects is any of them better or worse than Northern Lights?

### Takeaway
Where the others beat Northern Lights:
- **TiddlyWiki:** maturity, plugin ecosystem, community, and math.
- **Markdeep and TeXMe:** math and LaTeX.
- **orz-mdhtml:** KaTeX and charts, and a CodeMirror editor.
- **Feather Wiki:** tiny size (about 56 KB).
- **Markdeep/TeXMe/md-page:** they render in any browser, including Firefox and Safari.

Where Northern Lights is better than every candidate found:
- Clean partial-splice edits of external .md files
- Offline Mermaid
- Reading-ergonomics controls
- Folder browsing and connect-folder
- Interactive tables
- A Markdown fixer
- Script-free HTML export

### Cited Findings
- **Better (TiddlyWiki):** It has more than a decade of maturity, an extensible markdown-it pipeline (more plugins can be loaded), probable KaTeX, and an active forum with saver plugins. — [TiddlyWiki markdown plugin](https://github.com/Jermolene/TiddlyWiki5/tree/master/plugins/tiddlywiki/markdown); [talk.tiddlywiki.org](https://talk.tiddlywiki.org/t/tw5-major-updates-to-chromium-native-file-system-saver-plugin/2288)
- **Worse (TiddlyWiki):** Content lives in tiddlers inside the wiki file, not in standalone .md files. File System Access saving is labelled experimental and asks for permission again on each reopen. — [tiddlywiki.com FSA saver](https://tiddlywiki.com/static/Saving%2520on%2520Browser%2520with%2520File%2520System%2520Access%2520API.html); [forum](https://talk.tiddlywiki.org/t/tw5-major-updates-to-chromium-native-file-system-saver-plugin/2288)
- **Better (Feather Wiki):** About 55.6 KB versus Northern Lights' roughly 270 KB plus Mermaid. It can save to a WebDAV server. **Worse:** Local saving is download-only (no in-place write found), it uses an AGPL license, and its content is internal, not .md files. — [Codeberg](https://codeberg.org/Alamantus/FeatherWiki)
- **Better (Markdeep):** LaTeX math with numbering, ASCII-art diagrams, and rendering in any browser from file://. **Worse:** No editor, saving, tabs or folder support. Without a local copy it needs a CDN, and the file must be wrapped as .md.html. — [Markdeep](https://casual-effects.com/markdeep/)
- **Better (TeXMe):** Strong MathJax LaTeX. **Worse:** CDN by default; it is a viewer-only wrapper with no editing. — [TeXMe](https://github.com/susam/texme)
- **Better (orz-mdhtml):** KaTeX, Mermaid, charts, 11 themes, a CodeMirror editor, and copy-as-Markdown. **Worse:** Requires Node to generate files, requires internet to view, re-serialises the whole document (no line-level splice), and its own docs flag a security caveat about embedded JS. — [orz-mdhtml SKILL.md](https://cdn.jsdelivr.net/npm/orz-mdhtml@0.9.3/orz-mdhtml-skills/SKILL.md)
- **Better (EdgeMD):** Simpler, with keyboard-first Zen mode. **Worse:** CDN-loaded parser and sanitizer, no dark mode, no Mermaid or syntax highlighting mentioned, 2 commits. Its editor is a whole-file slide-out, not block-level editing. — [edge-md-viewer](https://github.com/0xedgelessblade/edge-md-viewer)
- **Better (Editor.md):** KaTeX plus flowchart and sequence diagrams in a split editor. **Worse:** Designed to post to a server, dormant since about 2019, and file:// behaviour is undocumented. — [editor.md](https://github.com/pandao/editor.md)

### Inferences
- **Math is the clearest feature gap for Northern Lights.** Markdeep, TeXMe, orz-mdhtml, Editor.md and probably TiddlyWiki all offer LaTeX/KaTeX; Northern Lights lists none.
- **Cross-browser saving is a gap for everyone.** File System Access write-back is Chromium-only, so no candidate beats Northern Lights on in-place saving in Firefox or Safari. The only alternatives are download or WebDAV.
- **None of the candidates offers true WYSIWYG editing, real-time collaboration, or a mobile-optimised UI.** Northern Lights' click-a-block edit-in-place is arguably the closest to WYSIWYG among them.
- **Community and maturity is where Northern Lights is weakest.** It is a one-person project; TiddlyWiki has a long-running ecosystem.

### Gaps
- I did not run hands-on tests of mobile behaviour for any candidate.
- I found no independent reviews comparing these specific single-file tools head to head.

## Would each pass a strict "no IT approval" corporate bar (nothing executable, no install, no network)?

### Takeaway
Only TiddlyWiki and Feather Wiki clearly pass as shipped. Markdeep and TeXMe (and probably md-page) pass only after you vendor their scripts locally. EdgeMD and orz-mdhtml fail because they need the network, and orz-mdhtml also needs Node to create files. Kapur is unverified.

### Cited Findings
- **TiddlyWiki:** a single HTML file with no network needed; saving in place needs Chromium plus the experimental File System Access saver or TiddlyStow. — [tiddlywiki.com FSA](https://tiddlywiki.com/static/Saving%2520on%2520Browser%2520with%2520File%2520System%2520Access%2520API.html)
- **Feather Wiki:** a single self-contained file; saving is a download. — [Codeberg](https://codeberg.org/Alamantus/FeatherWiki)
- **Markdeep:** works from file:// with a local copy of markdeep.min.js; without one it needs a CDN. — [Markdeep](https://casual-effects.com/markdeep/)
- **TeXMe:** CDN by default; self-hosting TeXMe, marked and MathJax locally makes it offline. — [TeXMe](https://github.com/susam/texme)
- **md-page:** the script comes from rawcdn.githack.com. — [md-page](https://github.com/oscarmorrison/md-page)
- **EdgeMD:** marked and DOMPurify load from cdnjs, so it fails the no-network bar as shipped. — [edge-md-viewer](https://github.com/0xedgelessblade/edge-md-viewer)
- **orz-mdhtml:** Node 18+ is needed to generate files, and viewing needs internet access even with `--inline`. — [SKILL.md](https://cdn.jsdelivr.net/npm/orz-mdhtml@0.9.3/orz-mdhtml-skills/SKILL.md)

### Inferences
- All browser-based tools, Northern Lights included, run JavaScript inside the browser sandbox. "Nothing executable" here means no .exe and no install, which is the same footing for all of them. Strict IT policies that block file:// JavaScript or File System Access via group policy would affect every candidate equally.
- Any CDN-loading tool can be made offline by vendoring its dependencies, but then it is no longer "download one file and go". Northern Lights' main differentiator is that it is already vendored, including Mermaid.

### Gaps
- I did not verify whether Chrome/Edge enterprise policies commonly disable the File System Access API (relevant to every candidate's write-back).
