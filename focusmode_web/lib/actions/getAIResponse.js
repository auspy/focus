import askAINew from "../ai/askAiNew";
import { readStreamableValue } from "ai/rsc";
export const getAIResponse = async (
  search,
  setGeneration,
  setGenerating = () => {},
  controller,
) => {
  let convo = null;
  try {
    if (!search) {
      console.log("no search in getAIResponse");
      return;
    }
    console.log(search, "searching start");
    setGenerating(true);
    setGeneration({
      role: "assistant",
      content: {
        question: search,
        answer: "I am thinking...",
        timestamp: null,
      },
    });

    const { object } = await askAINew(search, false, controller);
    for await (const partialObject of readStreamableValue(object)) {
      if (partialObject) {
        console.log(partialObject, "partialObject");
        console.log("-------------------");
        convo = {
          answer: partialObject.answer,
          timestamp: partialObject.timestamp,
          followUp: partialObject.followup_questions,
        };
        setGeneration((prev) => ({
          ...prev,
          content: {
            ...prev.content,
            ...convo,
          },
        }));
      }
    }
    console.log("convo addded to conversation successfully");
    setGenerating(false);
    return { ...convo, question: search };
  } catch (e) {
    console.log(e, "error in askAiNew");
    setGenerating(false);
  }
};
