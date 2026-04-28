-- ============================================
-- PLACEMENTHUB DATABASE SCHEMA
-- Multi-College Placement Portal
-- ============================================

-- Create ENUM types for roles and statuses
CREATE TYPE public.app_role AS ENUM ('student', 'company', 'college_admin', 'super_admin');
CREATE TYPE public.application_status AS ENUM ('applied', 'under_review', 'shortlisted', 'interview', 'offer', 'hired', 'rejected');
CREATE TYPE public.job_type AS ENUM ('full_time', 'internship', 'contract', 'part_time');
CREATE TYPE public.connection_status AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE public.verification_status AS ENUM ('pending', 'approved', 'rejected');

-- ============================================
-- USER ROLES TABLE (Security)
-- ============================================
CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role app_role NOT NULL DEFAULT 'student',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, role)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Security definer function to check roles
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role app_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id
      AND role = _role
  )
$$;

-- Function to get user's primary role
CREATE OR REPLACE FUNCTION public.get_user_role(_user_id UUID)
RETURNS app_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.user_roles WHERE user_id = _user_id LIMIT 1
$$;

-- ============================================
-- COLLEGES TABLE
-- ============================================
CREATE TABLE public.colleges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    logo_url TEXT,
    banner_url TEXT,
    description TEXT,
    website TEXT,
    address TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'India',
    established_year INTEGER,
    total_students INTEGER DEFAULT 0,
    verification_status verification_status NOT NULL DEFAULT 'pending',
    admin_user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.colleges ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PROFILES TABLE (Extended User Info)
-- ============================================
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    banner_url TEXT,
    headline TEXT,
    bio TEXT,
    phone TEXT,
    location TEXT,
    website TEXT,
    linkedin_url TEXT,
    github_url TEXT,
    portfolio_url TEXT,
    date_of_birth DATE,
    gender TEXT,
    resume_url TEXT,
    is_available BOOLEAN DEFAULT true,
    profile_completion INTEGER DEFAULT 0,
    college_id UUID REFERENCES public.colleges(id),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ============================================
-- SKILLS MASTER TABLE
-- ============================================
CREATE TABLE public.skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    category TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USER SKILLS (Junction Table)
-- ============================================
CREATE TABLE public.user_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    skill_id UUID REFERENCES public.skills(id) ON DELETE CASCADE NOT NULL,
    proficiency_level INTEGER DEFAULT 3 CHECK (proficiency_level >= 1 AND proficiency_level <= 5),
    years_experience NUMERIC(3,1) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, skill_id)
);

ALTER TABLE public.user_skills ENABLE ROW LEVEL SECURITY;

-- ============================================
-- EDUCATION TABLE
-- ============================================
CREATE TABLE public.education (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    institution TEXT NOT NULL,
    degree TEXT NOT NULL,
    field_of_study TEXT,
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    grade TEXT,
    cgpa NUMERIC(4,2),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.education ENABLE ROW LEVEL SECURITY;

-- ============================================
-- EXPERIENCE TABLE
-- ============================================
CREATE TABLE public.experience (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    company_name TEXT NOT NULL,
    title TEXT NOT NULL,
    employment_type job_type,
    location TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT false,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.experience ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PROJECTS TABLE
-- ============================================
CREATE TABLE public.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    project_url TEXT,
    github_url TEXT,
    image_url TEXT,
    technologies TEXT[],
    start_date DATE,
    end_date DATE,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CERTIFICATIONS TABLE
-- ============================================
CREATE TABLE public.certifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    issuing_organization TEXT NOT NULL,
    issue_date DATE,
    expiry_date DATE,
    credential_id TEXT,
    credential_url TEXT,
    certificate_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.certifications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- LANGUAGES TABLE
-- ============================================
CREATE TABLE public.languages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    language TEXT NOT NULL,
    proficiency TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, language)
);

ALTER TABLE public.languages ENABLE ROW LEVEL SECURITY;

-- ============================================
-- ACHIEVEMENTS TABLE
-- ============================================
CREATE TABLE public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    date_achieved DATE,
    issuer TEXT,
    url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

-- ============================================
-- COMPANIES TABLE
-- ============================================
CREATE TABLE public.companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    logo_url TEXT,
    banner_url TEXT,
    description TEXT,
    industry TEXT,
    company_size TEXT,
    headquarters TEXT,
    website TEXT,
    linkedin_url TEXT,
    founded_year INTEGER,
    culture TEXT,
    benefits TEXT[],
    perks TEXT[],
    verification_status verification_status NOT NULL DEFAULT 'pending',
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;

