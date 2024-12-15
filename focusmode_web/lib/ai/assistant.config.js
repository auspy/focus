export const assistantId = (appId) => {
  // ! later assistant ID will be fetched from some key management system
  if (appId === "100xdevs") {
    return process.env.OPENAI_ASSISTANT_ID_100XDEVS;
  } else {
    return process.env.OPENAI_ASSISTANT_ID_YT;
  }
}; // set your assistant ID here
