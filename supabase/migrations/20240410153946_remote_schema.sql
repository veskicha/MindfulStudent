set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.notify_conn_success()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into notifications (user_id, title, body)
  values (NEW."target", 'New friend added!', 'You and ' || (select name from profiles where id = NEW."source") || ' are now friends!');
  insert into notifications (user_id, title, body)
  values (NEW."source", 'New friend added!', 'You and ' || (select name from profiles where id = NEW."target") || ' are now friends!');

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.notify_recv_conn_req()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into notifications (user_id, title, body)
  values (NEW."target", 'Connection request', (select name from profiles where id = NEW."source") || ' wants to connect with you!');
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.notify_recv_message()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into notifications (user_id, title, body)
  values (NEW."to", 'Message from ' || (select name from profiles where id = NEW."from"), NEW."text");
  return new;
end;
$function$
;

CREATE TRIGGER notify_conn_success AFTER UPDATE ON public.connections FOR EACH ROW WHEN ((new."isMutual" = true)) EXECUTE FUNCTION notify_conn_success();

CREATE TRIGGER notify_recv_conn_req AFTER INSERT ON public.connections FOR EACH ROW EXECUTE FUNCTION notify_recv_conn_req();

CREATE TRIGGER notify_recv_message AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION notify_recv_message();


