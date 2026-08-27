const { initDb, pool } = require('./db');

async function runSeed() {
  try {
    console.log('🌱 Starting BhoomiSetu manual migration and seed runner...');
    await initDb();
    console.log('🎉 Seeding process completed successfully!');
    if (pool) {
      await pool.end();
    }
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

runSeed();