-- ============================================
-- JOBS TABLE
-- ============================================
CREATE TABLE public.jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    department TEXT,
    job_type job_type NOT NULL DEFAULT 'full_time',
    description TEXT NOT NULL,
    requirements TEXT,
    responsibilities TEXT,
    min_salary NUMERIC(12,2),
    max_salary NUMERIC(12,2),
    salary_currency TEXT DEFAULT 'INR',
    locations TEXT[],
    min_experience INTEGER DEFAULT 0,
    min_cgpa NUMERIC(4,2),
    required_degrees TEXT[],
    application_deadline DATE,
    openings INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    is_remote BOOLEAN DEFAULT false,
    views_count INTEGER DEFAULT 0,
    target_colleges UUID[] DEFAULT ARRAY[]::UUID[],
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- JOB SKILLS (Required/Preferred)
-- ============================================
CREATE TABLE public.job_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE NOT NULL,
    skill_id UUID REFERENCES public.skills(id) ON DELETE CASCADE NOT NULL,
    is_required BOOLEAN DEFAULT true,
    min_proficiency INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (job_id, skill_id)
);

ALTER TABLE public.job_skills ENABLE ROW LEVEL SECURITY;

-- ============================================
-- APPLICATIONS TABLE
-- ============================================
CREATE TABLE public.applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    status application_status NOT NULL DEFAULT 'applied',
    cover_letter TEXT,
    resume_url TEXT,
    skill_match_percentage INTEGER DEFAULT 0,
    company_feedback TEXT,
    interview_date TIMESTAMP WITH TIME ZONE,
    offer_details JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (job_id, user_id)
);

ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;

-- ============================================
-- SAVED JOBS TABLE
-- ============================================
CREATE TABLE public.saved_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, job_id)
);

ALTER TABLE public.saved_jobs ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CONNECTIONS TABLE (Social)
-- ============================================
CREATE TABLE public.connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    addressee_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    status connection_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (requester_id, addressee_id),
    CHECK (requester_id != addressee_id)
);

ALTER TABLE public.connections ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POSTS TABLE (Social Feed)
-- ============================================
CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    image_urls TEXT[],
    video_url TEXT,
    visibility TEXT DEFAULT 'public',
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Enable realtime for posts
ALTER PUBLICATION supabase_realtime ADD TABLE public.posts;

-- ============================================
-- COMMENTS TABLE
-- ============================================
CREATE TABLE public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- ============================================
-- LIKES TABLE
-- ============================================
CREATE TABLE public.likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE (user_id, post_id),
    UNIQUE (user_id, comment_id),
    CHECK ((post_id IS NOT NULL AND comment_id IS NULL) OR (post_id IS NULL AND comment_id IS NOT NULL))
);

ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- MESSAGES TABLE (Chat)
-- ============================================
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    attachments TEXT[],
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    CHECK (sender_id != receiver_id)
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Enable realtime for messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    link TEXT,
    is_read BOOLEAN DEFAULT false,
    data JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Enable realtime for notifications
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- User Roles Policies
CREATE POLICY "Users can view their own roles"
    ON public.user_roles FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Super admins can view all roles"
    ON public.user_roles FOR SELECT
    TO authenticated
    USING (public.has_role(auth.uid(), 'super_admin'));

CREATE POLICY "Users can insert their own role on signup"
    ON public.user_roles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Colleges Policies
CREATE POLICY "Anyone can view approved colleges"
    ON public.colleges FOR SELECT
    USING (verification_status = 'approved');

CREATE POLICY "College admins can update their college"
    ON public.colleges FOR UPDATE
    TO authenticated
    USING (admin_user_id = auth.uid());

CREATE POLICY "Super admins can manage all colleges"
    ON public.colleges FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'super_admin'));

CREATE POLICY "Users can create college registration"
    ON public.colleges FOR INSERT
    TO authenticated
    WITH CHECK (admin_user_id = auth.uid());

-- Profiles Policies
CREATE POLICY "Users can view all profiles"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Skills Policies (Read for all, insert for authenticated)
CREATE POLICY "Anyone can view skills"
    ON public.skills FOR SELECT
    USING (true);

CREATE POLICY "Authenticated users can add skills"
    ON public.skills FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- User Skills Policies
CREATE POLICY "Users can view all user skills"
    ON public.user_skills FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own skills"
    ON public.user_skills FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Education Policies
CREATE POLICY "Users can view all education"
    ON public.education FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own education"
    ON public.education FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Experience Policies
CREATE POLICY "Users can view all experience"
    ON public.experience FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own experience"
    ON public.experience FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Projects Policies
