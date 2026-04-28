import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const { Pool } = pg;

let pool: pg.Pool;
let isConnected = false;

const createPool = () => {
  const config: any = {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'postgres',
    user: process.env.DB_USER || 'postgres',
  };
  
  // Only add password if it's provided
  if (process.env.DB_PASSWORD) {
    config.password = process.env.DB_PASSWORD;
  }
  
  return new Pool(config);
};

try {
  pool = createPool();
  
  pool.on('error', (err) => {
    console.error('Unexpected error on idle client', err);
  });
  
  // Test connection
  pool.query('SELECT NOW()', (err) => {
    if (err) {
      console.warn('⚠️  Database connection failed:', err.message);
      isConnected = false;
    } else {
      console.log('✓ Database connected successfully');
      isConnected = true;
    }
  });
} catch (err) {
  console.warn('⚠️  Failed to create database pool:', err);
  // Create a dummy pool that will fail gracefully
  pool = createPool();
}

export const query = (text: string, params?: unknown[]) => {
  if (!isConnected) {
    console.warn('⚠️  Database not connected, query will fail:', text);
  }
  return pool.query(text, params);
};

export const getClient = () => {
  return pool.connect();
};

export const isDbConnected = () => isConnected;

export default pool;
