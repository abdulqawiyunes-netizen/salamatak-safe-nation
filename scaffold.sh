#!/usr/bin/env bash
# salamatak (Safe Nation AI) - Full project scaffolder
# Run from repo root: bash scaffold.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"
say() { printf "==> %s\n" "$*"; }
write() { local p="$1"; mkdir -p "$(dirname "$p")"; cat > "$p"; say "wrote $p"; }

write .gitignore <<'EOF'
node_modules
dist
build
coverage
.env
.env.local
*.log
.DS_Store
.vite
.cache
*.tsbuildinfo
EOF

write .prettierrc.json <<'EOF'
{ "semi": true, "singleQuote": true, "trailingComma": "all", "printWidth": 100, "tabWidth": 2, "arrowParens": "always", "endOfLine": "lf" }
EOF

write eslint.config.js <<'EOF'
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import prettier from 'eslint-config-prettier';
export default [
  { files: ['**/*.{ts,tsx}'],
      languageOptions: { parser: tsparser, parserOptions: { ecmaVersion: 2022, sourceType: 'module' } },
          plugins: { '@typescript-eslint': tseslint },
              rules: { '@typescript-eslint/no-explicit-any': 'error', '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }], '@typescript-eslint/consistent-type-imports': 'error' } },
                { ignores: ['**/dist/**','**/node_modules/**','**/build/**','**/coverage/**'] },
                  prettier,
                  ];
                  EOF

                  
