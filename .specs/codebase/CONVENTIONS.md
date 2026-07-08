# Code Conventions

## Desktop (TypeScript)

**Files:** kebab-case modules (`agent-command.service.ts`); PascalCase React components.

**Functions:** explicit parameter and return types on all exported functions and module boundaries.

**Types:**

- Branded types for domain IDs (`FilePath`, `DocumentContent`)
- `JsonValue` at JSON/IPC boundaries — no `any`, `object`, or `unknown`
- `Result<T, E>` for expected failures where used

**Imports:** domain → features → infrastructure; domain never imports React or Electron.

**Testing:** Vitest; colocated in `desktop/tests/` with `.test.ts` suffix.

**Lint:** ESLint strict type-checked + `@typescript-eslint/no-explicit-any` and `no-restricted-types`.

## Repo

- Semantic branch prefixes: `feat/`, `fix/`, `chore/`
- Specs in `.specs/` before large features
