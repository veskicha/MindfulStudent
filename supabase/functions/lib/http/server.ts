import { JsonResponse } from './responses.ts';

type ServeFunction = (req: Request) => Promise<Response | void>;

function sortByLen(s1: string ,s2: string): number {
    if (s1.length < s2.length) return 1;
    else if (s1.length > s2.length) return -1;
    else return 0;
}

export class SimpleHttpServer {
    private routes: Record<string, ServeFunction> = {};

    private isRunning: boolean = false;

    route(url: string, handler: ServeFunction): void {
        if (this.isRunning) throw Error("Cannot add routes after start!");

        this.routes[url] = handler;
    }

    serve() {
        this.isRunning = true;

        const routes = Object.keys(this.routes).toSorted(sortByLen);

        console.log(`Serving with routes: ${routes}`);

        Deno.serve(async (req: Request) => {
            const url = new URL(req.url);

            for (const route of routes) {
                if (!url.pathname.endsWith(route)) continue;

                const resp = await this.routes[route](req);
                return resp ?? JsonResponse(null, 204);
            }

            return JsonResponse({"error": "Not found"}, 404);
        })
    }
}
