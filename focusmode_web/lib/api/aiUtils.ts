// import { getEncoding } from "js-tiktoken";
import { encode } from "gpt-tokenizer";

// * CONSTANTS
const GROQ_MAX_TOKENS = 28500;

// * MODEL CONFIGURATIONS
export const modelPriority = [
  "llama-3.1-70b-versatile",
  "llama3-70b-8192",
  "llama3-groq-70b-8192-tool-use-preview",
  "llama-3.1-8b-instant",
  "llama3-8b-8192",
  "llama3-groq-8b-8192-tool-use-preview",
  "gemini-1.5-flash",
];

const smallModels = [
  "llama-3.1-8b-instant",
  "llama-3.1-70b-versatile",
  "llama-guard-3-8b",
  "llama3-groq-70b-8192-tool-use-preview",
  "llama3-groq-8b-8192-tool-use-preview",
];
const slightlyBiggerModels = [
  "llama-3.1-8b-instant",
  "llama-3.1-70b-versatile",
];
const mediumModels = ["llama3-70b-8192"];
const largeModels = ["gemini-1.5-flash"];

// Model capacities (in tokens)
const modelCapacities = {
  "llama-3.1-8b-instant": 19000,
  "llama-3.1-70b-versatile": 19000,
  "llama3-70b-8192": 5700,
  "llama3-groq-70b-8192-tool-use-preview": 14250,
  "llama3-8b-8192": 28500,
  "llama3-groq-8b-8192-tool-use-preview": 14250,
  "gemini-1.5-flash": 950000,
};

// Model rate limits
const modelRateLimits = {
  "llama-3.1-8b-instant": { tokensPerMinute: 19000, tokensPerDay: 950000 },
  "llama-3.1-70b-versatile": { tokensPerMinute: 19000, tokensPerDay: 950000 },
  "llama3-70b-8192": { tokensPerMinute: 5700, tokensPerDay: 950000 },
  "llama3-groq-70b-8192-tool-use-preview": {
    tokensPerMinute: 14250,
    tokensPerDay: 950000,
  },
  "llama3-8b-8192": { tokensPerMinute: 28500, tokensPerDay: 950000 },
  "llama3-groq-8b-8192-tool-use-preview": {
    tokensPerMinute: 14250,
    tokensPerDay: 950000,
  },
  "gemini-1.5-flash": { tokensPerMinute: 950000, tokensPerDay: 950000 },
};

// * MODEL USAGE TRACKING
const modelUsage = new Map<
  string,
  { minuteTokens: number; dayTokens: number; lastReset: number }
>();

// * TOKENIZATION
// const tokenizer = getEncoding("cl100k_base"); // was causing error in edge runtime, cause of large size

// export function countTokens(text: string): number {
//   return tokenizer.encode(text).length;
// }

export function countTokens2(text: string): number {
  return encode(text).length;
}

// * USAGE TRACKING HELPERS
function resetModelCounterIfNeeded(now: number, usage: any) {
  if (now - usage.lastReset > 60000) {
    usage.minuteTokens = 0;
    if (now - usage.lastReset > 86400000) {
      usage.dayTokens = 0;
    }
    usage.lastReset = now;
  }
}

function isModelRateLimited(model: string): boolean {
  const now = Date.now();
  const usage = modelUsage.get(model) || {
    minuteTokens: 0,
    dayTokens: 0,
    lastReset: now,
  };

  resetModelCounterIfNeeded(now, usage);

  return (
    usage.minuteTokens >= modelRateLimits[model].tokensPerMinute ||
    usage.dayTokens >= modelRateLimits[model].tokensPerDay
  );
}

export function updateModelTokenUsage(model: string, tokenCount: number): void {
  const now = Date.now();
  const usage = modelUsage.get(model) || {
    minuteTokens: 0,
    dayTokens: 0,
    lastReset: now,
  };

  resetModelCounterIfNeeded(now, usage);

  usage.minuteTokens += tokenCount;
  usage.dayTokens += tokenCount;
  modelUsage.set(model, usage);
}

// * MODEL SELECTION
export function getNextAvailableModel(tokenCount: number): string | null {
  for (const model of modelPriority) {
    if (modelCapacities[model] < tokenCount) {
      continue;
    }

    if (!isModelRateLimited(model)) {
      return model;
    }
  }

  return null;
}

export async function chooseModelBasedOnTokenCount(
  tokenCount: number,
  useCase: "chat" | "summary" = "chat"
): Promise<string> {
  let modelArray: string[];

  if (useCase === "summary") {
    modelArray = ["llama-3.1-70b-versatile", "gemini-1.5-flash"];
  } else {
    if (tokenCount > GROQ_MAX_TOKENS) {
      modelArray = largeModels;
    } else if (tokenCount > 19000) {
      modelArray = mediumModels;
    } else if (tokenCount > 14000) {
      modelArray = slightlyBiggerModels;
    } else {
      modelArray = smallModels;
    }
  }

  for (const model of modelArray) {
    if (!isModelRateLimited(model)) {
      return model;
    }
  }

  return modelArray[modelArray.length - 1];
}
