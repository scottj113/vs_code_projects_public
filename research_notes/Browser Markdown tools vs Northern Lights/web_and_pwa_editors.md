# Browser-based Markdown editors (web apps, PWAs, browser IDEs) vs Northern Lights MD Viewer

Research date: 2026-10-10. GitHub star counts and push dates were pulled live from the GitHub REST API on that date. Some feature details for older tools come from secondary sources and are flagged.

## Deployment model and data handling: hosted, PWA, self-hosted, or offline?

### Takeaway
Most "online Markdown editors" are hosted sites whose primary storage is browser storage plus OAuth cloud sync (StackEdit, Dillinger), or server-backed collaboration (HackMD, HedgeDoc, SilverBullet). Only vscode.dev and a long tail of small, recent single-purpose apps edit real local files in place with no server. All of them are loaded from a third-party origin over the network, so none has Northern Lights' "one file on disk, no network" property unless you self-host.

### Cited Findings
**vscode.dev / github.dev (Microsoft)**
- vscode.dev can create or open local files and projects. Opening a local *folder* needs the File System API, which Edge and Chrome support. Other browsers can open single files only. — [VS Code for the Web docs](https://code.visualstudio.com/docs/setup/vscode-web)
- There is no terminal or debugger. Only some extensions run in the browser: declarative ones (themes, snippets) work, and code-running extensions have to be adapted. — [VS Code for the Web docs](https://code.visualstudio.com/docs/setup/vscode-web)
- Remote repos (github.dev) aren't cloned. Code is loaded through the hosting service's APIs. Uncommitted work and installed extensions live in browser local storage. Settings Sync and "Cloud Changes" (Continue Working On) can store data in Microsoft services. — [VS Code for the Web docs](https://code.visualstudio.com/docs/setup/vscode-web)
- The docs don't say whether vscode.dev works offline or as an installed PWA, and they don't cover vscode.dev telemetry. — [VS Code for the Web docs](https://code.visualstudio.com/docs/setup/vscode-web)
- Desktop VS Code telemetry can be disabled centrally with a TelemetryLevel policy. That page covers desktop only, not vscode.dev. — [VS Code enterprise telemetry](https://code.visualstudio.com/docs/enterprise/telemetry)
- A GitLab issue reports that the VS Code-based Web IDE's service-worker setup calls an external URL and fails on air-gapped or offline instances. — [GitLab issue 414493](https://gitlab.com/gitlab-org/gitlab/-/issues/414493)

**StackEdit**
- It is hosted at stackedit.io and can be self-hosted (Helm chart for Kubernetes, Dockerfile, npm build). Integrations: Google Drive, Dropbox, GitHub, GitLab, Gist, Blogger, WordPress, Zendesk, CouchDB. — [StackEdit GitHub](https://github.com/benweet/stackedit)
- Repo: 23,094 stars. Last push 2023-07-04. Latest GitHub release v5.14.0 dated 2019-07-02. Not archived. — [GitHub API](https://api.github.com/repos/benweet/stackedit)
- Secondary sources describe KaTeX math, Mermaid diagrams, PWA offline use, an IndexedDB-backed local file explorer, and Google "workspace sync" vs per-file sync to Drive, Dropbox or GitHub. These are mostly copies of StackEdit docs and are undated. — [TrustRadius](https://www.trustradius.com/products/stackedit/details); [Algolia DocSearch mirror of StackEdit docs](https://docsearch.algolia.com/mcp/docs/repo/benweet/stackedit)
- A comparison table (published by a competitor) lists StackEdit as "No" for saving in place to local files: it uses browser storage plus cloud sync and publishing. — [NoteLoom blog (vendor, conflict of interest)](https://noteloom.cc/blog/browser-based-local-first-markdown-editors/)

**Dillinger**
- It has been rebuilt on Next.js 14, Monaco, Tailwind and Zustand. It offers OAuth integrations with Dropbox, GitHub, Google Drive, OneDrive and Bitbucket, drag-and-drop import of .md/.txt/.markdown, local auto-save, and export to MD, HTML and PDF. It self-hosts as a Node app (`npm run build && npm start`). — [Dillinger GitHub](https://github.com/joemccann/dillinger)
- The dillinger.io page says no signup is needed, drafts persist in browser local storage, and the editor keeps working without a network after first load. It mentions no File System Access API, Mermaid or KaTeX, and has no privacy statement. — [dillinger.io](https://dillinger.io/)
- Repo: 8,292 stars, last push 2026-06-21 (active). The only GitHub "release" is 3.5.1 from 2016, so releases aren't used. — [GitHub API](https://api.github.com/repos/joemccann/dillinger)

**HedgeDoc / CodiMD / HackMD (server-backed collaboration)**
- HedgeDoc makes "real-time collaborative markdown notes" and needs a self-hosted server. 1.x is stable but maintenance-only, with no feature PRs accepted. 2.0 is a ground-up rewrite (separate backend and frontend), not feature-complete, with an alpha demo at hedgedoc.dev. — [HedgeDoc GitHub](https://github.com/hedgedoc/hedgedoc)
- HedgeDoc: 7,475 stars. Latest release 1.12.0 on 2026-08-21. Last push 2026-10-09. — [GitHub API](https://api.github.com/repos/hedgedoc/hedgedoc); [releases](https://api.github.com/repos/hedgedoc/hedgedoc/releases/latest)
- hackmdio/codimd: 10,155 stars, last push 2025-10-02 (slowing). — [GitHub API](https://api.github.com/repos/hackmdio/codimd)
- HackMD is a cloud service that stores notes on its servers and does not save in place to local files. — [NoteLoom blog (vendor)](https://noteloom.cc/blog/browser-based-local-first-markdown-editors/)

**SilverBullet**
- It is a self-hosted server plus browser client, described as "offline-first". The server owns the folder, so a browser alone can't edit local files. — [NoteLoom blog (vendor)](https://noteloom.cc/blog/browser-based-local-first-markdown-editors/)
- 6,283 stars. Release 2.12.0 on 2026-10-06 (very active). — [GitHub API](https://api.github.com/repos/silverbulletmd/silverbullet); [releases](https://api.github.com/repos/silverbulletmd/silverbullet/releases/latest)

**Editor frameworks (not end-user apps)**
- Milkdown: 11,982 stars, release v7.22.3 on 2026-10-10 (very active). — [GitHub API](https://api.github.com/repos/Milkdown/milkdown)
- TipTap: 38,680 stars, active (push 2026-10-09). — [GitHub API](https://api.github.com/repos/ueberdosis/tiptap)
- Toast UI Editor (nhn/tui.editor): 18,000 stars. **Archived**, with last push 2024-08-01 and last release editor@3.2.2 on 2023-02-24. — [GitHub API](https://api.github.com/repos/nhn/tui.editor); [releases](https://api.github.com/repos/nhn/tui.editor/releases/latest)
- ByteMD (now pd4d10/bytemd): 1,374 stars. Last release v1.22.0 on 2025-02-12, dormant since. — [GitHub API](https://api.github.com/repos/bytedance/bytemd)

**Notion-like / local-first apps (adjacent)**
- AFFiNE: 73,372 stars. Logseq: 45,205. TriliumNext: 38,272. Memos: 63,679. Excalidraw: 133,615. All active as of Oct 2026. — [GitHub API AFFiNE](https://api.github.com/repos/toeverything/AFFiNE); [Logseq](https://api.github.com/repos/logseq/logseq); [Trilium](https://api.github.com/repos/TriliumNext/Trilium); [Memos](https://api.github.com/repos/usememos/memos); [Excalidraw](https://api.github.com/repos/excalidraw/excalidraw)

**2025–2026 File System Access API entrants (long tail)**
- A NoteLoom vendor article (19 Jul 2026, updated 1 Sep 2026) lists browser apps that save in place via FSA: NoteLoom, Accrete (PWA, offline after load, LaTeX math, Chromium only), EzyMarkdown, HermesMarkdown (bring-your-own-key AI), hotnote, mdread, Browsidian, Chore.md, files.md, and VS Code for the Web. Markdown Studio is a PWA with Mermaid that saves one file in place on Chromium. The article is written by NoteLoom's maker, which it admits, so the ratings are unverified. — [NoteLoom blog](https://noteloom.cc/blog/browser-based-local-first-markdown-editors/)
- GitHub FSA-based Markdown editors are almost all tiny and new: SimplyMarkdownEditor (4 stars, created Jun 2026), menusal/markdown-editor (0 stars, created Oct 2026), vladzima/mdd (10 stars, local folder or SSH server, Aug 2026), MoizDev/browserMarkdownEditor (2 stars), wsimps6i/markdown-editor-web (0 stars), nico-martin/markdown-editor (66 stars, on-device AI, dormant since Dec 2024). — [GitHub API results](https://api.github.com/repos/FreedomPortal/SimplyMarkdownEditor); [search results](https://github.com/menusal/markdown-editor); [mdd](https://github.com/vladzima/mdd)
- The FSA browser re-asks for folder access after a reload or on the next visit. Firefox and Safari can't write to folders, so apps fall back to file picker plus download. — [menusal/markdown-editor](https://github.com/menusal/markdown-editor); [markdowntools.io folder editor](https://www.markdowntools.io/folder-editor)

### Inferences
- **Does installing a PWA count as an install?** A PWA install puts no executable on disk. It is a browser-managed shortcut and origin, and the code still comes from the vendor's origin and can update silently. Under a strict "no IT approval" bar, the deciding issue is that a third-party hosted origin is processing confidential text, not the install itself. Admins can force-install PWAs (WebAppInstallForceList) ([Chrome Enterprise help](https://support.google.com/chrome/a/answer/9367354?hl=en)). This suggests orgs treat PWAs as a managed browser feature, not as software installs. Whether a given org's policy calls a PWA an install is org-specific (see Gaps).
- **Corporate "no IT approval" verdicts:**
  - vscode.dev: borderline pass. It is a Microsoft first-party site that many corporate networks already allow, and local folder content is read in the browser. But it is a hosted origin, its telemetry isn't documented for the web build, and extensions from the marketplace are a supply-chain vector.
  - StackEdit and Dillinger: weak. Hosted third-party origins with no documented privacy policy (the StackEdit privacy URL returned 404) and OAuth cloud sync as the "real" save path. They fail for confidential documents unless self-hosted, and self-hosting needs a server, which conflicts with the no-server principle.
  - HackMD, HedgeDoc, SilverBullet: fail for this bar. Content lives on a server by design.
  - Long-tail FSA apps: technically local, but hosted by unknown individuals with no track record, and any update could change behavior. They fail an IT risk review even where the code is client-only.
- Northern Lights runs the same File System Access API from a file:// page. So the Edge policies that would block FSA writes (DefaultFileSystemWriteGuardSetting = 2 blocks all sites; FileSystemWriteBlockedForUrls blocks listed sites) could block Northern Lights too ([Edge policy: DefaultFileSystemWriteGuardSetting](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-browser-policies/defaultfilesystemwriteguardsetting); [FileSystemWriteBlockedForUrls](https://learn.microsoft.com/en-my/deployEdge/microsoft-edge-policies/filesystemwriteblockedforurls)). This is a shared dependency, not something Northern Lights escapes. Its advantage is that no network origin is involved.

### Gaps
- Whether vscode.dev works offline after first load or installs as a PWA: not in the official docs, and no authoritative source found.
- vscode.dev web telemetry and data handling: not documented on the VS Code for the Web page.
- StackEdit privacy policy: the URL tried (stackedit.io/privacy_policy.html) returned 404. The current data-handling statement couldn't be verified.
- HackMD privacy policy: the URL tried returned 404. HackMD's storage claim rests only on the vendor comparison article.
- No source found stating how typical corporate IT policies classify PWA installs.

## Local file editing: does it open and save the original .md in place?

### Takeaway
Of the serious, well-known tools, only vscode.dev (on Chromium) opens a local folder and saves the original file in place. StackEdit and Dillinger import and export or sync to the cloud. HackMD, HedgeDoc and SilverBullet are server stores. The new FSA-based apps do save in place, but they are unproven.

### Cited Findings
- vscode.dev opens local folders via the File System API on Edge and Chrome. Other browsers open individual files only. — [VS Code for the Web docs](https://code.visualstudio.com/docs/setup/vscode-web)
- Dillinger: drag-and-drop import, browser local-storage drafts, export downloads. Saving "back" works for cloud providers (GitHub, Dropbox, Drive, OneDrive, Bitbucket). The File System Access API isn't mentioned. — [dillinger.io](https://dillinger.io/); [Dillinger GitHub](https://github.com/joemccann/dillinger)
- StackEdit: "No (browser storage)" for in-place save, with sync to Google Drive, Dropbox or GitHub. — [NoteLoom blog (vendor)](https://noteloom.cc/blog/browser-based-local-first-markdown-editors/); [StackEdit GitHub](https://github.com/benweet/stackedit)
- Markdown Studio saves one file in place on Chromium. mdread saves in place on Chrome and Edge and is read-only elsewhere. files.md defaults to browser storage until you pick a folder. — [NoteLoom blog (vendor)](https://noteloom.cc/blog/browser-based-local-first-markdown-editors/)

### Inferences
- vscode.dev is the only mainstream peer to Northern Lights on in-place local saving. Its save writes the whole buffer, which is fine for git diffs as long as you edit only what you mean to. Northern Lights' click-a-block splice is a different UX: you edit inside the rendered view while still producing minimal diffs. That advantage is about workflow, not diff correctness.
- "Save to the original file" is a hard requirement for Scott's use case. StackEdit and Dillinger fail it.

### Gaps
- Nobody has verified hands-on whether the long-tail FSA apps preserve line endings and unchanged content byte-for-byte when they save.

## Feature comparison vs Northern Lights: where each is better or worse

### Takeaway
vscode.dev is the strongest alternative. It is better at heavy editing (multi-cursor, search across files, git via github.dev, extensions), but worse as a reader: no readability controls, no rendered-view editing, it needs the network, and by default Mermaid needs an extension. StackEdit and Dillinger are better for cloud sync and publishing, and worse on local files, privacy and maintenance (StackEdit is effectively unmaintained). HedgeDoc and HackMD win only on real-time collaboration.

### Cited Findings
- vscode.dev Markdown support is "nearly identical to desktop" (webby languages are best supported). Extensions are limited to web-compatible ones. Some keyboard shortcuts (Ctrl+N, Ctrl+W) collide with the browser. Small mobile screens have constraints. — [VS Code for the Web docs](https://code.visualstudio.com/docs/setup/vscode-web)
- github.dev and vscode.dev load remote repos through the hosting service's APIs, so you can commit to GitHub without cloning. — [VS Code for the Web docs](https://code.visualstudio.com/docs/setup/vscode-web)
- StackEdit (per docs mirrors): KaTeX math, Mermaid, workspace sync, and publishing to Blogger, WordPress and Zendesk. — [TrustRadius](https://www.trustradius.com/products/stackedit/details); [StackEdit GitHub](https://github.com/benweet/stackedit)
- Dillinger: Monaco editor, image paste, MD/HTML/PDF export, five cloud providers. — [Dillinger GitHub](https://github.com/joemccann/dillinger)
- HedgeDoc: real-time collaborative editing (server-backed). — [HedgeDoc GitHub](https://github.com/hedgedoc/hedgedoc)
- Accrete: LaTeX math, PWA offline. Markdown Studio: Mermaid. — [NoteLoom blog (vendor)](https://noteloom.cc/blog/browser-based-local-first-markdown-editors/)

### Inferences (comparison matrix; from cited findings plus general product knowledge, flagged where unsourced)
- **Where alternatives are genuinely better than Northern Lights:**
  - *vscode.dev*: full-power source editing (multi-cursor, command palette, folder-wide search and replace, outline), git commit and PR flow via github.dev, an extension ecosystem, Microsoft backing and active maintenance. Its Markdown preview has no Mermaid by default; Mermaid would need a web-compatible extension (unverified from my own knowledge; not confirmed for the web build).
  - *StackEdit/Dillinger*: cross-device cloud sync and blog publishing. StackEdit has KaTeX math. Northern Lights' baseline lists no math support, which is a real gap if users need equations.
  - *HedgeDoc/HackMD*: multi-user real-time co-editing and revision history (server-side).
  - *Mobile*: hosted editors work on phones and tablets. Northern Lights relies on File System Access plus file:// in desktop Chrome/Edge, so it is effectively desktop-only (inferred from the baseline description).
- **Where Northern Lights is better:**
  - It needs no network origin. It runs from file:// with nothing fetched, so content can't leave the machine and there is no vendor update channel. None of the hosted tools can claim that, and vscode.dev's offline behavior isn't documented.
  - Reading ergonomics: 12 contrast-validated palettes, 65–260% text scaling without UI zoom, adjustable margins, resizable scroll-spy TOC. No reviewed tool documents comparable reading controls. These editors are editing-first.
  - Edit in place in the rendered view, splicing only the edited lines. Dillinger, StackEdit and vscode.dev all use a source pane with a preview.
  - Raw HTML rendered GitHub-style with an allow-list sanitizer, Mermaid bundled offline, interactive tables (sort, filter, CSV/JSON export), a syntax fixer, script-free standalone HTML export, and a print stylesheet. None of the reviewed tools documents interactive table tooling.
  - Maintenance risk is under the user's control: a frozen single file can't be broken by an upstream change, unlike StackEdit (no push since 2023) or a long-tail FSA app.
- **Where Northern Lights is worse:** no real-time collaboration, no cloud sync, no git integration, no math/KaTeX (per the baseline), no plugin ecosystem, no full IDE-grade editing, desktop Chromium only, and no built-in version history beyond what git provides externally.

### Gaps
- vscode.dev Mermaid-in-preview behavior on the web build: not verified with a source.
- Dillinger's current Mermaid and KaTeX support after the Next.js rewrite: not stated on its page or repo summary.
- No independent (non-vendor) 2026 comparison review of browser Markdown editors was found. The only broad 2026 comparison is NoteLoom's own.
