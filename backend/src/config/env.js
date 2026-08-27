const dotenv = require('dotenv');
const path = require('path');

// Load .env from root directory or backend directory
dotenv.config({ path: path.resolve(__dirname, '../../../.env') });
dotenv.config(); // fallback to current dir

module.exports = {
  PORT: process.env.PORT || 5000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  FRONTEND_URL: process.env.FRONTEND_URL || 'http://localhost:5173',
  DATABASE_URL: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/bhoomisetu',
  JWT_SECRET: process.env.JWT_SECRET || 'bhoomisetu_secure_jwt_secret_key_2026_smart_india_hackathon',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '24h'
};
