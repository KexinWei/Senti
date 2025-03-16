const express = require('express');
const router = express.Router();
const analyzeEmotion = require('../models/emotionAnalyzer');

// 处理情绪分析的 API
router.post('/', async (req, res) => {
  try {
    const { conversation } = req.body;
    if (!conversation || typeof conversation !== 'string') {
      return res.status(400).json({ error: 'Invalid input. Expecting a text conversation.' });
    }

    // 调用情绪分析函数
    const result = await analyzeEmotion(conversation);

    // 只保留需要的字段： created_at 和 response（注意 response 可能是 JSON 字符串，需要解析）
    let analysisResult = {};
    if (result && result.created_at && result.response) {
      analysisResult.created_at = result.created_at;
      try {
        // 如果 result.response 是 JSON 字符串，则解析为对象
        analysisResult.response = typeof result.response === 'string'
            ? JSON.parse(result.response)
            : result.response;
      } catch (e) {
        // 如果解析失败，直接返回原始字符串
        analysisResult.response = result.response;
      }
    } else {
      analysisResult = result;
    }

    res.json({
      message: "Emotion analysis completed successfully.",
      analysis: analysisResult
    });
  } catch (error) {
    console.error("Emotion analysis error:", error);
    res.status(500).json({ error: "Internal server error during emotion analysis." });
  }
});

module.exports = router;