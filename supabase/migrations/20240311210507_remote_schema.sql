alter table "public"."connections" drop column "is_accepted";

alter table "public"."connections" add column "isMutual" boolean not null default false;

alter table "public"."connections" add constraint "con_notsame" CHECK ((source <> target)) not valid;

alter table "public"."connections" validate constraint "con_notsame";

alter table "public"."connections" add constraint "con_order" CHECK ((source <= target)) not valid;

alter table "public"."connections" validate constraint "con_order";

create policy "Enable users to accept connection requests"
on "public"."connections"
as permissive
for update
to public
using ((auth.uid() = target))
with check (("isMutual" = true));


create policy "Enable users to create pending connection requests"
on "public"."connections"
as permissive
for insert
to public
with check (((auth.uid() = source) AND ("isMutual" = false)));


create policy "Enable users to deny or break connections"
on "public"."connections"
as permissive
for delete
to public
using (((auth.uid() = source) OR (auth.uid() = target)));


create policy "Enable users to view connections from or to themselves"
on "public"."connections"
as permissive
for select
to public
using (((auth.uid() = source) OR (auth.uid() = target)));



