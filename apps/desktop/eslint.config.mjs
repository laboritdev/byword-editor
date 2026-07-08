import eslint from '@eslint/js';
import tseslint from 'typescript-eslint';
import reactHooks from 'eslint-plugin-react-hooks';

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.strictTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-unsafe-assignment': 'error',
      '@typescript-eslint/no-unsafe-call': 'error',
      '@typescript-eslint/no-unsafe-member-access': 'error',
      '@typescript-eslint/no-unsafe-return': 'error',
      '@typescript-eslint/no-unsafe-argument': 'error',
      '@typescript-eslint/no-restricted-types': [
        'error',
        {
          types: {
            unknown: 'Use JsonValue and type guards at boundaries instead of unknown.',
            object: 'Use a specific interface or Record<string, JsonValue> instead.',
            Function: 'Use a typed function signature instead.',
          },
        },
      ],
      '@typescript-eslint/explicit-function-return-type': [
        'error',
        { allowExpressions: false, allowTypedFunctionExpressions: true },
      ],
      '@typescript-eslint/explicit-module-boundary-types': 'error',
    },
  },
  {
    files: ['**/*.{tsx,jsx}'],
    plugins: { 'react-hooks': reactHooks },
    rules: {
      ...reactHooks.configs.recommended.rules,
    },
  },
  {
    ignores: ['out/**', 'dist/**', 'node_modules/**', 'eslint.config.mjs'],
  },
  {
    files: ['electron/preload/**/*.ts'],
    rules: {
      '@typescript-eslint/no-unsafe-return': 'off',
    },
  },
);
