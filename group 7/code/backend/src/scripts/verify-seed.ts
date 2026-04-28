import { query } from '../db/connection.js';

async function verifyData() {
  try {
    console.log('Verifying seeded data...\n');
    
    // Count companies
    const companies = await query('SELECT COUNT(*) as count FROM companies');
    console.log(`Total companies: ${companies.rows[0].count}`);
    
    // Count jobs
    const jobs = await query('SELECT COUNT(*) as count FROM jobs');
    console.log(`Total jobs: ${jobs.rows[0].count}`);
    
    // List companies
    console.log('\nCompanies:');
    const companyList = await query('SELECT name, industry FROM companies ORDER BY name');
    for (const company of companyList.rows) {
      console.log(`  - ${company.name} (${company.industry})`);
    }
    
    // List jobs by company
    console.log('\nJobs:');
    const jobList = await query(`
      SELECT c.name, j.title, j.job_type, j.salary_min, j.salary_max
      FROM jobs j
      JOIN companies c ON j.company_id = c.id
      ORDER BY c.name, j.title
    `);
    
    let currentCompany = '';
    for (const job of jobList.rows) {
      if (job.name !== currentCompany) {
        currentCompany = job.name;
        console.log(`\n  ${currentCompany}:`);
      }
      const salary = job.salary_min !== null ? ` (₹${job.salary_min.toLocaleString('en-IN')} - ₹${job.salary_max.toLocaleString('en-IN')})` : '';
      console.log(`    → ${job.title} (${job.job_type})${salary}`);
    }
    
    console.log('\n✅ Verification complete!');
    process.exit(0);
  } catch (error: any) {
    console.error('✗ Error:', error.message);
    process.exit(1);
  }
}

verifyData();
