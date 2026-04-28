import { query } from '../db/connection.js';

async function checkJobsSchema() {
  try {
    console.log('Checking jobs table columns:');
    const columns = await query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'jobs'
      ORDER BY ordinal_position;
    `);
    
    if (columns.rows.length === 0) {
      console.log('  (jobs table does not exist)');
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

checkJobsSchema();
