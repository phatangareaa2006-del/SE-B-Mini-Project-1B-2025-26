import { query } from '../db/connection.js';

async function checkSchema() {
  try {
    console.log('Checking database schema...\n');
    
    // Get all tables
    const tables = await query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `);
    
    console.log('✓ Tables in database:');
    if (tables.rows.length === 0) {
      console.log('  (No tables found)');
    } else {
      for (const row of tables.rows) {
        console.log(`  - ${row.table_name}`);
      }
    }
    
    // Check companies table specifically
    console.log('\nChecking companies table columns:');
    const columns = await query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'companies'
      ORDER BY ordinal_position;
    `);
    
    if (columns.rows.length === 0) {
      console.log('  (companies table does not exist)');
    } else {
      for (const row of columns.rows) {
        console.log(`  - ${row.column_name}: ${row.data_type}`);
      }
    }
    
    process.exit(0);
  } catch (error: any) {
    console.error('✗ Error:', error.message);
    process.exit(1);
  }
}

checkSchema();
