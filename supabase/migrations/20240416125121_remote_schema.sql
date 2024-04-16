
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

CREATE SCHEMA IF NOT EXISTS "public";

ALTER SCHEMA "public" OWNER TO "pg_database_owner";

COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE TYPE "public"."MessageReaction" AS ENUM (
    'RED_HEART'
);

ALTER TYPE "public"."MessageReaction" OWNER TO "postgres";

CREATE TYPE "public"."SleepTrackingService" AS ENUM (
    'FITBIT'
);

ALTER TYPE "public"."SleepTrackingService" OWNER TO "postgres";

CREATE TYPE "public"."TaskFrequency" AS ENUM (
    'DAILY',
    'WEEKLY',
    'MONTHLY'
);

ALTER TYPE "public"."TaskFrequency" OWNER TO "postgres";

CREATE TYPE "public"."UserRole" AS ENUM (
    'USER',
    'HEALTH_EXPERT'
);

ALTER TYPE "public"."UserRole" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (id, name) values (new.id, new.raw_user_meta_data->>'name');
  return new;
end;

$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."notify_conn_success"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into notifications (user_id, title, body)
  values (NEW."target", 'New friend added!', 'You and ' || (select name from profiles where id = NEW."source") || ' are now friends!');
  insert into notifications (user_id, title, body)
  values (NEW."source", 'New friend added!', 'You and ' || (select name from profiles where id = NEW."target") || ' are now friends!');

  return new;
end;
$$;

ALTER FUNCTION "public"."notify_conn_success"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."notify_recv_conn_req"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into notifications (user_id, title, body)
  values (NEW."target", 'Connection request', (select name from profiles where id = NEW."source") || ' wants to connect with you!');
  return new;
end;
$$;

ALTER FUNCTION "public"."notify_recv_conn_req"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."notify_recv_message"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into notifications (user_id, title, body)
  values (NEW."to", 'Message from ' || (select name from profiles where id = NEW."from"), NEW."text");
  return new;
end;
$$;

ALTER FUNCTION "public"."notify_recv_message"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."sort_and_concat"("text", "text") RETURNS "text"
    LANGUAGE "sql"
    AS $_$
    SELECT CONCAT_WS(' ', LEAST($1, $2), GREATEST($1, $2));
$_$;

ALTER FUNCTION "public"."sort_and_concat"("text", "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."connections" (
    "source" "uuid" NOT NULL,
    "target" "uuid" NOT NULL,
    "isMutual" boolean DEFAULT false NOT NULL,
    CONSTRAINT "con_notsame" CHECK (("source" <> "target"))
);

ALTER TABLE "public"."connections" OWNER TO "postgres";

COMMENT ON TABLE "public"."connections" IS 'User connections';

CREATE TABLE IF NOT EXISTS "public"."journal" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text",
    "content" "text",
    "user_id" "uuid" DEFAULT "auth"."uid"(),
    "mood" "text"
);

ALTER TABLE "public"."journal" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "from" "uuid" NOT NULL,
    "to" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "text" "text" DEFAULT 'EMPTY'::"text" NOT NULL,
    CONSTRAINT "messages_text_check" CHECK ((("length"("text") > 0) AND ("length"("text") < 500)))
);

ALTER TABLE "public"."messages" OWNER TO "postgres";

COMMENT ON TABLE "public"."messages" IS 'Messages';

CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "body" "text" NOT NULL,
    "title" "text" DEFAULT ''::"text" NOT NULL
);

ALTER TABLE "public"."notifications" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."oauth2_states" (
    "state" "text" DEFAULT ''::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "verifier" "text" NOT NULL,
    "service" "public"."SleepTrackingService" NOT NULL,
    "userId" "uuid" NOT NULL,
    CONSTRAINT "oauth_states_state_check" CHECK (("length"("state") > 10)),
    CONSTRAINT "oauth_states_verifier_check" CHECK (("length"("verifier") > 10))
);

ALTER TABLE "public"."oauth2_states" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."oauth2_tokens" (
    "user" "uuid" NOT NULL,
    "service" "public"."SleepTrackingService" NOT NULL,
    "accessToken" "text" NOT NULL,
    "refreshToken" "text",
    "expiresAt" timestamp with time zone
);

ALTER TABLE "public"."oauth2_tokens" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "avatarUrl" "text" DEFAULT ''::"text" NOT NULL,
    "role" "public"."UserRole" DEFAULT 'USER'::"public"."UserRole" NOT NULL,
    "fcm_token" "text" DEFAULT ''::"text" NOT NULL
);

ALTER TABLE "public"."profiles" OWNER TO "postgres";

COMMENT ON TABLE "public"."profiles" IS 'Public user metadata';

