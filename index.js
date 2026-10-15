const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

const { Pool } = require('pg');

// Connection settings come from the DATABASE_URL environment variable
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
pool.on('error', (err) => console.error('Database error:', err.message));

app.get('/', (req, res) => {
  res.json({
    message: process.env.APP_MESSAGE || 'Hello from the 30 Days of Docker + Kubernetes project!',
    hostname: require('os').hostname(),
    timestamp: new Date().toISOString(),
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/db', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() AS time, version() AS version');
    res.json({
      status: 'connected',
      time: result.rows[0].time,
      version: result.rows[0].version,
    });
  } catch (err) {
    res.status(500).json({ status: 'error', message: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
});
