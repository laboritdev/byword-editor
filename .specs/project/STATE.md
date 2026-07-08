# Project State

**Last updated:** 2026-07-04

## Current focus

Electron desktop app is the sole implementation. Swift/native code removed.

## Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-07-04 | Remove Swift `native/` | Electron UX preferred; Agent terminal and overlays work better in web stack |
| 2026-07-04 | Monorepo simplified to `desktop/` | Single stack, simpler CI and onboarding |

## Desktop status

- Editor, preview, preferences, help, rename, unsaved prompt
- Agent terminal with help aliases (`?`, `hs`, `hc`, `hm`)
- Formatting palette (⌘K)
- Focus mode, font shortcuts, menu IPC

## Next

- AI providers in Agent
- Electron release packaging / Homebrew cask for desktop build
