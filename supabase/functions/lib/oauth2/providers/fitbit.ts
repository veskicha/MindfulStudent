import * as oauth from "oauth";

import { OAuth2Provider } from "./_base.ts";
import { OAuth2Token } from "../index.ts";
import { SleepLog } from "../../sleep.ts";

export class FitbitProvider extends OAuth2Provider {
  getId(): string {
    return "FITBIT";
  }

  protected getClient(): oauth.Client {
    return {
        client_id: Deno.env.get("FITBIT_CLIENT_ID") ?? "",
        client_secret: Deno.env.get("FITBIT_CLIENT_SECRET") ?? "",
        token_endpoint_auth_method: "client_secret_basic"
    }
  }
  
  protected getAuthServer(): oauth.AuthorizationServer {
    return {
        issuer: "fitbit",
        authorization_endpoint: "https://www.fitbit.com/oauth2/authorize",
        token_endpoint: "https://api.fitbit.com/oauth2/token"
    }
  }

  getAuthUrl(codeChallenge: string, state: string): URL {
    const authUrl = new URL(this.getAuthServer().authorization_endpoint!);
    authUrl.searchParams.set("client_id", this.getClient().client_id);
    authUrl.searchParams.set("scope", "sleep");
    authUrl.searchParams.set("code_challenge", codeChallenge);
    authUrl.searchParams.set("code_challenge_method", "S256");
    authUrl.searchParams.set("response_type", "code");
    authUrl.searchParams.set("state", state);

    return authUrl;
  }

  async getSleepLog(token: OAuth2Token): Promise<SleepLog[]> {
    const now = new Date();

    const url = new URL("https://api.fitbit.com/1.2/user/-/sleep/list.json");
    url.searchParams.set("afterDate", `${now.getUTCFullYear()}-${now.getUTCMonth()}-${now.getUTCDate()}`);
    url.searchParams.set("sort", "asc");
    url.searchParams.set("limit", "100");
    url.searchParams.set("offset", "0");

    const resp = await oauth.protectedResourceRequest(token.accessToken, "GET", url);
    if (resp.status !== 200) {
      console.error(await resp.text());
      throw new Error(`Could not retrieve sleep pattern details`)
    }

    const data = await resp.json();

    return data["sleep"];
  }
}