CREATE POLICY "Users can view all projects"
    ON public.projects FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own projects"
    ON public.projects FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Certifications Policies
CREATE POLICY "Users can view all certifications"
    ON public.certifications FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own certifications"
    ON public.certifications FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Languages Policies
CREATE POLICY "Users can view all languages"
    ON public.languages FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own languages"
    ON public.languages FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Achievements Policies
CREATE POLICY "Users can view all achievements"
    ON public.achievements FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own achievements"
    ON public.achievements FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Companies Policies
CREATE POLICY "Anyone can view verified companies"
    ON public.companies FOR SELECT
    USING (verification_status = 'approved' OR user_id = auth.uid());

CREATE POLICY "Company users can manage their company"
    ON public.companies FOR ALL
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Super admins can manage all companies"
    ON public.companies FOR ALL
    TO authenticated
    USING (public.has_role(auth.uid(), 'super_admin'));

-- Jobs Policies
CREATE POLICY "Authenticated users can view active jobs"
    ON public.jobs FOR SELECT
    TO authenticated
    USING (is_active = true OR EXISTS (
        SELECT 1 FROM public.companies WHERE companies.id = jobs.company_id AND companies.user_id = auth.uid()
    ));

CREATE POLICY "Company owners can manage their jobs"
    ON public.jobs FOR ALL
    TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.companies WHERE companies.id = jobs.company_id AND companies.user_id = auth.uid()
    ));

-- Job Skills Policies
CREATE POLICY "Anyone can view job skills"
    ON public.job_skills FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Company owners can manage job skills"
    ON public.job_skills FOR ALL
    TO authenticated
    USING (EXISTS (
        SELECT 1 FROM public.jobs 
        JOIN public.companies ON companies.id = jobs.company_id 
        WHERE jobs.id = job_skills.job_id AND companies.user_id = auth.uid()
    ));

-- Applications Policies
CREATE POLICY "Students can view their applications"
    ON public.applications FOR SELECT
    TO authenticated
    USING (user_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.jobs 
        JOIN public.companies ON companies.id = jobs.company_id 
        WHERE jobs.id = applications.job_id AND companies.user_id = auth.uid()
    ));

CREATE POLICY "Students can create applications"
    ON public.applications FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Students can update their applications"
    ON public.applications FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.jobs 
        JOIN public.companies ON companies.id = jobs.company_id 
        WHERE jobs.id = applications.job_id AND companies.user_id = auth.uid()
    ));

-- Saved Jobs Policies
CREATE POLICY "Users can manage saved jobs"
    ON public.saved_jobs FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Connections Policies
CREATE POLICY "Users can view their connections"
    ON public.connections FOR SELECT
    TO authenticated
    USING (requester_id = auth.uid() OR addressee_id = auth.uid());

CREATE POLICY "Users can create connection requests"
    ON public.connections FOR INSERT
    TO authenticated
    WITH CHECK (requester_id = auth.uid());

CREATE POLICY "Users can update their connections"
    ON public.connections FOR UPDATE
    TO authenticated
    USING (requester_id = auth.uid() OR addressee_id = auth.uid());

CREATE POLICY "Users can delete their connections"
    ON public.connections FOR DELETE
    TO authenticated
    USING (requester_id = auth.uid() OR addressee_id = auth.uid());

-- Posts Policies
CREATE POLICY "Anyone can view public posts"
    ON public.posts FOR SELECT
    TO authenticated
    USING (visibility = 'public' OR user_id = auth.uid());

CREATE POLICY "Users can create posts"
    ON public.posts FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
    ON public.posts FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
    ON public.posts FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Comments Policies
CREATE POLICY "Anyone can view comments"
    ON public.comments FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can create comments"
    ON public.comments FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage own comments"
    ON public.comments FOR ALL
    TO authenticated
    USING (auth.uid() = user_id);

-- Likes Policies
CREATE POLICY "Anyone can view likes"
    ON public.likes FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can manage own likes"
    ON public.likes FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Messages Policies
CREATE POLICY "Users can view their messages"
    ON public.messages FOR SELECT
    TO authenticated
    USING (sender_id = auth.uid() OR receiver_id = auth.uid());

CREATE POLICY "Users can send messages"
    ON public.messages FOR INSERT
    TO authenticated
    WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Users can update messages they sent"
    ON public.messages FOR UPDATE
    TO authenticated
    USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- Notifications Policies
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "System can create notifications"
    ON public.notifications FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================
-- TRIGGER FUNCTIONS
-- ============================================

