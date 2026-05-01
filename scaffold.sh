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

                  

# ====================== lib/db ======================
write lib/db/package.json <<'EOF'
{
  "name": "@salamatak/db",
    "version": "0.1.0",
      "private": true,
        "type": "module",
          "main": "./src/index.ts",
            "types": "./src/index.ts",
              "scripts": { "typecheck": "tsc --noEmit", "build": "tsc -p tsconfig.json", "generate": "drizzle-kit generate", "migrate": "tsx src/migrate.ts", "seed": "tsx src/seed.ts" },
                "dependencies": { "bcryptjs": "^2.4.3", "drizzle-orm": "^0.33.0", "postgres": "^3.4.4" },
                  "devDependencies": { "@types/bcryptjs": "^2.4.6", "drizzle-kit": "^0.24.0", "tsx": "^4.19.0", "typescript": "^5.6.0" }
                  }
                  EOF

                  write lib/db/tsconfig.json <<'EOF'
                  { "extends": "../../tsconfig.base.json",
                    "compilerOptions": { "outDir": "dist", "rootDir": "src", "declaration": true, "composite": true, "module": "NodeNext", "moduleResolution": "NodeNext", "verbatimModuleSyntax": false },
                      "include": ["src/**/*"] }
                      EOF

                      write lib/db/drizzle.config.ts <<'EOF'
                      import type { Config } from 'drizzle-kit';
                      export default {
                        schema: './src/schema/index.ts',
                          out: './drizzle',
                            dialect: 'postgresql',
                              dbCredentials: { url: process.env.DATABASE_URL ?? '' },
                                strict: true, verbose: true,
                                } satisfies Config;
                                EOF

                                write lib/db/src/client.ts <<'EOF'
                                import { drizzle } from 'drizzle-orm/postgres-js';
                                import postgres from 'postgres';
                                import * as schema from './schema/index.js';
                                const cs = process.env.DATABASE_URL;
                                if (!cs) throw new Error('DATABASE_URL not set');
                                export const sql = postgres(cs, { max: 10, idle_timeout: 20 });
                                export const db = drizzle(sql, { schema });
                                export type DB = typeof db;
                                export { schema };
                                EOF

                                write lib/db/src/index.ts <<'EOF'
                                export * from './client.js';
                                export * from './schema/index.js';
                                EOF

                                write lib/db/src/migrate.ts <<'EOF'
                                import { drizzle } from 'drizzle-orm/postgres-js';
                                import { migrate } from 'drizzle-orm/postgres-js/migrator';
                                import postgres from 'postgres';
                                async function main() {
                                  const url = process.env.DATABASE_URL;
                                    if (!url) throw new Error('DATABASE_URL not set');
                                      const c = postgres(url, { max: 1 });
                                        await migrate(drizzle(c), { migrationsFolder: './drizzle' });
                                          await c.end();
                                            console.warn('migrations applied');
                                            }
                                            main().catch((e) => { console.error(e); process.exit(1); });
                                            EOF

                                            write lib/db/src/schema/users.ts <<'EOF'
                                            import { pgTable, serial, varchar, text, boolean, timestamp } from 'drizzle-orm/pg-core';
                                            export const users = pgTable('users', {
                                              id: serial('id').primaryKey(),
                                                username: varchar('username', { length: 64 }).notNull().unique(),
                                                  phone: varchar('phone', { length: 16 }).notNull().unique(),
                                                    passwordHash: text('password_hash').notNull(),
                                                      fullName: text('full_name').notNull(),
                                                        role: varchar('role', { length: 16 }).notNull().default('citizen'),
                                                          isActive: boolean('is_active').notNull().default(true),
                                                            createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                              updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
                                                              });
                                                              export type User = typeof users.$inferSelect;
                                                              export type NewUser = typeof users.$inferInsert;
                                                              EOF

                                                              write lib/db/src/schema/branches.ts <<'EOF'
                                                              import { pgTable, serial, varchar, text, boolean, timestamp, doublePrecision } from 'drizzle-orm/pg-core';
                                                              export const branches = pgTable('branches', {
                                                                id: serial('id').primaryKey(),
                                                                  name: text('name').notNull(),
                                                                    nameEn: text('name_en').notNull(),
                                                                      category: varchar('category', { length: 32 }).notNull(),
                                                                        city: text('city').notNull(),
                                                                          phone: varchar('phone', { length: 32 }).notNull(),
                                                                            latitude: doublePrecision('latitude').notNull(),
                                                                              longitude: doublePrecision('longitude').notNull(),
                                                                                isActive: boolean('is_active').notNull().default(true),
                                                                                  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                  });
                                                                                  export type Branch = typeof branches.$inferSelect;
                                                                                  export type NewBranch = typeof branches.$inferInsert;
                                                                                  EOF

                                                                                  write lib/db/src/schema/reports.ts <<'EOF'
                                                                                  import { pgTable, serial, varchar, text, timestamp, doublePrecision, integer, boolean, real, jsonb, index } from 'drizzle-orm/pg-core';
                                                                                  import { users } from './users.js';
                                                                                  import { branches } from './branches.js';
                                                                                  export const reports = pgTable('reports', {
                                                                                    id: serial('id').primaryKey(),
                                                                                      userId: integer('user_id').references(() => users.id, { onDelete: 'set null' }),
                                                                                        reporterPhone: varchar('reporter_phone', { length: 16 }),
                                                                                          type: varchar('type', { length: 16 }).notNull(),
                                                                                            category: varchar('category', { length: 32 }).notNull(),
                                                                                              title: text('title').notNull(),
                                                                                                description: text('description').notNull(),
                                                                                                  latitude: doublePrecision('latitude').notNull(),
                                                                                                    longitude: doublePrecision('longitude').notNull(),
                                                                                                      locationLabel: text('location_label'),
                                                                                                        status: varchar('status', { length: 16 }).notNull().default('new'),
                                                                                                          priority: varchar('priority', { length: 16 }).notNull().default('medium'),
                                                                                                            branchId: integer('branch_id').references(() => branches.id, { onDelete: 'set null' }),
                                                                                                              assignedToUserId: integer('assigned_to_user_id').references(() => users.id, { onDelete: 'set null' }),
                                                                                                                aiSteps: jsonb('ai_steps').$type<string[]>().notNull().default([]),
                                                                                                                  aiSummary: text('ai_summary'),
                                                                                                                    aiConfidence: real('ai_confidence'),
                                                                                                                      suspectedFake: boolean('suspected_fake').notNull().default(false),
                                                                                                                        fakeReason: text('fake_reason'),
                                                                                                                          fakeConfidence: real('fake_confidence'),
                                                                                                                            adminNotes: text('admin_notes'),
                                                                                                                              photoUrls: jsonb('photo_urls').$type<string[]>().notNull().default([]),
                                                                                                                                createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                                                                  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                                                                    resolvedAt: timestamp('resolved_at', { withTimezone: true }),
                                                                                                                                    }, (t) => ({
                                                                                                                                      statusIdx: index('reports_status_idx').on(t.status),
                                                                                                                                        priorityIdx: index('reports_priority_idx').on(t.priority),
                                                                                                                                          createdAtIdx: index('reports_created_at_idx').on(t.createdAt),
                                                                                                                                            geoIdx: index('reports_geo_idx').on(t.latitude, t.longitude),
                                                                                                                                              branchIdx: index('reports_branch_idx').on(t.branchId),
                                                                                                                                              }));
                                                                                                                                              export type Report = typeof reports.$inferSelect;
                                                                                                                                              export type NewReport = typeof reports.$inferInsert;
                                                                                                                                              EOF
                                                                                                                                              
                                                                                                                                              write lib/db/src/schema/missing.ts <<'EOF'
                                                                                                                                              import { pgTable, serial, varchar, text, timestamp, doublePrecision, integer, jsonb } from 'drizzle-orm/pg-core';
                                                                                                                                              import { users } from './users.js';
                                                                                                                                              export const missingPersons = pgTable('missing_persons', {
                                                                                                                                                id: serial('id').primaryKey(),
                                                                                                                                                  userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
                                                                                                                                                    name: text('name').notNull(),
                                                                                                                                                      age: integer('age'),
                                                                                                                                                        gender: varchar('gender', { length: 16 }),
                                                                                                                                                          lastSeenLocation: text('last_seen_location').notNull(),
                                                                                                                                                            lastSeenAt: timestamp('last_seen_at', { withTimezone: true }).notNull(),
                                                                                                                                                              description: text('description').notNull(),
                                                                                                                                                                photoUrl: text('photo_url'),
                                                                                                                                                                  latitude: doublePrecision('latitude'),
                                                                                                                                                                    longitude: doublePrecision('longitude'),
                                                                                                                                                                      status: varchar('status', { length: 16 }).notNull().default('active'),
                                                                                                                                                                        aiAnalysis: jsonb('ai_analysis'),
                                                                                                                                                                          createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                                                                                                          });
                                                                                                                                                                          EOF
                                                                                                                                                                          
                                                                                                                                                                          write lib/db/src/schema/tracking.ts <<'EOF'
                                                                                                                                                                          import { pgTable, serial, integer, doublePrecision, real, timestamp, index } from 'drizzle-orm/pg-core';
                                                                                                                                                                          import { users } from './users.js';
                                                                                                                                                                          export const trackingPings = pgTable('tracking_pings', {
                                                                                                                                                                            id: serial('id').primaryKey(),
                                                                                                                                                                              userId: integer('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
                                                                                                                                                                                latitude: doublePrecision('latitude').notNull(),
                                                                                                                                                                                  longitude: doublePrecision('longitude').notNull(),
                                                                                                                                                                                    accuracy: real('accuracy'),
                                                                                                                                                                                      createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                                                                                                                      }, (t) => ({ userTimeIdx: index('tracking_user_time_idx').on(t.userId, t.createdAt) }));
                                                                                                                                                                                      EOF
                                                                                                                                                                                      
                                                                                                                                                                                      write lib/db/src/schema/conversations.ts <<'EOF'
                                                                                                                                                                                      import { pgTable, serial, integer, text, timestamp, varchar } from 'drizzle-orm/pg-core';
                                                                                                                                                                                      import { users } from './users.js';
                                                                                                                                                                                      export const conversations = pgTable('conversations', {
                                                                                                                                                                                        id: serial('id').primaryKey(),
                                                                                                                                                                                          userId: integer('user_id').references(() => users.id, { onDelete: 'set null' }),
                                                                                                                                                                                            title: text('title').notNull(),
                                                                                                                                                                                              createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                                                                                                                              });
                                                                                                                                                                                              export const messages = pgTable('messages', {
                                                                                                                                                                                                id: serial('id').primaryKey(),
                                                                                                                                                                                                  conversationId: integer('conversation_id').notNull().references(() => conversations.id, { onDelete: 'cascade' }),
                                                                                                                                                                                                    role: varchar('role', { length: 16 }).notNull(),
                                                                                                                                                                                                      content: text('content').notNull(),
                                                                                                                                                                                                        createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                                                                                                                                        });
                                                                                                                                                                                                        EOF
                                                                                                                                                                                                        
                                                                                                                                                                                                        write lib/db/src/schema/audit.ts <<'EOF'
                                                                                                                                                                                                        import { pgTable, serial, integer, varchar, jsonb, timestamp } from 'drizzle-orm/pg-core';
                                                                                                                                                                                                        import { users } from './users.js';
                                                                                                                                                                                                        export const auditLogs = pgTable('audit_logs', {
                                                                                                                                                                                                          id: serial('id').primaryKey(),
                                                                                                                                                                                                            actorUserId: integer('actor_user_id').references(() => users.id, { onDelete: 'set null' }),
                                                                                                                                                                                                              action: varchar('action', { length: 64 }).notNull(),
                                                                                                                                                                                                                entityType: varchar('entity_type', { length: 32 }).notNull(),
                                                                                                                                                                                                                  entityId: integer('entity_id').notNull(),
                                                                                                                                                                                                                    changes: jsonb('changes'),
                                                                                                                                                                                                                      createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
                                                                                                                                                                                                                      });
                                                                                                                                                                                                                      EOF
                                                                                                                                                                                                                      
                                                                                                                                                                                                                      write lib/db/src/schema/index.ts <<'EOF'
                                                                                                                                                                                                                      export * from './users.js';
                                                                                                                                                                                                                      export * from './branches.js';
                                                                                                                                                                                                                      export * from './reports.js';
                                                                                                                                                                                                                      export * from './missing.js';
                                                                                                                                                                                                                      export * from './tracking.js';
                                                                                                                                                                                                                      export * from './conversations.js';
                                                                                                                                                                                                                      export * from './audit.js';
                                                                                                                                                                                                                      EOF
                                                                                                                                                                                                                      
                                                                                                                                                                                                                      write lib/db/src/seed.ts <<'EOF'
                                                                                                                                                                                                                      import bcrypt from 'bcryptjs';
                                                                                                                                                                                                                      import { db, sql } from './client.js';
                                                                                                                                                                                                                      import { users, branches } from './schema/index.js';
                                                                                                                                                                                                                      async function main() {
                                                                                                                                                                                                                        const adminHash = await bcrypt.hash('Admin@1234', 12);
                                                                                                                                                                                                                          const userHash = await bcrypt.hash('User@1234', 12);
                                                                                                                                                                                                                            await db.insert(users).values([
                                                                                                                                                                                                                                { username: 'admin', phone: '0500000000', passwordHash: adminHash, fullName: 'Admin', role: 'admin' },
                                                                                                                                                                                                                                    { username: 'citizen', phone: '0511111111', passwordHash: userHash, fullName: 'Mohammed', role: 'citizen' },
                                                                                                                                                                                                                                      ]).onConflictDoNothing();
                                                                                                                                                                                                                                        await db.insert(branches).values([
                                                                                                                                                                                                                                            { name: 'شرطة الرياض', nameEn: 'Riyadh Police', category: 'police', city: 'Riyadh', phone: '999', latitude: 24.7136, longitude: 46.6753 },
                                                                                                                                                                                                                                                { name: 'الدفاع المدني الرياض', nameEn: 'Civil Defense Riyadh', category: 'civil_defense', city: 'Riyadh', phone: '998', latitude: 24.7300, longitude: 46.6800 },
                                                                                                                                                                                                                                                    { name: 'الهلال الأحمر الرياض', nameEn: 'Red Crescent Riyadh', category: 'red_crescent', city: 'Riyadh', phone: '997', latitude: 24.7000, longitude: 46.6700 },
                                                                                                                                                                                                                                                        { name: 'أمانة الرياض', nameEn: 'Riyadh Municipality', category: 'municipality', city: 'Riyadh', phone: '940', latitude: 24.6900, longitude: 46.7200 },
                                                                                                                                                                                                                                                            { name: 'الكهرباء الرياض', nameEn: 'Electricity Riyadh', category: 'electricity', city: 'Riyadh', phone: '933', latitude: 24.7050, longitude: 46.6900 },
                                                                                                                                                                                                                                                                { name: 'حرس الحدود', nameEn: 'Border Guard', category: 'border_guard', city: 'Riyadh', phone: '994', latitude: 24.6800, longitude: 46.7100 },
                                                                                                                                                                                                                                                                    { name: 'شرطة المرور الرياض', nameEn: 'Traffic Police Riyadh', category: 'traffic_police', city: 'Riyadh', phone: '993', latitude: 24.7250, longitude: 46.6650 },
                                                                                                                                                                                                                                                                      ]).onConflictDoNothing();
                                                                                                                                                                                                                                                                        console.warn('seed completed');
                                                                                                                                                                                                                                                                          await sql.end();
                                                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                                                          main().catch((e) => { console.error(e); process.exit(1); });
                                                                                                                                                                                                                                                                          EOF
                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                          
