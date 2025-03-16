const express = require("express");
const router = express.Router();
const EmotionAnalyzer = require("../models/emotionAnalyzer");

// Analyze emotions in text
router.post("/emotions", async (req, res) => {
  const { text } = req.body;

  if (!text) {
    res.status(400).json({ error: "Text is required for analysis" });
    return;
  }

  try {
    const analyzer = new EmotionAnalyzer();
    const emotions = await analyzer.analyzeEmotions(text);
    res.json({ emotions });
  } catch (error) {
    res.status(500).json({ error: "Failed to analyze emotions" });
  }
});

// Get emotion analysis history
router.get("/history/:sessionId", (req, res) => {
  const sessionId = req.params.sessionId;

  db.all(
    "SELECT * FROM EmotionAnalysis WHERE session_id = ? ORDER BY created_at DESC",
    [sessionId],
    (err, rows) => {
      if (err) {
        res.status(500).json({ error: "Failed to fetch emotion history" });
        return;
      }
      res.json({ history: rows });
    }
  );
});

module.exports = router;
