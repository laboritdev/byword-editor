import { defineConfig } from 'vitest/config';
import { resolve } from 'node:path';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
  },
  resolve: {
    alias: {
      '@labword/app': resolve('src'),
      '@labword/domain/domain': resolve('../domain/src/domain'),
      '@labword/domain/shared': resolve('../domain/src/shared'),
      '@labword/platform': resolve('../platform/src/index.ts'),
    },
  },
});
