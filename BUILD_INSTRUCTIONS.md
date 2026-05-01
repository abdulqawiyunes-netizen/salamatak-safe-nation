# BUILD_INSTRUCTIONS — للأداة المنفّذة (Claude Code / Copilot Workspace / Cursor / Windsurf)

## ملخص المهمة

أنت أداة AI ذات terminal فعلي. مهمتك: إكمال بناء تطبيق "سلامتك (Safe Nation AI)" بناءً على PROMPT.md في هذا المستودع، حتى يصبح التطبيق يعمل بالكامل بدون أخطاء.

## ما هو موجود فعلاً عند البداية

- README.md — توثيق شامل ثنائي اللغة
- - PROMPT.md — المواصفات الكاملة (المرجع الوحيد للبناء)
  - - package.json — جذر workspace
    - - pnpm-workspace.yaml
      - - tsconfig.base.json — TypeScript صارم
        - - .env.example — كل متغيرات البيئة موثقة
          - - .gitignore (Node)
            - - scaffold.sh — يحتوي على lib/db كامل (Drizzle schemas + migrate runner + seed بـ 7 فروع حكومية ومستخدمَي اختبار)
             
              - ## خطوات التنفيذ المطلوبة (بالترتيب)
             
              - ### الخطوة 0 — التهيئة
             
              - 1. تحقق من إصدار Node: يجب أن يكون 20 LTS. إذا لم يكن كذلك، استخدم nvm install 20 && nvm use 20.
                2. 2. ثبّت pnpm: npm install -g pnpm@9
                   3. 3. أنشئ ملف .env من .env.example: cp .env.example .env ثم عبّئ القيم (DATABASE_URL محلي، JWT_SECRET بـ openssl rand -hex 64، JWT_REFRESH_SECRET بنفس الطريقة، OPENAI_API_KEY اتركه فارغاً وسنضيف وضع mock في الكود).
                      4. 4. تأكد من تشغيل PostgreSQL 16 محلياً. إذا لم يكن متوفراً، شغّله بـ Docker: docker run --name salamatak-pg -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=salamatak -p 5432:5432 -d postgres:16.
                        
                         5. ### الخطوة 1 — تشغيل scaffold.sh لإنشاء lib/db
                        
                         6. bash scaffold.sh
                        
                         7. تحقق من إنشاء lib/db بمحتوى Drizzle schemas، runner للهجرة، seed.
                        
                         8. ### الخطوة 2 — تثبيت التبعيات الجذرية
                        
                         9. pnpm install
                        
                         10. ### الخطوة 3 — تنفيذ المرحلة 1 من PROMPT.md
                        
                         11. - أنشئ ESLint و Prettier configs على مستوى الجذر.
                             - - أنشئ lib/db/package.json (إن لم يكن موجوداً) مع scripts: typecheck, build, migrate, seed.
                               - - أضف drizzle.config.ts.
                                 - - شغّل: pnpm --filter @salamatak/db typecheck && pnpm --filter @salamatak/db build
                                   - - شغّل drizzle-kit generate ثم drizzle-kit migrate
                                     - - شغّل seed: pnpm --filter @salamatak/db seed
                                       - - quality gate: pnpm typecheck && pnpm lint
                                         - - git add -A && git commit -m "feat(phase-1): foundation + db migrate & seed"
                                          
                                           - ### الخطوة 4 — تنفيذ المرحلة 2 (Auth & Core API)
                                          
                                           - أنشئ artifacts/api-server بالبنية:
                                           - - src/index.ts (entry)
                                             - - src/app.ts (Express app)
                                               - - src/env.ts (Zod env validation)
                                                 - - src/middlewares/ (errorHandler, requestLogger, authGuard, roleGuard, rateLimit)
                                                   - - src/modules/auth/ (controller, service, routes, dto)
                                                     - - src/lib/ (logger Pino, response helpers, jwt helpers, password helpers)
                                                       - - tests/ (Vitest)
                                                        
                                                         - نفّذ endpoints:
                                                         - - POST /auth/register
                                                           - - POST /auth/login
                                                             - - POST /auth/refresh
                                                               - - GET /auth/me
                                                                
                                                                 - quality gate كامل، ثم commit.
                                                                
                                                                 - ### الخطوة 5 — تنفيذ المرحلة 3 (Reports & Missing)
                                                                
                                                                 - أضف modules/reports و modules/missing مع CRUD كامل، pagination, filters, audit_logs، اختبارات.
                                                                
                                                                 - ### الخطوة 6 — تنفيذ المرحلة 4 (SOS & Branches & Tracking)
                                                                
                                                                 - - POST /sos مع تخصيص أقرب فرع جغرافياً (Haversine).
                                                                   - - GET /branches مع تصفية geo (?lat=&lng=&radius_km=).
                                                                     - - POST /tracking/ping مع rate limit (مثلاً ping كل 10s لكل user).
                                                                      
                                                                       - ### الخطوة 7 — تنفيذ المرحلة 5 (AI Integration)
                                                                      
                                                                       - أنشئ lib/integrations-openai-ai-server:
                                                                       - - OpenAI client مع timeout (15s) و retry (3x exponential backoff).
                                                                         - - اكتب system prompt محترف بالعربي للسلامة العامة السعودية.
                                                                           - - إذا OPENAI_API_KEY فارغ: استخدم وضع mock يُرجع ردوداً ثابتة محترمة (لا تكسر التطبيق).
                                                                            
                                                                             - أضف في api-server:
                                                                             - - POST /ai/chat (SSE streaming).
                                                                               - - POST /ai/classify-report (يُصنّف نوع البلاغ من النص).
                                                                                 - - POST /ai/triage (يُحدّد أولوية SOS: low/medium/high/critical).
                                                                                   - - احفظ كل المحادثات في conversations + messages.
                                                                                    
                                                                                     - ### الخطوة 8 — تنفيذ المرحلة 6 (Admin)
                                                                                    
                                                                                     - أنشئ modules/admin مع endpoints stats/users/reports/branches و PATCH role، و audit_logs لكل عملية.
                                                                                    
                                                                                     - ### الخطوة 9 — تنفيذ المرحلة 7 (Frontend)
                                                                                    
                                                                                     - أنشئ artifacts/salamatak (Vite + React 18 + TS):
                                                                                     - - vite.config.ts مع PWA plugin.
                                                                                       - - tailwind.config.ts مع دعم RTL وخط Cairo.
                                                                                         - - src/main.tsx, src/App.tsx (Wouter routes).
                                                                                           - - src/pages/ (كل الصفحات في PROMPT.md).
                                                                                             - - src/components/ (Layout, AuthGuard, SOSButton, LiveMap, ChatWindow, LanguageSwitcher).
                                                                                               - - src/i18n/ (ar.json, en.json, useI18n hook).
                                                                                                 - - src/lib/api.ts (TanStack Query + lib/api-client-react).
                                                                                                   - - src/styles/globals.css (Tailwind + RTL).
                                                                                                    
                                                                                                     - ### الخطوة 10 — quality gate نهائي
                                                                                                    
                                                                                                     - pnpm -r typecheck
                                                                                                     - pnpm -r lint
                                                                                                     - pnpm -r test
                                                                                                     - pnpm -r build
                                                                                                    
                                                                                                     - شغّل التطبيق:
                                                                                                     - - Terminal 1: pnpm --filter @salamatak/api-server dev (port 4000)
                                                                                                       - - Terminal 2: pnpm --filter salamatak dev (port 5173)
                                                                                                        
                                                                                                         - اختبار يدوي: تسجيل، دخول، إنشاء بلاغ، SOS، AI chat، dashboard، تبديل اللغة.
                                                                                                        
                                                                                                         - ### الخطوة 11 — التسليم
                                                                                                        
                                                                                                         - - تأكد من أن كل الـ commits لها رسائل واضحة (Conventional Commits).
                                                                                                           - - ادفع للـ main: git push origin main.
                                                                                                             - - أنشئ tag: git tag v1.0.0 && git push --tags.
                                                                                                               - - أضف ملف SETUP.md يشرح كيفية التشغيل المحلي بثلاث خطوات للمطور القادم.
                                                                                                                
                                                                                                                 - ## قواعد عند مواجهة الأخطاء
                                                                                                                
                                                                                                                 - 1. لا تتجاهل خطأ TypeScript أبداً. أصلح الـ type بدلاً من as any.
                                                                                                                   2. 2. إذا فشل اختبار: اقرأ السبب، أصلحه، شغّل مرة ثانية.
                                                                                                                      3. 3. إذا فشل بناء frontend بسبب dependency: ثبّت الإصدار المحدد في PROMPT.md.
                                                                                                                         4. 4. إذا فشل drizzle migrate: تحقق من DATABASE_URL، لا تحذف الجدول إلا بإذن صريح.
                                                                                                                            5. 5. لا تستخدم disable لقواعد ESLint إلا إذا كان مبرراً ومُعلّقاً عليه.
                                                                                                                              
                                                                                                                               6. ## مؤشرات النجاح النهائية
                                                                                                                              
                                                                                                                               7. - pnpm -r typecheck passes
                                                                                                                                  - - pnpm -r lint passes (zero warnings)
                                                                                                                                    - - pnpm -r test passes (coverage 60%+ on critical services)
                                                                                                                                      - - pnpm -r build passes
                                                                                                                                        - - Manual smoke test passes for all flows
                                                                                                                                          - - Lighthouse a11y >= 90 on main pages
                                                                                                                                           
                                                                                                                                            - عند تحقق كل المؤشرات: التطبيق جاهز للنشر.
                                                                                                                                           
                                                                                                                                            - — انتهى —
                                                                                                                                            - 
