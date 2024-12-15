import { createRouteMatcher } from "@clerk/nextjs/server";

const isPublicApi = createRouteMatcher(["/api/vizolv", "/api/db/video(.*)"]);
export const getAppIdFromRequest = (req) => {
  const method = req.method;
  const origin =
    req.headers.get("origin") ||
    req.headers.get("Origin") ||
    "https://www.vizolv.com";
  const pathname = new URL(req.url).pathname;
  const vizolvUrl = process.env.NEXT_PUBLIC_SITE_URL;
  console.log(
    "Method:",
    method,
    "Origin:",
    origin,
    "Pathname:",
    pathname,
    "Vizolv URL:",
    vizolvUrl,
  );
  // Extract Authorization header from request
  const authHeader = req.headers.get("authorization");
  if (origin === vizolvUrl && !authHeader)
    // this is vizolv frontedn accessing the library){
    return "ytviz";

  if (method === "OPTIONS") {
    return null;
  }
  // console.log("Authorization header:", authHeader);

  if (!authHeader) {
    // console.log("Authorization header missing");
    return "ytviz";
  }
  // Extract appId from Authorization header
  const [appId] = authHeader.split(" ")[1].split(":");
  console.log("--- assistant being used for =>", appId);
  if (!appId) {
    throw new Error("User is not authorized to access this resource");
  }
  return appId;
};
