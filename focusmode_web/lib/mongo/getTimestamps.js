import { getMongoClient } from "@/adapters/mongodb";
import { ObjectId } from "mongodb"; // Import ObjectId from mongodb library

// ! will need to create an old timestamps method for old flows
const getTimestamps = async ({ textUsed, ytVidId, videoId, db }) => {
  try {
    if (!textUsed) {
      console.log("No metadata found");
      return null;
    }
    if (!db) {
      console.log("No db found");
      return null;
    }
    // find unique ids and add text to array
    const uniqueText = {};

    function createPhrases(texts) {
      console.log("texts createPhrase", texts);
      let a;
      if (Array.isArray(texts)) {
        a = texts.flatMap((text) => {
          // ! this method will not be possible when timestamps are generated using whisper
          let sentences = text.split(/[.,?!()]/);
          const phrases = [];
          for (const sentence of sentences) {
            if (sentence.length == 0) continue;
            if (phrases.length > 3) break;
            const words = sentence.split(" ");
            if (words.length < 3) continue;
            if (words.length <= 4) {
              phrases.push(sentence.trim());
            } else {
              phrases.push(words.slice(0, 4).join(" ").trim());
              if (words.length > 6 && words.length - 4 > 3) {
                phrases.push(words.slice(3, 7).join(" ").trim());
                if (words.length > 8 && words.length - 7 > 3) {
                  phrases.push(words.slice(5, 9).join(" ").trim());
                }
              }
            }
          }
          // first sentence has more than 5 words
          // first sentence has

          return phrases;
        });
      } else {
        a = [`${texts}`];
      }
      console.log("phrases created", a.length);
      return a;
    }

    for (const textObj of textUsed) {
      if (!(textObj["text"]?.length > 0)) continue;

      if (!uniqueText[textObj.videoId]) {
        uniqueText[textObj.videoId] = {
          text: createPhrases(textObj.text),
        };
      } else {
        let a = createPhrases(textObj.text);
        uniqueText[textObj.videoId]["text"] = [
          ...uniqueText[textObj.videoId]["text"],
          ...a,
        ];
      }
    }
    // console.log("uniqueText", uniqueText);

    // create a query that will search for the text in each video using or and $text. now using search index as multiple phrases is not allowed in $text
    const phrases = Object.keys(uniqueText).flatMap(
      (vidId) => uniqueText[vidId].text,
    );
    // console.log("phrases", phrases);
    // getting video ids
    const query = {
      start: {
        $gt: 30,
      },
      // is greater than 30
    };
    const $or = [];
    // const $text = { $search: "" };
    for (const vidId in uniqueText) {
      // $text.$search = uniqueText[vidId].text
      //   .join(" ")
      //   .replace(/\n/g, " ")
      if (!videoId && vidId && ObjectId.isValid(vidId)) {
        $or.push({ videoId: new ObjectId(vidId) });
      }
    }

    // adding video id to search for
    if (videoId && typeof videoId === "string") {
      query.videoId = new ObjectId(videoId);
    } else if ($or.length > 0) {
      if ($or.length === 1) {
        query.videoId = $or[0].videoId;
      } else query["$or"] = $or;
    }

    // // add text phrases
    // query.$text = $text;
    // console.log("query", query);

    // initialize the mongo client
    const segments = await (
      await getMongoClient(db, true)
    ).collection("segments");

    // search for the text in the segments collection using search index
    const searchIndex = {
      yt_vizolv: "yt_vizolv_timestamps",
      "100xdevs_vizolv": "default",
    };
    const pipeline = [
      {
        $search: {
          index: searchIndex[db],
          phrase: {
            query: phrases,
            path: "text",
          },
        },
      },
      {
        $match: query,
      },
      {
        $limit: 10, // ! this should depend on duration of video
      },
    ];
    if (db === "100xdevs_vizolv") {
      pipeline.push(
        ...[
          {
            $lookup: {
              from: "videos",
              localField: "videoId",
              foreignField: "_id",
              as: "video",
              pipeline: [
                {
                  $project: {
                    _id: 1,
                    title: 1,
                    courseId: 1,
                    folderId: 1,
                    vid_100xdevs: 1,
                  },
                },
              ],
            },
          },
          {
            $unwind: "$video",
          },
          {
            $project: {
              _id: 1,
              start: 1,
              text: 1,
              video: 1,
            },
          },
        ],
      );
    } else if (db === "yt_vizolv") {
      pipeline.push(
        ...[
          {
            $project: {
              _id: 1,
              start: 1,
              text: 1,
              videoId: 1,
            },
          },
        ],
      );
    }
    console.log("pipeline", JSON.stringify(pipeline));
    const cursor = segments.aggregate(pipeline);
    const docs = await cursor.toArray();
    // console.log("docs", docs);
    console.log("Total timestamps length:", docs.length);
    return docs;
  } catch (e) {
    console.log(e, "in getTimestamps");
    return null;
  }
};

export default getTimestamps;
