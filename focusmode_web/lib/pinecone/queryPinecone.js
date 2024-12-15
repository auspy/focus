import openaiClient from "@/lib/ai/openai.config";
import getPineconeIndex from "./getPineconeIndex";
import isObject from "../isObject";

const queryPinecone = async ({
  query,
  videoId = null,
  ytVidId = null,
  courseId = null,
  folderId = null,
  vid_100xdevs = null,
  client = openaiClient,
  MODEL = "text-embedding-3-small",
  indexProps = {},
}) => {
  try {
    const index = await getPineconeIndex(
      isObject(indexProps) ? indexProps : {},
    );

    if (!(query && index && client)) {
      console.log("Query, index, or client not found");
      throw new Error("Query, index, or client not found");
    }

    // Create the query embedding
    const vector = (
      await client.embeddings.create({ input: query, model: MODEL })
    ).data[0].embedding;
    console.log("Query embedding:", Boolean(vector));
    // Query, returning the top 5 most similar results
    const filters = {};
    if (videoId) filters.videoId = videoId;
    if (ytVidId) filters.ytVidId = ytVidId;
    if (courseId) filters.courseId = courseId;
    if (folderId) filters.folderId = folderId;
    if (vid_100xdevs) filters.vid_100xdevs = vid_100xdevs;

    console.log("Pinecone Filters:", filters);
    const res = await index.query({
      vector: vector,
      topK: 5,
      includeMetadata: true,
      filter: filters,
    });

    return res;
  } catch (e) {
    console.log("Error in queryPinecone", e.message);
    return null;
  }
};

export default queryPinecone;
