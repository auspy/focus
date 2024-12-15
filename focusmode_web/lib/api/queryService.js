import { openai } from "@ai-sdk/openai";
import { streamObject } from "ai";
import { createReadStream } from "fs";
import { NextResponse } from "next/server";
import { Parser } from "stream-json";
import { streamValues } from "stream-json/streamers/StreamValues";
import { z } from "zod";
import { getMongoClient } from "@/adapters/mongodb";
import getTimestamps from "@/lib/mongo/getTimestamps";
import { default as queryPinecone } from "@/lib/pinecone/queryPinecone";
import { sleep } from "@/lib/sleep";
import { videoPrompt } from "../prompts";

// Function to create a Transform Stream that buffers incomplete JSON chunks
function createJsonStringifyTransformStream() {
  return new TransformStream({
    transform(chunk, controller) {
      try {
        const jsonString = JSON.stringify(chunk) + "\n";
        console.log("chunk in transformer=>", chunk);
        controller.enqueue(jsonString);
      } catch (err) {
        controller.error(err);
      }
    },
  });
}

export default async function serviceQuery({
  messages,
  isDev,
  videoId,
  indexName,
}) {
  try {
    const lastMsg = messages[messages.length - 1];
    if (lastMsg.role != "user") {
      console.log("lastMsg=>", lastMsg);
      throw new Error("Last message role should be user");
    }
    const question = lastMsg.content;
    // start by sending response to ai to answer without context and breakdown the question
    // const { text: query } = await generateText({
    //   model: anthropic("claude-3-haiku-20240307"),
    //   tools: tools,
    //   messages: [],
    //   system: agent1Prompt,
    // });
    // if the question is answered
    if (!Array.isArray(messages)) {
      console.log("messages not found");
      throw new Error("messages not found");
    }
    const startTime = new Date().getTime();

    const result = await queryPinecone({
      query: question,
      videoId,
      indexProps: { indexName },
    });
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

    const controller = new AbortController();
    const { partialObjectStream } = await streamObject({
      model: openai("gpt-3.5-turbo-0125"),
      prompt: question,
      mode: "auto",
      abortSignal: controller.signal,
      schema: schema,
      system: videoPrompt(context),
      // prompt: "say ok.",
    });

    let textUsed = null;
    // let timestampCollected = false;
    let streamedData = {};
    const readableStream = new ReadableStream({
      async start(controller) {
        for await (const partialObject of partialObjectStream) {
          console.log("chunk in readable stream=> ", partialObject);
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
            const data = await getTimestamps(textUsed);
            // .then(async (data) => {
            console.log(Boolean(data), "data");
            resJson.timestamp = data;
            const endTime = new Date().getTime();
            const timeTaken = endTime - startTime;
            resJson.timeTaken = timeTaken;
            // extraData.append(resJson);
            streamedData.timestamp = resJson.timestamp;
            streamedData.question = resJson.question;
            // timestampCollected = true;
            // extraData.close();
            // Write JSON to a file
            (await getMongoClient()).collection("search").insertOne(resJson);
            // stream.done();
            // })
            // .catch((e) => {
            //   timestampCollected = true;
            //   console.log(e, "error getting the source");
            // })
            // .finally(() => {
            //   timestampCollected = true;
            // });
          }
          controller.enqueue(streamedData);
        }
        // let count = 0;
        // while (!timestampCollected && count < 40) {
        //   count++;
        //   console.log("waiting for timestamp");
        //   await sleep(250);
        // }
        controller.close();
      },
    });

    // Create the JSON stringify transform stream
    const jsonStringifyTransformStream = createJsonStringifyTransformStream();

    // Pipe the readable stream through the transform stream

    const transformedStream = readableStream.pipeThrough(
      jsonStringifyTransformStream,
    );

    // Return the transformed stream as the response
    return new Response(transformedStream, {
      headers: {
        "Content-Type": "application/json",
      },
    });
  } catch (e) {
    console.log(e);
    return NextResponse.error();
  }
}
