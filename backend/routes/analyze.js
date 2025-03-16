const express = require('express');
const router = express.Router();
const analyzeEmotion = require('../models/emotionAnalyzer');

// 处理情绪分析的 API
router.post('/', async (req, res) => {
  // try {
  //   const { conversation } = req.body;
  //   if (!conversation || typeof conversation !== 'string') {
  //     return res.status(400).json({ error: 'Invalid input. Expecting a text conversation.' });
  //   }

  //   // 调用情绪分析函数
  //   const result = await analyzeEmotion(conversation);

  //   // 只保留需要的字段： created_at 和 response（注意 response 可能是 JSON 字符串，需要解析）
  //   let analysisResult = {};
  //   if (result && result.created_at && result.response) {
  //     analysisResult.created_at = result.created_at;
  //     try {
  //       // 如果 result.response 是 JSON 字符串，则解析为对象
  //       analysisResult.response = typeof result.response === 'string'
  //           ? JSON.parse(result.response)
  //           : result.response;
  //     } catch (e) {
  //       // 如果解析失败，直接返回原始字符串
  //       analysisResult.response = result.response;
  //     }
  //   } else {
  //     analysisResult = result;
  //   }

  //   res.json({
  //     message: "Emotion analysis completed successfully.",
  //     analysis: analysisResult
  //   });

    res.json({
      "message": "Emotion analysis completed successfully.",
      "analysis": {
          "created_at": "2025-03-16T07:05:33.9561783Z",
          "response": {
              "emotions": [
                  {
                      "emotion": "stress",
                      "turn_range": "Turn 1",
                      "notes": "The conversation partner expresses feelings of stress and anxiety about their work."
                  },
                  {
                      "emotion": "aroused",
                      "turn_range": "Turn 2 and Turn 3",
                      "notes": "The conversation partner seems aroused or interested in the sexual advance made by the user."
                  }
              ],
              "possible_causes": "The stress and anxiety mentioned by the conversation partner could be due to work-related pressures. The sudden change of topic and explicit sexual advances from the user might also contribute to their aroused or interested response.",
              "suggestion": "It is important to acknowledge the emotions expressed by your conversation partner and offer support if needed. In this case, showing understanding and empathy for their work-related stress could help de-escalate the situation. Additionally, it may be beneficial to discuss boundaries and ensure that the conversation remains respectful and appropriate."
          }
      }
  });
  // } catch (error) {
  //   console.error("Emotion analysis error:", error);
  //   res.status(500).json({ error: "Internal server error during emotion analysis." });
  // }
});

module.exports = router;
