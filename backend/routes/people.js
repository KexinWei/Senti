const express = require("express");
const router = express.Router();
const { db } = require("../database/initDB");

// Get all people records
router.get("/", (req, res) => {
  const sql = "SELECT * FROM People ORDER BY created_at DESC";
  db.all(sql, [], (err, rows) => {
    if (err) {
      console.error("Failed to fetch people:", err.message);
      return res.status(500).json({ error: "Failed to fetch people" });
    }
    res.json({ people: rows });
  });
});

// Get a specific person by id
router.get("/:id", (req, res) => {
  const sql = "SELECT * FROM People WHERE id = ?";
  const params = [req.params.id];
  db.get(sql, params, (err, row) => {
    if (err) {
      console.error("Failed to fetch person:", err.message);
      return res.status(500).json({ error: "Failed to fetch person" });
    }
    if (!row) {
      return res.status(404).json({ error: "Person not found" });
    }
    res.json({ person: row });
  });
});

// Add a new person
router.post("/", (req, res) => {
  const { name, relationship, description } = req.body;
  if (!name || !relationship) {
    return res
      .status(400)
      .json({ error: "Name and relationship are required" });
  }

  const sql =
    "INSERT INTO People (name, relationship, description) VALUES (?, ?, ?)";
  const params = [name, relationship, description || null];

  db.run(sql, params, function (err) {
    if (err) {
      console.error("Failed to create person:", err.message);
      return res.status(500).json({ error: "Failed to create person" });
    }

    // Get newly created user data
    db.get("SELECT * FROM People WHERE id = ?", [this.lastID], (err, row) => {
      if (err) {
        console.error("Failed to fetch created person:", err.message);
        return res
          .status(500)
          .json({ error: "Failed to fetch created person" });
      }
      res.status(201).json({ people: row });
    });
  });
});

module.exports = router;
