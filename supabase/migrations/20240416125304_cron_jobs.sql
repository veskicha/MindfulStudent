create extension if not exists pg_cron with schema extensions;

grant usage on schema cron to postgres;
grant all privileges on all tables in schema cron to postgres;

select cron.schedule (
    'notification-cleanup',
    '0 * * * *',
    $$ delete from "public"."notifications" where created_at < now() - interval '1 week' $$
);

select cron.schedule (
    'oauth-states-cleanup',
    '0 * * * *',
    $$ delete from "public"."oauth2_states" where created_at < now() - interval '1 hour' $$
);
