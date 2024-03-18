import { SimpleHttpServer, RedirectResponse, JsonResponse, TextResponse } from "../lib/http/index.ts";
import { FitbitProvider } from "../lib/oauth2/providers/index.ts";
import { StateStorage, TokenStorage, OAuth2Token } from "../lib/oauth2/index.ts";

// TODO: support multiple providers?
const provider = new FitbitProvider();
const states = new StateStorage();
const tokens = new TokenStorage();
const server = new SimpleHttpServer();


function getUserId(req: Request): string | null {
  const authHeader = req.headers.get("Authorization")!;
  const jwtData = JSON.parse(atob(authHeader.split(".")[1]));
  return jwtData["sub"] ?? null;
}

async function getToken(userId: string): Promise<OAuth2Token | null> {
  let token = await tokens.getToken(userId, provider.getId());
  if (!token) return null;

  if (new Date() > token.expiresAt) {
    // Need refresh
    token = await provider.refreshToken(token);
    tokens.setToken(userId, token);
  }

  return token;
}

server.route("/login", async (req: Request) => {
  const userId = getUserId(req);
  if (!userId) return TextResponse("Not authenticated!", 401);

  const [state, codeChallenge] = await states.createState(provider, userId);

  const authUrl = provider.getAuthUrl(codeChallenge, state);

  return RedirectResponse(authUrl.href);
})

server.route("/logout", async (req: Request) => {
  const userId = getUserId(req);
  if (!userId) return JsonResponse({"error": "Not authenticated."}, 401);

  await tokens.deleteToken(userId, provider.getId());

  return JsonResponse(null, 204);
})

server.route("/status", async (req: Request) => {
  const userId = getUserId(req);
  if (!userId) return JsonResponse({"error": "Not authenticated!"}, 401);

  const token = await getToken(userId);

  return JsonResponse({"logged_in": token !== null});
})

server.route("/logs", async (req: Request) => {
  const userId = getUserId(req);
  if (!userId) return JsonResponse({"error": "Not authenticated!"}, 401);

  const token = await getToken(userId);
  if (!token) return JsonResponse({"error": "Account not linked!"}, 401);

  try {
    const log = await provider.getSleepLog(token);
    return JsonResponse(log);
  } catch (e) {
    const err = e as Error;
    return JsonResponse({"error": err.message}, 500);
  }
})

server.serve();
