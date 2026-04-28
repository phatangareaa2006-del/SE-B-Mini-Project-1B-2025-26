-- Initialize PlacementHub Database Schema
-- This script creates all necessary tables for the application

-- Create enum types
CREATE TYPE app_role AS ENUM ('student', 'company', 'college_admin', 'super_admin');
CREATE TYPE job_type AS ENUM ('full_time', 'internship', 'contract', 'part_time');
CREATE TYPE opportunity_type AS ENUM ('internship', 'job', 'competition', 'mock_test', 'mentorship', 'course');
CREATE TYPE application_status AS ENUM ('applied', 'under_review', 'shortlisted', 'interview', 'offer', 'hired', 'rejected');
CREATE TYPE connection_status AS ENUM ('pending', 'accepted', 'rejected');

-- Auth Users Table
CREATE TABLE auth_users (
    id UUID PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- User Roles Table
CREATE TABLE user_roles (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    role app_role NOT NULL DEFAULT 'student',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Profiles Table
CREATE TABLE profiles (
    id UUID PRIMARY KEY,
    user_id UUID UNIQUE REFERENCES auth_users(id) ON DELETE CASCADE,
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
);

-- Education Table
CREATE TABLE education (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
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
);

-- Experience Table
CREATE TABLE experience (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
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
);

-- Skills Table
CREATE TABLE skills (
    id UUID PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    category TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- User Skills Table
CREATE TABLE user_skills (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    skill_id UUID REFERENCES skills(id) ON DELETE CASCADE,
    proficiency_level INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Certifications Table
CREATE TABLE certifications (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    issuing_organization TEXT NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    credential_id TEXT,
    credential_url TEXT,
    certificate_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Projects Table
CREATE TABLE projects (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    project_url TEXT,
    github_url TEXT,
    image_url TEXT,
    technologies TEXT[],
    start_date DATE,
    end_date DATE,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Achievements Table
CREATE TABLE achievements (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    date_achieved DATE,
    issuer TEXT,
    url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Companies Table
CREATE TABLE companies (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    logo_url TEXT,
    banner_url TEXT,
    description TEXT,
    website TEXT,
    email TEXT,
    phone TEXT,
    industry TEXT,
    company_size TEXT,
    founded_year INTEGER,
    location TEXT,
    headquarters TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Jobs Table
CREATE TABLE jobs (
    id UUID PRIMARY KEY,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    location TEXT,
    job_type job_type NOT NULL,
    salary_min DECIMAL(10,2),
    salary_max DECIMAL(10,2),
    salary_currency TEXT DEFAULT 'INR',
    experience_required TEXT,
    skills_required TEXT[],
    application_deadline DATE,
    is_active BOOLEAN DEFAULT true,
    status TEXT DEFAULT 'open',
    posters_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Job Applications Table
CREATE TABLE job_applications (
    id UUID PRIMARY KEY,
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    status application_status DEFAULT 'applied',
    applied_at TIMESTAMP DEFAULT NOW(),
    cover_letter TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Saved Jobs Table
CREATE TABLE saved_jobs (
    id UUID PRIMARY KEY,
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Opportunities Table
CREATE TABLE opportunities (
    id UUID PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    opportunity_type opportunity_type NOT NULL,
    location TEXT,
    company_name TEXT,
    eligibility TEXT,
    application_deadline DATE,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    image_url TEXT,
    link TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Opportunity Registrations Table
CREATE TABLE opportunity_registrations (
    id UUID PRIMARY KEY,
    opportunity_id UUID REFERENCES opportunities(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'registered',
    registered_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Saved Opportunities Table
CREATE TABLE saved_opportunities (
    id UUID PRIMARY KEY,
    opportunity_id UUID REFERENCES opportunities(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Posts Table
CREATE TABLE posts (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Post Likes Table
CREATE TABLE post_likes (
    id UUID PRIMARY KEY,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Comments Table
CREATE TABLE comments (
    id UUID PRIMARY KEY,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Connections Table
CREATE TABLE connections (
    id UUID PRIMARY KEY,
    requester_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    addressee_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    status connection_status DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Messages Table
CREATE TABLE messages (
    id UUID PRIMARY KEY,
    sender_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Conversations Table (for grouping messages)
CREATE TABLE conversations (
    id UUID PRIMARY KEY,
    participant_1_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    participant_2_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    last_message_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Notifications Table
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth_users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    related_user_id UUID REFERENCES auth_users(id),
    related_entity_id UUID,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_education_user_id ON education(user_id);
CREATE INDEX idx_experience_user_id ON experience(user_id);
CREATE INDEX idx_user_skills_user_id ON user_skills(user_id);
CREATE INDEX idx_jobs_company_id ON jobs(company_id);
CREATE INDEX idx_job_applications_user_id ON job_applications(user_id);
CREATE INDEX idx_saved_jobs_user_id ON saved_jobs(user_id);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
