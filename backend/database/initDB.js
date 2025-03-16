// server/database/initDB.js
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Define the database file path
const dbPath = path.join(__dirname, 'database.sqlite3');

// Connect to the database (creates the file if it doesn't exist)
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error connecting to the database:', err.message);
  } else {
    console.log('Connected to the SQLite database at', dbPath);
  }
});

// Initialize the database and create tables
const initDB = () => {
  // Create People table
  db.run(`
    CREATE TABLE IF NOT EXISTS People (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      relationship TEXT NOT NULL,
      description TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `, (err) => {
    if (err) {
      console.error('Error creating People table:', err.message);
    }
  });

  // Create Sessions table
  db.run(`
    CREATE TABLE IF NOT EXISTS Sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      people_id INTEGER NOT NULL,
      title TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (people_id) REFERENCES People(id)
    )
  `, (err) => {
    if (err) {
      console.error('Error creating Sessions table:', err.message);
    }
  });

  // Create Messages table
  db.run(`
    CREATE TABLE IF NOT EXISTS Messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id INTEGER NOT NULL,
      sender TEXT NOT NULL,
      content TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (session_id) REFERENCES Sessions(id)
    )
  `, (err) => {
    if (err) {
      console.error('Error creating Messages table:', err.message);
    }
  });
};

module.exports = { db, initDB };
