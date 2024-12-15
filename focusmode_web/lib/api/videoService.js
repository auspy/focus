import Fetch from "@/lib/fetch";
import zodCheckVideoSchema from "@/lib/zod/zodCheckVideoSchema";

// to send video to be parsed
export default async function serviceVideoStatus({ videoId }) {
  try {
    const params = zodCheckVideoSchema.parse({ videoId });
    console.log("params in serviceVideoStatus", params);
    // using non auth Fetch as this is not needed in library, so directly use in web app. only protection will be user login
    const [data, res] = await Fetch({
      endpoint: "/api/db/video/" + params.videoId + "/status",
      method: "GET",
    });
    return data;
  } catch (e) {
    console.log("Error in serviceVideo", e.message, e.issues);
    return {
      status: handleErrorMessage(e.message),
    };
  }
}

const handleErrorMessage = (msg) => {
  if (typeof msg == "string" || msg.includes("/api")) {
    return "Error: Internal server error, Try again later";
  }
  return "Error: " + msg;
};
