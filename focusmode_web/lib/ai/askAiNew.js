"use server";
import { openai } from "@ai-sdk/openai";
import { streamObject } from "ai";
import { createStreamableValue } from "ai/rsc";
import { z } from "zod";
import { getMongoClient } from "../../adapters/mongodb";
import getTimestamps from "../mongo/getTimestamps";
import queryPinecone from "../pinecone/queryPinecone";
import { sleep } from "@/lib/sleep";
import { createReadStream } from "fs";
import { Parser } from "stream-json";
import { streamValues } from "stream-json/streamers/StreamValues";

const askAINew = async (
  userQuery,
  isDev,
  controller = new AbortController(),
) => {
  // "use server";
  try {
    const stream = createStreamableValue();
    if (isDev) {
      await sleep(2000);
      let path =
        "/Users/spark/Desktop/nextApps/videoai_fe/lib/openai/dummydata3.json";
      // if (userQuery.includes("strategies")) {
      //   path =
      //     "/Users/spark/Desktop/nextApps/videoai_fe/lib/openai/dummydata.json";
      // }
      const readStream = createReadStream(path, {
        encoding: "utf8",
        highWaterMark: 2,
      });

      const parser = new Parser();
      const valueStream = parser.pipe(streamValues());

      // Listen for data events to process JSON objects
      valueStream.on("data", async ({ value }) => {
        // Process each JSON object here
        console.log("Partial object:", value);

        // Simulate processing time (remove in production)
        stream.update(value);
        await new Promise((resolve) => setTimeout(resolve, 1000));

        // Update streamable value with partial object
      });

      // Listen for end event when all data has been processed
      valueStream.on("end", () => {
        console.log("Stream ended");
        stream.done();
      });

      // Handle stream errors
      // valueStream.on("error", (error) => {
      //   console.error("Stream error:", error);
      //   stream.done(); // Mark stream as done in case of error
      // });

      // Pipe the JSON data from the file to the parser
      readStream.pipe(parser);
      return { object: stream.value };
    }
    if (!userQuery) {
      console.log("Query, index, or client not found");
      throw new Error("Query not found");
    }
    const startTime = new Date().getTime();
    const question = userQuery;
    const result = await queryPinecone({ query: question });

    if (!result) {
      throw new Error("Result not found");
    }
    const context =
      Array.isArray(result.matches) &&
      result.matches.map((match) => match.metadata);

    const resJson = {
      ...result,
      question,
      created_at: new Date(),
    };
    console.log(resJson);
    // const extraData = new StreamData();
    let textUsed = null;
    let timestampCollected = false;
    let streamedData = {};
    const schema = z.object({
      answer: z.string().describe("The answer to the question"),
      text_used: z.array(
        z.object({
          videoId: z.string().describe("ID of the first video used."),
          text: z
            .string()
            .array()
            .describe(
              "Do not use emojis or links and only return the first line of the paragraph",
            ),
        }),
      ),
      followup_questions: z.string().array(),
    });
    async function generate() {
      const { partialObjectStream } = await streamObject({
        model: openai("gpt-3.5-turbo-0125"),
        system: `You will be given transcript from different videos with their video ids. Your task is to analyze the given context from videos and fulfil the given objectives. Your objectives are as follows:
    Answer the question: Begin by thoroughly reading the provided videos transcript. Understand the main ideas, key points, and the overall message conveyed and create a well structured answer with proper headings in very simple terms which is easy to read and understand.
    Return the first line of text used for answering: only return the starting line of each paragraph you used to answer the question along with video id.
    3 Followup questions: provide a list of follow-up questions that you think would be interesting to ask based on the context of the video.
    By following these guidelines, answer the questions based on the context of the video transcript. output should be in json format.
    e.g.:
    {
      "answer": "The answer to the question",
      "text_used": [{ videoId: "", text: ["first line of first paragraph", "first line of second paragraph"]}],
      "followup_questions": ["Follow-up question 1", "Follow-up question 2", "Follow-up question 3"]
    }

    Video transcripts: ${JSON.stringify(context)}
  `,
        mode: "json",
        abortSignal: controller.signal,
        prompt: userQuery,
        schema: schema,
      });
      console.log(partialObjectStream, "partialObjectStream");
      for await (const partialObject of partialObjectStream) {
        console.log("writing...");
        // console.log(
        //   partialObject,
        //   textUsed,
        //   Boolean(partialObject.followup_questions),
        //   Boolean(partialObject.followup_questions && !textUsed),
        //   "partialObject",
        // );
        streamedData = {
          ...streamedData,
          answer: partialObject.answer,
          followup_questions: partialObject.followup_questions,
        };
        // console.log("-------------------");
        if (partialObject.followup_questions && !textUsed) {
          console.log("starting to get timestamps");
          textUsed = partialObject.text_used;
          console.log(Boolean(textUsed), "textUsed");
          // start getting timestamps
          getTimestamps(textUsed)
            .then(async (data) => {
              console.log(Boolean(data), "data");
              resJson.timestamp = data;

              resJson.answer = partialObject.answer;
              // extraData.append(resJson);
              streamedData.timestamp = resJson.timestamp;
              streamedData.question = resJson.question;
              timestampCollected = true;
              // extraData.close();
              // Write JSON to a file
              // stream.done();
            })
            .catch((e) => {
              timestampCollected = true;
              console.log(e, "error getting the source");
            })
            .finally(() => {
              timestampCollected = true;
            });
        }
        stream.update(streamedData);
      }
      let count = 0;
      while (!timestampCollected && count < 40) {
        count++;
        console.log("waiting for timestamp");
        await sleep(250);
      }
      console.log("data stored in mdb", { ...resJson, ...streamedData });
      const endTime = new Date().getTime();
      const timeTaken = endTime - startTime;
      resJson.timeTaken = timeTaken;
      (await getMongoClient())
        .collection("search")
        .insertOne({ ...resJson, ...streamedData });
      stream.done();
    }
    generate();
    const res = { object: stream.value };
    console.log("streaming => ", res);
    return res;
  } catch (e) {
    console.log(e);
  }
};

export default askAINew;
