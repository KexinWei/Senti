// server/app.js
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const { initDB } = require("./database/initDB");

const app = express();

const port = process.env.PORT || 3000;

// Initialize the database (create tables)
initDB();

// Enable CORS
app.use(cors());

// Use middleware to parse JSON request bodies
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

// Load routes
const peopleRoutes = require("./routes/people");
const sessionsRoutes = require("./routes/sessions");
const messagesRoutes = require("./routes/messages");
const analyzeRoutes = require("./routes/analyze");

app.use("/api/people", peopleRoutes);
app.use("/api/sessions", sessionsRoutes);
app.use("/api/messages", messagesRoutes);
app.use("/api/analyze", analyzeRoutes);

// 404 handler
app.use((req, res, next) => {
  res.status(404).json({ error: "Not Found" });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error("Internal error:", err);
  res.status(500).json({ error: "Internal Server Error" });
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
