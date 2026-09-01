const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const projectRoutes = require('./routes/projectRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const geoRoutes = require('./routes/geoRoutes');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();

// Security & Body parsing middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get(['/api/health', '/api/v1/health'], (req, res) => {
  res.status(200).json({
    status: 'UP',
    system: 'BhoomiSetu - Real-Time National Land Acquisition & Management System',
    timestamp: new Date().toISOString()
  });
});

// API Routes (support both /api and /api/v1)
app.use(['/api/auth', '/api/v1/auth'], authRoutes);
app.use(['/api/projects', '/api/v1/projects'], projectRoutes);
app.use(['/api/dashboard', '/api/v1/dashboard'], dashboardRoutes);
app.use(['/api/geo', '/api/v1/geo'], geoRoutes);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
