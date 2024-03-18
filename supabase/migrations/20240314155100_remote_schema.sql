
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

CREATE TYPE "public"."UserRole" AS ENUM (
    'USER',
    'HEALTH_EXPERT'
);

ALTER TYPE "public"."UserRole" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;

$$;

ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

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

CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "from" "uuid" NOT NULL,
    "to" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "text" "text" DEFAULT 'EMPTY'::"text" NOT NULL,
    CONSTRAINT "messages_text_check" CHECK ((("length"("text") > 0) AND ("length"("text") < 500)))
);

ALTER TABLE "public"."messages" OWNER TO "postgres";

COMMENT ON TABLE "public"."messages" IS 'Messages';

CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "name" "text" DEFAULT ''::"text" NOT NULL,
    "avatarUrl" "text" DEFAULT ''::"text" NOT NULL,
    "role" "public"."UserRole" DEFAULT 'USER'::"public"."UserRole" NOT NULL
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

ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "connections_pkey" PRIMARY KEY ("source", "target");

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."reactions"
    ADD CONSTRAINT "reactions_pkey" PRIMARY KEY ("messageId", "author", "reaction");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");

CREATE UNIQUE INDEX "con_unique" ON "public"."connections" USING "btree" (LEAST("source", "target"), GREATEST("source", "target"));

ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "public_connections_source_fkey" FOREIGN KEY ("source") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."connections"
    ADD CONSTRAINT "public_connections_target_fkey" FOREIGN KEY ("target") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "public_messages_from_id_fkey" FOREIGN KEY ("from") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "public_messages_to_id_fkey" FOREIGN KEY ("to") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reactions"
    ADD CONSTRAINT "public_reactions_author_fkey" FOREIGN KEY ("author") REFERENCES "public"."profiles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reactions"
    ADD CONSTRAINT "public_reactions_messageId_fkey" FOREIGN KEY ("messageId") REFERENCES "public"."messages"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "public_users_user_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;

CREATE POLICY "Enable read access for all users" ON "public"."profiles" FOR SELECT USING (true);

CREATE POLICY "Enable users to accept connection requests" ON "public"."connections" FOR UPDATE USING (("auth"."uid"() = "target")) WITH CHECK (("isMutual" = true));

CREATE POLICY "Enable users to create pending connection requests" ON "public"."connections" FOR INSERT WITH CHECK ((("auth"."uid"() = "source") AND ("isMutual" = false)));

CREATE POLICY "Enable users to delete their own messages" ON "public"."messages" FOR DELETE USING (("auth"."uid"() = "from"));

CREATE POLICY "Enable users to deny or break connections" ON "public"."connections" FOR DELETE USING ((("auth"."uid"() = "source") OR ("auth"."uid"() = "target")));

CREATE POLICY "Enable users to send messages to their connections" ON "public"."messages" FOR INSERT WITH CHECK ((("auth"."uid"() = "from") AND (EXISTS ( SELECT 1
   FROM "public"."connections" "c"
  WHERE ((("messages"."from" = "c"."source") AND ("messages"."to" = "c"."target") AND ("c"."isMutual" = true)) OR (("messages"."from" = "c"."target") AND ("messages"."to" = "c"."source") AND ("c"."isMutual" = true)))))));

CREATE POLICY "Enable users to update their profile details" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));

CREATE POLICY "Enable users to view connections from or to themselves" ON "public"."connections" FOR SELECT USING ((("auth"."uid"() = "source") OR ("auth"."uid"() = "target")));

CREATE POLICY "Enable users to view messages sent by or to them" ON "public"."messages" FOR SELECT USING ((("auth"."uid"() = "from") OR ("auth"."uid"() = "to")));

ALTER TABLE "public"."connections" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."reactions" ENABLE ROW LEVEL SECURITY;

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."sort_and_concat"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."sort_and_concat"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sort_and_concat"("text", "text") TO "service_role";

GRANT ALL ON TABLE "public"."connections" TO "anon";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE "public"."connections" TO "authenticated";
GRANT ALL ON TABLE "public"."connections" TO "service_role";

GRANT UPDATE("isMutual") ON TABLE "public"."connections" TO "authenticated";

GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT SELECT,REFERENCES,DELETE,TRIGGER,TRUNCATE ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";

GRANT UPDATE("id") ON TABLE "public"."profiles" TO "anon";
GRANT UPDATE("id") ON TABLE "public"."profiles" TO "authenticated";

GRANT UPDATE("name") ON TABLE "public"."profiles" TO "anon";
GRANT UPDATE("name") ON TABLE "public"."profiles" TO "authenticated";

GRANT UPDATE("avatarUrl") ON TABLE "public"."profiles" TO "anon";
GRANT UPDATE("avatarUrl") ON TABLE "public"."profiles" TO "authenticated";

GRANT ALL ON TABLE "public"."reactions" TO "anon";
GRANT ALL ON TABLE "public"."reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."reactions" TO "service_role";

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
