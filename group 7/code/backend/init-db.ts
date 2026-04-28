import { getClient } from './src/db/connection.js';
import { v4 as uuidv4 } from 'uuid';
import { hashPassword } from './src/utils/crypto.js';
import dotenv from 'dotenv';

dotenv.config();

const initDatabase = async () => {
  const client = await getClient();
  
  try {
    console.log('🔧 Initializing database schema...');
    
    // Drop existing objects (in correct order due to foreign keys)
    const dropStatements = [
      'DROP TABLE IF EXISTS notifications CASCADE',
      'DROP TABLE IF EXISTS messages CASCADE',
      'DROP TABLE IF EXISTS conversations CASCADE',
      'DROP TABLE IF EXISTS comments CASCADE',
      'DROP TABLE IF EXISTS post_likes CASCADE',
      'DROP TABLE IF EXISTS posts CASCADE',
      'DROP TABLE IF EXISTS connections CASCADE',
      'DROP TABLE IF EXISTS saved_opportunities CASCADE',
      'DROP TABLE IF EXISTS opportunity_registrations CASCADE',
      'DROP TABLE IF EXISTS opportunities CASCADE',
      'DROP TABLE IF EXISTS saved_jobs CASCADE',
      'DROP TABLE IF EXISTS job_applications CASCADE',
      'DROP TABLE IF EXISTS jobs CASCADE',
      'DROP TABLE IF EXISTS companies CASCADE',
      'DROP TABLE IF EXISTS achievements CASCADE',
      'DROP TABLE IF EXISTS projects CASCADE',
      'DROP TABLE IF EXISTS certifications CASCADE',
      'DROP TABLE IF EXISTS user_skills CASCADE',
      'DROP TABLE IF EXISTS skills CASCADE',
      'DROP TABLE IF EXISTS experience CASCADE',
      'DROP TABLE IF EXISTS education CASCADE',
      'DROP TABLE IF EXISTS profiles CASCADE',
      'DROP TABLE IF EXISTS user_roles CASCADE',
      'DROP TABLE IF EXISTS auth_users CASCADE',
      'DROP TYPE IF EXISTS connection_status CASCADE',
      'DROP TYPE IF EXISTS application_status CASCADE',
      'DROP TYPE IF EXISTS opportunity_type CASCADE',
      'DROP TYPE IF EXISTS job_type CASCADE',
      'DROP TYPE IF EXISTS app_role CASCADE',
    ];

    for (const stmt of dropStatements) {
      try {
        await client.query(stmt);
      } catch (err: any) {
        // Silently ignore
      }
    }

    console.log('✓ Cleaned up existing schema');

    // Create enum types
    const typeStatements = [
      `CREATE TYPE app_role AS ENUM ('student', 'company', 'college_admin', 'super_admin')`,
      `CREATE TYPE job_type AS ENUM ('full_time', 'internship', 'contract', 'part_time')`,
      `CREATE TYPE opportunity_type AS ENUM ('internship', 'job', 'competition', 'mock_test', 'mentorship', 'course')`,
      `CREATE TYPE application_status AS ENUM ('applied', 'under_review', 'shortlisted', 'interview', 'offer', 'hired', 'rejected')`,
      `CREATE TYPE connection_status AS ENUM ('pending', 'accepted', 'rejected')`,
    ];

    for (const stmt of typeStatements) {
      await client.query(stmt);
    }

    console.log('✓ Created enum types');

    // Create tables
    await client.query(`
      CREATE TABLE auth_users (
        id UUID PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE user_roles (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL UNIQUE REFERENCES auth_users(id) ON DELETE CASCADE,
        role app_role NOT NULL DEFAULT 'student',
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE profiles (
        id UUID PRIMARY KEY,
        user_id UUID UNIQUE NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        email TEXT NOT NULL,
        full_name TEXT,
        avatar_url TEXT,
        headline TEXT,
        bio TEXT,
        location TEXT,
        linkedin_url TEXT,
        github_url TEXT,
        portfolio_url TEXT,
        resume_url TEXT,
        college_id UUID,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE education (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        institution TEXT NOT NULL,
        degree TEXT NOT NULL,
        field_of_study TEXT,
        start_date DATE,
        end_date DATE,
        is_current BOOLEAN DEFAULT false,
        grade TEXT,
        cgpa DECIMAL(3,2),
        description TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE experience (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        company_name TEXT NOT NULL,
        title TEXT NOT NULL,
        employment_type TEXT,
        location TEXT,
        start_date DATE NOT NULL,
        end_date DATE,
        is_current BOOLEAN DEFAULT false,
        description TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE skills (
        id UUID PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        category TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE user_skills (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
        proficiency_level INTEGER,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE certifications (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        issuer TEXT NOT NULL,
        issue_date DATE,
        expiry_date DATE,
        credential_url TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE projects (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        description TEXT,
        link TEXT,
        github_link TEXT,
        start_date DATE,
        end_date DATE,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE achievements (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        description TEXT,
        achievement_date DATE,
        badge_url TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE companies (
        id UUID PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        logo_url TEXT,
        website TEXT,
        description TEXT,
        industry TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE jobs (
        id UUID PRIMARY KEY,
        company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
        title TEXT NOT NULL,
        description TEXT,
        job_type job_type,
        location TEXT,
        salary_min DECIMAL(10,2),
        salary_max DECIMAL(10,2),
        posted_date TIMESTAMP DEFAULT NOW(),
        deadline DATE,
        active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE job_applications (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
        status application_status DEFAULT 'applied',
        applied_date TIMESTAMP DEFAULT NOW(),
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, job_id)
      )
    `);

    await client.query(`
      CREATE TABLE saved_jobs (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
        saved_date TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, job_id)
      )
    `);

    await client.query(`
      CREATE TABLE opportunities (
        id UUID PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        opportunity_type opportunity_type,
        organization TEXT,
        posted_by UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        location TEXT,
        eligibility_criteria TEXT,
        posted_date TIMESTAMP DEFAULT NOW(),
        deadline DATE,
        active BOOLEAN DEFAULT true,
        featured BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE opportunity_registrations (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
        registered_date TIMESTAMP DEFAULT NOW(),
        status TEXT DEFAULT 'registered',
        UNIQUE(user_id, opportunity_id)
      )
    `);

    await client.query(`
      CREATE TABLE saved_opportunities (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        opportunity_id UUID NOT NULL REFERENCES opportunities(id) ON DELETE CASCADE,
        saved_date TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, opportunity_id)
      )
    `);

    await client.query(`
      CREATE TABLE posts (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        image_url TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE post_likes (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, post_id)
      )
    `);

    await client.query(`
      CREATE TABLE comments (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE connections (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        connected_user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        status connection_status DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, connected_user_id)
      )
    `);

    await client.query(`
      CREATE TABLE conversations (
        id UUID PRIMARY KEY,
        participant1_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        participant2_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(participant1_id, participant2_id)
      )
    `);

    await client.query(`
      CREATE TABLE messages (
        id UUID PRIMARY KEY,
        conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
        sender_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        receiver_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        content TEXT NOT NULL,
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    await client.query(`
      CREATE TABLE notifications (
        id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT,
        related_id UUID,
        is_read BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    console.log('✓ Created all tables');

    // Create indexes
    const indexStatements = [
      'CREATE INDEX idx_education_user_id ON education(user_id)',
      'CREATE INDEX idx_experience_user_id ON experience(user_id)',
      'CREATE INDEX idx_user_skills_user_id ON user_skills(user_id)',
      'CREATE INDEX idx_jobs_company_id ON jobs(company_id)',
      'CREATE INDEX idx_job_applications_user_id ON job_applications(user_id)',
      'CREATE INDEX idx_saved_jobs_user_id ON saved_jobs(user_id)',
      'CREATE INDEX idx_opportunities_posted_by ON opportunities(posted_by)',
      'CREATE INDEX idx_opportunity_registrations_user_id ON opportunity_registrations(user_id)',
      'CREATE INDEX idx_saved_opportunities_user_id ON saved_opportunities(user_id)',
      'CREATE INDEX idx_posts_user_id ON posts(user_id)',
      'CREATE INDEX idx_messages_receiver_id ON messages(receiver_id)',
      'CREATE INDEX idx_notifications_user_id ON notifications(user_id)',
      'CREATE INDEX idx_auth_users_email ON auth_users(email)',
      'CREATE INDEX idx_jobs_active ON jobs(active)',
      'CREATE INDEX idx_opportunities_active ON opportunities(active)',
    ];

    for (const stmt of indexStatements) {
      await client.query(stmt);
    }

    console.log('✓ Created indexes');

    // Add sample data
    console.log('📝 Adding sample data...');

    const studentId = uuidv4();
    const studentPassword = await hashPassword('student123');
    
    const companyId = uuidv4();
    const companyPassword = await hashPassword('company123');

    // Insert users
    await client.query(
      `INSERT INTO auth_users (id, email, password_hash) VALUES ($1, $2, $3)`,
      [studentId, 'student@example.com', studentPassword]
    );

    await client.query(
      `INSERT INTO auth_users (id, email, password_hash) VALUES ($1, $2, $3)`,
      [companyId, 'company@example.com', companyPassword]
    );

    // Assign roles
    await client.query(
      `INSERT INTO user_roles (id, user_id, role) VALUES ($1, $2, $3)`,
      [uuidv4(), studentId, 'student']
    );

    await client.query(
      `INSERT INTO user_roles (id, user_id, role) VALUES ($1, $2, $3)`,
      [uuidv4(), companyId, 'company']
    );

    // Create profiles
    await client.query(
      `INSERT INTO profiles (id, user_id, email, full_name, headline, bio) 
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [uuidv4(), studentId, 'student@example.com', 'John Student', 'Looking for internships', 'Computer Science student']
    );

    await client.query(
      `INSERT INTO profiles (id, user_id, email, full_name, headline, bio) 
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [uuidv4(), companyId, 'company@example.com', 'Tech Corp', 'Hiring for multiple roles', 'Leading tech company']
    );

    // Create company
    const companyRecordId = uuidv4();
    await client.query(
      `INSERT INTO companies (id, name, website, industry) VALUES ($1, $2, $3, $4)`,
      [companyRecordId, 'Tech Corp', 'https://techcorp.example.com', 'Technology']
    );

    // Create sample jobs
    const jobId = uuidv4();
    await client.query(
      `INSERT INTO jobs (id, company_id, title, description, job_type, location, salary_min, salary_max, deadline) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [jobId, companyRecordId, 'Junior Developer', 'Looking for junior developers', 'full_time', 'New York', 60000, 80000, new Date(Date.now() + 30*24*60*60*1000)]
    );

    // Create sample opportunities
    const oppId = uuidv4();
    await client.query(
      `INSERT INTO opportunities (id, title, description, opportunity_type, organization, posted_by, deadline, featured) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [oppId, 'Summer Internship Program', 'Join our summer internship program', 'internship', 'Tech Corp', companyId, new Date(Date.now() + 60*24*60*60*1000), true]
    );

    const oppId2 = uuidv4();
    await client.query(
      `INSERT INTO opportunities (id, title, description, opportunity_type, organization, posted_by, deadline) 
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [oppId2, 'Coding Competition', 'Annual coding competition', 'competition', 'CodeChamps', companyId, new Date(Date.now() + 45*24*60*60*1000)]
    );

    console.log('✓ Sample data added successfully');
    console.log('🎉 Database initialization complete!');
    console.log('\nTest credentials:');
    console.log('  Student: student@example.com / student123');
    console.log('  Company: company@example.com / company123');

    process.exit(0);
  } catch (err) {
    console.error('❌ Failed to initialize database:', err);
    process.exit(1);
  } finally {
    client.release();
  }
};

initDatabase();
