drop policy "permission for profiles" on "public"."profiles";

revoke select on table "public"."profiles" from "authenticated";

alter table "public"."messages" alter column "created_at" set default now();