CREATE TABLE IF NOT EXISTS "public"."reactions" (
    "messageId" "uuid" NOT NULL,
    "author" "uuid" NOT NULL,
    "reaction" "public"."MessageReaction" NOT NULL
);

ALTER TABLE "public"."reactions" OWNER TO "postgres";

COMMENT ON TABLE "public"."reactions" IS 'Message reactions';

CREATE TABLE IF NOT EXISTS "public"."tasks" (
    "title" "text",
    "reminder" "public"."TaskFrequency",
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "completed_at" timestamp with time zone
);

ALTER TABLE "public"."tasks" OWNER TO "postgres";

ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_pkey" PRIMARY KEY ("source", "target");

ALTER TABLE ONLY "public"."journal"
    ADD CONSTRAINT "journal_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."oauth2_states"
    ADD CONSTRAINT "oauth_states_pkey" PRIMARY KEY ("state");

ALTER TABLE ONLY "public"."reactions"
    ADD CONSTRAINT "reactions_pkey" PRIMARY KEY ("messageId", "author", "reaction");

ALTER TABLE ONLY "public"."oauth2_tokens"
    ADD CONSTRAINT "sleep_tracker_tokens_pkey" PRIMARY KEY ("user", "service");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");

CREATE UNIQUE INDEX "con_unique" ON "public"."connections" USING "btree" (LEAST("source", "target"), GREATEST("source", "target"));

CREATE OR REPLACE TRIGGER "notification" AFTER INSERT ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://jdghiexlhavidaqgcrqw.supabase.co/functions/v1/push', 'POST', '{"Content-type":"application/json"}', '{}', '1000');

CREATE OR REPLACE TRIGGER "notify_conn_success" AFTER UPDATE ON "public"."connections" FOR EACH ROW WHEN (("new"."isMutual" = true)) EXECUTE FUNCTION "public"."notify_conn_success"();

CREATE OR REPLACE TRIGGER "notify_recv_conn_req" AFTER INSERT ON "public"."connections" FOR EACH ROW EXECUTE FUNCTION "public"."notify_recv_conn_req"();

CREATE OR REPLACE TRIGGER "notify_recv_message" AFTER INSERT ON "public"."messages" FOR EACH ROW EXECUTE FUNCTION "public"."notify_recv_message"();

ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "public_connections_source_fkey" FOREIGN KEY ("source") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "public_connections_target_fkey" FOREIGN KEY ("target") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."journal"
    ADD CONSTRAINT "public_journal_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "public_messages_from_id_fkey" FOREIGN KEY ("from") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "public_messages_to_id_fkey" FOREIGN KEY ("to") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "public_notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."oauth2_states"
    ADD CONSTRAINT "public_oauth2_states_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reactions"
    ADD CONSTRAINT "public_reactions_author_fkey" FOREIGN KEY ("author") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reactions"
    ADD CONSTRAINT "public_reactions_messageId_fkey" FOREIGN KEY ("messageId") REFERENCES "public"."messages"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."oauth2_tokens"
    ADD CONSTRAINT "public_sleep_tracker_tokens_user_fkey" FOREIGN KEY ("user") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "public_users_user_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."tasks"
    ADD CONSTRAINT "tasks_profile_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

CREATE POLICY "Allow users to add reactions to messages they can see" ON "public"."reactions" FOR INSERT WITH CHECK ((("auth"."uid"() = "author") AND (EXISTS ( SELECT 1
   FROM "public"."messages" "m"
  WHERE (("m"."from" = "auth"."uid"()) OR ("m"."to" = "auth"."uid"()))))));

CREATE POLICY "Allow users to create instant connections to health experts" ON "public"."connections" FOR INSERT WITH CHECK ((("auth"."uid"() = "source") AND ("isMutual" = true) AND (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."id" = "connections"."target") AND ("p"."role" = 'HEALTH_EXPERT'::"public"."UserRole"))))));

CREATE POLICY "Allow users to delete their own reactions" ON "public"."reactions" FOR DELETE USING (("auth"."uid"() = "author"));

CREATE POLICY "Allow users to manage their own journal entries" ON "public"."journal" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

CREATE POLICY "Allow users to view reactions on messages they can see" ON "public"."reactions" FOR SELECT USING ((("auth"."uid"() = "author") AND (EXISTS ( SELECT 1
   FROM "public"."messages" "m"
  WHERE (("m"."from" = "auth"."uid"()) OR ("m"."to" = "auth"."uid"()))))));

CREATE POLICY "Enable read access for all users" ON "public"."profiles" FOR SELECT USING (true);

