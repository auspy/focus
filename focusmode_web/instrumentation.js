import NodeCache from "node-cache";

export async function register() {
  if (process.env.NEXT_RUNTIME === "nodejs") {
    await import("./sentry.server.config");
  }

  if (process.env.NEXT_RUNTIME === "edge") {
    await import("./sentry.edge.config");
  }
  if (process.env.NEXT_RUNTIME === "nodejs") {
    const NodeCache = (await import("node-cache")).default;
    const config = {
      stdTTL: process.env.NODE_ENV === "production" ? 0 : 60,
    };

    global.cacheConfigs = new NodeCache(config);
    global.cacheSessions = new NodeCache({ stdTTL: 600, checkperiod: 120 });
    //other caches

    // Other things that should only happen once at server startup.
    // firebase-admin connect, etc
  }
}
