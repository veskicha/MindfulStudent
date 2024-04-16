revoke update on table "public"."connections" from "authenticated";

revoke insert on table "public"."messages" from "authenticated";

revoke update on table "public"."messages" from "authenticated";

revoke insert on table "public"."profiles" from "authenticated";

revoke select on table "public"."profiles" from "authenticated";

revoke update on table "public"."profiles" from "authenticated";

CREATE UNIQUE INDEX tasks_pkey ON public.tasks USING btree (id);

alter table "public"."tasks" add constraint "tasks_pkey" PRIMARY KEY using index "tasks_pkey";


