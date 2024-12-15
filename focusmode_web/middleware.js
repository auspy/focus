import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";
import { Ratelimit } from "@upstash/ratelimit";
import { Redis as Rd } from "@upstash/redis";
import { isDev } from "./constants";
import { NextResponse } from "next/server";
import { waitUntil } from "@vercel/functions";

const isPublicRoute = createRouteMatcher([
  "/",
  "/clips",
  "/auth(.*)",
  "/api(.*)",
  "/monitoring",
  "/privacy",
]);

const isExtensionRoute = createRouteMatcher([
  "/api/summarize",
  "/api/chat",
  "/api/clips",
]);
// const isExtensionPrivateRoute = createRouteMatcher(["/api/summarize"]);
// const isApiRoute = createRouteMatcher(["/api(.*)"]);
// const isVizolvFrontend = createRouteMatcher(["/", "/c(.*)"]);

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(" ")
  : [];
if (isDev) {
  allowedOrigins.push(...["http://localhost:3000", "http://localhost:3001"]);
}
const corsOptions = {
  "Access-Control-Allow-Methods": "GET, POST",
  "Access-Control-Allow-Headers":
    "Content-Type, Authorization, x-vizolv, x-csrf-token",
  "Access-Control-Allow-Credentials": "true",
};

// middleware is applied to all routes, use conditionals to select
const cache = new Map();
const ratelimit = !isDev && {
  public: new Ratelimit({
    redis: Rd.fromEnv(),
    timeout: 2000,
    analytics: true,
    prefix: "ratelimit:public",
    ephemeralCache: cache,
    limiter: Ratelimit.slidingWindow(100, "60 s"),
  }),
  private: new Ratelimit({
    redis: Rd.fromEnv(),
    analytics: true,
    prefix: "ratelimit:private",
    ephemeralCache: cache,
    limiter: Ratelimit.slidingWindow(60, "60 s"),
  }),
};

async function handleRateLimiting(req) {
  if (ratelimit) {
    const ip = req.ip ?? "127.0.0.1";
    const identifier = ip;
    const { success, pending, limit, reset, remaining } =
      await ratelimit[isPublicRoute(req) ? "public" : "private"].limit(
        identifier
      );
    waitUntil(pending);

    console.log("ratelimit: within limit?", success, limit, reset, remaining);

    if (!success) {
      return NextResponse.json(
        { error: "rate limit exceeded" },
        { status: 429, statusText: "Rate limit exceeded" }
      );
    }
  }
  return null;
}

async function handleProtectedRoutes(req, auth) {
  if (!isPublicRoute(req)) {
    console.log("Protected route");
    await auth().protect();
  } else {
    console.log("Public route");
  }
}

async function handleExtensionRoutes(req, auth) {
  const origin = req.headers.get("origin") ?? "";
  // console.log("Extension route", req.headers);

  // Check if the origin is allowed
  const isAllowedOrigin =
    origin.endsWith("youtube.com") ||
    origin.endsWith("vizolv.com") ||
    (isDev && origin.includes("localhost"));

  // Create the response
  const response = NextResponse.next();

  // Set CORS headers
  response.headers.set(
    "Access-Control-Allow-Origin",
    isAllowedOrigin ? origin : "*"
  );
  Object.entries(corsOptions).forEach(([key, value]) => {
    response.headers.set(key, value);
  });

  // If not allowed origin, you can still return a 403 error
  if (!isAllowedOrigin) {
    return NextResponse.json(
      { error: "Unauthorized" + origin },
      { status: 403, headers: response.headers }
    );
  }

  // for some reason headers are not coming from extension
  // if (isExtensionPrivateRoute(req)) {
  //   console.log("Extension auth route");
  //   try {
  //     await auth().protect();
  //   } catch (error) {
  //     console.error("Authentication error:", error);
  //     return NextResponse.json(
  //       { error: "Authentication failed" },
  //       { status: 401, headers: response.headers },
  //     );
  //   }
  // }

  return response;
}

async function middlewareHandler(auth, req) {
  try {
    const origin = req.headers.get("origin");
    console.log("Middleware called", req.method, origin, req.url);

    if (isExtensionRoute(req)) {
      return await handleExtensionRoutes(req, auth);
    }

    const isAllowedOrigin = allowedOrigins.includes(origin);
    if (req.method === "OPTIONS") {
      const preflightHeaders = {
        ...(isAllowedOrigin && { "Access-Control-Allow-Origin": origin }),
        ...corsOptions,
      };
      return NextResponse.next({
        headers: preflightHeaders,
      });
    }

    // check rate limiting
    const rateLimitResponse = await handleRateLimiting(req);
    if (rateLimitResponse) {
      return rateLimitResponse;
    }

    // check if the request is protected
    await handleProtectedRoutes(req, auth);

    // Handle simple requests
    const response = NextResponse.next();

    if (isAllowedOrigin) {
      response.headers.set("Access-Control-Allow-Origin", origin);
    }

    Object.entries(corsOptions).forEach(([key, value]) => {
      response.headers.set(key, value);
    });

    // console.log("headers in middleware", req.headers);

    return response;
  } catch (error) {
    console.error("Middleware error", error);
    return NextResponse.error();
  }
}

export default clerkMiddleware(middlewareHandler);

export const config = {
  matcher: ["/((?!.*\\..*|_next).*)", "/"],
};
