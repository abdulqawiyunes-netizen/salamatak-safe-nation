# سلامتك (Safe Nation AI) — Master Build Prompt

> هذا الملف هو التعليمات الكاملة لأي أداة AI ذات terminal فعلي (Claude Code / Copilot Workspace / Cursor / Windsurf) لإكمال بناء التطبيق بالكامل من نقطة البداية الحالية حتى تطبيق منتج جاهز للنشر.
>
> ## كيفية الاستخدام (للمستخدم النهائي)
>
> 1. افتح الـ Codespace الموجود على هذا المستودع، أو استنسخ المستودع محلياً.
> 2. 2. شغّل أداة AI ذات terminal فعلي داخل المستودع (Claude Code موصى بها).
>    3. 3. أعطِ الأداة الأمر التالي بالضبط:
>      
>       4.    اقرأ PROMPT.md و BUILD_INSTRUCTIONS.md في هذا المستودع، ثم نفّذ كل المراحل من 1 إلى 7 بالترتيب، مع quality gates بعد كل مرحلة، حتى يصبح التطبيق يعمل بالكامل بدون أخطاء.
>      
>       5.4. الأداة ستبني التطبيق كاملاً وتشغّل اختبارات البناء وتصلح أي أخطاء حتى يعمل التطبيق فعلياً.
>
> ---
>
> ## 1. الهوية والهدف
>
> - اسم المنتج: سلامتك (Safe Nation AI)
> - - الفئة: منصة سلامة عامة سعودية
>   - - اللغة: عربي أولاً (RTL) + إنجليزي ثانوي (LTR)
>     - - الجمهور: المواطنون والمقيمون في المملكة العربية السعودية + الجهات الحكومية المختصة
>       - - الوظائف الرئيسية: بلاغات، أشخاص مفقودون، SOS، تتبع، مساعد ذكي بالذكاء الاصطناعي، لوحة إدارية
>        
>         - ## 2. القواعد الحرجة (لا تُكسر أبداً)
>        
>         - 1. TypeScript صارم في كل مكان: ممنوع any، ممنوع ts-ignore، ممنوع as any. استخدم unknown + narrowing.
>           2. 2. لا فشل صامت: كل مسار async له try/catch أو catch.
>              3. 3. تحقق Zod عند كل حد (request body, query, params, env, AI responses).
>                 4. 4. شكل استجابة موحّد: ok:true/data أو ok:false/error code+message.
>                    5. 5. quality gates بعد كل مرحلة: pnpm typecheck && pnpm lint && pnpm test && pnpm build && manual smoke && git commit.
>                       6. 6. ممنوع رفع أسرار. كل الأسرار من process.env. ووثّقها في .env.example.
>                          7. 7. هجرات قابلة لإعادة التشغيل عبر drizzle-kit.
>                             8. 8. انضباط Logging (Pino): لا تسجّل كلمات مرور أو tokens أو PII.
>                                9. 9. لا منطق وقت هش: استخدم UTC على الخادم.
>                                   10. 10. الوصولية إلزامية: aria-label، تنقل بلوحة المفاتيح، focus-visible، تباين WCAG AA.
>                                      
>                                       11. ## 3. حزمة التقنيات
>                                      
>                                       12. Backend: Node.js 20 LTS, pnpm 9, Express 5, TypeScript 5.6+, Drizzle ORM, PostgreSQL 16, Pino, jsonwebtoken, bcryptjs (cost 12+), zod 3.23+, openai 4.x
>                                      
>                                       13. Frontend: Vite 5, React 18, Wouter, TailwindCSS 3.4, Radix UI, React Hook Form, TanStack Query v5, Lucide, Leaflet, idb-keyval, date-fns
>
> ## 4. تخطيط المستودع (monorepo)
>
> - artifacts/api-server (Express backend)
> - - artifacts/salamatak (React frontend)
>   - - lib/db (Drizzle schemas + migrations + seed)
>     - - lib/api-zod (Zod schemas مشتركة)
>       - - lib/api-spec (OpenAPI spec)
>         - - lib/api-client-react (عميل API)
>           - - lib/integrations-openai-ai-server (تكامل OpenAI server)
>             - - lib/integrations-openai-ai-react (hooks frontend)
>              
>               - ## 5. مخطط قاعدة البيانات (8 جداول)
>              
>               - users, branches, reports, missing_persons, tracking_pings, conversations, messages, audit_logs
>              
>               - كل التفاصيل في scaffold.sh الموجود في الجذر — schemas مكتوبة بالكامل في Drizzle، مع seed لـ 7 فروع حكومية سعودية ومستخدمَي اختبار.
>
> ## 6. المراحل (نفّذ بالترتيب الصارم)
>
> المرحلة 1 — الأساس: monorepo, ESLint+Prettier, env validation (Zod), lib/db (شغّل scaffold.sh)، quality gate + commit.
>
> المرحلة 2 — Auth & Core API: POST /auth/register, /auth/login, /auth/refresh, /auth/me. middlewares: errorHandler, requestLogger, authGuard, roleGuard, rateLimit. JWT HS256 بسر 64+ hex. bcrypt cost 12.
>
> المرحلة 3 — Reports & Missing API: CRUD /reports (citizen create, officer update status), CRUD /missing, pagination + filters + Zod, audit_logs على كل تغيير حالة.
>
> المرحلة 4 — SOS & Branches API: POST /sos (إشعار فوري + تخصيص أقرب فرع جغرافياً). GET /branches (مع تصفية geo). POST /tracking/ping (rate-limited).
>
> المرحلة 5 — تكامل الذكاء الاصطناعي: lib/integrations-openai-ai-server (client مع retry وtimeout). POST /ai/chat (streaming SSE). POST /ai/classify-report. POST /ai/triage. system prompt عربي محترف للسلامة العامة السعودية. حفظ المحادثات في conversations + messages.
>
> المرحلة 6 — Admin API: GET /admin/stats, /admin/users, /admin/reports, /admin/branches (pagination). PATCH /admin/users/:id/role. audit_logs لكل عملية إدارية.
>
> المرحلة 7 — Frontend (Vite + React):
>
> صفحات (25+): Landing, login, register, dashboard, reports/*, missing/*, /sos, /tracking, /assistant, /branches, /profile, /settings, /admin/*, /404, /offline.
>
> مكونات: Layout, AuthGuard, RoleGuard, ReportCard, MissingCard, BranchCard, SOSButton (large + accessible + haptic), LiveMap (Leaflet), ChatWindow (streaming + markdown), LanguageSwitcher.
>
> i18n: locales/ar.json + locales/en.json. HTML dir/lang ديناميكي. خط Cairo أو IBM Plex Sans Arabic للعربي.
>
> Offline: Vite PWA plugin + idb-keyval لحفظ البلاغات وSOS draft. مزامنة عند العودة للاتصال.
>
> Forms: React Hook Form + Zod resolvers (نفس مخططات lib/api-zod).
>
> quality gate نهائي: typecheck + lint + test + build لكل من api-server وsalamatak. اختبار يدوي: تسجيل، دخول، بلاغ، SOS، AI chat، admin.
>
> ## 7. متغيرات البيئة
>
> انظر .env.example. الأساسيات: DATABASE_URL, JWT_SECRET (64 hex), JWT_REFRESH_SECRET, OPENAI_API_KEY, PORT, NODE_ENV, LOG_LEVEL, CORS_ORIGINS.
>
> ## 8. معايير القبول
>
> - pnpm typecheck يمر بدون أي خطأ في كل الحزم
> - - pnpm lint يمر بدون warnings
>   - - pnpm test يمر (تغطية 60%+ للـ services الحرجة)
>     - - pnpm build ينتج dist نظيف
>       - - pnpm dev يفتح frontend على 5173 وbackend على 4000
>         - - يمكن: تسجيل، دخول، إنشاء بلاغ، SOS، AI chat
>           - - التبديل بين العربي والإنجليزي يعمل (dir + content)
>             - - Lighthouse a11y >= 90
>              
>               - ## 9. ملاحظات للأداة المنفذة
>              
>               - - ابدأ من ما هو موجود فعلاً: package.json, pnpm-workspace.yaml, tsconfig.base.json, .env.example, scaffold.sh.
>                 - - شغّل scaffold.sh أولاً لإنشاء lib/db.
>                   - - ثم أنشئ بقية الحزم واحدة واحدة وفق المراحل.
>                     - - استخدم drizzle-kit generate ثم drizzle-kit migrate قبل seed.
>                       - - لا تخترع APIs غير موجودة في هذا المستند.
>                         - - إذا واجهت غموضاً، اختر الخيار الأبسط والأكثر أماناً.
>                           - - بعد كل مرحلة: نفّذ quality gate و commit برسالة واضحة (feat:, fix:, chore:).
>                            
>                             - — انتهى —
>                             - 
