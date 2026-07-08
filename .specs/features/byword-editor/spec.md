# LabWord Specification

## Problem Statement

Writers need a native macOS Markdown editor focused purely on local files — without the complexity of note apps, workspaces, or cloud services.

## Goals

- [x] Fast startup and fluid editing with NSTextView
- [x] Transparent auto-save and session recovery
- [x] Minimal UI with optional preview, focus mode, and statistics

## Out of Scope

| Feature | Reason |
|---------|--------|
| Note library / database | Not Byword philosophy |
| Cloud sync | Local files only |
| AI / plugins / Git | Distraction from writing |

## Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| R1 | Open/save `.md`, `.markdown`, `.txt` | Done |
| R2 | Auto-save on idle, blur, close | Done |
| R3 | Session + crash recovery | Done |
| R4 | Markdown syntax highlighting | Done |
| R5 | Optional HTML preview | Done |
| R6 | Find/replace with regex | Done |
| R7 | Export PDF/HTML/RTF | Done |
| R8 | Print support | Done |
| R9 | Preferences (font, theme, column) | Done |
| R10 | Focus mode | Done |
| R11 | Statistics bar | Done |
