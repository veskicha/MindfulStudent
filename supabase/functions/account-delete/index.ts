import { createClient } from "supabase-js";

function getUserId(req: Request): string | null {
  const authHeader = req.headers.get("Authorization")!;
  const jwtData = JSON.parse(atob(authHeader.split(".")[1]));
  return jwtData["sub"] ?? null;
}

const client = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

Deno.serve(async (req: Request) => {
    const userId = getUserId(req);
    if (!userId) return new Response("Not logged in :-(", {"status": 401});

    console.log(`Deleting account ${userId}`);
    const resp = await client.auth.admin.deleteUser(userId);
    console.log(resp);

    return new Response("Success!");
})
