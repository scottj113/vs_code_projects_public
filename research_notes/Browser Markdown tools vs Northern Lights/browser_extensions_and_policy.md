# Browser Markdown Extensions (Chrome/Edge) vs Northern Lights, and Corporate Extension Policy

Research date: 2026-10-10. Store numbers come from live Chrome Web Store fetches on this date unless noted. Aggregator figures (extscope, extensionauditor, chromeboard) lag the store and are flagged as such.

## Q1. What are the leading Markdown extensions, and what can they do (features, editing, permissions, maintenance, users/ratings)?

### Takeaway
Five extensions matter. Markdown Viewer (simov) is the most installed (500K users) and open source, but its store listing has not been updated since May 2024. Markdown Reader (100K) and Markdown Preview Plus (90K) are actively maintained. MarkView (20K, 5.0 stars, updated Sept 2026) has the most features. All of them view only: none edits Markdown or saves back to the original file. Every one needs the user to turn on the off-by-default "Allow access to file URLs" toggle before it can open local files. Markdown Here is a different kind of tool (Markdown-to-HTML in email compose windows), not a file viewer.

### Cited Findings

**Markdown Viewer (simov), ID ckkdlimhmcjmikdlpkmbgfkaikojcbjk**
- 500,000 users; 4.3/5 from 427 ratings; version 5.3; last updated **May 2, 2024**. That date may be stale or may mean the project has slowed. — [Chrome Web Store](https://chromewebstore.google.com/detail/markdown-viewer/ckkdlimhmcjmikdlpkmbgfkaikojcbjk)
- MIT licensed; GitHub shows 473 commits, ~1.7k stars, 231 forks, 88 open issues, and no published GitHub releases. — [GitHub simov/markdown-viewer](https://github.com/simov/markdown-viewer)
- Parsers: markdown-it, marked, or remark, each with options (footnotes, deflist, tasklists, abbr, sub/sup, mark, typographer, raw `html` on by default, linkify). Code highlighting via Prism; GFM. — [GitHub](https://github.com/simov/markdown-viewer)
- 30+ themes including github / github-dark and cleanrmd; content width presets (tiny 576px to full); custom uploaded themes up to 8 KB. — [GitHub](https://github.com/simov/markdown-viewer)
- Mermaid (resize by dragging, Shift+wheel zoom, drag to pan); MathJax (`$…$`, `$$…$$`, `\(...\)`, `\[...\]`); TOC from headers (off by default); emoji shortnames; remembers scroll position; raw/rendered toggle; settings sync. — [GitHub](https://github.com/simov/markdown-viewer)
- Autoreload is off by default. When on, it **polls the file every second**, only on `file:///` URLs and localhost. — [GitHub](https://github.com/simov/markdown-viewer)
- Permissions: "No content access by default." Users grant remote origins one at a time (wildcards allowed) or "Allow All" (`*://*`). Local files need "Allow access to file URLs" turned on in chrome://extensions → Details. Content is detected per origin by header (`text/markdown`, `text/x-markdown`, `text/plain`) and by a path regex. — [GitHub](https://github.com/simov/markdown-viewer)
- The README and store page mention no export/save and no editing. It is a viewer only. — [GitHub](https://github.com/simov/markdown-viewer); [Chrome Web Store](https://chromewebstore.google.com/detail/markdown-viewer/ckkdlimhmcjmikdlpkmbgfkaikojcbjk)

**Markdown Reader, ID medapdbncneneejhbgcjceippjlfkmkg**
- About 100,000 users; 4.7/5 from 132 ratings; version 3.6.31; updated **Oct 4, 2026**; "Featured" badge; 11.6 MiB; developer site md-reader.github.io. — [Chrome Web Store](https://chromewebstore.google.com/detail/medapdbncneneejhbgcjceippjlfkmkg)
- Opens http, https, and file:// sources with .md, .mkd, .mdx, .markdown extensions. Features: math, flowcharts, Gantt charts, TOC, emoji, sub/sup, checkboxes, abbreviations; dark/light themes; code highlighting; "real-time refreshing"; sidebar TOC; view of the original source; image preview; keyboard shortcuts. — [Chrome Web Store](https://chromewebstore.google.com/detail/medapdbncneneejhbgcjceippjlfkmkg)
- Local files need "Allow access to file URLs" turned on. The listing mentions no export or editing. Developer says no user data is collected. — [Chrome Web Store](https://chromewebstore.google.com/detail/medapdbncneneejhbgcjceippjlfkmkg)
- Aggregators show older figures (v3.6.7–3.6.9, 88–92 reviews), which illustrates how far they lag. — [Extension Auditor](https://extensionauditor.com/scan/markdown-reader-medapdbncneneejhbgcjceippjlfkmkg); [ExtScope](https://www.extscope.org/extension/medapdbncneneejhbgcjceippjlfkmkg)

**Markdown Preview Plus, ID febilkbfcbhebfnokafefeacimjdckgl**
- 90,000 users; 4.1/5 from 236 ratings; version 0.8.16; updated **June 8, 2026**; open source. — [Chrome Web Store](https://chromewebstore.google.com/detail/febilkbfcbhebfnokafefeacimjdckgl)
- Features: GFM, KaTeX, Mermaid, TOC, live reload (off by default), external CSS, per-file themes, "Export nicely formatted HTML." No editing. Local files need "Allow access to file URLs." — [Chrome Web Store](https://chromewebstore.google.com/detail/febilkbfcbhebfnokafefeacimjdckgl)

**MarkView: Markdown Viewer with Mermaid Diagrams, Math & Export, ID cfopbpknalachedpcddhgbgjoigklien**
- 20,000 users; 5.0/5 from 89 ratings; version 3.0.4; updated **Sept 27, 2026**; "Featured" and "Follows recommended practices" badges; 3.66 MiB; 19 UI languages; developer site getmarkview.com. — [Chrome Web Store](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien)
- Features: export to DOCX, HTML, and PDF (through browser print); presentation/slide mode with speaker notes; mind map (SVG/PNG/JPEG); annotations (highlight/underline/comment) that persist into print and exports; folder browser, bookmarks, and full-text search across a folder; live auto-refresh; Mermaid, PlantUML, Graphviz, and WaveDrom; KaTeX; TOC; sticky table headers; copy buttons on code blocks; image lightbox; word count and reading time; raw/rendered toggle; recent documents; RTL; renders .txt as Markdown. — [Chrome Web Store](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien)
- The listing mentions no editing of the Markdown source and no saving back to the file. — [Chrome Web Store](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien)
- Permissions: Storage, ActiveTab, Downloads (for export), File URLs (off by default), and **host permissions to render raw Markdown on any site you open**. PlantUML can use a remote server, but that option is off by default and requires consent. No telemetry is claimed. ExtScope labels it "High-risk permissions" and "Paid features detected", which conflicts with the store listing, where no paid tier appears. — [Chrome Web Store](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien); [ExtScope](https://extscope.org/extension/cfopbpknalachedpcddhgbgjoigklien)
- It does not activate on sites that already render Markdown (GitHub blob pages, ReadTheDocs, GitBook), but it does work on raw URLs. — [Chrome Web Store](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien)
- I could not find a public source repo. GitHub only has a support repo (markdown-app/support). — [Chrome Web Store](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien)

**Markdown Here (adam-p)**
- A compose-time tool: you write email in Markdown in Gmail, Outlook.com/Hotmail, Yahoo, Google Groups, Blogger, Evernote, or WordPress and render it before sending. It is **not a local file viewer**. Supports Chrome, Firefox, Opera, and Thunderbird. GitHub: 852 commits, 302 open issues, no published releases. I did not confirm its Manifest V3 status. — [GitHub adam-p/markdown-here](https://github.com/adam-p/markdown-here)

**Smaller 2025–2026 entrants (low install counts, aggregator data only)**
- "Markdown Viewer" v1.2.1 (May 2026; GFM, Mermaid, TOC, HTML/PDF export, GitHub/GitLab/Bitbucket URLs) has about 53 users. "MD Viewer Pro" v1.1.2 (Jan 2026; file tree, scroll-spy TOC, Mermaid, standalone HTML export) has about 168 users. iafan's "Markdown Viewer" v1.0.2 (Feb 2026; frontmatter, themes) has about 46 users. — [chromeboard (Markdown Viewer)](https://chromeboard.com/extension/markdown-viewer-omadmgibipiacmehagkeencnidfjnnbd); [chromeboard (MD Viewer Pro)](https://chromeboard.com/extension/md-viewer-pro-gldjnpeaodkapkmkoljmaholndeogemk); [chromeboard (Markdown Viewer, iafan)](https://chromeboard.com/extension/markdown-viewer-lbllebpimjnbbcamgfmaaooafpoglahk)
- A macmdviewer.com roundup names a free Markdown Viewer Chrome extension as its pick. It is a vendor blog for a Mac app, so treat it as weak evidence. — [macmdviewer.com](https://macmdviewer.com/blog/best-markdown-viewer)

### Inferences
- **The strongest picks by category:** simov's Markdown Viewer for reach, open source, and granular permissions (but check maintenance). MarkView for features: folders, exports, diagrams, annotations. Markdown Reader for an actively maintained, highly rated mid-weight option.
- **None of the five edits Markdown source or saves back to the original file.** "Saving" in these tools means exporting a new file. MarkView's Downloads permission points to the downloads mechanism, so output lands as a new file rather than overwriting the original. That is an inference from the permission list.
- Extensions that use polling-based autoreload (simov polls every 1 s) can watch a file:// URL without the user picking it. The browser loads the URL and the extension re-fetches it.

### Gaps
- I did not fetch the Edge Add-ons listings. I could not confirm which of these extensions are published natively on Edge Add-ons or what their counts are there. Edge can also install from the Chrome Web Store, but I did not source that here.
- I could not confirm simov's Markdown Viewer maintenance status beyond the May 2024 store date. No GitHub release dates are published, and I did not check commit dates.
- I did not view the exact manifest permission strings (for example, whether any extension shows the install-time warning "Read and change all your data on all websites"). MarkView's host permissions for "any site" suggest it would show a broad warning. That is unverified.
- I found no reputable 2026 head-to-head review of these extensions.

## Q2. Where is an extension better than a single HTML file, and where is Northern Lights better?

### Takeaway
Extensions do better at **zero-friction opening**. You double-click a .md file or drag it into the browser, or navigate to a raw URL, and it renders at its own file:// or https URL. Autoreload works without a file picker, and raw Markdown on the web renders too. MarkView also adds things Northern Lights lacks: DOCX export, slides, mind maps, PlantUML/Graphviz, and KaTeX math. Northern Lights does better at **everything that writes**: block, section, and source editing, saving in place, regex replace, and the syntax fixer. It also needs **no install, no permission toggle, and no store trust decision**, and it has richer tables and readability controls.

### Cited Findings
- Extensions render a .md opened directly at its file:// URL once file access is allowed. This works with drag and drop, File → Open, or clicking a link. — [MarkView listing](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien); [simov README](https://github.com/simov/markdown-viewer)
- Extensions render remote and raw Markdown URLs. simov handles any origin you grant, matched by content-type header or path regex. MarkView handles raw GitHub URLs. — [simov README](https://github.com/simov/markdown-viewer); [MarkView listing](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien)
- simov's autoreload polls file:// every second, with no file-picker step. — [simov README](https://github.com/simov/markdown-viewer)
- Features in extensions that are not in the Northern Lights baseline:
  - Math: MathJax in simov, KaTeX in MarkView and Preview Plus.
  - Diagrams beyond Mermaid: PlantUML, Graphviz, and WaveDrom in MarkView.
  - DOCX export, presentation mode, mind maps, and annotations in MarkView.
  - Full-text search across a folder in MarkView.
  - Choice of parser engine in simov.
  - 30+ themes plus custom CSS in simov.

  Sources: [simov README](https://github.com/simov/markdown-viewer); [MarkView listing](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien); [Markdown Preview Plus listing](https://chromewebstore.google.com/detail/febilkbfcbhebfnokafefeacimjdckgl)
- None of the leading listings advertise editing or writing back to the source file. — [simov](https://github.com/simov/markdown-viewer); [Markdown Reader](https://chromewebstore.google.com/detail/medapdbncneneejhbgcjceippjlfkmkg); [Preview Plus](https://chromewebstore.google.com/detail/febilkbfcbhebfnokafefeacimjdckgl); [MarkView](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien)
- Each extension needs a user to install it, then turn on the off-by-default "Allow access to file URLs" toggle before it works on local files. — [Markdown Reader](https://chromewebstore.google.com/detail/medapdbncneneejhbgcjceippjlfkmkg); [Preview Plus](https://chromewebstore.google.com/detail/febilkbfcbhebfnokafefeacimjdckgl); [MarkView](https://chromewebstore.google.com/detail/cfopbpknalachedpcddhgbgjoigklien); [simov](https://github.com/simov/markdown-viewer)

### Inferences
- **Extension advantages:**
  - Opening a file is the browser's native action: double-click (if .md is associated with the browser), drag in, or a link.
  - You can open any number of .md files without a picker.
  - Relative images resolve naturally, because the page lives at the file's own URL. Northern Lights needs "connect folder" for this.
  - Raw Markdown on the web renders.
  - Math and the extra diagram types.
  - DOCX export (MarkView only).
- **Northern Lights advantages:**
  - Editing: click-a-block edits that splice only the changed lines, section edit, source view, and regex find & replace.
  - Saving straight to the original file through the File System Access API.
  - The Markdown syntax fixer.
  - Interactive tables (sort, filter, hide, CSV/JSON export).
  - 12 contrast-validated palettes; text scaling (65–260%) that leaves the UI unzoomed; reading margins.
  - Tabs remembered across sessions.
  - Standalone HTML export with no scripts.
  - An allow-list HTML sanitizer. simov renders raw HTML by default (`html: true`); I did not document its sanitizing behavior.
  - No install, no permission grant, no auto-updates from a third party. Updates are a supply-chain risk for extensions; that is a general inference, not sourced here.
  - It is a single file you can inspect.
- **Overlap:** TOC, Mermaid, syntax highlighting, themes, autoreload, folder browsing (MarkView), and HTML export (Preview Plus, MarkView) all exist in both camps.

### Gaps
- I did not test how well each extension handles raw HTML sanitizing, or how well it handles large files.
- I did not verify whether any extension resolves relative images or links across folders differently from plain file:// behavior.

## Q3. Corporate reality: would installing an extension pass a strict "no IT approval" bar? What policies could affect Northern Lights itself?

### Takeaway
Out of the box, Chrome's and Edge's default `installation_mode` is "allowed". On an **unmanaged or lightly managed** browser, a user can install a store extension without IT. Locked-down organizations commonly run **default-deny**: `ExtensionInstallBlocklist = *` plus an allowlist, or `ExtensionSettings` with blocked permissions. There, installing an extension *is* by definition an IT-approval event. Even where installs are allowed, the user must also turn on file:// access. So **an extension does not meet a strict "no IT approval" bar**, while a self-contained HTML file opened from disk involves no install. Northern Lights is not immune to policy, though. `DefaultFileSystemWriteGuardSetting = 2` blocks every site from asking for write access, which would disable saving in place. The site-specific FileSystem*BlockedForUrls lists could do the same if they match its file:// origin. Viewing would still work.

### Cited Findings
- ExtensionSettings `installation_mode` values are allowed (**the default**), blocked, force_installed, normal_installed, and removed (removed also uninstalls; Chrome 75+). — [Google: Configure ExtensionSettings policy](https://support.google.com/chrome/a/answer/9867568?hl=en)
- `blocked_permissions`: extensions that require a blocked permission won't install, and existing copies stop loading. `runtime_blocked_hosts` / `runtime_allowed_hosts` stop extensions from injecting scripts, reading cookies, or modifying requests on listed sites (max 100 patterns). `allowed_types` and `install_sources` can only be set on the `*` default. `blocked_install_message` customizes the error. `minimum_version_required` disables outdated versions. — [Google: Configure ExtensionSettings policy](https://support.google.com/chrome/a/answer/9867568?hl=en)
- `file_url_navigation_allowed` (Chrome 119+) is an ExtensionSettings field that "allows extensions to navigate to specified file URLs." A Chromium-extensions thread reports that it must be set per extension ID. One commenter's claim that it is deprecated is unverified and conflicts with the official page. — [Google: Configure ExtensionSettings policy](https://support.google.com/chrome/a/answer/9867568?hl=en); [chromium-extensions group thread](https://groups.google.com/a/chromium.org/g/chromium-extensions/c/ZtCvVISQU54/m/tOjjlzkfAgAJ)
- Edge: setting `ExtensionInstallBlocklist` to `*` blocks every extension install. Combine it with `ExtensionInstallAllowlist` to allow only specific ones. Blocklisting an installed extension disables it, and the user can't re-enable it. `ExtensionSettings` can block by permission and can block an entire store by its update_url (for example, the Chrome Web Store). `ExtensionInstallForcelist` silently installs extensions that users can't remove, and it overrides the blocklist. — [Microsoft Learn: Use group policies to manage Microsoft Edge extensions](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-manage-extensions-policies) (updated 2026-06-15)
- Security vendors recommend "deny by default", meaning only vetted extension IDs are allowed. Palo Alto calls "Block-First (Default Deny)" the most secure posture. — [Island](https://www.island.io/browser-extension-security/browser-extension-security-defending-against-installation-behavior-patterns); [Palo Alto Networks Prisma Browser docs](https://docs.paloaltonetworks.com/prisma-browser/administration/manage-prisma-browser-extensions/browser-extension-security-best-practices) (vendor sources)
- A LayerX 2025 report reportedly found that 99% of enterprise employees have at least one extension and 52% have more than ten. I saw this only through a secondary article and could not verify it. — [algeriatech.news](https://algeriatech.news/?p=20223)
- **Policies that could affect Northern Lights:**
  - `DefaultFileSystemWriteGuardSetting`: 2 means "Don't allow any site to request write access to files and directories"; 3 means ask. If it is unset, sites can ask and users can change the setting. Edge 86+ on Windows and macOS. — [Microsoft Learn: DefaultFileSystemWriteGuardSetting](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultfilesystemwriteguardsetting)
  - `FileSystemWriteBlockedForUrls` lists URL patterns that "can't ask users to grant them write access." `*` is not accepted. If it is unset, the default guard setting applies. It can't overlap with `FileSystemWriteAskForUrls`. Edge 86+. The read counterparts are `DefaultFileSystemReadGuardSetting`, `FileSystemReadAskForUrls`, and `FileSystemReadBlockedForUrls`. — [Microsoft Learn: FileSystemWriteBlockedForUrls](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/filesystemwriteblockedforurls)
  - `URLBlocklist` blocks URL patterns (1,000-entry limit; supports `custom_scheme:*` and `*`), but Microsoft notes that it "**doesn't work as expected with file://\* wildcards.**" — [Microsoft Learn: URLBlocklist](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/urlblocklist) (updated 2026-10-01)

### Inferences
- **Verdict for extensions under a strict "no IT approval" bar:** an extension doesn't pass. Where policy blocks or allowlists installs, adding a Markdown extension needs an admin to allowlist or force-install it. Where installs are technically allowed, it is still installed software that runs with browser permissions and auto-updates. Many corporate acceptable-use rules treat that as needing approval, though I did not source a specific policy text. Flipping "Allow access to file URLs" is a second, separate grant.
- **Northern Lights' policy exposure:**
  - Viewing a local HTML file is ordinary browser use.
  - The main risk is `DefaultFileSystemWriteGuardSetting = 2`, or the read equivalent set to 2. That disables saving in place and could disable folder or file picking through the API. Northern Lights could still view files through `<input type=file>` or drag and drop, unless `AllowFileSelectionDialogs` is disabled. That last policy is not verified here.
  - Blocking file:// URLs outright is possible in principle, but Microsoft documents that file:// wildcards in URLBlocklist behave unreliably.
- Managed setups like the Edge management service and Chrome Enterprise Core make default-deny easy to roll out, so expect it in regulated industries (finance, healthcare, government). That is an inference; I have no prevalence statistic.

### Gaps
- I could not fetch the Chrome Enterprise policy list page, which renders client-side. The FileSystem* policy descriptions above come from Microsoft's Edge docs. The Chrome equivalents share the same names, but I did not quote them directly.
- I did not verify whether content-setting URL patterns such as `file:///*` can target the file:// origin in FileSystem*BlockedForUrls. That decides whether an admin could block Northern Lights' saving specifically, rather than for all sites.
- I did not verify whether `AllowFileSelectionDialogs = false` breaks `showOpenFilePicker` / `showDirectoryPicker`. That is likely but unconfirmed.
- I found no reliable statistic on what share of enterprises run default-deny extension policies.
- I did not source a policy that controls the per-extension "Allow access to file URLs" toggle, apart from `file_url_navigation_allowed`, whose scope is navigation only.
