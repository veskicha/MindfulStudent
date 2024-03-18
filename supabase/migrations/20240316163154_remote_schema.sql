create type "public"."SleepTrackingService" as enum ('FITBIT');

create table "public"."oauth2_states" (
    "state" text not null default ''::text,
    "created_at" timestamp with time zone not null default now(),
    "verifier" text not null,
    "service" "SleepTrackingService" not null,
    "userId" uuid not null
);


alter table "public"."oauth2_states" enable row level security;

create table "public"."oauth2_tokens" (
    "user" uuid not null,
    "service" "SleepTrackingService" not null,
    "accessToken" text not null,
    "refreshToken" text,
    "expiresAt" timestamp with time zone
);


alter table "public"."oauth2_tokens" enable row level security;

CREATE UNIQUE INDEX oauth_states_pkey ON public.oauth2_states USING btree (state);

CREATE UNIQUE INDEX sleep_tracker_tokens_pkey ON public.oauth2_tokens USING btree ("user", service);

alter table "public"."oauth2_states" add constraint "oauth_states_pkey" PRIMARY KEY using index "oauth_states_pkey";

alter table "public"."oauth2_tokens" add constraint "sleep_tracker_tokens_pkey" PRIMARY KEY using index "sleep_tracker_tokens_pkey";

alter table "public"."oauth2_states" add constraint "oauth_states_state_check" CHECK ((length(state) > 10)) not valid;

alter table "public"."oauth2_states" validate constraint "oauth_states_state_check";

alter table "public"."oauth2_states" add constraint "oauth_states_verifier_check" CHECK ((length(verifier) > 10)) not valid;

alter table "public"."oauth2_states" validate constraint "oauth_states_verifier_check";

alter table "public"."oauth2_states" add constraint "public_oauth2_states_userId_fkey" FOREIGN KEY ("userId") REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."oauth2_states" validate constraint "public_oauth2_states_userId_fkey";

alter table "public"."oauth2_tokens" add constraint "public_sleep_tracker_tokens_user_fkey" FOREIGN KEY ("user") REFERENCES profiles(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."oauth2_tokens" validate constraint "public_sleep_tracker_tokens_user_fkey";

grant delete on table "public"."oauth2_states" to "anon";

grant insert on table "public"."oauth2_states" to "anon";

grant references on table "public"."oauth2_states" to "anon";

grant select on table "public"."oauth2_states" to "anon";

grant trigger on table "public"."oauth2_states" to "anon";

grant truncate on table "public"."oauth2_states" to "anon";

grant update on table "public"."oauth2_states" to "anon";

grant delete on table "public"."oauth2_states" to "authenticated";

grant insert on table "public"."oauth2_states" to "authenticated";

grant references on table "public"."oauth2_states" to "authenticated";

grant select on table "public"."oauth2_states" to "authenticated";

grant trigger on table "public"."oauth2_states" to "authenticated";

grant truncate on table "public"."oauth2_states" to "authenticated";

grant update on table "public"."oauth2_states" to "authenticated";

grant delete on table "public"."oauth2_states" to "service_role";

grant insert on table "public"."oauth2_states" to "service_role";

grant references on table "public"."oauth2_states" to "service_role";

grant select on table "public"."oauth2_states" to "service_role";

grant trigger on table "public"."oauth2_states" to "service_role";

grant truncate on table "public"."oauth2_states" to "service_role";

grant update on table "public"."oauth2_states" to "service_role";

grant delete on table "public"."oauth2_tokens" to "anon";

grant insert on table "public"."oauth2_tokens" to "anon";

grant references on table "public"."oauth2_tokens" to "anon";

grant select on table "public"."oauth2_tokens" to "anon";

grant trigger on table "public"."oauth2_tokens" to "anon";

grant truncate on table "public"."oauth2_tokens" to "anon";

grant update on table "public"."oauth2_tokens" to "anon";

grant delete on table "public"."oauth2_tokens" to "authenticated";

grant insert on table "public"."oauth2_tokens" to "authenticated";

grant references on table "public"."oauth2_tokens" to "authenticated";

grant select on table "public"."oauth2_tokens" to "authenticated";

grant trigger on table "public"."oauth2_tokens" to "authenticated";

grant truncate on table "public"."oauth2_tokens" to "authenticated";

grant update on table "public"."oauth2_tokens" to "authenticated";

grant delete on table "public"."oauth2_tokens" to "service_role";

grant insert on table "public"."oauth2_tokens" to "service_role";

grant references on table "public"."oauth2_tokens" to "service_role";

grant select on table "public"."oauth2_tokens" to "service_role";

grant trigger on table "public"."oauth2_tokens" to "service_role";

grant truncate on table "public"."oauth2_tokens" to "service_role";

grant update on table "public"."oauth2_tokens" to "service_role";


