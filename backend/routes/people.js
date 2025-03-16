const express = require("express");
const router = express.Router();
const { db } = require("../database/initDB");

// Get all people records
router.get("/", (req, res) => {
  const sql = "SELECT * FROM People ORDER BY created_at DESC";
  db.all(sql, [], (err, rows) => {
    if (err) {
      console.error("Error fetching People:", err.message);
      return res.status(500).json({ error: err.message });
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
      console.error("Error fetching person:", err.message);
      return res.status(500).json({ error: err.message });
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
      console.error("Error adding person:", err.message);
      return res.status(500).json({ error: err.message });
    }

    // 获取新创建的用户数据
    db.get("SELECT * FROM People WHERE id = ?", [this.lastID], (err, row) => {
      if (err) {
        console.error("Error fetching new person:", err.message);
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({ people: row });
    });
  });
});

module.exports = router;
