import { embedMany, cosineSimilarity } from "ai";
import { openai } from "@ai-sdk/openai";

const BASE_MAX_TOKEN_SIZE = 750;
const MIN_CHUNK_SIZE = 100;

// Updated function to calculate SIMILARITY_THRESHOLD and MAX_TOKEN_SIZE based on duration
function calculateThresholdAndTokenSize(duration) {
  // Base threshold
  const baseThreshold = 0.28;
  let similarityThreshold = baseThreshold;
  let maxTokenSize = BASE_MAX_TOKEN_SIZE;

  // Adjust threshold and token size based on duration (in seconds)
  if (duration <= 300) {
    // 5 minutes or less
    // No changes
  } else if (duration <= 900) {
    // 5-15 minutes
    similarityThreshold -= 0.04;
    maxTokenSize += 250;
  } else if (duration <= 1800) {
    // 15-30 minutes
    similarityThreshold -= 0.08;
    maxTokenSize += 500;
  } else if (duration <= 3600) {
    // 30-60 minutes
    similarityThreshold -= 0.12;
    maxTokenSize += 750;
  } else {
    // More than 60 minutes
    similarityThreshold -= 0.16;
    maxTokenSize += 1000;
  }

  return { similarityThreshold, maxTokenSize };
}

export async function createSemanticChunks(segments, duration) {
  const { similarityThreshold, maxTokenSize } =
    calculateThresholdAndTokenSize(duration);
  try {
    const similarities = await computeSimilarities(segments);
    return createChunks(
      segments,
      similarities,
      maxTokenSize,
      similarityThreshold
    );
  } catch (error) {
    if (error.message.includes("'$.input' is invalid")) {
      throw new Error("VIOLENT_CONTENT");
    }
    throw error; // Re-throw other errors
  }
}

async function computeSimilarities(sentences) {
  try {
    const { embeddings } = await embedMany({
      model: openai.embedding("text-embedding-3-small"),
      values: sentences,
    });

    const similarities = await Promise.all(
      embeddings.map((embedding, i) =>
        i < embeddings.length - 1
          ? Promise.resolve(cosineSimilarity(embedding, embeddings[i + 1]))
          : Promise.resolve(null)
      )
    );

    return similarities.filter((sim) => sim !== null);
  } catch (error) {
    throw error; // This will be caught in createSemanticChunks
  }
}

function createChunks(
  sentences,
  similarities,
  maxTokenSize,
  similarityThreshold
) {
  const chunks = [];
  let currentChunk = [sentences[0]];
  let currentChunkSize = sentences[0].split(/\s+/).length;

  for (let i = 1; i < sentences.length; i++) {
    const sentenceTokenCount = sentences[i].split(/\s+/).length;

    if (
      (similarities[i - 1] >= similarityThreshold &&
        currentChunkSize + sentenceTokenCount <= maxTokenSize) ||
      currentChunkSize < MIN_CHUNK_SIZE
    ) {
      currentChunk.push(sentences[i]);
      currentChunkSize += sentenceTokenCount;
    } else {
      if (currentChunkSize >= MIN_CHUNK_SIZE) {
        chunks.push(currentChunk.join(" "));
        currentChunk = [sentences[i]];
        currentChunkSize = sentenceTokenCount;
      } else {
        // If the current chunk is too small, continue adding sentences
        currentChunk.push(sentences[i]);
        currentChunkSize += sentenceTokenCount;
      }
    }
  }

  if (currentChunk.length > 0) {
    chunks.push(currentChunk.join(" "));
  }
  //   console.log("chunks", chunks);
  return chunks;
}
