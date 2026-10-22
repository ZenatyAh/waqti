-- وقتي: مخطط قاعدة البيانات على Supabase
-- الصق هذا الملف كاملًا في: Supabase > SQL Editor > New query ثم Run
-- كل جدول يخزن سجلات المستخدم كوثائق JSON، ولا يرى أي مستخدم إلا بياناته (RLS).

do $$
declare t text;
begin
  foreach t in array array['projects','tasks','sessions','day_logs','settings','habits','goals','journals'] loop
    execute format($f$
      create table if not exists public.%I (
        user_id    uuid        not null default auth.uid() references auth.users(id) on delete cascade,
        id         text        not null,
        data       jsonb       not null default '{}'::jsonb,
        deleted    boolean     not null default false,
        updated_at timestamptz not null default now(),
        primary key (user_id, id)
      )$f$, t);
    execute format('create index if not exists %I on public.%I (user_id, updated_at)', t || '_upd', t);
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "own rows" on public.%I', t);
    execute format('create policy "own rows" on public.%I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
  end loop;
end $$;

-- وقت التعديل يُضبط من الخادم دائمًا ليعتمد عليه السحب بين الأجهزة
create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

do $$
declare t text;
begin
  foreach t in array array['projects','tasks','sessions','day_logs','settings','habits','goals','journals'] loop
    execute format('drop trigger if exists %I on public.%I', t || '_touch', t);
    execute format('create trigger %I before insert or update on public.%I for each row execute function public.touch_updated_at()', t || '_touch', t);
  end loop;
end $$;

-- تقرير جاهز للاستعلام المباشر: الوقت المسجّل لكل مهمة (بالدقائق)
create or replace view public.report_task_time with (security_invoker = true) as
select se.user_id,
       se.data->>'id'        as task_id,
       t.data->>'title'      as title,
       t.data->>'projectId'  as project_id,
       round(sum(((se.data->>'e')::bigint - (se.data->>'s')::bigint) / 60000.0), 1) as minutes,
       count(*)              as sessions
from public.sessions se
left join public.tasks t on t.user_id = se.user_id and t.id = se.data->>'id'
where not se.deleted
group by 1, 2, 3, 4;
