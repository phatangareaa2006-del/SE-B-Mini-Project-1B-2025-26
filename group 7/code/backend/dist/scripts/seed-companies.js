import { query } from '../db/connection.js';
import { v4 as uuidv4 } from 'uuid';
const COMPANIES_DATA = [
    {
        name: "TechVision Labs",
        industry: "Technology",
        description: "Leading AI and ML solutions company transforming businesses with cutting-edge technology",
        website: "https://techvisionlabs.example.com",
        linkedin_url: "https://linkedin.com/company/techvisionlabs",
        logo_url: "https://via.placeholder.com/200?text=TechVision",
        banner_url: "https://via.placeholder.com/1200x300?text=TechVision+Banner",
        founded_year: 2015,
        culture: "Innovation-driven, collaborative, growth-focused",
        benefits: ["Health Insurance", "Remote Work", "Learning Budget", "Stock Options"],
        perks: ["Free Meals", "Gaming Room", "Wellness Programs", "Flexible Hours"],
    },
    {
        name: "DataFlow Systems",
        industry: "Data Analytics",
        description: "Enterprise data solutions and business intelligence platforms",
        website: "https://dataflow.example.com",
        linkedin_url: "https://linkedin.com/company/dataflow",
        logo_url: "https://via.placeholder.com/200?text=DataFlow",
        banner_url: "https://via.placeholder.com/1200x300?text=DataFlow+Banner",
        founded_year: 2016,
        culture: "Data-driven, analytical, result-oriented",
        benefits: ["Retirement Plan", "Health Coverage", "Paid Time Off", "Bonuses"],
        perks: ["Gym Membership", "Team Outings", "Career Development", "Mentorship"],
    },
    {
        name: "CloudPeak Solutions",
        industry: "Cloud Computing",
        description: "AWS and cloud infrastructure consulting and implementation",
        company_size: "101-200",
        linkedin_url: "https://linkedin.com/company/cloudpeak",
        logo_url: "https://via.placeholder.com/200?text=CloudPeak",
        banner_url: "https://via.placeholder.com/1200x300?text=CloudPeak+Banner",
        founded_year: 2018,
        culture: "Cloud-native, agile, customer-centric",
        benefits: ["Health & Wellness", "Flexible Schedule", "Relocation Support", "Training"],
        perks: ["Office Snacks", "Commute Allowance", "Project Bonuses", "Team Celebrations"],
    },
    {
        name: "FinTech Innovations",
        industry: "Financial Technology",
        description: "Revolutionary fintech solutions for digital banking and payments",
        company_size: "50-100",
        linkedin_url: "https://linkedin.com/company/fintech-innovations",
        logo_url: "https://via.placeholder.com/200?text=FinTech",
        banner_url: "https://via.placeholder.com/1200x300?text=FinTech+Banner",
        founded_year: 2019,
        culture: "Startup-like, innovative, fast-paced",
        benefits: ["Equity Options", "Health Insurance", "Flexible WFH", "Wellness"],
        perks: ["Free Parking", "Quarterly Bonus", "Learning Fund", "Tech Stipend"],
    },
    {
        name: "GreenTech Energy",
        industry: "Renewable Energy",
        description: "Sustainable energy solutions and solar technology innovations",
        company_size: "201-500",
        website: "https://greentechenergy.example.com",
        logo_url: "https://via.placeholder.com/200?text=GreenTech",
        banner_url: "https://via.placeholder.com/1200x300?text=GreenTech+Banner",
        founded_year: 2017,
        culture: "Sustainability-focused, impact-driven, collaborative",
        benefits: ["ESG Benefits", "Health Coverage", "Education Fund", "Parental Leave"],
        perks: ["Green Commute", "Eco Initiatives", "Volunteering Days", "Sustainability Bonus"],
    },
    {
        name: "CyberShield Security",
        industry: "Cybersecurity",
        description: "Enterprise cybersecurity and threat intelligence solutions",
        company_size: "301-500",
        linkedin_url: "https://linkedin.com/company/cybershield",
        logo_url: "https://via.placeholder.com/200?text=CyberShield",
        banner_url: "https://via.placeholder.com/1200x300?text=CyberShield+Banner",
        founded_year: 2014,
        culture: "Security-first, vigilant, expertise-driven",
        benefits: ["Security Training", "Health Insurance", "Relocation", "Stock Options"],
        perks: ["Certification Support", "Conference Attendance", "Home Office Setup", "Bonuses"],
    },
    {
        name: "MediHealth AI",
        industry: "Healthcare Technology",
        description: "AI-powered healthcare solutions and medical diagnostics",
        company_size: "101-200",
        website: "https://medihealthai.example.com",
        logo_url: "https://via.placeholder.com/200?text=MediHealth",
        banner_url: "https://via.placeholder.com/1200x300?text=MediHealth+Banner",
        founded_year: 2018,
        culture: "Mission-driven, collaborative, impact-focused",
        benefits: ["Health & Wellness", "Mental Health", "Flexible Hours", "Family Support"],
        perks: ["Free Health Checkups", "Gym", "Counseling", "Team Building"],
    },
];
const JOBS_BY_COMPANY = {
    "TechVision Labs": [
        {
            title: "Senior Software Engineer",
            job_type: "full_time",
            department: "Engineering",
            description: "Lead our ML infrastructure team",
            requirements: "8+ years experience, Python, ML frameworks",
            responsibilities: "Design scalable systems, mentor juniors",
            min_salary: 2000000,
            max_salary: 3500000,
            locations: ["Bangalore", "Remote"],
            min_experience: 8,
            openings: 2,
            min_cgpa: 7.0,
        },
        {
            title: "ML Engineer Internship",
            job_type: "internship",
            department: "AI/ML",
            description: "Work on cutting-edge ML projects",
            requirements: "Proficiency in Python, TensorFlow/PyTorch",
            responsibilities: "Build ML models, conduct research",
            min_salary: 0,
            max_salary: 300000,
            locations: ["Bangalore"],
            min_experience: 0,
            openings: 5,
            min_cgpa: 7.5,
        },
    ],
    "DataFlow Systems": [
        {
            title: "Data Analyst",
            job_type: "full_time",
            department: "Analytics",
            description: "Analyze complex business data",
            requirements: "SQL, Python, Statistics knowledge",
            responsibilities: "Create dashboards, reports, insights",
            min_salary: 1500000,
            max_salary: 2500000,
            locations: ["Mumbai", "Pune", "Remote"],
            min_experience: 3,
            openings: 3,
            min_cgpa: 7.0,
        },
        {
            title: "Data Science Internship",
            job_type: "internship",
            department: "Data Science",
            description: "Build ML models for business problems",
            requirements: "Python, Statistics, Pandas",
            responsibilities: "Data analysis, model development",
            min_salary: 0,
            max_salary: 400000,
            locations: ["Pune"],
            min_experience: 0,
            openings: 4,
            min_cgpa: 8.0,
        },
    ],
    "CloudPeak Solutions": [
        {
            title: "DevOps Engineer",
            job_type: "full_time",
            department: "Infrastructure",
            description: "Manage AWS infrastructure and CI/CD",
            requirements: "AWS, Docker, Kubernetes, Linux",
            responsibilities: "Manage cloud infrastructure, automation",
            min_salary: 1800000,
            max_salary: 3000000,
            locations: ["Bangalore", "Remote"],
            min_experience: 4,
            openings: 2,
            min_cgpa: 7.0,
        },
        {
            title: "Cloud Engineering Internship",
            job_type: "internship",
            department: "Cloud",
            description: "Learn AWS and cloud technologies",
            requirements: "Basic Linux, Programming knowledge",
            responsibilities: "AWS projects, infrastructure tasks",
            min_salary: 0,
            max_salary: 350000,
            locations: ["Bangalore"],
            min_experience: 0,
            openings: 3,
            min_cgpa: 7.0,
        },
    ],
    "FinTech Innovations": [
        {
            title: "Backend Engineer",
            job_type: "full_time",
            department: "Engineering",
            description: "Build payment systems and APIs",
            requirements: "Node.js, MongoDB, AWS",
            responsibilities: "Develop APIs, system design",
            min_salary: 1600000,
            max_salary: 2800000,
            locations: ["Bangalore", "Remote"],
            min_experience: 3,
            openings: 4,
            min_cgpa: 7.0,
        },
        {
            title: "Full Stack Developer Internship",
            job_type: "internship",
            department: "Development",
            description: "Build fintech features",
            requirements: "JavaScript, React, Node.js basics",
            responsibilities: "Feature development, bug fixes",
            min_salary: 0,
            max_salary: 250000,
            locations: ["Bangalore"],
            min_experience: 0,
            openings: 6,
            min_cgpa: 6.5,
        },
    ],
    "GreenTech Energy": [
        {
            title: "Solar Systems Engineer",
            job_type: "full_time",
            department: "Engineering",
            description: "Design solar energy systems",
            requirements: "Engineering degree, CAD skills",
            responsibilities: "System design, testing, optimization",
            min_salary: 1400000,
            max_salary: 2400000,
            locations: ["Pune", "Ahmedabad"],
            min_experience: 3,
            openings: 2,
            min_cgpa: 7.0,
        },
        {
            title: "Environmental Internship",
            job_type: "internship",
            department: "Sustainability",
            description: "Support sustainability initiatives",
            requirements: "Environmental science or related",
            responsibilities: "Research, analysis, field work",
            min_salary: 0,
            max_salary: 200000,
            locations: ["Pune"],
            min_experience: 0,
            openings: 3,
            min_cgpa: 6.5,
        },
    ],
    "CyberShield Security": [
        {
            title: "Security Engineer",
            job_type: "full_time",
            department: "Security",
            description: "Identify and mitigate security threats",
            requirements: "Cybersecurity knowledge, networking",
            responsibilities: "Threat analysis, system hardening",
            min_salary: 2000000,
            max_salary: 3500000,
            locations: ["Bangalore", "Remote"],
            min_experience: 5,
            openings: 3,
            min_cgpa: 7.5,
        },
        {
            title: "Cybersecurity Internship",
            job_type: "internship",
            department: "Security",
            description: "Learn cybersecurity fundamentals",
            requirements: "Networking basics, problem-solving",
            responsibilities: "Security testing, research",
            min_salary: 0,
            max_salary: 300000,
            locations: ["Bangalore"],
            min_experience: 0,
            openings: 4,
            min_cgpa: 7.5,
        },
    ],
    "MediHealth AI": [
        {
            title: "Healthcare Software Engineer",
            job_type: "full_time",
            department: "Engineering",
            description: "Build healthcare AI applications",
            requirements: "Node.js, Python, Medical domain knowledge",
            responsibilities: "Software development, HIPAA compliance",
            min_salary: 1700000,
            max_salary: 2900000,
            locations: ["Pune", "Remote"],
            min_experience: 3,
            openings: 2,
            min_cgpa: 7.0,
        },
        {
            title: "Healthcare AI Internship",
            job_type: "internship",
            department: "AI/ML",
            description: "Work on medical AI projects",
            requirements: "Python, ML basics, Healthcare interest",
            responsibilities: "Model development, data analysis",
            min_salary: 0,
            max_salary: 320000,
            locations: ["Pune"],
            min_experience: 0,
            openings: 3,
            min_cgpa: 7.5,
        },
    ],
};
async function seedCompanies() {
    try {
        console.log("Starting company seeding...");
        for (const companyData of COMPANIES_DATA) {
            const companyId = uuidv4();
            // Insert company
            await query(`INSERT INTO co (without user_id - making them public/demo companies)
      await query(
        `, INSERT, INTO, companies(id, name, industry, description, logo_url, banner_url, founded_year, culture, benefits, perks, verification_status, is_featured, website, linkedin_url, created_at, updated_at), VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, NOW(), NOW()) `,
        [
          companyId,
          companyData.name,
          companyData.industry,
          companyData.description,
          companyData.logo_url,
          companyData.banner_url,
          companyData.founded_year,
          companyData.culture,
          JSON.stringify(companyData.benefits),
          JSON.stringify(companyData.perks),
          'approved',
          true,
          companyData.website,
          companyData.linkedin_url

      console.log(`, Created, company, $, { companyData, : .name } `);

      // Insert jobs for this company
      const jobsForCompany = JOBS_BY_COMPANY[companyData.name] || [];
      
      for (const jobData of jobsForCompany) {
        const jobId = uuidv4();
        
        await query(
          `, INSERT, INTO, jobs(id, company_id, title, job_type, department, description, requirements, responsibilities, min_salary, max_salary, locations, min_experience, openings, min_cgpa, is_active, created_at, updated_at), VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, NOW(), NOW()) `,
          [
            jobId,
            companyId,
            jobData.title,
            jobData.job_type,
            jobData.department,
            jobData.description,
            jobData.requirements,
            jobData.responsibilities,
            jobData.min_salary || null,
            jobData.max_salary || null,
            JSON.stringify(jobData.locations),
            jobData.min_experience || 0,
            jobData.openings || 1,
            jobData.min_cgpa || null,
            true,
          ]
        );

        console.log(`, Created, job, $, { jobData, : .title } `);
      }
    }

    console.log("\n✅ Company seeding completed successfully!");
    console.log(`, Created, $, { COMPANIES_DATA, : .length }, companies);
            with ($) {
                Object.values(JOBS_BY_COMPANY).flatMap(j => j).length;
            }
            jobs `);
    
  } catch (error: any) {
    console.error("❌ Error seeding companies:", error.message);
  } finally {
    process.exit(0);
  }
}

seedCompanies();
            ;
        }
    }
    finally { }
}
//# sourceMappingURL=seed-companies.js.map