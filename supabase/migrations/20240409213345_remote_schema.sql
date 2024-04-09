create policy "Allow users to add reactions to messages they can see"
on "public"."reactions"
as permissive
for insert
to public
with check (((auth.uid() = author) AND (EXISTS ( SELECT 1
   FROM messages m
  WHERE ((m."from" = auth.uid()) OR (m."to" = auth.uid()))))));


create policy "Allow users to delete their own reactions"
on "public"."reactions"
as permissive
for delete
to public
using ((auth.uid() = author));


create policy "Allow users to view reactions on messages they can see"
on "public"."reactions"
as permissive
for select
to public
using (((auth.uid() = author) AND (EXISTS ( SELECT 1
   FROM messages m
  WHERE ((m."from" = auth.uid()) OR (m."to" = auth.uid()))))));



