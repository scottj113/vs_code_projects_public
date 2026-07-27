# vs_code_projects_public

Public projects, one folder each. Each is self-contained and carries its own
README and license.

---

## [md_to_html_viewer](md_to_html_viewer/)

*The lightest genuinely powerful Markdown reader you can run without installing
anything. One HTML file, ~92 KB.*

**Every other Markdown viewer is built to render the file. This one is built so you
can read it.**

None of them seem concerned with your eyes — whether the type is a size you can
comfortably take in, whether the contrast suits the room you're in, whether you can
shape the page the way *you* want. And you're stuck with whichever one you've got: the
preview pane bolted into your editor, the renderer on a website, the viewer inside
your notes app, each with one fixed appearance and no say in it.

**Made for reading**

- **Text that scales without the page falling apart.** Most viewers offer one size and
  a zoom that enlarges the whole interface — the toolbar grows with the text, the
  layout reflows, tables break, and you end up with *fewer* words on screen. This
  scales the **document**, 65% to 260%, and leaves the furniture alone.
- **Contrast you choose.** Twelve palettes across light and dark, every one
  contrast-validated rather than eyeballed: body text holds 12:1 or better in all
  twelve. **Bold all** for glare and low-contrast screens; dark mode dims images so
  screenshots stop glaring.
- **It remembers.** Size, palette and layout persist between sessions, and the page
  opens already themed instead of flashing white first.

**Made for working**

- **Keep your editor — use this as the preview.** Turn on **Watch** and the viewer
  re-reads the file every time you save. No preview pane fighting you for space, no
  second rendering engine disagreeing with the first. *(Chromium browsers.)*
- **Read it as a web page, then take it with you.** **Export** writes a standalone
  HTML file — fully styled, opens anywhere, nothing else needed — or `Ctrl+P` for a
  clean PDF. Useful when whoever you're sending it to has no Markdown viewer at all.
- **Renders properly** — GitHub-Flavored Markdown with footnotes, definition lists and
  front matter; Mermaid diagrams offline; syntax highlighting across ten language
  families; a contents sidebar with scroll-spy.

**Nothing to install, nothing to approve**

No install, no server, no build step, no `node_modules`. **Nothing in the package is
executable** — no installer, no script, no launcher — so there's nothing for a mail
gateway to strip, SmartScreen to warn about, or policy to block, and nothing to raise
a ticket for. The people who most need a readable Markdown viewer are often exactly
the people who can't get one approved.

Raw HTML is escaped by default; opting in still filters everything through a tag and
attribute allow-list.

**Why one file can do this**

It feels like a real application because in every way that matters it is one. Your
browser stopped being a document viewer long ago — it's an application platform with a
rendering engine, a fast JavaScript runtime, storage that remembers your settings, and
permission to re-read a file you've pointed it at. Software like this normally ships as
a 150 MB Electron bundle, nearly all of which is a private copy of Chromium. You
already have Chromium. This is only the part that would have been wrapped inside it.

Double-click it, drop a `.md` on it, bookmark it to your toolbar.

[Full documentation →](md_to_html_viewer/distro/README.md) ·
[Download the package](md_to_html_viewer/md_to_html_viewer.zip)
