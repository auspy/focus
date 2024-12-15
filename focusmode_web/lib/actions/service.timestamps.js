"use server";
import queryPinecone from "../pinecone/queryPinecone";
import getTimestamps from "../mongo/getTimestamps";

export default async function serviceTimestamps({
  querys,
  videoId,
  vectorIndex,
  db,
  ...ids
}) {
  try {
    // console.log("serviceTimestamps started", ids);
    const storeMDB = {};
    if (!(Array.isArray(querys) && querys.length > 0)) {
      throw new Error("No query provided");
    }
    console.log("getting timestamps for querys=>", querys);
    storeMDB.querys = querys;
    // convert query to embeddings and get the related text
    const [context, results] = await semanticSearch({
      querys,
      ...(ids || {}),
      videoId,
      vectorIndex,
    });
    console.log("context=>", context);
    storeMDB.context = context;
    storeMDB.results = results;
    // return;
    // search the text for timestamps from mdb
    const timestamps = await getTimestamps({
      textUsed: context,
      videoId,
      db,
    });
    // return the timestamps
    console.log("timestamps=>", timestamps?.length);
    storeMDB.timestamps = timestamps;
    return [timestamps, storeMDB];
  } catch (e) {
    console.log(e, "error getting the timestamps");
  }
}

const semanticSearch = async ({
  querys,
  videoId,
  vectorIndex = "",
  ...ids
}) => {
  try {
    const results = [];
    for (const query of querys) {
      const result = await queryPinecone({
        query,
        videoId,
        indexProps: {
          indexName: vectorIndex,
        },
        ...ids,
      });
      results.push(result);
      if (!result) {
        console.log("Result not found");
        continue;
      }
    }
    const context = {};
    for (const result of results) {
      // sort the context by videoId and create a new array for each id
      if (Array.isArray(result.matches) && result.matches.length > 0) {
        const matches = result.matches;
        console.log("matches=>", matches);
        for (const match of matches) {
          console.log("match=>", match);
          if (!match?.metadata) continue;
          const vidId = match.metadata.video_id || match.metadata.videoId;
          if (!vidId) continue;
          const metadata = match.metadata;
          if (!Array.isArray(context[vidId])) {
            context[vidId] = [metadata["text"]];
          } else {
            context[vidId].push(metadata["text"]);
          }
        }
      }
    }

    return [
      Object.entries(context).map(([key, value]) => {
        return {
          videoId: key.toString(),
          text: value,
        };
      }),
      results,
    ];
  } catch (e) {
    console.log(e, "error in semantic search");
  }
};
