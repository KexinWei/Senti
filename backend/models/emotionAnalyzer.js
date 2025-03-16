const axios = require('axios');

async function analyzeEmotion(conversation) {
  try {
    const prompt = `
You are a professional conversation analyst specializing in emotion detection.
Your task is to analyze the emotional state of the speaker based on the given conversation and provide a judgment along with actionable advice.
Output only the result in valid JSON format without any additional explanation or commentary.

### Input:
"${conversation}"

### Required Output (JSON format):
{
    "emotion": "<Predicted Emotion>",
    "possible_causes": "<Possible causes of this emotion>",
    "suggestion": "<Advice for the user>"
}
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
