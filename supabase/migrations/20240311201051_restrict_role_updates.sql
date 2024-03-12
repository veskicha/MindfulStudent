revoke update on public.profiles from authenticated;
grant update (name, "avatarUrl") on public.profiles to authenticated;

