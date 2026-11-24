// eslint.config.js — flat config. Install:
//   npx expo install -- --save-dev eslint eslint-config-expo eslint-plugin-perfectionist \
//     eslint-plugin-boundaries @tanstack/eslint-plugin-query eslint-config-prettier
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');
const perfectionist = require('eslint-plugin-perfectionist');
const boundaries = require('eslint-plugin-boundaries');
const tanstackQuery = require('@tanstack/eslint-plugin-query');
const prettier = require('eslint-config-prettier');

module.exports = defineConfig([
  expoConfig,
  ...tanstackQuery.configs['flat/recommended'],
  {
    ignores: ['dist/*', 'ios/*', 'android/*', '.expo/*', '**/generated/**', 'coverage/*'],
  },
  {
    plugins: { boundaries, perfectionist },
    settings: {
      'boundaries/elements': [
        { type: 'app', pattern: 'app/**' },
        { type: 'ui', pattern: 'src/ui/**' },
        { type: 'core', pattern: 'src/core/**' },
        { type: 'feature', pattern: 'src/features/*', capture: ['feature'], mode: 'folder' },
      ],
      'import/resolver': { typescript: { alwaysTryTypes: true } },
    },
    rules: {
      // ---------- general ----------
      'no-console': 'error',
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/consistent-type-imports': ['error', { fixStyle: 'separate-type-imports' }],
      'react-hooks/exhaustive-deps': 'error',
      'import/order': 'off', // perfectionist owns ordering
      'import/no-default-export': 'off', // Expo Router needs default exports in app/

      // ---------- boundaries ----------
      'boundaries/element-types': [
        'error',
        {
          default: 'disallow',
          rules: [
            { from: 'app', allow: ['feature', 'ui', 'core'] },
            { from: 'feature', allow: ['core', 'ui', 'feature'] },
            { from: 'core', allow: ['ui', 'core'] },
            { from: 'ui', allow: ['ui'] },
          ],
        },
      ],
      // other features only via index.ts
      'boundaries/entry-point': [
        'error',
        {
          default: 'allow',
          rules: [{ target: ['feature'], disallow: ['**'], allow: ['index.ts'] }],
        },
      ],

      // ---------- ordering (autofixable) ----------
      'perfectionist/sort-imports': [
        'error',
        {
          type: 'alphabetical',
          order: 'asc',
          newlinesBetween: 'always',
          internalPattern: ['^@/.*'],
          customGroups: {
            value: {
              react: ['^react$', '^react-native$', '^react/.*', '^react-native/.*'],
              expo: ['^expo$', '^expo-.*', '^@expo/.*', '^expo-router.*'],
            },
          },
          groups: [
            'react',
            'expo',
            ['builtin', 'external'],
            'internal',
            ['parent', 'sibling', 'index'],
            ['type', 'internal-type', 'parent-type', 'sibling-type', 'index-type'],
            'side-effect',
            'unknown',
          ],
        },
      ],
      'perfectionist/sort-named-imports': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-named-exports': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-jsx-props': [
        'error',
        {
          type: 'alphabetical',
          customGroups: { reserved: ['^key$', '^ref$'], callback: '^on.+' },
          groups: ['reserved', 'unknown', 'callback'],
        },
      ],
      'perfectionist/sort-objects': ['error', { type: 'alphabetical', partitionByNewLine: true }],
      'perfectionist/sort-interfaces': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-object-types': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-union-types': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-enums': ['error', { type: 'alphabetical' }],
    },
  },
  {
    // query keys / step arrays: order carries meaning — perfectionist off for objects
    files: ['src/features/*/queries/keys.ts'],
    rules: { 'perfectionist/sort-objects': 'off' },
  },
  {
    files: ['**/*.test.ts', '**/*.test.tsx', 'test/**'],
    rules: { '@typescript-eslint/no-explicit-any': 'off' },
  },
  prettier,
]);
