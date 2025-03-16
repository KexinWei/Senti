const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// 数据库文件路径（直接硬编码）
const dbPath = path.join(__dirname, '../mydatabase.sqlite');

// 连接 SQLite 数据库
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Database connection failed:', err);
  } else {
    console.log('Connected to SQLite database');
  }
});

// 创建表（如果不存在）


module.exports = db;
