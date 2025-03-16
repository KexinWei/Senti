const express = require("express");
const router = express.Router();
const { db } = require("../database/initDB");
const axios = require("axios");

// Get all messages for a given session_id
router.get("/", (req, res) => {
  const { session_id } = req.query;
  if (!session_id) {
    return res.status(400).json({ error: "Missing session_id parameter" });
  }
  const sql =
    "SELECT * FROM Messages WHERE session_id = ? ORDER BY created_at ASC";
  const params = [session_id];
  db.all(sql, params, (err, rows) => {
    if (err) {
      console.error("Error fetching messages:", err.message);
      return res.status(500).json({ error: err.message });
    }
    res.json({ messages: rows });
  });
});

// Helper functions to wrap db.run and db.all in Promises
const runQuery = (sql, params) => {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) reject(err);
      else resolve({ lastID: this.lastID });
    });
  });
};

const allQuery = (sql, params) => {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
};

// POST endpoint to add a user message, then analyze and insert AI messages
router.post("/", async (req, res) => {
  try {
    const { session_id, sender, content } = req.body;
    if (!session_id || !sender || !content) {
      return res.status(400).json({ error: "Missing required fields." });
    }

    // 1. Insert the user's message
    const insertSQL =
      "INSERT INTO Messages (session_id, sender, content) VALUES (?, ?, ?)";
    const insertParams = [session_id, sender, content];
    const userInsertResult = await runQuery(insertSQL, insertParams);

    // 2. Retrieve all messages for this session and concatenate their content
    const selectSQL =
      "SELECT * FROM Messages WHERE session_id = ? ORDER BY created_at ASC";
    const messages = await allQuery(selectSQL, [session_id]);
    const conversation = messages
      .map((msg) => `${msg.sender}: ${msg.content}`)
      .join("\n");

    // 3. Call the analyze endpoint
    try {
      const analysisResponse = await axios.post(
        "http://localhost:3000/api/analyze",
        {
          conversation: conversation,
        }
      );

      const analysis = analysisResponse.data.analysis;

      if (analysis && analysis.response) {
        // 4. Extract fields for the AI messages
        const possibleCauses = analysis.response.possible_causes;
        const suggestion = analysis.response.suggestion;
        const combinedAnalysis = `${possibleCauses} ${suggestion}`;

        // 5. Insert the AI message with combined analysis
        const aiInsertSQL =
          "INSERT INTO Messages (session_id, sender, content) VALUES (?, ?, ?)";
        await runQuery(aiInsertSQL, [session_id, "ai", combinedAnalysis]);

        // 6. Respond with success message
        res.status(201).json({
          message:
            "User message recorded and emotion analysis completed successfully.",
          userMessage: {
            id: userInsertResult.lastID,
            session_id,
            sender,
            content,
          },
          analysis: {
            possible_causes: possibleCauses,
            suggestion: suggestion,
          },
        });
      } else {
        throw new Error("Invalid analysis response format");
      }
    } catch (analysisError) {
      console.error("Error during analysis:", analysisError);
      // Even if analysis fails, we still want to save the user message
      res.status(201).json({
        message: "User message recorded but analysis failed.",
        userMessage: {
          id: userInsertResult.lastID,
          session_id,
          sender,
          content,
        },
        error: "Analysis failed",
      });
    }
  } catch (error) {
    console.error("Error in message endpoint:", error);
    res.status(500).json({ error: "Internal server error." });
  }
});

module.exports = router;
