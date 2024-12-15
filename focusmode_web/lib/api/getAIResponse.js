export async function getAIResponse(
  messages,
  parsedMsgs,
  input,
  setMessages,
  setParsedMsgs,
  isDev = false,
) {
  try {
    const msgs = [...messages, { content: input, role: "user" }];
    const chats = [...parsedMsgs, { content: input, role: "user" }];
    setMessages(msgs);
    setParsedMsgs(chats);
    const response = await fetch("http://localhost:3000/api/chat", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ messages: msgs, isDev }),
    });

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let done = false;

    while (!done) {
      const { value, done: readerDone } = await reader.read();
      done = readerDone;
      let chunk = decoder.decode(value, { stream: true });

      try {
        console.log("chunk", chunk);
        if (!chunk) {
          throw new Error("No response from AI");
        }
        if (chunk.match(/}\s*{/)) {
          const arr = chunk.split(/}\s*{/);

          chunk = "{" + arr[arr.length - 1];
          console.log("chunk in");
        }
        const parsedChunk = JSON.parse(chunk);
        console.log("parsedChunk", parsedChunk);
        const lastMsg = msgs[msgs.length - 1];
        const lastChat = chats[chats.length - 1];
        if (lastMsg?.role === "assistant") {
          msgs[msgs.length - 1].content = chunk;
        } else {
          msgs.push({ role: "assistant", content: chunk });
        }
        if (lastChat?.role === "assistant") {
          chats[chats.length - 1].content = parsedChunk;
        } else {
          chats.push({ role: "assistant", content: parsedChunk });
        }
        console.log("msgs", msgs, chats);
        setMessages(() => [...msgs]);
        setParsedMsgs([...chats]);
      } catch (error) {
        console.log("error iin inner loop", error);
        console.log("msgs", msgs, chats);
        setMessages(() => [...msgs]);
        setParsedMsgs([...chats]);
      }
    }
    return {
      messages: msgs,
      parsedMsgs: chats,
    };
  } catch (e) {
    console.log(e, "error in getAIResponse");
  }
}
