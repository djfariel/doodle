# Doodle

Map annotation mod for Factorio. Draw lines, arrows, rectangles, circles, and eraser marks on the map chart through [Extensible Map Overlay Framework](https://mods.factorio.com/mod/extensible-map-overlay-framework) (EMOF) **Chart Controls**.

Requires **Extensible Map Overlay Framework**.

## Quick start

1. Enable **Doodle** and **Extensible Map Overlay Framework**.
2. Open the map in chart view and open **Chart Controls**.
3. Pick a drawing tool and left-click on the map (see **Tools**).
4. Adjust width and color in the extension slot below the action buttons.

Undo, redo, and clear are Chart Controls buttons. Keyboard undo/redo: **Settings → Controls → Doodle**.

## Tools

| Button | How to use |
|--------|------------|
| **Line** | Click to add points. **Finish line** saves (needs at least two points); **Cancel line** discards. |
| **Arrow** | Two clicks: start, then end. |
| **Square** | Two clicks: opposite corners. |
| **Circle** | Two clicks: center, then edge (radius). Too-small circles are rejected. |
| **Eraser** | One click removes your nearest doodle on that surface. |
| **Undo / Redo** | Step through your doodle history. |
| **Clear doodles** | Confirms in the extension slot, then removes your doodles on the current surface. |

Click a drawing tool again or switch tools to deactivate. Closing Chart Controls cancels the active tool.

The extension slot also holds the width slider and color dropdown while a tool is active. **Finish line**, **Cancel line**, and clear confirmation appear there when relevant.

## Multiplayer

Committed doodles are visible to your **force**. Previews while drawing are only yours. Changing teams clears your doodles on the save.

## Settings

**Settings → Mod settings → Doodle**:

| Setting | Type | Notes |
|---------|------|-------|
| Undo history size | Runtime (global) | 5-200 steps, default 50. |
| Minimum / maximum line width | Startup | Width slider range; restart required. |
| Line width step | Startup | Slider increment; restart required. |
| Default line color | Per user | Player color or a preset (white, black, red, green, blue, yellow, cyan, magenta, orange). New lines only. |

## Keyboard shortcuts

| Action | Default |
|--------|---------|
| Undo | `SHIFT + Z` |
| Redo | `SHIFT + Y` |

Defaults may conflict with other mods. Rebind under **Settings → Controls → Doodle**. Inputs are game-only (not while typing in text fields).

## Changelog

[changelog.txt](changelog.txt)
