# Tech Stack — LabWord Desktop

## Runtime

- Electron
- Node.js 20+
- pnpm 10+

## Renderer

- React 19
- TypeScript (strict, `noUncheckedIndexedAccess`)
- CodeMirror 6 + `@codemirror/lang-markdown`

## Main process

- TypeScript
- Electron IPC + native dialogs (open/save/print)

## Quality

- Vitest — unit tests in `desktop/tests/`
- ESLint — strict rules, no `any`
- Commands: `pnpm run typecheck`, `pnpm run lint`, `pnpm run test`

## CI

GitHub Actions on `macos-15`: install → typecheck → lint → test
