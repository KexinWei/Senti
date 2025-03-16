const express = require('express');
const router = express.Router();
const { db } = require('../database/initDB');

// Get all messages for a given session_id
router.get('/', (req, res) => {
  const { session_id } = req.query;
  if (!session_id) {
    return res.status(400).json({ error: 'Missing session_id parameter' });
  }
  const sql = 'SELECT * FROM Messages WHERE session_id = ? ORDER BY created_at ASC';
  const params = [session_id];
  db.all(sql, params, (err, rows) => {
    if (err) {
      console.error('Error fetching messages:', err.message);
      return res.status(500).json({ error: err.message });
    }
    res.json({ messages: rows });
  });
});

// Get a specific message by id
router.get('/:id', (req, res) => {
  const sql = 'SELECT * FROM Messages WHERE id = ?';
  const params = [req.params.id];
  db.get(sql, params, (err, row) => {
    if (err) {
      console.error('Error fetching message:', err.message);
      return res.status(500).json({ error: err.message });
    }
    if (!row) {
      return res.status(404).json({ error: 'Message not found' });
    }
    res.json({ message: row });
  });
});

// Add a new message
router.post('/', (req, res) => {
  const { session_id, sender, content } = req.body;
  const sql = 'INSERT INTO Messages (session_id, sender, content) VALUES (?, ?, ?)';
  const params = [session_id, sender, content];
  db.run(sql, params, function(err) {
    if (err) {
      console.error('Error adding message:', err.message);
      return res.status(500).json({ error: err.message });
    }
    res.status(201).json({ id: this.lastID, session_id, sender, content });
  });
});

module.exports = router;
