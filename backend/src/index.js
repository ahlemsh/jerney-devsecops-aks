require('dotenv').config();
const express = require('express');
const cors = require('cors');
const postRoutes = require('./routes/posts');
const commentRoutes = require('./routes/comments');
const db = require('./db');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
const allowedOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(',')
  : ['http://localhost', 'http://localhost:80'];

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (e.g. curl, health checks)
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error(`CORS policy: origin ${origin} not allowed`));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Jerney API is vibing ✨' });
});

// Routes
app.use('/api/posts', postRoutes);
app.use('/api/comments', commentRoutes);

// Initialize database and start server
async function start() {
  try {
    await db.initDB();
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Jerney backend running on port ${PORT}`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();
