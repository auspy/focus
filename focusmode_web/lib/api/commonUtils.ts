import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";
import { isDev } from "@/constants";
import { getRatelimitCache } from "@/lib/redis/ratelimitCache";
import { NextResponse } from "next/server";

// * CONSTANTS
export const RATELIMIT_DURATION = "1 d";
export const SUMMARY_CACHE_EXPIRATION = 60 * 60 * 24 * 30; // 7 days in seconds

// * RATE LIMITS
// Rate limits for chat
const CHAT_RATELIMIT_ANONYMOUS = isDev ? 10 : 20;
const CHAT_RATELIMIT_FREE = isDev ? 100 : 100;
const CHAT_RATELIMIT_PRO = isDev ? 500 : 500;

// Rate limits for summary
const SUMMARY_RATELIMIT_ANONYMOUS = isDev ? 5 : 10;
const SUMMARY_RATELIMIT_FREE = isDev ? 50 : 100;
const SUMMARY_RATELIMIT_PRO = isDev ? 200 : 500;

// * REDIS INITIALIZATION
export const redis = Redis.fromEnv();

// * RATELIMIT CONFIGURATION
const cache = getRatelimitCache(2);

// Function to create ratelimit objects for different user types
function createRatelimit(
  prefix: string,
  anonymous: number,
  free: number,
  pro: number
) {
  return {
    anonymous: new Ratelimit({
      redis: Redis.fromEnv(),
      limiter: Ratelimit.slidingWindow(anonymous, RATELIMIT_DURATION),
      prefix: `ratelimit:${prefix}:anonymous`,
      analytics: true,
      ephemeralCache: cache,
    }),
    free: new Ratelimit({
      redis: Redis.fromEnv(),
      limiter: Ratelimit.slidingWindow(free, RATELIMIT_DURATION),
      prefix: `ratelimit:${prefix}:free`,
      analytics: true,
      ephemeralCache: cache,
    }),
    pro: new Ratelimit({
      redis: Redis.fromEnv(),
      limiter: Ratelimit.slidingWindow(pro, RATELIMIT_DURATION),
      prefix: `ratelimit:${prefix}:pro`,
      analytics: true,
      ephemeralCache: cache,
    }),
  };
}

// Create ratelimit objects for chat and summary
export const chatRatelimit = createRatelimit(
  "chat",
  CHAT_RATELIMIT_ANONYMOUS,
  CHAT_RATELIMIT_FREE,
  CHAT_RATELIMIT_PRO
);
export const summaryRatelimit = createRatelimit(
  "summary",
  SUMMARY_RATELIMIT_ANONYMOUS,
  SUMMARY_RATELIMIT_FREE,
  SUMMARY_RATELIMIT_PRO
);

// * LOGGING
export const log = (
  level: "INFO" | "WARN" | "ERROR",
  message: string,
  data?: any
) => {
  const timestamp = new Date().toISOString();
  console.log(JSON.stringify({ timestamp, level, message, data }));
};

// * RESPONSE CREATION
export function createNextResponse(
  data: any,
  status: number = 200,
  headers: Record<string, string> = {}
) {
  let responseData = data;

  // If status is greater than 200, convert the data to {error: message, status} format
  if (status > 200) {
    responseData = {
      error:
        typeof data === "string" ? data : data.error || "An error occurred",
      status,
    };
  }

  const response = NextResponse.json(responseData, { status });

  // Set default headers
  response.headers.set("Content-Type", "application/json");

  // Set custom headers
  Object.entries(headers).forEach(([key, value]) => {
    response.headers.set(key, value);
  });
  return response;
}
