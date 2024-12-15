import { z } from "zod";
const schema = z.string().min(11).url();
export default function getYtId(url) {
  const parsedUrl = schema.safeParse(url);
  if (!parsedUrl.success) {
    if (typeof url !== "string") {
      return null;
    }
    if (url.length != 11) {
      return null;
    }
    return url;
  }
  const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
  const match = url.match(regExp);

  return match && match[2].length === 11 ? match[2] : null;
}
