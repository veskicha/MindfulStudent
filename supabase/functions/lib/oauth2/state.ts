import * as oauth from "oauth";
import { createClient } from "supabase-js";

import { OAuth2Provider } from "./providers/index.ts";

interface State {
    userId: string;
    service: string;
    verifier: string;
}

export class StateStorage {
    private static SCHEMA = "public";
    private static TABLE = "oauth2_states";

    private client = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    private getDBHandle() {
        return this.client
            .schema(StateStorage.SCHEMA)
            .from(StateStorage.TABLE);
    }

    public async createState(provider: OAuth2Provider, userId: string): Promise<[string, string]> {
        const state = oauth.generateRandomState();

        const codeVerifier = oauth.generateRandomCodeVerifier();
        const codeChallenge = await oauth.calculatePKCECodeChallenge(codeVerifier);
        
        await this.getDBHandle()
            .insert({
                state: state,
                verifier: codeVerifier,
                service: provider.getId(),
                userId: userId
            });
        
        return [state, codeChallenge]
    }

    public async removeState(state: string): Promise<void> {
        await this.getDBHandle()
            .delete()
            .eq("state", state);
    }

    public async getState(state: string): Promise<State | null> {
        const challenge = await this.getDBHandle()
            .delete()
            .eq("state", state)
            .select();
        
        const data = challenge.data;

        // Challenge is missing for this state!
        if (!data?.length) return null;

        return {
            userId: data[0].userId,
            service: data[0].service,
            verifier: data[0].verifier
        };
    }
}