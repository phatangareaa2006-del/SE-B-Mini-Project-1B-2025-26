-- Create opportunity types enum
CREATE TYPE public.opportunity_type AS ENUM ('internship', 'job', 'competition', 'mock_test', 'mentorship', 'course');

-- Create opportunity mode enum  
CREATE TYPE public.opportunity_mode AS ENUM ('online', 'offline', 'hybrid', 'wfh');

-- Create unified opportunities table for all content types
CREATE TABLE public.opportunities (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    short_description TEXT,
    opportunity_type opportunity_type NOT NULL,
    mode opportunity_mode DEFAULT 'online',
    is_free BOOLEAN DEFAULT true,
    price NUMERIC DEFAULT 0,
    currency TEXT DEFAULT 'INR',
    image_url TEXT,
    banner_url TEXT,
    company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    organizer_name TEXT,
    organizer_logo TEXT,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    location TEXT,
    locations TEXT[] DEFAULT ARRAY[]::TEXT[],
    stipend_min NUMERIC,
    stipend_max NUMERIC,
    prize_pool NUMERIC,
    prize_description TEXT,
    eligibility TEXT,
    required_skills TEXT[] DEFAULT ARRAY[]::TEXT[],
    duration TEXT,
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    views_count INTEGER DEFAULT 0,
    external_url TEXT,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create opportunity registrations table
CREATE TABLE public.opportunity_registrations (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    status TEXT DEFAULT 'registered',
    registered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    completed_at TIMESTAMP WITH TIME ZONE,
    score NUMERIC,
    certificate_url TEXT,
    metadata JSONB DEFAULT '{}'::JSONB,
    UNIQUE(opportunity_id, user_id)
);

-- Create saved opportunities table
CREATE TABLE public.saved_opportunities (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    opportunity_id UUID NOT NULL REFERENCES public.opportunities(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    UNIQUE(opportunity_id, user_id)
);

-- Create mentor profiles table
CREATE TABLE public.mentors (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE,
    title TEXT,
    expertise TEXT[] DEFAULT ARRAY[]::TEXT[],
    bio TEXT,
    hourly_rate NUMERIC,
    currency TEXT DEFAULT 'INR',
    available_slots JSONB DEFAULT '[]'::JSONB,
    total_sessions INTEGER DEFAULT 0,
    rating NUMERIC DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    linkedin_url TEXT,
    calendly_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create mentor bookings table
CREATE TABLE public.mentor_bookings (
    id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    mentor_id UUID NOT NULL REFERENCES public.mentors(id) ON DELETE CASCADE,
    mentee_id UUID NOT NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    status TEXT DEFAULT 'pending',
    meeting_link TEXT,
    notes TEXT,
    rating INTEGER,
    review TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opportunity_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_opportunities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mentor_bookings ENABLE ROW LEVEL SECURITY;

-- Opportunities policies
CREATE POLICY "Anyone can view active opportunities"
    ON public.opportunities FOR SELECT
    USING (is_active = true);

CREATE POLICY "Companies can manage their opportunities"
    ON public.opportunities FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM companies 
            WHERE companies.id = opportunities.company_id 
            AND companies.user_id = auth.uid()
        )
    );

CREATE POLICY "Super admins can manage all opportunities"
    ON public.opportunities FOR ALL
    USING (has_role(auth.uid(), 'super_admin'));

-- Opportunity registrations policies
CREATE POLICY "Users can view their registrations"
    ON public.opportunity_registrations FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can register for opportunities"
    ON public.opportunity_registrations FOR INSERT
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their registrations"
    ON public.opportunity_registrations FOR UPDATE
    USING (user_id = auth.uid());

-- Saved opportunities policies
CREATE POLICY "Users can manage saved opportunities"
    ON public.saved_opportunities FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Mentors policies
CREATE POLICY "Anyone can view active mentors"
    ON public.mentors FOR SELECT
    USING (is_active = true);

CREATE POLICY "Users can manage their mentor profile"
    ON public.mentors FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Mentor bookings policies
CREATE POLICY "Users can view their bookings"
    ON public.mentor_bookings FOR SELECT
    USING (mentee_id = auth.uid() OR mentor_id IN (
        SELECT id FROM mentors WHERE user_id = auth.uid()
    ));

CREATE POLICY "Users can create bookings"
    ON public.mentor_bookings FOR INSERT
    WITH CHECK (mentee_id = auth.uid());

CREATE POLICY "Users can update their bookings"
    ON public.mentor_bookings FOR UPDATE
    USING (mentee_id = auth.uid() OR mentor_id IN (
        SELECT id FROM mentors WHERE user_id = auth.uid()
    ));

-- Create indexes for performance
CREATE INDEX idx_opportunities_type ON public.opportunities(opportunity_type);
CREATE INDEX idx_opportunities_featured ON public.opportunities(is_featured) WHERE is_featured = true;
CREATE INDEX idx_opportunities_active ON public.opportunities(is_active) WHERE is_active = true;
CREATE INDEX idx_opportunity_registrations_user ON public.opportunity_registrations(user_id);
CREATE INDEX idx_saved_opportunities_user ON public.saved_opportunities(user_id);

-- Add trigger for updated_at
CREATE TRIGGER update_opportunities_updated_at
    BEFORE UPDATE ON public.opportunities
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_mentors_updated_at
    BEFORE UPDATE ON public.mentors
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_mentor_bookings_updated_at
    BEFORE UPDATE ON public.mentor_bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();