create type "public"."TaskFrequency" as enum ('DAILY', 'WEEKLY', 'MONTHLY');

drop policy "Delete note" on "public"."journal";

drop policy "Read from journal" on "public"."journal";

drop policy "Update notes" on "public"."journal";

drop policy "insert_journal" on "public"."journal";

alter table "public"."tasks" drop constraint "tasks_pkey";

drop index if exists "public"."tasks_pkey";

alter table "public"."tasks" drop column "completed";

alter table "public"."tasks" drop column "updated_at";

alter table "public"."tasks" add column "completed_at" timestamp with time zone;

alter table "public"."tasks" alter column "id" set default gen_random_uuid();

alter table "public"."tasks" alter column "id" set data type uuid using "id"::uuid;

alter table "public"."tasks" alter column "reminder" set data type "TaskFrequency" using "reminder"::"TaskFrequency";

alter table "public"."tasks" enable row level security;

drop sequence if exists "public"."tasks_id_seq";

create policy "Allow users to manage their own journal entries"
on "public"."journal"
as permissive
for all
to public
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



