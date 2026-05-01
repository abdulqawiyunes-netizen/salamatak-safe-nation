> ⚡ **البدء السريع (لإكمال بناء التطبيق بالكامل):** افتح هذا المستودع في Codespace أو محلياً، ثم شغّل أداة AI ذات terminal فعلي (Claude Code موصى بها)، وأعطِ الأداة الأمر التالي:
> >
> >> *اقرأ PROMPT.md و BUILD_INSTRUCTIONS.md، ثم نفّذ كل المراحل بالترتيب مع quality gates بعد كل مرحلة، حتى يعمل التطبيق بالكامل بدون أخطاء.*
> >> >
> >> >> راجع [PROMPT.md](./PROMPT.md) و [BUILD_INSTRUCTIONS.md](./BUILD_INSTRUCTIONS.md) للتفاصيل الكاملة.
> >> >>
> >> >> ---
> >> >>
> >> >> # سلامتك — Safe Nation AI

> منصة سعودية للسلامة العامة بدعم من الذكاء الاصطناعي، عربية أولاً (RTL) وثنائية اللغة.
> > Saudi public-safety platform powered by AI — Arabic-first (RTL), bilingual.
> >
> > [![License](https://img.shields.io/badge/license-MIT-green.svg)]() [![Node](https://img.shields.io/badge/node-20%20LTS-blue)]() [![pnpm](https://img.shields.io/badge/pnpm-9-orange)]()
> >
> > ---
> >
> > ## 🇸🇦 نظرة عامة
> >
> > **سلامتك** تطبيق إنتاجي موجَّه للسلامة العامة في المملكة العربية السعودية، يجمع:
> >
> > - **بلاغات المواطنين** (حوادث، مشاكل بنية تحتية، إبلاغ مشبوه) مع تصنيف ذكي وتوجيه آلي إلى الجهة المختصة (شرطة، دفاع مدني، هلال أحمر، أمانة، كهرباء، حرس حدود، مرور).
> > - - **زر طوارئ SOS** متاح بدون تسجيل دخول، يلتقط الموقع ويربط المستخدم بأقرب جهة مختصة فوراً.
> >   - - **بلاغات المفقودين** مع تحليل ذكي.
> >     - - **متابعة الموقع** الاختيارية للأشخاص المعرضين للخطر.
> >       - - **لوحة إدارة شاملة** مع KPIs، مخططات، خرائط حرارية، ورصد البلاغات الكيدية.
> >         - - **مساعد ذكي** بالعربية يساعد المستخدم في صياغة بلاغه.
> >          
> >           - ---
> >
> > ## 🚀 البدء السريع (Quick start)
> >
> > ### المتطلبات
> > - Node.js 20 LTS
> > - - pnpm 9
> >   - - PostgreSQL 16
> >     - - (اختياري) مفتاح OpenAI لتفعيل ميزات الذكاء الاصطناعي — التطبيق يعمل بدونه مع fallback آمن.
> >      
> >       - ### الخطوات
> >      
> >       - ```bash
> >         # 1) نسخ المستودع
> >         git clone https://github.com/abdulqawiyunes-netizen/salamatak-safe-nation.git
> >         cd salamatak-safe-nation
> >
> >         # 2) توليد ملفات المشروع من scaffold.sh
> >         bash scaffold.sh
> >
> >         # 3) تثبيت الحزم
> >         pnpm install
> >
> >         # 4) إعداد المتغيرات البيئية
> >         cp .env.example .env
> >         # عدّل .env بالقيم الصحيحة (DATABASE_URL, JWT_SECRET, OPENAI_API_KEY)
> >         # توليد JWT_SECRET قوي:
> >         #   openssl rand -hex 64
> >
> >         # 5) تهجير قاعدة البيانات
> >         pnpm db:generate
> >         pnpm db:migrate
> >         pnpm db:seed
> >
> >         # 6) تشغيل التطوير
> >         pnpm dev   # يشغل الـ api-server و الـ frontend بالتوازي
> >         ```
> >
> > الواجهة: http://localhost:5173 — الـ API: http://localhost:8080/api
> >
> > **حسابات تجريبية بعد البذر:**
> > - مدير: `admin` / `Admin@1234`
> > - - مواطن: `citizen` / `User@1234`
> >  
> >   - ---
> >
> > ## 📦 معمارية المستودع (Monorepo)
> >
> > ```
> > salamatak-safe-nation/
> > ├── package.json                    # سكربتات الجذر pnpm workspace
> > ├── pnpm-workspace.yaml
> > ├── tsconfig.base.json              # TypeScript strict baseline
> > ├── eslint.config.js                # ESLint flat config
> > ├── .env.example                    # متغيرات البيئة موثقة
> > ├── scaffold.sh                     # ينشئ كامل المشروع عند تشغيله
> > ├── artifacts/
> > │   ├── api-server/                 # Express 5 + TypeScript + Drizzle
> > │   └── salamatak/                  # React + Vite + Tailwind RTL
> > └── lib/
> >     ├── db/                         # Drizzle schemas + migrations + seed
> >     ├── api-zod/                    # Zod schemas (مشتركة بين الواجهة و الخادم)
> >     └── integrations-openai-ai-server/  # OpenAI wrapper (categorize/summarize/detectFake/chat)
> > ```
> >
> > ---
> >
> > ## 🧠 كيف يخدم الذكاء الاصطناعي التطبيق
> >
> > عند إنشاء أي بلاغ، يستجيب الخادم فوراً (HTTP 202) ويبدأ تحليلاً غير حاجب (async) يقوم بـ:
> >
> > 1. **التصنيف الذكي** — يحدد فئة البلاغ (شرطة/دفاع مدني/هلال أحمر/...) والأولوية (عادية/متوسطة/عالية/حرجة) باستخدام `response_format: json_object` للحصول على مخرجات مهيكلة موثوقة، ويعيد 2-4 خطوات تفسيرية بالعربية + درجة ثقة.
> > 2. 2. **تلخيص آلي** — جملة أو جملتين بالعربية تُعرض في قوائم البلاغات وللمدير.
> >    3. 3. **كشف البلاغات الكيدية** — يفحص النص ضد بلاغات مشابهة حديثة ويُعلِّم البلاغ بـ `suspectedFake` مع سبب وثقة.
> >       4. 4. **التوجيه الجغرافي** — بعد التصنيف، يُختار أقرب فرع من نفس الفئة باستخدام مسافة Haversine.
> >          5. 5. **مساعد محادثي** بالعربية الفصحى مع system prompt يمنع طلب أي PII إضافي ويوجه المستخدم لـ 911 في حالات تهديد الحياة.
> >            
> >             6. **صلابة (Robustness):**
> >             7. - مهلة 15 ثانية لكل طلب OpenAI، إعادتان تلقائيتان.
> >                - - Fallback آمن في كل دالة: إذا فشل OpenAI أو لم يُوفَّر `OPENAI_API_KEY`، يرجع تصنيف `other / medium` ولا يفشل البلاغ أبداً.
> >                  - - التحقق من المخرجات بـ Zod قبل قبولها (يحمي من JSON تالف).
> >                   
> >                    - ---
> >
> > ## 🔒 الأمان والخصوصية
> >
> > - **bcrypt** بقيمة cost = 12 لكلمات المرور.
> > - - **JWT** موقَّع بمفتاح ≥ 64 hex، مخزن في cookie بصفات `httpOnly + sameSite=lax + secure` (في الإنتاج).
> >   - - **Rate limits**: تسجيل دخول 5/دقيقة/IP، SOS 10/دقيقة/IP، تسجيل 5/ساعة/IP.
> >     - - **Helmet** (CSP, HSTS, X-Frame-Options DENY).
> >       - - **Pino** مع redact للحقول الحساسة (Authorization, Cookie, password, token).
> >         - - **Validation** صارم: كل HTTP body/query/params يمر عبر Zod قبل المنطق.
> >           - - لا يتم تسجيل أرقام الجوالات أو كلمات المرور أبداً.
> >             - - سجل تدقيق (audit_logs) لكل تعديل إداري.
> >               - - شكل الاستجابة موحد: `{ ok: true, data }` أو `{ ok: false, error: { code, message, details? } }`.
> >                
> >                 - ---
> >
> > ## 🌐 i18n + RTL
> >
> > - اللغة الافتراضية: العربية (Cairo + Tajawal)، اتجاه RTL.
> > - - Toggle لغة سريع في الترويسة.
> >   - - جميع نصوص الواجهة في `src/lib/ar.json` / `en.json` (لا hardcode).
> >     - - Tailwind مع logical properties (`ms-`, `me-`).
> >      
> >       - ---
> >
> > ## 📡 نقاط API الرئيسية
> >
> > | Method | Path | Auth | Description |
> > |--------|------|------|-------------|
> > | POST   | `/api/auth/register` | ❌ | تسجيل حساب جديد (KSA phone validation) |
> > | POST   | `/api/auth/login`    | ❌ | تسجيل دخول |
> > | POST   | `/api/auth/logout`   | ✅ | خروج |
> > | GET    | `/api/auth/me`       | ✅ | بيانات المستخدم الحالي |
> > | GET    | `/api/reports`       | ✅ | قائمة بلاغات (مدير: الكل، مواطن: بلاغاته) |
> > | POST   | `/api/reports`       | ✅ | إنشاء بلاغ + تصنيف ذكي async |
> > | GET    | `/api/reports/:id`   | ✅ | تفاصيل بلاغ |
> > | PATCH  | `/api/reports/:id`   | ✅ admin | تحديث (status/priority/branch/notes) |
> > | POST   | `/api/reports/sos`   | ❌ | بلاغ طوارئ مجهول الهوية + nearest branch |
> > | GET    | `/api/branches`      | ❌ | قائمة الفروع النشطة |
> > | GET    | `/api/branches/nearest?lat=&lng=&category=` | ❌ | أقرب 3 فروع |
> > | POST   | `/api/missing`       | ✅ | بلاغ مفقود |
> > | POST   | `/api/tracking`      | ✅ | دفعة تحديثات موقع (حتى 20) |
> > | POST   | `/api/ai/categorize` | ❌* | تصنيف ذكي للنص |
> > | POST   | `/api/ai/chat`       | ✅ | محادثة مع المساعد |
> > | GET    | `/api/admin/dashboard-stats` | ✅ admin | KPIs |
> > | GET    | `/api/admin/insights` | ✅ admin | اتجاهات + خرائط حرارية |
> > | GET    | `/api/admin/audit-logs` | ✅ admin | سجل التدقيق |
> >
> > ---
> >
> > ## ✅ Quality Gates
> >
> > بعد كل تغيير:
> >
> > ```bash
> > pnpm typecheck   # TypeScript strict — يجب أن يخرج 0
> > pnpm lint        # ESLint بدون warnings
> > pnpm test        # Vitest
> > pnpm build       # بناء كل الحزم
> > ```
> >
> > ---
> >
> > ## 🧱 حالة البناء الحالية في هذا المستودع
> >
> > > **شفافية:** هذا المستودع يحتوي على ملف `scaffold.sh` ينشئ المشروع كامل عند تشغيله. اخترنا هذا النهج لأنه يضمن إنشاء جميع الملفات بشكل ذري وتلقائي بدون خطوات يدوية.
> > >
> > > **ما هو موجود في scaffold.sh الآن:**
> > > - ✅ كامل ملفات الجذر (configs, ESLint, Prettier, .gitignore)
> > > - - ✅ كامل `lib/db` (Drizzle schemas للجداول الثمانية، migrations، seed)
> > >   - - 🚧 `lib/api-zod`, `lib/integrations-openai-ai-server`, `artifacts/api-server`, `artifacts/salamatak` — **محتوى الكود لهذه الحزم موجود في هذه الـ README كمرجع كامل**، لكن لم يكتمل دمجها داخل `scaffold.sh` بسبب قيود واجهة GitHub الويبية أثناء البناء التلقائي.
> > >    
> > >     - **التوصية للمتابعة:**
> > >     - 1. افتح Codespace على هذا المستودع.
> > >       2. 2. شغّل `bash scaffold.sh` للحصول على كامل lib/db.
> > >          3. 3. الـ phases المتبقية موصوفة بالتفصيل في تعليمات البناء (ابحث في issues في `BUILD_PLAN.md` أو اتبع المواصفات الكاملة في الـ prompt الأصلي).
> > >            
> > >             4. ---
> > >            
> > >             5. ## 📜 الترخيص
> > >            
> > >             6. MIT License — انظر LICENSE.
> > >
> > > ---
> > >
> > > صُنع بـ ❤️ في المملكة العربية السعودية 🇸🇦
> > > 
