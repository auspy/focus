import { createAnthropic } from "@ai-sdk/anthropic";
import { createGoogleGenerativeAI } from "@ai-sdk/google";
import { createOpenAI } from "@ai-sdk/openai";

const google = createGoogleGenerativeAI({
  // custom settings
});
const anthropic = createAnthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});
const openai = createOpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});
const perplexity = createOpenAI({
  apiKey: process.env.PERPLEXITY_API_KEY ?? "",
  baseURL: "https://api.perplexity.ai/",
});
const groq = createOpenAI({
  baseURL: "https://api.groq.com/openai/v1",
  apiKey: process.env.GROQ_API_KEY,
});

// Update MODEL_IDENTIFIERS to include Google
const MODEL_IDENTIFIERS = {
  openai: (model: string) =>
    model.startsWith("gpt-") || model.startsWith("text-"),
  groq: (model: string) =>
    model.startsWith("llama-3.1-") ||
    model.startsWith("llama3") ||
    model.startsWith("mixtral-"),
  anthropic: (model: string) => model.startsWith("claude-"),
  google: (model: string) => model.startsWith("gemini-"),
  perplexity: (model: string) =>
    model.startsWith("llama-") && model.includes("sonar"),
};

// Function to determine which AI service to use based on the model
export function getAIService(model: string) {
  for (const [provider, identifier] of Object.entries(MODEL_IDENTIFIERS)) {
    if (identifier(model)) {
      return provider;
    }
  }
  throw new Error(`Unsupported model: ${model}`);
}

// Function to get the AI client by provider
export function getAIClient(provider: string) {
  switch (provider) {
    case "openai":
      return openai;
    case "groq":
      return groq;
    case "anthropic":
      return anthropic;
    case "google":
      return google;
    case "perplexity":
      return perplexity;
    default:
      throw new Error(`Unsupported provider: ${provider}`);
  }
}

export function getModel(model: string) {
  for (const [provider, identifier] of Object.entries(MODEL_IDENTIFIERS)) {
    if (identifier(model)) {
      return getAIClient(provider)(model);
    }
  }
  throw new Error(`Unsupported model: ${model}`);
}