CREATE POLICY "Enable users to accept connection requests" ON "public"."connections" FOR UPDATE USING (("auth"."uid"() = "target")) WITH CHECK (("isMutual" = true));

CREATE POLICY "Enable users to create pending connection requests" ON "public"."connections" FOR INSERT WITH CHECK ((("auth"."uid"() = "source") AND ("isMutual" = false)));

CREATE POLICY "Enable users to delete their own messages" ON "public"."messages" FOR DELETE USING (("auth"."uid"() = "from"));

CREATE POLICY "Enable users to deny or break connections" ON "public"."connections" FOR DELETE USING ((("auth"."uid"() = "source") OR ("auth"."uid"() = "target")));

CREATE POLICY "Enable users to manage their own tasks" ON "public"."tasks" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

CREATE POLICY "Enable users to send messages to their connections" ON "public"."messages" FOR INSERT WITH CHECK ((("auth"."uid"() = "from") AND (EXISTS ( SELECT 1
   FROM "public"."connections" "c"
  WHERE ((("messages"."from" = "c"."source") AND ("messages"."to" = "c"."target") AND ("c"."isMutual" = true)) OR (("messages"."from" = "c"."target") AND ("messages"."to" = "c"."source") AND ("c"."isMutual" = true)))))));

CREATE POLICY "Enable users to update their profile details" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));

CREATE POLICY "Enable users to view connections from or to themselves" ON "public"."connections" FOR SELECT USING ((("auth"."uid"() = "source") OR ("auth"."uid"() = "target")));

CREATE POLICY "Enable users to view messages sent by or to them" ON "public"."messages" FOR SELECT USING ((("auth"."uid"() = "from") OR ("auth"."uid"() = "to")));

ALTER TABLE "public"."connections" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."journal" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."oauth2_states" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."oauth2_tokens" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."reactions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."tasks" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."notify_conn_success"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_conn_success"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_conn_success"() TO "service_role";

GRANT ALL ON FUNCTION "public"."notify_recv_conn_req"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_recv_conn_req"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_recv_conn_req"() TO "service_role";

GRANT ALL ON FUNCTION "public"."notify_recv_message"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_recv_message"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_recv_message"() TO "service_role";

GRANT ALL ON FUNCTION "public"."sort_and_concat"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."sort_and_concat"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sort_and_concat"("text", "text") TO "service_role";

GRANT ALL ON TABLE "public"."connections" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE "public"."connections" TO "authenticated";
GRANT ALL ON TABLE "public"."connections" TO "service_role";

GRANT UPDATE("isMutual") ON TABLE "public"."connections" TO "authenticated";

GRANT ALL ON TABLE "public"."journal" TO "anon";
GRANT ALL ON TABLE "public"."journal" TO "authenticated";
GRANT ALL ON TABLE "public"."journal" TO "service_role";

GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT SELECT,REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";

GRANT INSERT("from") ON TABLE "public"."messages" TO "authenticated";

GRANT INSERT("to") ON TABLE "public"."messages" TO "authenticated";

GRANT INSERT("text"),UPDATE("text") ON TABLE "public"."messages" TO "authenticated";

GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";

GRANT ALL ON TABLE "public"."oauth2_states" TO "anon";
GRANT ALL ON TABLE "public"."oauth2_states" TO "authenticated";
GRANT ALL ON TABLE "public"."oauth2_states" TO "service_role";

GRANT ALL ON TABLE "public"."oauth2_tokens" TO "anon";
GRANT ALL ON TABLE "public"."oauth2_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."oauth2_tokens" TO "service_role";

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";

GRANT UPDATE("id") ON TABLE "public"."profiles" TO "anon";
GRANT SELECT("id"),UPDATE("id") ON TABLE "public"."profiles" TO "authenticated";

GRANT UPDATE("name") ON TABLE "public"."profiles" TO "anon";
GRANT SELECT("name"),UPDATE("name") ON TABLE "public"."profiles" TO "authenticated";

GRANT UPDATE("avatarUrl") ON TABLE "public"."profiles" TO "anon";
GRANT SELECT("avatarUrl"),UPDATE("avatarUrl") ON TABLE "public"."profiles" TO "authenticated";

GRANT SELECT("role") ON TABLE "public"."profiles" TO "authenticated";

GRANT UPDATE("fcm_token") ON TABLE "public"."profiles" TO "authenticated";

GRANT ALL ON TABLE "public"."reactions" TO "anon";
GRANT ALL ON TABLE "public"."reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."reactions" TO "service_role";

GRANT ALL ON TABLE "public"."tasks" TO "anon";
GRANT ALL ON TABLE "public"."tasks" TO "authenticated";
GRANT ALL ON TABLE "public"."tasks" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
