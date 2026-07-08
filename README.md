# LabWord

Minimalist Markdown editor by [Laborit](https://laborit.com.br).

Monorepo with **Turborepo** + **pnpm workspaces**:

| Package / App | Role |
|---------------|------|
| `packages/domain` | Types, markdown logic, agent commands |
| `packages/platform` | `PlatformPort` interface |
| `packages/platform-electron` | Electron adapter (IPC, native menus) |
| `packages/platform-web` | Browser adapter (File API, toolbar) |
| `packages/app` | Shared React UI (editor, agent, overlays) |
| `apps/desktop` | Electron shell |
| `apps/web` | Vite SPA |

## Quick start

```bash
make install
make dev-desktop   # Electron
make dev-web       # Browser at http://localhost:5173
make test
```

## Requirements

- Node.js 20+
- pnpm 10+

Specs: [`.specs/`](.specs/)
