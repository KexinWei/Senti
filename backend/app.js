const express = require('express');
const app = express();
const PORT = 3000; // 直接硬编码端口
const db = require('./db'); // 连接 SQLite
const analyzeRouter = require('./routes/analyze');

// 中间件
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

// 挂载路由
app.use('/analyze', analyzeRouter);

// 启动服务器
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
