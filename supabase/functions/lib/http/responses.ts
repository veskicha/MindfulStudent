export function JsonResponse(content: object | null, status: number = 200) {
    return new Response(content ? JSON.stringify(content) : null, {
        status: status,
        headers: {
            "content-type": "application/json"
        }
    })
}

export function RedirectResponse(location: string) {
    return new Response(null, {
        status: 302,
        headers: {
            "location": location
        }
    })
}

export function TextResponse(content: string | null, status: number = 200) {
    return new Response(content || "", {
        status: status,
        headers: {
            "content-type": "application/text"
        }
    })
}
