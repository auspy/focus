import { Pinecone } from "@pinecone-database/pinecone";
import { PINECONE_INDEX } from "@/constants";

const apiKey = process.env.PINECONE_API_KEY;
// console.log("pinecone api", apiKey);

const pine = new Pinecone({ apiKey });

const specDefault = {
  serverless: {
    cloud: "aws",
    region: "us-east-1",
  },
};
const indexNameDefault = PINECONE_INDEX;
const getPineconeIndex = async ({
  dimensionLen = 1536,
  spec = specDefault,
  indexName,
  pc = pine,
}) => {
  try {
    if (dimensionLen === null) {
      console.log("Embeddings not found");
      return null;
    }
    const indexNames = (await pc.listIndexes())?.indexes;
    const indexNm =
      typeof indexName == "string" &&
      indexNames?.find((index) => index.name === indexName)
        ? indexName
        : indexNameDefault;

    // console.log("indexNames", indexNames);
    if (indexNames && !indexNames.find((index) => index.name === indexNm)) {
      // if does not exist, throw error
      throw new Error("Index not found");
    }

    // connect to index
    const index = pc.Index(indexNm);
    // await sleep(1000);

    //  // view index stats
    // const indexStats = await index.describeIndexStats();
    // console.log("indexStats", indexStats);

    console.log("Index connected", indexNm);
    return index;
  } catch (e) {
    console.log("Error in createPineconeIndex", e);
    return null;
  }
};

export default getPineconeIndex;
