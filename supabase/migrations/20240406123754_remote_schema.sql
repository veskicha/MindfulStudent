revoke update on table "public"."connections" from "authenticated";

revoke insert on table "public"."messages" from "authenticated";

revoke update on table "public"."messages" from "authenticated";

revoke insert on table "public"."profiles" from "authenticated";

revoke update on table "public"."profiles" from "authenticated";

create table "public"."journal" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "title" text,
    "content" text,
    "user_id" uuid default auth.uid()
);


alter table "public"."journal" enable row level security;

create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "body" text not null
);


alter table "public"."notifications" enable row level security;

alter table "public"."profiles" add column "fcm_token" text not null default ''::text;

CREATE UNIQUE INDEX journal_pkey ON public.journal USING btree (id);

CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id);

alter table "public"."journal" add constraint "journal_pkey" PRIMARY KEY using index "journal_pkey";

alter table "public"."notifications" add constraint "notifications_pkey" PRIMARY KEY using index "notifications_pkey";

alter table "public"."journal" add constraint "public_journal_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."journal" validate constraint "public_journal_user_id_fkey";

alter table "public"."notifications" add constraint "public_notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "public_notifications_user_id_fkey";

grant delete on table "public"."journal" to "anon";

grant insert on table "public"."journal" to "anon";

grant references on table "public"."journal" to "anon";

grant select on table "public"."journal" to "anon";

grant trigger on table "public"."journal" to "anon";

grant truncate on table "public"."journal" to "anon";

grant update on table "public"."journal" to "anon";

grant delete on table "public"."journal" to "authenticated";

grant insert on table "public"."journal" to "authenticated";

grant references on table "public"."journal" to "authenticated";

grant select on table "public"."journal" to "authenticated";

grant trigger on table "public"."journal" to "authenticated";

grant truncate on table "public"."journal" to "authenticated";

grant update on table "public"."journal" to "authenticated";

grant delete on table "public"."journal" to "service_role";

grant insert on table "public"."journal" to "service_role";

grant references on table "public"."journal" to "service_role";

grant select on table "public"."journal" to "service_role";

grant trigger on table "public"."journal" to "service_role";

grant truncate on table "public"."journal" to "service_role";

grant update on table "public"."journal" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

create policy "Delete note"
on "public"."journal"
as permissive
for delete
to authenticated
using ((auth.uid() = user_id));


create policy "Read from journal"
on "public"."journal"
as permissive
for select
to authenticated
using ((auth.uid() = user_id));


create policy "Update notes"
on "public"."journal"
as permissive
for update
to authenticated
using ((auth.uid() = user_id));


create policy "insert_journal"
on "public"."journal"
as permissive
for insert
to authenticated
with check ((auth.uid() = user_id));


create policy "permission for profiles"
on "public"."profiles"
as permissive
for all
to public
using (true);


CREATE TRIGGER notification AFTER INSERT ON public.notifications FOR EACH ROW EXECUTE FUNCTION supabase_functions.http_request('https://jdghiexlhavidaqgcrqw.supabase.co/functions/v1/push', 'POST', '{"Content-type":"application/json"}', '{}', '1000');


