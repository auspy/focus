import OpenAI from "openai";

const openaiApiKey = process.env.OPENAI_API_KEY;
console.log(
  "OpenAI API key:",
  process.env.NODE_ENV,
  // process.env.VIZOLV_APP_ID,
  Boolean(openaiApiKey),
);
const openaiClient = new OpenAI({
  apiKey: openaiApiKey,
});
export default openaiClient;
