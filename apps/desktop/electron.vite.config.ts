import { defineConfig, externalizeDepsPlugin } from 'electron-vite';
import react from '@vitejs/plugin-react';
import { fileURLToPath } from 'node:url';
import { resolve } from 'node:path';

const root = fileURLToPath(new URL('.', import.meta.url));
const packages = resolve(root, '../../packages');

const workspacePackages = ['@labword/domain', '@labword/platform-electron'];

export default defineConfig({
  main: {
    plugins: [
      externalizeDepsPlugin({
        exclude: workspacePackages,
      }),
    ],
    build: {
      lib: {
        entry: resolve(root, 'electron/main/index.ts'),
      },
    },
    resolve: {
      alias: {
        '@labword/domain': resolve(packages, 'domain/src'),
        '@labword/platform-electron': resolve(packages, 'platform-electron/src'),
      },
    },
  },
  preload: {
    plugins: [externalizeDepsPlugin()],
    build: {
      lib: {
        entry: resolve(root, 'electron/preload/index.ts'),
        formats: ['cjs'],
      },
      rollupOptions: {
        output: {
          entryFileNames: 'index.js',
        },
      },
    },
    resolve: {
      alias: {
        '@labword/domain': resolve(packages, 'domain/src'),
        '@labword/platform': resolve(packages, 'platform/src'),
        '@labword/platform-electron': resolve(packages, 'platform-electron/src'),
      },
    },
  },
  renderer: {
    root: resolve(root, 'src'),
    plugins: [react()],
    build: {
      rollupOptions: {
        input: resolve(root, 'src/index.html'),
      },
    },
    resolve: {
      alias: {
        '@labword/app': resolve(packages, 'app/src'),
        '@labword/domain': resolve(packages, 'domain/src'),
        '@labword/platform': resolve(packages, 'platform/src'),
        '@labword/platform-electron': resolve(packages, 'platform-electron/src'),
      },
    },
  },
});
