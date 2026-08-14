# Raw HTML Tag Test

Scratch document for checking what the sanitizer lets through. Raw HTML is now
**on by default** — if everything below renders as plain text instead, the
toggle got turned off at some point (⋮ → Allow raw HTML).

---

## 1. Inline formatting

Plain markdown **bold** next to <b>tag bold</b>, <i>italic</i>, <u>underline</u>,
<mark>marked</mark>, <sub>sub</sub>/<sup>sup</sup>, <kbd>Ctrl</kbd>+<kbd>C</kbd>,
<abbr title="HyperText Markup Language">HTML</abbr>, and <s>struck</s>.

Line one.<br>Line two after a `<br>`.

## 2. Inline styles

<span style="color: crimson">This should be red.</span>   
<span style="background: gold; padding: 2px 6px; border-radius: 3px">Gold pill.</span>

<div style="border-left: 4px solid teal; padding: 8px 12px; margin: 12px 0">
A bordered callout built with a styled div.
</div>

## 3. Links

<a href="https://example.com" target="_blank" rel="noopener">Opens in a new tab</a>

<a href="javascript:alert('xss')">This href should be neutered to #</a>

## 4. Semantic sectioning

<article>
  <header><strong>Article header</strong></header>
  <p>Body inside an article element.</p>
  <footer><small>Article footer</small></footer>
</article>

<aside style="opacity: .8">Aside content.</aside>

<nav><a href="#1-inline-formatting">Jump to section 1</a></nav>

<main><p>Main element content.</p></main>

## 5. Legacy tags

<center>Centered via the legacy center tag.</center>

<font color="purple" size="5">Purple, size 5.</font>

<big>big</big> / <small>small</small> / <strike>strike</strike> / <tt>teletype</tt>

## 6. Definition and description lists

<dl>
  <dt>Term</dt><dd>Definition of the term.</dd>
  <dt>Another</dt><dd>Second definition.</dd>
</dl>

## 7. Details / summary

<details>
  <summary>Click to expand</summary>
  Hidden content revealed on toggle.
</details>

## 8. Tables with legacy attributes

<table border="1" cellpadding="6" cellspacing="0">
  <thead>
    <tr><th>Region</th><th>Revenue</th><th>Status</th></tr>
  </thead>
  <tbody>
    <tr><td>North</td><td>5200</td><td>Closed</td></tr>
    <tr><td>South</td><td>3100</td><td>Open</td></tr>
    <tr><td>East</td><td bgcolor="#fff3cd">7400</td><td>Closed</td></tr>
  </tbody>
</table>

## 9. Media

<video controls width="320" poster="">
  <source src="nonexistent.mp4" type="video/mp4">
  Fallback text if video is unsupported.
</video>

<audio controls>
  <source src="nonexistent.mp3" type="audio/mpeg">
  Fallback text if audio is unsupported.
</audio>

## 10. Accessibility attributes

<div role="note" aria-label="Accessible note">
  Should keep both role and aria-label.
</div>

## 11. Things that MUST be stripped

If any of the following execute or appear, the sanitizer has a hole.

<script>document.title = "XSS FIRED";</script>

<iframe src="https://example.com" width="300" height="150"></iframe>

<div onclick="alert('inline handler')">Clicking this should do nothing.</div>

<img src="x" onerror="document.title='IMG XSS'" alt="broken image, no alert">

<form><input type="text" value="form input"><button>Submit</button></form>

<svg width="50" height="50"><circle cx="25" cy="25" r="20" fill="red"/></svg>

<object data="test.swf"></object>
<embed src="test.swf">

---

**Expected:** sections 1–10 render as described. Section 11 shows the
"Clicking this should do nothing" text and the image alt text, everything else
gone, page title unchanged, no alerts.
