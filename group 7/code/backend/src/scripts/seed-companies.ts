import { query } from '../db/connection.js';
import { v4 as uuidv4 } from 'uuid';

const COMPANIES_DATA = [
  {
    name: "TechVision Labs",
    industry: "Technology",
    description: "Leading AI and ML solutions company",
    website: "https://techvisionlabs.example.com",
    logo_url: "https://via.placeholder.com/200?text=TechVision",
  },
  {
    name: "DataFlow Systems",
    industry: "Data Analytics",
    description: "Enterprise data solutions and BI platforms",
    website: "https://dataflow.example.com",
    logo_url: "https://via.placeholder.com/200?text=DataFlow",
  },
  {
    name: "CloudPeak Solutions",
    industry: "Cloud Computing",
    description: "AWS and cloud infrastructure services",
    website: "https://cloudpeak.example.com",
    logo_url: "https://via.placeholder.com/200?text=CloudPeak",
  },
  {
    name: "FinTech Innovations",
    industry: "Financial Technology",
    description: "Fintech solutions for digital banking",
    website: "https://fintechinnovations.example.com",
    logo_url: "https://via.placeholder.com/200?text=FinTech",
  },
  {
    name: "GreenTech Energy",
    industry: "Renewable Energy",
    description: "Solar technology and renewable solutions",
    website: "https://greentechenergy.example.com",
    logo_url: "https://via.placeholder.com/200?text=GreenTech",
  },
  {
    name: "CyberShield Security",
    industry: "Cybersecurity",
    description: "Enterprise cybersecurity solutions",
    website: "https://cybershieldsecurity.example.com",
    logo_url: "https://via.placeholder.com/200?text=CyberShield",
  },
  {
    name: "MediHealth AI",
    industry: "Healthcare Technology",
    description: "AI-powered healthcare solutions",
    website: "https://medihealthai.example.com",
    logo_url: "https://via.placeholder.com/200?text=MediHealth",
  },
];

const JOBS_BY_COMPANY: Record<string, any[]> = {
  "TechVision Labs": [
    { 
      title: "Senior Software Engineer", 
      job_type: "full_time", 
      description: "Lead ML infrastructure development", 
      location: "Bangalore",
      salary_min: 2000000, 
      salary_max: 3500000, 
    },
    { 
      title: "ML Engineer Internship", 
      job_type: "internship", 
      description: "Work on ML projects and models", 
      location: "Bangalore",
      salary_min: 0, 
      salary_max: 300000, 
    },
  ],
  "DataFlow Systems": [
    { 
      title: "Data Analyst", 
      job_type: "full_time", 
      description: "Analyze data and create dashboards", 
      location: "Mumbai",
      salary_min: 1500000, 
      salary_max: 2500000, 
    },
    { 
      title: "Data Science Internship", 
      job_type: "internship", 
      description: "Build ML models and analyze data", 
      location: "Pune",
      salary_min: 0, 
      salary_max: 400000, 
    },
  ],
  "CloudPeak Solutions": [
    { 
      title: "DevOps Engineer", 
      job_type: "full_time", 
      description: "Manage AWS infrastructure", 
      location: "Bangalore",
      salary_min: 1800000, 
      salary_max: 3000000, 
    },
    { 
      title: "Cloud Engineering Internship", 
      job_type: "internship", 
      description: "Learn AWS and cloud technologies", 
      location: "Bangalore",
      salary_min: 0, 
      salary_max: 350000, 
    },
  ],
  "FinTech Innovations": [
    { 
      title: "Backend Engineer", 
      job_type: "full_time", 
      description: "Build payment systems and APIs", 
      location: "Bangalore",
      salary_min: 1600000, 
      salary_max: 2800000, 
    },
    { 
      title: "Full Stack Developer Internship", 
      job_type: "internship", 
      description: "Develop fintech features", 
      location: "Bangalore",
      salary_min: 0, 
      salary_max: 250000, 
    },
  ],
  "GreenTech Energy": [
    { 
      title: "Solar Systems Engineer", 
      job_type: "full_time", 
      description: "Design solar systems", 
      location: "Pune",
      salary_min: 1400000, 
      salary_max: 2400000, 
    },
    { 
      title: "Environmental Internship", 
      job_type: "internship", 
      description: "Research sustainability solutions", 
      location: "Pune",
      salary_min: 0, 
      salary_max: 200000, 
    },
  ],
  "CyberShield Security": [
    { 
      title: "Security Engineer", 
      job_type: "full_time", 
      description: "Mitigate security threats", 
      location: "Bangalore",
      salary_min: 2000000, 
      salary_max: 3500000, 
    },
    { 
      title: "Cybersecurity Internship", 
      job_type: "internship", 
      description: "Learn cybersecurity basics", 
      location: "Bangalore",
      salary_min: 0, 
      salary_max: 300000, 
    },
  ],
  "MediHealth AI": [
    { 
      title: "Healthcare Software Engineer", 
      job_type: "full_time", 
      description: "Build healthcare AI solutions", 
      location: "Pune",
      salary_min: 1700000, 
      salary_max: 2900000, 
    },
    { 
      title: "Healthcare AI Internship", 
      job_type: "internship", 
      description: "Develop medical AI models", 
      location: "Pune",
      salary_min: 0, 
      salary_max: 320000, 
    },
  ],
};

async function seedCompanies() {
  try {
    console.log("Starting to seed companies...");

    for (const companyData of COMPANIES_DATA) {
      const companyId = uuidv4();
      
      try {
        // Insert company
        const result = await query(
          `INSERT INTO companies (id, name, industry, description, logo_url, website, created_at, updated_at) 
           VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
           RETURNING id`,
          [
            companyId,
            companyData.name,
            companyData.industry,
            companyData.description,
            companyData.logo_url,
            companyData.website,
          ]
        );

        console.log(`✓ Created company: ${companyData.name}`);

        const jobsForCompany = JOBS_BY_COMPANY[companyData.name] || [];
        
        // Insert jobs for this company
        for (const jobData of jobsForCompany) {
          const jobId = uuidv4();
          
          await query(
            `INSERT INTO jobs (id, company_id, title, job_type, description, location, 
             salary_min, salary_max, active, created_at, updated_at) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW())`,
            [
              jobId,
              companyId,
              jobData.title,
              jobData.job_type,
              jobData.description,
              jobData.location,
              jobData.salary_min || null,
              jobData.salary_max || null,
              true,
            ]
          );

          console.log(`  → Created job: ${jobData.title}`);
        }
      } catch (err: any) {
        console.error(`✗ Error with ${companyData.name}: ${err.message}`);
      }
    }

    console.log("\n✅ Seeding completed successfully!");
    
  } catch (error: any) {
    console.error("✗ Fatal error:", error.message);
  } finally {
    process.exit(0);
  }
}

seedCompanies();
