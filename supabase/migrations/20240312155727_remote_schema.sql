alter table "public"."connections" drop constraint "con_order";

alter table "public"."messages" drop constraint "public_messages_from_id_fkey";

alter table "public"."messages" drop constraint "public_messages_to_id_fkey";

alter table "public"."messages" drop column "from_id";

alter table "public"."messages" drop column "to_id";

alter table "public"."messages" add column "from" uuid not null;

alter table "public"."messages" add column "to" uuid not null;

alter table "public"."messages" alter column "id" set default gen_random_uuid();

alter table "public"."messages" alter column "id" drop identity;

alter table "public"."messages" alter column "id" set data type uuid using "id"::uuid;

alter table "public"."messages" alter column "text" set default 'EMPTY'::text;

alter table "public"."messages" alter column "text" set data type text using "text"::text;

alter table "public"."reactions" alter column "messageId" drop identity;

alter table "public"."reactions" alter column "messageId" set data type uuid using "messageId"::uuid;

CREATE UNIQUE INDEX con_unique ON public.connections USING btree (LEAST(source, target), GREATEST(source, target));

alter table "public"."messages" add constraint "messages_text_check" CHECK (((length(text) > 0) AND (length(text) < 500))) not valid;

alter table "public"."messages" validate constraint "messages_text_check";

alter table "public"."messages" add constraint "public_messages_from_id_fkey" FOREIGN KEY ("from") REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "public_messages_from_id_fkey";

alter table "public"."messages" add constraint "public_messages_to_id_fkey" FOREIGN KEY ("to") REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."messages" validate constraint "public_messages_to_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.sort_and_concat(text, text)
 RETURNS text
 LANGUAGE sql
AS $function$
    SELECT CONCAT_WS(' ', LEAST($1, $2), GREATEST($1, $2));
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;

$function$
;

create policy "Enable users to delete their own messages"
on "public"."messages"
as permissive
for delete
to public
using ((auth.uid() = "from"));


create policy "Enable users to send messages to their connections"
on "public"."messages"
as permissive
for insert
to public
with check (((auth.uid() = "from") AND (EXISTS ( SELECT 1
   FROM connections c
  WHERE (((messages."from" = c.source) AND (messages."to" = c.target) AND (c."isMutual" = true)) OR ((messages."from" = c.target) AND (messages."to" = c.source) AND (c."isMutual" = true)))))));


create policy "Enable users to view messages sent by or to them"
on "public"."messages"
as permissive
for select
to public
using (((auth.uid() = "from") OR (auth.uid() = "to")));



