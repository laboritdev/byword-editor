# LabWord Desktop Specification

## Problem Statement

Writers need a minimalist local Markdown editor with reliable keyboard UX and an Agent terminal. Electron + TypeScript provides predictable DOM input and a maintainable typed codebase.

## Goals

- [x] Runnable Electron app from `desktop/` with typed IPC and file I/O
- [x] Explicit typing in app code (zero `any`/`object`/`unknown`)
- [x] Editor, agent, preferences, help overlays

## Out of Scope (for now)

| Feature | Reason |
|---------|--------|
| Mobile/web-only build | Desktop Electron first |
| Plugin marketplace | Deferred |
| Windows/Linux | macOS first |

---

## User Stories

### P1: Strict TypeScript foundation ✅

**Acceptance Criteria**:

1. `strict` and `noUncheckedIndexedAccess` enabled
2. ESLint `@typescript-eslint/no-explicit-any` errors
3. Public functions declare explicit parameter and return types

---

### P2: Markdown editor ✅

1. Open/save/rename `.md` files
2. CodeMirror editor + preview toggle
3. Unsaved changes prompt; dirty title with `*`

---

### P2: Agent terminal ✅

1. Enter submits command immediately
2. `help shortcuts` / `hs` / `?` etc.
3. Auto-scroll on output

---

### P3: AI providers

1. `ai <prompt>` streams when provider configured
2. Settings in preferences

---

## Success Criteria

- [x] Desktop passes typecheck + unit tests in CI
- [x] Agent Enter works on first keypress
- [ ] Signed Electron release build
