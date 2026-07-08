# Structure

```
byword/
├── desktop/              Electron + TypeScript app
│   ├── electron/         Main process, IPC, menu
│   ├── src/              Renderer (domain, features, shared)
│   └── tests/            Vitest
├── .specs/               Project specs and architecture notes
├── .github/workflows/    CI
├── Makefile              Root shortcuts → desktop/
└── README.md
```

## Key paths

- Editor UI: `desktop/src/features/editor/`
- Agent terminal: `desktop/src/features/agent-terminal/`
- IPC: `desktop/electron/main/ipc/`
- Domain types: `desktop/src/domain/`

## Build outputs (gitignored)

| Path | Purpose |
|------|---------|
| `desktop/out/` | electron-vite dev/build output |
| `desktop/dist/` | Production Electron bundle |
| `desktop/node_modules/` | Dependencies |
