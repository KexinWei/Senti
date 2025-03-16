const axios = require('axios');

async function analyzeEmotion(conversation) {
  try {
    const prompt = `
      You are a professional conversation analyst with expertise in understanding and evaluating the emotional tone of a conversation partner.
      Below is the complete multi-turn conversation transcript between "me" (the user) and "them" (the conversation partner). Your task is to ignore any utterances that belong to me (the user) – for example, phrases like "I said" or "I mentioned" – and focus solely on analyzing the conversation partner's messages.
      
      Based solely on the partner's dialogue, please perform the following tasks:
      1. Analyze the conversation partner's messages and determine any emotional variations throughout the conversation.
      2. If only one consistent emotion is detected, output it as a single entry in the "emotions" array.
      3. If multiple distinct emotions are detected, output each emotion as an object in the "emotions" array. For each object, include:
         - "emotion": the identified emotion.
         - "turn_range": a description of which turns (or parts) of the conversation this emotion appears.
         - "notes": any additional analysis or observations about that emotional segment.
      4. Analyze the overall conversation for possible causes of the emotional variations and provide actionable advice on how to respond appropriately.
      
      IMPORTANT: Your output MUST be strictly in valid JSON format with the following structure:
      
      {
        "emotions": [
          {
            "emotion": "<Emotion>",
            "turn_range": "<Description of the turns where this emotion appears>",
            "notes": "<Additional notes about emotion>"
          }
        ],
        "possible_causes": "<Possible causes for the emotional variations>",
        "suggestion": "<Advice for responding appropriately>"
      }
      
      If any of the items are not applicable, leave them as an empty string (for text fields) or an empty array (for the emotions array if no emotions are detected).
      
      Conversation Transcript:
      "${conversation}"
    `;

    // 调用 Mistral 模型，设置 stream 为 false，确保返回完整输出
    const response = await axios.post("http://127.0.0.1:11434/api/generate", {
      prompt: prompt,
      model: "mistral",
      stream: false
    });

    const aiOutput = response.data;
    console.log("Raw AI output:", aiOutput);

    let parsedOutput;
    // 假设返回的是一个完整的 JSON 字符串
    if (typeof aiOutput === 'string') {
      let cleanOutput = aiOutput.trim();
      // 提取第一个 { 到最后一个 } 之间的内容
      const firstBrace = cleanOutput.indexOf('{');
      const lastBrace = cleanOutput.lastIndexOf('}');
      if (firstBrace !== -1 && lastBrace !== -1) {
        cleanOutput = cleanOutput.substring(firstBrace, lastBrace + 1);
      }
      parsedOutput = JSON.parse(cleanOutput);
    } else {
      parsedOutput = aiOutput;
    }
    return parsedOutput;
  } catch (error) {
    console.error("Error calling AI model:", error);
    return { error: "AI analysis failed." };
  }
}

module.exports = analyzeEmotion;
