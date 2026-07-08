import { defineConfig } from 'vitest/config';
import { resolve } from 'node:path';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts'],
  },
  resolve: {
    alias: {
      '@labword/domain/domain': resolve('src/domain'),
      '@labword/domain/shared': resolve('src/shared'),
    },
  },
});