-- Update timestamp function
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (user_id, email, full_name, avatar_url)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Update post counts
CREATE OR REPLACE FUNCTION public.update_post_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.post_id IS NOT NULL THEN
            UPDATE public.posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.post_id IS NOT NULL THEN
            UPDATE public.posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
        END IF;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update comment counts
CREATE OR REPLACE FUNCTION public.update_comment_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGERS
-- ============================================

-- Updated at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_colleges_updated_at BEFORE UPDATE ON public.colleges
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_education_updated_at BEFORE UPDATE ON public.education
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_experience_updated_at BEFORE UPDATE ON public.experience
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON public.projects
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_certifications_updated_at BEFORE UPDATE ON public.certifications
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON public.companies
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON public.jobs
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON public.applications
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_connections_updated_at BEFORE UPDATE ON public.connections
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON public.posts
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- New user trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Like count triggers
CREATE TRIGGER on_like_created
    AFTER INSERT ON public.likes
    FOR EACH ROW EXECUTE FUNCTION public.update_post_counts();

CREATE TRIGGER on_like_deleted
    AFTER DELETE ON public.likes
    FOR EACH ROW EXECUTE FUNCTION public.update_post_counts();

-- Comment count triggers
CREATE TRIGGER on_comment_created
    AFTER INSERT ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.update_comment_counts();

CREATE TRIGGER on_comment_deleted
    AFTER DELETE ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.update_comment_counts();

-- ============================================
-- SEED DATA: Popular Skills
-- ============================================
INSERT INTO public.skills (name, category) VALUES
-- Programming Languages
('JavaScript', 'Programming'),
('TypeScript', 'Programming'),
('Python', 'Programming'),
('Java', 'Programming'),
('C++', 'Programming'),
('C#', 'Programming'),
('Go', 'Programming'),
('Rust', 'Programming'),
('PHP', 'Programming'),
('Ruby', 'Programming'),
('Swift', 'Programming'),
('Kotlin', 'Programming'),
('Scala', 'Programming'),
('R', 'Programming'),
-- Frontend
('React', 'Frontend'),
('Angular', 'Frontend'),
('Vue.js', 'Frontend'),
('Next.js', 'Frontend'),
('HTML5', 'Frontend'),
('CSS3', 'Frontend'),
('Tailwind CSS', 'Frontend'),
('Bootstrap', 'Frontend'),
('SASS/SCSS', 'Frontend'),
('Redux', 'Frontend'),
-- Backend
('Node.js', 'Backend'),
('Express.js', 'Backend'),
('Django', 'Backend'),
('Flask', 'Backend'),
('Spring Boot', 'Backend'),
('ASP.NET', 'Backend'),
('Ruby on Rails', 'Backend'),
('Laravel', 'Backend'),
('FastAPI', 'Backend'),
('GraphQL', 'Backend'),
('REST API', 'Backend'),
-- Database
('MySQL', 'Database'),
('PostgreSQL', 'Database'),
('MongoDB', 'Database'),
('Redis', 'Database'),
('Elasticsearch', 'Database'),
('Firebase', 'Database'),
('Oracle', 'Database'),
('SQL Server', 'Database'),
('Cassandra', 'Database'),
-- Cloud & DevOps
('AWS', 'Cloud'),
('Azure', 'Cloud'),
('Google Cloud', 'Cloud'),
('Docker', 'DevOps'),
('Kubernetes', 'DevOps'),
('Jenkins', 'DevOps'),
('GitHub Actions', 'DevOps'),
('Terraform', 'DevOps'),
('Ansible', 'DevOps'),
('Linux', 'DevOps'),
-- AI/ML
('Machine Learning', 'AI/ML'),
('Deep Learning', 'AI/ML'),
('TensorFlow', 'AI/ML'),
('PyTorch', 'AI/ML'),
('Natural Language Processing', 'AI/ML'),
('Computer Vision', 'AI/ML'),
('Data Science', 'AI/ML'),
('Pandas', 'AI/ML'),
('NumPy', 'AI/ML'),
('Scikit-learn', 'AI/ML'),
-- Mobile
('React Native', 'Mobile'),
('Flutter', 'Mobile'),
('iOS Development', 'Mobile'),
('Android Development', 'Mobile'),
-- Other
('Git', 'Tools'),
('Agile', 'Methodology'),
('Scrum', 'Methodology'),
('JIRA', 'Tools'),
('Figma', 'Design'),
('UI/UX Design', 'Design'),
('Problem Solving', 'Soft Skills'),
('Communication', 'Soft Skills'),
('Leadership', 'Soft Skills'),
('Team Collaboration', 'Soft Skills')
ON CONFLICT (name) DO NOTHING;