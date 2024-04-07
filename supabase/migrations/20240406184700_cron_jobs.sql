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
