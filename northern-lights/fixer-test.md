---
title: Fixer test — #this-is-front-matter-and-must-not-change
---

# Markdown Fixer Test (one by one)

This file has **six** deliberate Markdown mistakes. Open it in the viewer and a
**🩹 6** badge should appear in the toolbar. Click it and fix them **one at a time**:
read each before/after, press **Fix** (or **Skip** to leave one).

After each fix, check the section below now looks right. Refresh, or open the file in
another viewer, if you want to be sure. When you're done the badge disappears.

Want to try **Fix all** or **Hurry mode** instead? Use `fixer-test-autofix.md`. It's the
same mistakes, so this file stays good for one-by-one testing. (To reset this file
afterwards: `git checkout -- fixer-test.md`.)

---

## 1. Heading with no space

Fix this: the line below should be a heading, but it shows as plain text.

#This should be a heading

*After: "This should be a heading" shows as a big heading.*

## 2. List item with no space

Fix this: the middle item has no space after its dash, so it joins the line above.

- first item
-second item
- third item

*After: three separate bullets.*

## 3. Table with no blank line before it

Fix this: the table is glued to this sentence, so it shows as a line of pipes.
| Fruit | Colour |
| --- | --- |
| Apple | Red |

*After: a real table with two columns.*

## 4. Table divider with the wrong column count

Fix this: the divider row has one column, but the header has three.

| Name | Role | Team |
|---|
| Ada | Engineer | Core |

*After: a real table with three columns.*

## 5. Space breaking a link

Fix this: the space between `]` and `(` stops this being a link —
see [the example site] (https://example.com) for details.

*After: "the example site" is a clickable link.*

## 6. Decoys — these must NOT change

None of these should be flagged or touched by any fix:

```bash
#this-is-a-comment-in-code
[not a link] (https://example.com)
```

Inline code is left alone too: `[also not a link] (https://example.com)`.

## 7. Code block that never closes

Fix this: the code block at the very end of this file is never closed. The fixer closes
it at the end of the file, so it's the last thing here.

*After: the code block is closed and shows the two lines of code; nothing else changes.
(Before the fix, everything after the opening fence counts as code. Here that's only the
code itself, because the block is last.)*

```js
const answer = 42;
console.log(answer);
