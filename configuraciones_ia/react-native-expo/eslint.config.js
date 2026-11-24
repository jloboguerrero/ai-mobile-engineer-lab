// eslint.config.js — flat config. Install:
//   npx expo install -- --save-dev eslint eslint-config-expo eslint-plugin-perfectionist \
//     @tanstack/eslint-plugin-query eslint-config-prettier
//
// Layers (docs/architecture.md):
//   src/app → src/features → src/ui, src/core.   core imports nothing above it; ui imports only ui.
//   Inside a feature: domain ← data ← presentation/queries ← presentation/components|screens.
//   A feature imports another only from the shared domain (SHARED_FEATURES).
const fs = require('fs');
const path = require('path');

const pluginQuery = require('@tanstack/eslint-plugin-query');
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');
const prettierConfig = require('eslint-config-prettier/flat');
const perfectionist = require('eslint-plugin-perfectionist');

// Adding to this list is a decision (an ADR), not a fix for a lint error.
const SHARED_FEATURES = ['account', 'employee', 'auth'];

const FEATURES_DIR = path.join(__dirname, 'src/features');
const features = fs.existsSync(FEATURES_DIR)
  ? fs
      .readdirSync(FEATURES_DIR, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .map(({ name }) => name)
  : [];

// One zone per feature folder, read from disk: a new feature is covered the day it exists.
const featureZones = features.map((name) => ({
  except: [name, ...SHARED_FEATURES.filter((shared) => shared !== name)].map((allowed) => `./${allowed}`),
  from: './src/features',
  message: `A feature imports another only from the shared domain (${SHARED_FEATURES.join(', ')}). Compose them in src/app, or move the shared part to core or ui.`,
  target: `./src/features/${name}`,
}));

// Clean Architecture lite inside each feature.
const layerZones = features.flatMap((name) => {
  const root = `./src/features/${name}`;
  return [
    {
      from: [`${root}/data`, `${root}/presentation`],
      message: 'domain is pure: it imports only domain.',
      target: `${root}/domain`,
    },
    {
      from: `${root}/presentation`,
      message: 'data never imports presentation.',
      target: `${root}/data`,
    },
    {
      from: `${root}/data`,
      message: 'Components and screens never import data/: go through presentation/queries.',
      target: [`${root}/presentation/components`, `${root}/presentation/screens`],
    },
  ];
});

const SECURE_STORE_IMPORT = {
  message: 'Use secureStore from @/core/secure-store: it keeps every value on this device.',
  name: 'expo-secure-store',
};
const AXIOS_IMPORT = {
  message: 'Call shr-be through @/core/api and read failures with apiErrorOf or errorText.',
  name: 'axios',
};
const ACCOUNT_PROVIDER_PATTERN = {
  group: ['**/account/account-provider'],
  message: 'A feature takes the userId / employeeId it shows as a parameter: the route reads useAccount() and passes it.',
};
const DOMAIN_IMPORTS = ['react', 'react-native', 'axios', '@tanstack/react-query', 'expo-router'].map((name) => ({
  message: 'domain/ is pure TypeScript: no React, no HTTP, no TanStack, no router.',
  name,
}));

// Only capabilities.ts compares the app's role values.
const ROLE_VALUE = '/^(employee|sm|dm)$/';
const ROLE_CHECKS = [
  {
    message: 'Ask capabilitiesOf / useCapabilities (features/account/capabilities.ts) instead of comparing the role.',
    selector: [
      `BinaryExpression[left.property.name='role'][right.value=${ROLE_VALUE}]`,
      `BinaryExpression[right.property.name='role'][left.value=${ROLE_VALUE}]`,
      `SwitchStatement[discriminant.property.name='role']:has(SwitchCase > Literal.test[value=${ROLE_VALUE}])`,
    ].join(', '),
  },
];
const NO_TRY_IN_TSX = {
  message:
    'No try in a component file: React Compiler would skip the component. Use a mutation (onError), a promise chain (.catch/.finally), or move the logic to a .ts module.',
  selector: 'TryStatement',
};
const NO_QUERY_CLIENT_IN_SCREENS = {
  message: 'Screens and components do not touch the cache: add a hook in presentation/queries (useRefreshX, invalidateX).',
  selector: "CallExpression[callee.name='useQueryClient']",
};

module.exports = defineConfig([
  expoConfig,
  { extends: [pluginQuery.configs['flat/recommended']], files: ['src/**/*.ts', 'src/**/*.tsx'] },
  { ignores: ['dist/*', 'web-build/*', '.expo/*', 'android/*', 'ios/*', 'coverage/*'] },
  {
    files: ['src/**/*.ts', 'src/**/*.tsx'],
    languageOptions: { parserOptions: { projectService: true, tsconfigRootDir: __dirname } },
    plugins: { perfectionist },
    rules: {
      // ---------- general ----------
      '@typescript-eslint/consistent-type-imports': ['error', { fixStyle: 'separate-type-imports' }],
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': ['error', { checksVoidReturn: { attributes: false } }],
      '@typescript-eslint/switch-exhaustiveness-check': 'error',
      eqeqeq: ['error', 'smart'],
      'import/no-cycle': ['error', { disableScc: true, ignoreExternal: true }],
      'import/order': 'off', // perfectionist owns ordering
      'no-console': 'error',
      'react-hooks/exhaustive-deps': 'error',
      'react-hooks/todo': 'error', // React Compiler: syntax it cannot lower yet

      // ---------- layers ----------
      'import/no-restricted-paths': [
        'error',
        {
          basePath: __dirname,
          zones: [
            {
              from: ['./src/features', './src/ui', './src/app'],
              message: 'core is plumbing: it imports nothing from features, ui or app.',
              target: './src/core',
            },
            {
              from: ['./src/features', './src/core', './src/app'],
              message: 'ui is presentational: it imports only other ui parts.',
              target: './src/ui',
            },
            { from: './src/app', message: 'Routes import features, never the other way round.', target: './src/features' },
            {
              from: './src/translations.ts',
              message: 'Catalogs are started once, by the root layout. Read words with useTranslation.',
              target: ['./src/core', './src/features', './src/ui'],
            },
            {
              from: ['./src/core', './src/features', './src/ui', './src/app'],
              message: 'app-config.ts is the one module core reads above it, so it imports nothing.',
              target: './src/app-config.ts',
            },
            ...featureZones,
            ...layerZones,
          ],
        },
      ],

      // ---------- ordering (autofixable) ----------
      'perfectionist/sort-enums': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-imports': [
        'error',
        {
          customGroups: {
            value: {
              expo: ['^expo$', '^expo-.*', '^@expo/.*', '^expo-router.*'],
              react: ['^react$', '^react-native$', '^react/.*', '^react-native/.*'],
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
          internalPattern: ['^@/.*'],
          newlinesBetween: 'always',
          order: 'asc',
          type: 'alphabetical',
        },
      ],
      'perfectionist/sort-interfaces': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-jsx-props': [
        'error',
        {
          customGroups: { callback: '^on.+', reserved: ['^key$', '^ref$'] },
          groups: ['reserved', 'unknown', 'callback'],
          type: 'alphabetical',
        },
      ],
      'perfectionist/sort-named-exports': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-named-imports': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-object-types': ['error', { type: 'alphabetical' }],
      'perfectionist/sort-objects': ['error', { partitionByNewLine: true, type: 'alphabetical' }],
      'perfectionist/sort-union-types': ['error', { type: 'alphabetical' }],
    },
  },
  {
    // Order carries meaning: key factories (hierarchy) and cache policies.
    files: ['src/features/*/presentation/queries/keys.ts', 'src/core/cache.ts'],
    rules: { 'perfectionist/sort-objects': 'off' },
  },
  {
    // Role comparisons live in one file (its tests may build roles).
    files: ['src/**/*.ts', 'src/**/*.tsx'],
    ignores: ['**/*.test.ts', '**/*.test.tsx', 'src/features/account/capabilities.ts'],
    rules: { 'no-restricted-syntax': ['error', ...ROLE_CHECKS] },
  },
  {
    // Component files: no try, no cache work (replaces the block above here, so it repeats ROLE_CHECKS).
    files: ['src/**/*.tsx'],
    ignores: ['**/*.test.tsx', '**/*.fixture.tsx', 'src/app/_layout.tsx'],
    rules: { 'no-restricted-syntax': ['error', NO_TRY_IN_TSX, NO_QUERY_CLIENT_IN_SCREENS, ...ROLE_CHECKS] },
  },
  {
    // Secure storage has one door.
    files: ['src/**/*.ts', 'src/**/*.tsx'],
    ignores: ['**/*.test.ts', '**/*.test.tsx', 'src/core/secure-store.ts'],
    rules: { 'no-restricted-imports': ['error', { paths: [SECURE_STORE_IMPORT] }] },
  },
  {
    // axios only in core (repeats the secure storage rule: later blocks replace earlier ones).
    files: ['src/app/**', 'src/features/**', 'src/ui/**'],
    ignores: ['**/*.test.ts', '**/*.test.tsx'],
    rules: { 'no-restricted-imports': ['error', { paths: [SECURE_STORE_IMPORT, AXIOS_IMPORT] }] },
  },
  {
    // Features are told whose data they show: only routes read the account.
    files: ['src/features/**'],
    ignores: ['**/*.test.ts', '**/*.test.tsx', 'src/features/account/**'],
    rules: {
      'no-restricted-imports': [
        'error',
        { paths: [SECURE_STORE_IMPORT, AXIOS_IMPORT], patterns: [ACCOUNT_PROVIDER_PATTERN] },
      ],
    },
  },
  {
    // domain/ is pure (repeats the rules above for these files).
    files: ['src/features/*/domain/**'],
    ignores: ['**/*.test.ts'],
    rules: {
      'no-restricted-imports': [
        'error',
        { paths: [SECURE_STORE_IMPORT, AXIOS_IMPORT, ...DOMAIN_IMPORTS], patterns: [ACCOUNT_PROVIDER_PATTERN] },
      ],
    },
  },
  { files: ['src/core/monitoring.ts'], rules: { 'no-console': 'off' } },
  {
    files: ['**/*.test.ts', '**/*.test.tsx', '**/*.fixture.ts', '**/*.fixture.tsx'],
    rules: { '@typescript-eslint/no-explicit-any': 'off' },
  },
  prettierConfig,
]);
