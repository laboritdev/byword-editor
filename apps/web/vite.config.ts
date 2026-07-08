import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname);
const packages = resolve(root, '../../packages');

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@labword/app': resolve(packages, 'app/src'),
      '@labword/domain': resolve(packages, 'domain/src'),
      '@labword/platform': resolve(packages, 'platform/src/index.ts'),
      '@labword/platform-web': resolve(packages, 'platform-web/src'),
    },
  },
  server: {
    port: 5173,
  },
});
