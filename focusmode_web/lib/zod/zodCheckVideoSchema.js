import { z } from "zod";
import getYtId from "../getYtId";
const zodCheckVideoSchema = z.object({
  videoId: z
    .string()
    .min(11)
    .max(200)
    .transform((str) => {
      if (!str) return "";
      return getYtId(str);
    }),
});
export default zodCheckVideoSchema;
