const app = require('./app');
const config = require('./config/env');
const { initDb } = require('./config/db');

async function startServer() {
  try {
    // Initialize database, run migrations and seeds
    await initDb();

    app.listen(config.PORT, () => {
      console.log('====================================================');
      console.log(`🇮🇳  BHOOMISETU BACKEND SERVER ONLINE`);
      console.log(`📡  Port: ${config.PORT}`);
      console.log(`🌐  Environment: ${config.NODE_ENV}`);
      console.log(`🔗  Health API: http://localhost:${config.PORT}/api/health`);
      console.log('====================================================');
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

if (require.main === module) {
  startServer();
}

module.exports = app;
