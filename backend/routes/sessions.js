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

// Get all sessions for a user
router.get("/person/:peopleId", (req, res) => {
  const peopleId = req.params.peopleId;

  db.all(
    `SELECT s.*, p.name as person_name, p.relationship 
     FROM Sessions s 
     JOIN People p ON s.people_id = p.id 
     WHERE s.people_id = ? 
     ORDER BY s.created_at DESC`,
    [peopleId],
    (err, rows) => {
      if (err) {
        res.status(500).json({ error: "Failed to fetch sessions" });
        return;
      }
      res.json({ sessions: rows });
    }
  );
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

// Create new session
router.post("/", (req, res) => {
  const { people_id, title } = req.body;

  if (!people_id) {
    res.status(400).json({ error: "User ID is required" });
    return;
  }

  // Check if user exists
  db.get("SELECT id FROM People WHERE id = ?", [people_id], (err, row) => {
    if (err) {
      res.status(500).json({ error: "Failed to verify user" });
      return;
    }

    if (!row) {
      res.status(404).json({ error: "User not found" });
      return;
    }

    // Create session
    db.run(
      'INSERT INTO Sessions (people_id, title, created_at) VALUES (?, ?, datetime("now"))',
      [people_id, title || null],
      function (err) {
        if (err) {
          res.status(500).json({ error: "Failed to create session" });
          return;
        }

        // Get created session with user info
        db.get(
          `SELECT s.*, p.name as person_name, p.relationship 
           FROM Sessions s 
           JOIN People p ON s.people_id = p.id 
           WHERE s.id = ?`,
          [this.lastID],
          (err, row) => {
            if (err) {
              res
                .status(500)
                .json({ error: "Failed to fetch created session" });
              return;
            }
            res.status(201).json({ session: row });
          }
        );
      }
    );
  });
});

// Delete session
router.delete("/:id", (req, res) => {
  const sessionId = req.params.id;

  db.run("DELETE FROM Sessions WHERE id = ?", [sessionId], (err) => {
    if (err) {
      res.status(500).json({ error: "Failed to delete session" });
      return;
    }
    res.json({ message: "Session deleted successfully" });
  });
});

module.exports = router;
