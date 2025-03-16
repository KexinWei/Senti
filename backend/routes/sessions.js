// server/routes/sessions.js
const express = require("express");
const router = express.Router();
const { db } = require("../database/initDB");

// Get message count for a session
router.get("/messages/count/:session_id", (req, res) => {
  const sql = "SELECT COUNT(*) as count FROM Messages WHERE session_id = ?";
  const params = [req.params.session_id];

  db.get(sql, params, (err, row) => {
    if (err) {
      console.error("Error counting messages:", err.message);
      return res.status(500).json({ error: err.message });
    }

    res.json({ count: row.count });
  });
});

// Get all sessions for a specific person
router.get("/person/:people_id", (req, res) => {
  const sql =
    "SELECT * FROM Sessions WHERE people_id = ? ORDER BY created_at DESC";
  const params = [req.params.people_id];
  db.all(sql, params, (err, rows) => {
    if (err) {
      console.error("Error fetching sessions:", err.message);
      return res.status(500).json({ error: err.message });
    }
    res.json({ sessions: rows });
  });
});

// Get a specific session by id
router.get("/:id", (req, res) => {
  const sql = "SELECT * FROM Sessions WHERE id = ?";
  const params = [req.params.id];
  db.get(sql, params, (err, row) => {
    if (err) {
      console.error("Error fetching session:", err.message);
      return res.status(500).json({ error: err.message });
    }
    if (!row) {
      return res.status(404).json({ error: "Session not found" });
    }
    res.json({ session: row });
  });
});

// Add a new session
router.post("/", (req, res) => {
  const { people_id, title } = req.body;
  if (!people_id) {
    return res.status(400).json({ error: "people_id is required" });
  }

  const sql = "INSERT INTO Sessions (people_id, title) VALUES (?, ?)";
  const params = [
    people_id,
    title || `Chat Session ${new Date().toLocaleString()}`,
  ];

  db.run(sql, params, function (err) {
    if (err) {
      console.error("Error adding session:", err.message);
      return res.status(500).json({ error: err.message });
    }

    // 获取新创建的会话
    db.get("SELECT * FROM Sessions WHERE id = ?", [this.lastID], (err, row) => {
      if (err) {
        console.error("Error fetching new session:", err.message);
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ session: row });
    });
  });
});

// Delete a session
router.delete("/:id", (req, res) => {
  const sql = "DELETE FROM Sessions WHERE id = ?";
  const params = [req.params.id];

  db.run(sql, params, function (err) {
    if (err) {
      console.error("Error deleting session:", err.message);
      return res.status(500).json({ error: err.message });
    }

    if (this.changes === 0) {
      return res.status(404).json({ error: "Session not found" });
    }

    res.json({ message: "Session deleted successfully" });
  });
});

module.exports = router;
