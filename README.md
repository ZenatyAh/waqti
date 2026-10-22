# وقتي: تطبيق تنظيم اليوم على مواقيت الصلاة

## 1) تشغيل محلي سريع
داخل هذا المجلد: `python3 -m http.server 8000` ثم افتح `http://localhost:8000`.

## 2) ربط التخزين السحابي (Supabase)
1. أنشئ مشروعًا مجانيًا على supabase.com.
2. من **SQL Editor** الصق محتوى `supabase/schema.sql` ونفّذه (Run).
3. من **Project Settings > API** انسخ `Project URL` ومفتاح `anon` (أو publishable) إلى `config.js`.
4. من **Authentication > Providers > Email** اترك البريد وكلمة المرور مفعّلين. لأنك مستخدم واحد يمكنك تعطيل "Confirm email" لتسجيل الدخول فورًا، أو اتركه مفعّلًا وأكّد من بريدك.
5. من **Authentication > URL Configuration** أضف عنوان موقعك المستضاف في Site URL.
6. افتح التطبيق: **الإعدادات > الحساب والمزامنة** وأنشئ حسابك أو سجّل الدخول.

بعد الدخول تُرفع بياناتك الحالية تلقائيًا وتتزامن بين كل أجهزتك.

## 3) الاستضافة
ارفع المجلد كما هو إلى Netlify (اسحبه إلى netlify.com/drop) أو GitHub Pages أو Cloudflare Pages. لا يلزم أي بناء.

## ملاحظات
- التطبيق يعمل بدون إنترنت ويزامن عند عودة الاتصال.
- الأمان: كل صف مربوط بحسابك، وسياسة RLS تمنع غيرك من قراءته. لا تنشر مفتاح `service_role` أبدًا.
- لاستعلامات مباشرة على وقتك: `select * from report_task_time order by minutes desc;`
