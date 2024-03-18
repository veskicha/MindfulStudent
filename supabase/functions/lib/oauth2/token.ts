import { createClient } from "supabase-js";

export interface OAuth2Token {
    service: string;
    accessToken: string;
    refreshToken: string;
    expiresAt: Date;
}

export class TokenStorage {
    private static SCHEMA = "public";
    private static TABLE = "oauth2_tokens";

    private client = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    private getDBHandle() {
        return this.client
            .schema(TokenStorage.SCHEMA)
            .from(TokenStorage.TABLE);
    }

    public async setToken(userId: string, token: OAuth2Token) {
        await this.getDBHandle()
            .upsert({
                user: userId,
                ...token
            })
    }

    public async getToken(userId: string, service: string): Promise<OAuth2Token | null> {
        const tokens = await this.getDBHandle()
            .select()
            .eq("user", userId)
            .eq("service", service)
            .select();
        
        if (!tokens.data?.length) return null;

        const token = tokens.data[0];

        return {
            service: service,
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
            expiresAt: token.expiresAt
        }
    }

    public async deleteToken(userId: string, service: string) {
        await this.getDBHandle()
            .delete()
            .eq("user", userId)
            .eq("service", service);
    }
}
