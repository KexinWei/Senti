const express = require('express');
const router = express.Router();
const { db } = require('../database/initDB');

// Get all sessions (optionally filter by people_id)
router.get('/', (req, res) => {
  const { people_id } = req.query;
  let sql = 'SELECT * FROM Sessions';
  let params = [];
  if (people_id) {
    sql += ' WHERE people_id = ?';
    params.push(people_id);
  }
  sql += ' ORDER BY created_at DESC';
  db.all(sql, params, (err, rows) => {
    if (err) {
      console.error('Error fetching sessions:', err.message);
      return res.status(500).json({ error: err.message });
    }
    res.json({ sessions: rows });
  });
});

// Get a specific session by id
router.get('/:id', (req, res) => {
  const sql = 'SELECT * FROM Sessions WHERE id = ?';
  const params = [req.params.id];
  db.get(sql, params, (err, row) => {
    if (err) {
      console.error('Error fetching session:', err.message);
      return res.status(500).json({ error: err.message });
    }
    if (!row) {
      return res.status(404).json({ error: 'Session not found' });
    }
    res.json({ session: row });
  });
});

// Add a new session
router.post('/', (req, res) => {
  const { people_id, title } = req.body;
  const sql = 'INSERT INTO Sessions (people_id, title) VALUES (?, ?)';
  const params = [people_id, title];
  db.run(sql, params, function(err) {
    if (err) {
      console.error('Error adding session:', err.message);
      return res.status(500).json({ error: err.message });
    }
    res.status(201).json({ id: this.lastID, people_id, title });
  });
});

module.exports = router;
