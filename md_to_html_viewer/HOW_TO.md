# How to Use Eye Love Markdown Viewer

A practical guide to reading, editing, and exporting Markdown with Eye Love Markdown Viewer.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Opening Documents](#opening-documents)
3. [Reading and Navigation](#reading-and-navigation)
4. [Appearance and Comfort](#appearance-and-comfort)
5. [Editing Markdown](#editing-markdown)
6. [Live Reload and Watching](#live-reload-and-watching)
7. [Exporting and Sharing](#exporting-and-sharing)
8. [VS Code Integration](#vs-code-integration)
9. [Projects and Multiple Files](#projects-and-multiple-files)
10. [Troubleshooting](#troubleshooting)

---

## Getting Started

### Installation (No Setup Required!)

1. **Download** the viewer from GitHub, or unzip the package you received
2. **Double-click** `md_to_html_viewer.html` in your browser
3. **Bookmark** the page in your toolbar — it behaves like a built-in app

That's it. No install, no permissions, no accounts. It runs entirely in your browser.

### Your First Document

When you open the viewer, you'll see the splash screen with several ways to load a file:

**Choose a file…** — Open a single Markdown file from your computer

**Open a folder…** — Open an entire folder to browse multiple Markdown files (Chrome/Edge only)

**Or just drag & drop** — Drag a `.md` file anywhere on the page (works in all browsers)

---

## Opening Documents

### Method 1: Drag & Drop (All Browsers)

1. Open the folder containing your Markdown files
2. Drag a `.md` file onto the viewer window
3. Drop it — the file loads instantly

**Tip:** Drag the Markdown file AND its images together for relative image links to work.

### Method 2: Use the "Choose a file…" Button

1. Click the "Choose a file…" button on the splash screen
2. Browse your computer and select a `.md` file
3. Click "Open"

### Method 3: Keyboard Shortcut

Press **Ctrl+V** and paste your Markdown text directly onto the page.

### Method 4: From VS Code

See [VS Code Integration](#vs-code-integration) below.

---

## Reading and Navigation

### The Layout

- **Sidebar (left)**: Contains two sections:
  - **Documents** list (if you opened a folder)
  - **Contents** list showing all headings in the current document

- **Main area (center)**: Your Markdown document, rendered and ready to read

- **Toolbar (top)**: Controls for appearance, export, and printing

### Using the Contents Sidebar

**Click any heading** in the Contents to jump straight to that section.

**Hover over a heading** to see a pencil icon (✏️) — click it to edit that section directly.

### Switching Between Documents

If you opened a folder, the sidebar shows all documents. **Click any document name** to read it. The Contents sidebar updates instantly to show that document's headings.

### Keyboard Shortcuts for Navigation

| Key | Action |
|-----|--------|
| `Ctrl+F` | Browser's find function (highlighted across the page) |
| Click heading | Jump to that section |
| Click document name | Switch to that document |

---

## Appearance and Comfort

### Text Size

The toolbar shows `A−` and `A+` buttons, plus a percentage display (e.g., "100%").

- **Click `A−`** to make text smaller (down to 65%)
- **Click `A+`** to make text larger (up to 260%)
- **Click `0`** key (or the percentage number) to reset to 100%

**Unlike browser zoom**, this scales only the document text — the toolbar and sidebar stay the same size, so you see more words, not a magnified interface.

### Colors and Themes

Click the **color palette button** (labeled `Aa`) in the toolbar:

**Mode** — Light or Dark
- **Light** offers White and Beige (warm, soft backgrounds)
- **Dark** offers Blue and Slate (cool, professional backgrounds)

**Colour** — Pick a color family within your chosen mode

**Depth** — Lightest, Darker, or Darkest (controls background brightness)

The viewer remembers your preference for each mode. Switch between Light and Dark — when you come back, it returns to the palette you last chose.

**Match system** — Checkbox at the top. Enable it to let your operating system choose Light or Dark for you.

### Bold All

In the same menu, the **Bold all text** checkbox (`B`) thickens body text for:
- Glare in bright rooms
- Low-contrast screens
- Reading comfort preference

When enabled, bold text (`**text**`) stays visibly heavier than the body.

### Dark Mode and Images

In dark mode, the viewer automatically **dims and desaturates images**. This prevents bright white backgrounds (like screenshots) from being a flashbulb when you're reading in the dark. Diagrams re-render in their own dark theme.

---

## Editing Markdown

### Quick Edit: Pencil Icon

1. **Hover over any heading** in the Contents sidebar
2. Click the **pencil icon** (✏️) that appears
3. The **section editor** opens with that section's raw Markdown
4. Make your changes
5. Press **Ctrl+S** to save

### Edit Any Section: Keyboard Shortcut

1. **Scroll to the section** you want to edit
2. Press **Ctrl+E**
3. The section editor opens with that section selected

### The Editor Window

The editor shows:
- **Section heading** at the top
- **Raw Markdown** in the text area
- **Status line** at the bottom showing what Ctrl+S will do
- **Save button** and **Close button**

The section means the heading, its text, and all its subsections. Editing `## Setup` gives you everything down to the next `##` or higher-level heading.

### Saving Changes

**First save (from a file you opened):**
1. Press **Ctrl+S** in the editor
2. Browser asks once: "May this page edit the file?"
3. Click **Allow**
4. File is saved ✓

**All future saves:**
- Press **Ctrl+S** again — it writes straight to disk with no dialog

**From pasted text (no file to write to):**
- Press **Ctrl+S**
- Choose where to save, or download as a file instead

### Project Folder Path (VS Code Task)

When opening from VS Code (see section below), the editor may ask for your project folder path the first time you save.

1. Paste your project folder path into the prompt
2. The path is saved for future sessions
3. Click the **📁 icon** in the editor header to change it anytime

---

## Live Reload and Watching

### Reload: Get the Latest Version

When you open a file by **dragging and dropping** it, the viewer gets permission to re-read it.

**Reload now:**
- Click the **↻** refresh button in the toolbar
- Or press **Ctrl+R**

The file re-reads from disk and re-renders instantly.

### Watch: Auto-Reload on Save

1. Click the **Watch** button (appears after you drop a file)
2. The button changes to **Live** with a pulsing dot
3. Now, every time you save the file in your editor, the viewer auto-reloads

This is perfect for split-screen editing: write in one half, see the formatted preview in the other half, automatically updated.

### Enable Live Reload After Opening Without It

If you opened a file with **"Choose a file…"** or from **VS Code**, you can enable live reload:

1. Click the **Enable live reload** option (appears if not already enabled)
2. A file picker opens
3. Select the file again
4. Viewer now has permission to re-read and watch it

---

## Exporting and Sharing

### Export as Standalone HTML

Creates a single `.html` file with everything built in — no external stylesheets, fonts, or scripts.

**How:**
1. Click the **hamburger menu** (⋮) in the toolbar
2. Select **Export standalone HTML…**
3. Choose where to save
4. The file opens looking exactly like what's on your screen, in any browser

**What's included:**
- Your text size preference
- Your chosen color palette
- Bold text if enabled
- Image dimming in dark mode
- Rendered Mermaid diagrams (as SVG)

**What's removed:**
- Copy buttons from code blocks
- All JavaScript (the export is static HTML)

This makes it perfect for emailing, sharing on wikis, or opening on locked-down machines.

### Print to PDF

Creates a clean PDF with proper formatting.

**How:**
- Press **Ctrl+P**, or
- Click the **hamburger menu** (⋮) → **Print / Save as PDF**

**Print behavior:**
- Text size reverts to standard 11pt (readable on paper)
- Background color becomes white (saves ink, reads clearly)
- Dark mode is ignored (prints cleanly)

---

## VS Code Integration

### Setup: Create a Keyboard Shortcut

In VS Code, you can open any file directly in the viewer with a single keypress.

1. **Open VS Code settings:**
   - Go to Preferences → Keyboard Shortcuts
   - Or press `Ctrl+K Ctrl+S`

2. **Add the shortcut:**
   - Copy the task from the repo's `.vscode/tasks.json`
   - Paste it into your user-level tasks file (**Ctrl+Shift+P** → **Tasks: Open User Tasks**)

3. **Set a keybinding:**
   - In Keyboard Shortcuts, add:
   ```json
   { "key": "ctrl+m down", "command": "workbench.action.tasks.runTask",
     "args": "Open in MD Viewer" }
   ```
   - This creates a chord: press Ctrl+M, release, then Down arrow

### Using It

1. **Open any `.md` file** in VS Code
2. **Press Ctrl+M then Down**
3. Viewer opens in your default browser with that file loaded

### First Time Editing

When you first try to save an edit from the VS Code flow:

1. The editor asks: "Where is your project folder?"
2. Paste your project folder path
3. Click **📋 Select file** (or the "Open file" button)
4. Choose the Markdown file in the picker
5. Press **Ctrl+S** to save
6. Future saves go straight to disk — no dialog

### Changing Your Project Folder

If you switch projects, click the **📁 folder icon** in the editor to update your stored project path.

---

## Projects and Multiple Files

### Opening a Folder

1. **Drag a folder** onto the viewer, or
2. Click **Open a folder…** (Chrome/Edge only)

The viewer:
- Finds all `.md` files recursively
- Skips folders like `node_modules`, `.git`, `build`, `dist`, `target`, `vendor`
- Stops at 8 levels deep or 500 files (whichever comes first)

### The Documents List

Appears at the top of the sidebar with:
- **Root files first** (like `README.md`)
- **Each folder's README at the top** of its files
- **Nested folder names** shown under filenames (so two `README.md` files in different folders stay distinguishable)

### Switching Documents

**Click any document name** in the list. Contents sidebar updates instantly.

### No Metadata

The viewer creates no manifest, index, or config file. The document list exists for the life of the tab — close it and nothing is saved to disk. Open the folder again and it builds the list fresh.

---

## Troubleshooting

### "This browser cannot open files"

The file picker requires the File System Access API, available in:
- Chrome/Edge (latest versions)
- Others: Use **Drag & Drop** or **"Choose a file…"** instead

### Changes aren't saving

**Check the editor status line** — it always shows what Ctrl+S will do:

- **"Not connected to file"** — You haven't selected a file yet (VS Code task flow). Click **📋** or "Open file" to pick one.
- **"No changes to save"** — You didn't actually edit anything, or the changes match the saved version.
- **"Document changed on disk"** — The file was modified by another program. Reload first (Ctrl+R), then re-edit.

### Live reload isn't working

**"Watch" button is grayed out?** You need permission to re-read the file.

1. Click **Enable live reload**
2. Pick the file again in the dialog
3. Watch will now appear enabled

### Images aren't showing

**Relative image links don't work when:**
- You opened just the `.md` file without its images nearby
- Images are in a different folder

**Fix:** Drag both the `.md` file AND the image files together onto the viewer.

### The page looks weird / colors are wrong

**Try clearing cache:**
1. Click hamburger menu (⋮)
2. Select **Clear cache and settings…**
3. Confirm
4. Page reloads with factory defaults

This resets:
- Text size, color palette, dark mode preference
- Saved documents
- Project folder path
- Any other stored preferences

### Keyboard shortcuts aren't working

Check that focus isn't in a text area or input field — shortcuts work at the document level, not inside the editor.

---

## Tips & Tricks

### Bookmark It for Quick Access

1. Press **Ctrl+D** to bookmark the page
2. Place it in your toolbar
3. Now you can open the viewer from your toolbar anytime

### Split-Screen Editing Workflow

1. Open your editor (VS Code, etc.) on the left half
2. Drag your file onto the viewer on the right half
3. Enable **Watch**
4. Edit → Save in the editor → instantly see changes in the viewer

### Reading Long Documents

1. Adjust text size for comfort
2. Use **Ctrl+F** to find keywords
3. Click headings in the Contents sidebar to jump around
4. Adjust colors if you're reading for a long time

### Sharing Read-Only Content

Export as standalone HTML and send the `.html` file. Recipients don't need the viewer — they just open the file in any browser.

### Exporting for Print

1. Adjust your document (make sure important content is there)
2. Press **Ctrl+P**
3. Choose "Save as PDF" in the print dialog
4. Done — clean, printable PDF with proper formatting

---

## Keyboard Shortcut Reference

| Key | Action |
|-----|--------|
| `Ctrl+O` | Open a file (splash screen) |
| `Ctrl+E` | Edit the current section |
| `Ctrl+S` | Save the edit |
| `Ctrl+R` | Reload the file from disk |
| `Ctrl+P` | Print / Save as PDF |
| `Ctrl+V` | Paste Markdown text |
| `Ctrl+F` | Browser find (highlight all matches) |
| `+` / `-` | Increase / decrease text size |
| `0` | Reset text size to 100% |
| `B` | Toggle bold-all text |
| `D` | Toggle light / dark mode |
| `Esc` | Close the editor |

---

## What's Next?

- **Customize your appearance** — Find the color palette that works for your eyes and your room
- **Try editing** — Make a small change to a section to see how quick it is
- **Set up VS Code** — If you use VS Code, the integration makes workflows much faster
- **Drop a folder** — Experience browsing a whole project at once
- **Export something** — Try exporting as HTML or PDF to see the quality

Happy reading!
