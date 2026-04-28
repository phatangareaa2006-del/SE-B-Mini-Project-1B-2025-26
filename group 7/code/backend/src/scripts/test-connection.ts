import { query } from '../db/connection.js';

async function testConnection() {
  try {
    console.log('Testing database connection...');
    const result = await query('SELECT NOW()');
    console.log('✓ Connection successful!');
    console.log('Current time from DB:', result.rows[0]);
    process.exit(0);
  } catch (error: any) {
    console.error('✗ Connection failed:', error.message);
    process.exit(1);
  }
}

testConnection();
