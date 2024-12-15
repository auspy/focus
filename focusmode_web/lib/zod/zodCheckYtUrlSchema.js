import { z } from "zod";
import getYtId from "../getYtId";
export const zodCheckYtUrlSchema = z
  .string()
  .min(43, "Pls check the URL, you might have missed something")
  .url("Pls check the URL format")
  .startsWith(
    "https://www.youtube.com/watch?v=",
    "Please check the URL.\nCorrect format: https://www.youtube.com/watch?v=xyz",
  )
  .refine((str) => {
    const videoId = getYtId(str);
    if (!videoId) {
      return;
    }
    return videoId;
  }, "Pls check the url");
