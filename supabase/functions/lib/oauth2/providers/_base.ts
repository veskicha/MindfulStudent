import * as oauth from "oauth";

import { OAuth2Token } from "../token.ts";
import { SleepLog } from "../../sleep.ts";


export abstract class OAuth2Provider {
    private getTokenFromResponse(resp: oauth.OAuth2TokenEndpointResponse | oauth.TokenEndpointResponse): OAuth2Token {
        const expiresAt = new Date();
        expiresAt.setSeconds(expiresAt.getSeconds() + resp.expires_in!)
    
        return {
            service: this.getId(),
            accessToken: resp.access_token,
            refreshToken: resp.refresh_token!,
            expiresAt: expiresAt
        };
    }

    public validateAuthResponse(url: URL, state: string): URLSearchParams {
        const params = oauth.validateAuthResponse(this.getAuthServer(), this.getClient(), url, state);

        if (oauth.isOAuth2Error(params)) {
            throw new Error(params.error_description);
        }

        return params;
    }

    public async doGrantRequest(params: URLSearchParams, codeVerifier: string): Promise<OAuth2Token> {
        const resp = await oauth.authorizationCodeGrantRequest(
            this.getAuthServer(), this.getClient(), params, "bogus", codeVerifier
        );
        const result = await oauth.processAuthorizationCodeOAuth2Response(
            this.getAuthServer(), this.getClient(), resp
        );

        if (oauth.isOAuth2Error(result)) {
            throw new Error(result.error_description);
        }

        return this.getTokenFromResponse(result);
    }

    public async refreshToken(token: OAuth2Token) {
        const resp = await oauth.refreshTokenGrantRequest(
            this.getAuthServer(), this.getClient(), token.refreshToken
        );
        const result = await oauth.processRefreshTokenResponse(
            this.getAuthServer(), this.getClient(), resp
        )

        if (oauth.isOAuth2Error(result)) {
            throw new Error(result.error_description);
        }

        return this.getTokenFromResponse(result);
    }

    abstract getId(): string;

    abstract getAuthUrl(codeChallenge: string, state: string): URL;

    protected abstract getClient(): oauth.Client;

    protected abstract getAuthServer(): oauth.AuthorizationServer;

    abstract getSleepLog(token: OAuth2Token): Promise<SleepLog[]>;
}
