import { StateStorage, TokenStorage } from "../lib/oauth2/index.ts";
import { FitbitProvider } from "../lib/oauth2/providers/index.ts";

// TODO: support multiple providers?
const provider = new FitbitProvider();
const states = new StateStorage();
const tokens = new TokenStorage();


Deno.serve(async (req: Request) => {
    const url = new URL(req.url);
    
    // Make sure we have a state
    const stateToken = url.searchParams.get("state");
    if (!stateToken) return new Response("Missing state", {status: 400});
    
    try {
        // Validate query params
        const params = provider.validateAuthResponse(url, stateToken);

        // Fetch code verifier from DB
        const state = await states.getState(stateToken);
        if (!state) return new Response("Invalid state", {status: 400});

        // Fetch token
        const token = await provider.doGrantRequest(params, state.verifier);

        await tokens.setToken(state.userId, token)
    } catch (e) {
        await states.removeState(stateToken);

        const err = e as Error;
        return new Response(err.message, {status: 400});
    }
    
    return new Response("Success!");
})