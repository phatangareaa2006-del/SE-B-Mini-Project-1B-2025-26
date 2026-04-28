export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.4"
  }
  public: {
    Tables: {
      achievements: {
        Row: {
          created_at: string
          date_achieved: string | null
          description: string | null
          id: string
          issuer: string | null
          title: string
          url: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          date_achieved?: string | null
          description?: string | null
          id?: string
          issuer?: string | null
          title: string
          url?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          date_achieved?: string | null
          description?: string | null
          id?: string
          issuer?: string | null
          title?: string
          url?: string | null
          user_id?: string
        }
        Relationships: []
      }
      applications: {
        Row: {
          company_feedback: string | null
          cover_letter: string | null
          created_at: string
          id: string
          interview_date: string | null
          job_id: string
          offer_details: Json | null
          resume_url: string | null
          skill_match_percentage: number | null
          status: Database["public"]["Enums"]["application_status"]
          updated_at: string
          user_id: string
        }
        Insert: {
          company_feedback?: string | null
          cover_letter?: string | null
          created_at?: string
          id?: string
          interview_date?: string | null
          job_id: string
          offer_details?: Json | null
          resume_url?: string | null
          skill_match_percentage?: number | null
          status?: Database["public"]["Enums"]["application_status"]
          updated_at?: string
          user_id: string
        }
        Update: {
          company_feedback?: string | null
          cover_letter?: string | null
          created_at?: string
          id?: string
          interview_date?: string | null
          job_id?: string
          offer_details?: Json | null
          resume_url?: string | null
          skill_match_percentage?: number | null
          status?: Database["public"]["Enums"]["application_status"]
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "applications_job_id_fkey"
            columns: ["job_id"]
            isOneToOne: false
            referencedRelation: "jobs"
            referencedColumns: ["id"]
          },
        ]
      }
      certifications: {
        Row: {
          certificate_url: string | null
          created_at: string
          credential_id: string | null
          credential_url: string | null
          expiry_date: string | null
          id: string
          issue_date: string | null
          issuing_organization: string
          name: string
          updated_at: string
          user_id: string
        }
        Insert: {
          certificate_url?: string | null
          created_at?: string
          credential_id?: string | null
          credential_url?: string | null
          expiry_date?: string | null
          id?: string
          issue_date?: string | null
          issuing_organization: string
          name: string
          updated_at?: string
          user_id: string
        }
        Update: {
          certificate_url?: string | null
          created_at?: string
          credential_id?: string | null
          credential_url?: string | null
          expiry_date?: string | null
          id?: string
          issue_date?: string | null
          issuing_organization?: string
          name?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      colleges: {
        Row: {
          address: string | null
          admin_user_id: string | null
          banner_url: string | null
          city: string
          code: string
          country: string
          created_at: string
          description: string | null
          established_year: number | null
          id: string
          logo_url: string | null
          name: string
          state: string
          total_students: number | null
          updated_at: string
          verification_status: Database["public"]["Enums"]["verification_status"]
          website: string | null
        }
        Insert: {
          address?: string | null
          admin_user_id?: string | null
          banner_url?: string | null
          city: string
          code: string
          country?: string
          created_at?: string
          description?: string | null
          established_year?: number | null
          id?: string
          logo_url?: string | null
          name: string
          state: string
          total_students?: number | null
          updated_at?: string
          verification_status?: Database["public"]["Enums"]["verification_status"]
          website?: string | null
        }
        Update: {
          address?: string | null
          admin_user_id?: string | null
          banner_url?: string | null
          city?: string
          code?: string
          country?: string
          created_at?: string
          description?: string | null
          established_year?: number | null
          id?: string
          logo_url?: string | null
          name?: string
          state?: string
          total_students?: number | null
          updated_at?: string
          verification_status?: Database["public"]["Enums"]["verification_status"]
          website?: string | null
        }
        Relationships: []
      }
      comments: {
        Row: {
          content: string
          created_at: string
          id: string
          parent_id: string | null
          post_id: string
          updated_at: string
          user_id: string
        }
        Insert: {
          content: string
          created_at?: string
          id?: string
          parent_id?: string | null
          post_id: string
          updated_at?: string
          user_id: string
        }
        Update: {
          content?: string
          created_at?: string
          id?: string
          parent_id?: string | null
          post_id?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "comments_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "comments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "comments_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
        ]
      }
      companies: {
        Row: {
          banner_url: string | null
          benefits: string[] | null
          company_size: string | null
          created_at: string
          culture: string | null
          description: string | null
          founded_year: number | null
          headquarters: string | null
          id: string
          industry: string | null
          is_featured: boolean | null
          linkedin_url: string | null
          logo_url: string | null
          name: string
          perks: string[] | null
          updated_at: string
          user_id: string
          verification_status: Database["public"]["Enums"]["verification_status"]
          website: string | null
        }
        Insert: {
          banner_url?: string | null
          benefits?: string[] | null
          company_size?: string | null
          created_at?: string
          culture?: string | null
          description?: string | null
          founded_year?: number | null
          headquarters?: string | null
          id?: string
          industry?: string | null
          is_featured?: boolean | null
          linkedin_url?: string | null
          logo_url?: string | null
          name: string
          perks?: string[] | null
          updated_at?: string
          user_id: string
          verification_status?: Database["public"]["Enums"]["verification_status"]
          website?: string | null
        }
        Update: {
          banner_url?: string | null
          benefits?: string[] | null
          company_size?: string | null
          created_at?: string
          culture?: string | null
          description?: string | null
          founded_year?: number | null
          headquarters?: string | null
          id?: string
          industry?: string | null
          is_featured?: boolean | null
          linkedin_url?: string | null
          logo_url?: string | null
          name?: string
          perks?: string[] | null
          updated_at?: string
          user_id?: string
          verification_status?: Database["public"]["Enums"]["verification_status"]
          website?: string | null
        }
        Relationships: []
      }
      connections: {
        Row: {
          addressee_id: string
          created_at: string
          id: string
          requester_id: string
          status: Database["public"]["Enums"]["connection_status"]
          updated_at: string
        }
        Insert: {
          addressee_id: string
          created_at?: string
          id?: string
          requester_id: string
          status?: Database["public"]["Enums"]["connection_status"]
          updated_at?: string
        }
        Update: {
          addressee_id?: string
          created_at?: string
          id?: string
          requester_id?: string
          status?: Database["public"]["Enums"]["connection_status"]
          updated_at?: string
        }
        Relationships: []
      }
      education: {
        Row: {
          cgpa: number | null
          created_at: string
          degree: string
          description: string | null
          end_date: string | null
          field_of_study: string | null
          grade: string | null
          id: string
          institution: string
          is_current: boolean | null
          start_date: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          cgpa?: number | null
          created_at?: string
          degree: string
          description?: string | null
          end_date?: string | null
          field_of_study?: string | null
          grade?: string | null
          id?: string
          institution: string
          is_current?: boolean | null
          start_date?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          cgpa?: number | null
          created_at?: string
          degree?: string
          description?: string | null
          end_date?: string | null
          field_of_study?: string | null
          grade?: string | null
          id?: string
          institution?: string
          is_current?: boolean | null
          start_date?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      experience: {
        Row: {
          company_name: string
          created_at: string
          description: string | null
          employment_type: Database["public"]["Enums"]["job_type"] | null
          end_date: string | null
          id: string
          is_current: boolean | null
          location: string | null
          start_date: string
          title: string
          updated_at: string
          user_id: string
        }
        Insert: {
          company_name: string
          created_at?: string
          description?: string | null
          employment_type?: Database["public"]["Enums"]["job_type"] | null
          end_date?: string | null
          id?: string
          is_current?: boolean | null
          location?: string | null
          start_date: string
          title: string
          updated_at?: string
          user_id: string
        }
        Update: {
          company_name?: string
          created_at?: string
          description?: string | null
          employment_type?: Database["public"]["Enums"]["job_type"] | null
          end_date?: string | null
          id?: string
          is_current?: boolean | null
          location?: string | null
          start_date?: string
          title?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      job_skills: {
        Row: {
          created_at: string
          id: string
          is_required: boolean | null
          job_id: string
          min_proficiency: number | null
          skill_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_required?: boolean | null
          job_id: string
          min_proficiency?: number | null
          skill_id: string
        }
        Update: {
          created_at?: string
          id?: string
          is_required?: boolean | null
          job_id?: string
          min_proficiency?: number | null
          skill_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "job_skills_job_id_fkey"
            columns: ["job_id"]
            isOneToOne: false
            referencedRelation: "jobs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "job_skills_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
      jobs: {
        Row: {
          application_deadline: string | null
          company_id: string
          created_at: string
          department: string | null
          description: string
          id: string
          is_active: boolean | null
          is_remote: boolean | null
          job_type: Database["public"]["Enums"]["job_type"]
          locations: string[] | null
          max_salary: number | null
          min_cgpa: number | null
          min_experience: number | null
          min_salary: number | null
          openings: number | null
          required_degrees: string[] | null
          requirements: string | null
          responsibilities: string | null
          salary_currency: string | null
          target_colleges: string[] | null
          title: string
          updated_at: string
          views_count: number | null
        }
        Insert: {
          application_deadline?: string | null
          company_id: string
          created_at?: string
          department?: string | null
          description: string
          id?: string
          is_active?: boolean | null
          is_remote?: boolean | null
          job_type?: Database["public"]["Enums"]["job_type"]
          locations?: string[] | null
          max_salary?: number | null
          min_cgpa?: number | null
          min_experience?: number | null
          min_salary?: number | null
          openings?: number | null
          required_degrees?: string[] | null
          requirements?: string | null
          responsibilities?: string | null
          salary_currency?: string | null
          target_colleges?: string[] | null
          title: string
          updated_at?: string
          views_count?: number | null
        }
        Update: {
          application_deadline?: string | null
          company_id?: string
          created_at?: string
          department?: string | null
          description?: string
          id?: string
          is_active?: boolean | null
          is_remote?: boolean | null
          job_type?: Database["public"]["Enums"]["job_type"]
          locations?: string[] | null
          max_salary?: number | null
          min_cgpa?: number | null
          min_experience?: number | null
          min_salary?: number | null
          openings?: number | null
          required_degrees?: string[] | null
          requirements?: string | null
          responsibilities?: string | null
          salary_currency?: string | null
          target_colleges?: string[] | null
          title?: string
          updated_at?: string
          views_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "jobs_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      languages: {
        Row: {
          created_at: string
          id: string
          language: string
          proficiency: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          language: string
          proficiency: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          language?: string
          proficiency?: string
          user_id?: string
        }
        Relationships: []
      }
      likes: {
        Row: {
          comment_id: string | null
          created_at: string
          id: string
          post_id: string | null
          user_id: string
        }
        Insert: {
          comment_id?: string | null
          created_at?: string
          id?: string
          post_id?: string | null
          user_id: string
        }
        Update: {
          comment_id?: string | null
          created_at?: string
          id?: string
          post_id?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "likes_comment_id_fkey"
            columns: ["comment_id"]
            isOneToOne: false
            referencedRelation: "comments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "likes_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
        ]
      }
      mentor_bookings: {
        Row: {
          created_at: string
          duration_minutes: number | null
          id: string
          meeting_link: string | null
          mentee_id: string
          mentor_id: string
          notes: string | null
          rating: number | null
          review: string | null
          scheduled_at: string
          status: string | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          duration_minutes?: number | null
          id?: string
          meeting_link?: string | null
          mentee_id: string
          mentor_id: string
          notes?: string | null
          rating?: number | null
          review?: string | null
          scheduled_at: string
          status?: string | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          duration_minutes?: number | null
          id?: string
          meeting_link?: string | null
          mentee_id?: string
          mentor_id?: string
          notes?: string | null
          rating?: number | null
          review?: string | null
          scheduled_at?: string
          status?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "mentor_bookings_mentor_id_fkey"
            columns: ["mentor_id"]
            isOneToOne: false
            referencedRelation: "mentors"
            referencedColumns: ["id"]
          },
        ]
      }
      mentors: {
        Row: {
          available_slots: Json | null
          bio: string | null
          calendly_url: string | null
          created_at: string
          currency: string | null
          expertise: string[] | null
          hourly_rate: number | null
          id: string
          is_active: boolean | null
          is_verified: boolean | null
          linkedin_url: string | null
          rating: number | null
          review_count: number | null
          title: string | null
          total_sessions: number | null
          updated_at: string
          user_id: string
        }
        Insert: {
          available_slots?: Json | null
          bio?: string | null
          calendly_url?: string | null
          created_at?: string
          currency?: string | null
          expertise?: string[] | null
          hourly_rate?: number | null
          id?: string
          is_active?: boolean | null
          is_verified?: boolean | null
          linkedin_url?: string | null
          rating?: number | null
          review_count?: number | null
          title?: string | null
          total_sessions?: number | null
          updated_at?: string
          user_id: string
        }
        Update: {
          available_slots?: Json | null
          bio?: string | null
          calendly_url?: string | null
          created_at?: string
          currency?: string | null
          expertise?: string[] | null
          hourly_rate?: number | null
          id?: string
          is_active?: boolean | null
          is_verified?: boolean | null
          linkedin_url?: string | null
          rating?: number | null
          review_count?: number | null
          title?: string | null
          total_sessions?: number | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      messages: {
        Row: {
          attachments: string[] | null
          content: string
          created_at: string
          id: string
          is_read: boolean | null
          receiver_id: string
          sender_id: string
        }
        Insert: {
          attachments?: string[] | null
          content: string
          created_at?: string
          id?: string
          is_read?: boolean | null
          receiver_id: string
          sender_id: string
        }
        Update: {
          attachments?: string[] | null
          content?: string
          created_at?: string
          id?: string
          is_read?: boolean | null
          receiver_id?: string
          sender_id?: string
        }
        Relationships: []
      }
      mock_test_questions: {
        Row: {
          correct_answer: number
          created_at: string
          difficulty: string | null
          explanation: string | null
          id: string
          opportunity_id: string | null
          options: Json
          question: string
          topic: string | null
        }
        Insert: {
          correct_answer: number
          created_at?: string
          difficulty?: string | null
          explanation?: string | null
          id?: string
          opportunity_id?: string | null
          options?: Json
          question: string
          topic?: string | null
        }
        Update: {
          correct_answer?: number
          created_at?: string
          difficulty?: string | null
          explanation?: string | null
          id?: string
          opportunity_id?: string | null
          options?: Json
          question?: string
          topic?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "mock_test_questions_opportunity_id_fkey"
            columns: ["opportunity_id"]
            isOneToOne: false
            referencedRelation: "opportunities"
            referencedColumns: ["id"]
          },
        ]
      }
      mock_test_results: {
        Row: {
          answers: Json | null
          completed_at: string
          correct_answers: number
          created_at: string
          id: string
          opportunity_id: string | null
          score: number
          time_taken_seconds: number
          total_questions: number
          user_id: string
        }
        Insert: {
          answers?: Json | null
          completed_at?: string
          correct_answers?: number
          created_at?: string
          id?: string
          opportunity_id?: string | null
          score?: number
          time_taken_seconds?: number
          total_questions?: number
          user_id: string
        }
        Update: {
          answers?: Json | null
          completed_at?: string
          correct_answers?: number
          created_at?: string
          id?: string
          opportunity_id?: string | null
          score?: number
          time_taken_seconds?: number
          total_questions?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "mock_test_results_opportunity_id_fkey"
            columns: ["opportunity_id"]
            isOneToOne: false
            referencedRelation: "opportunities"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          created_at: string
          data: Json | null
          id: string
          is_read: boolean | null
          link: string | null
          message: string | null
          title: string
          type: string
          user_id: string
        }
        Insert: {
          created_at?: string
          data?: Json | null
          id?: string
          is_read?: boolean | null
          link?: string | null
          message?: string | null
          title: string
          type: string
          user_id: string
        }
        Update: {
          created_at?: string
          data?: Json | null
          id?: string
          is_read?: boolean | null
          link?: string | null
          message?: string | null
          title?: string
          type?: string
          user_id?: string
        }
        Relationships: []
      }
      opportunities: {
        Row: {
          banner_url: string | null
          company_id: string | null
          created_at: string
          currency: string | null
          current_participants: number | null
          description: string | null
          duration: string | null
          eligibility: string | null
          end_date: string | null
          external_url: string | null
          id: string
          image_url: string | null
          is_active: boolean | null
          is_featured: boolean | null
          is_free: boolean | null
          location: string | null
          locations: string[] | null
          max_participants: number | null
          metadata: Json | null
          mode: Database["public"]["Enums"]["opportunity_mode"] | null
          opportunity_type: Database["public"]["Enums"]["opportunity_type"]
          organizer_logo: string | null
          organizer_name: string | null
          price: number | null
          prize_description: string | null
          prize_pool: number | null
          registration_deadline: string | null
          required_skills: string[] | null
          short_description: string | null
          start_date: string | null
          stipend_max: number | null
          stipend_min: number | null
          tags: string[] | null
          title: string
          updated_at: string
          views_count: number | null
        }
        Insert: {
          banner_url?: string | null
          company_id?: string | null
          created_at?: string
          currency?: string | null
          current_participants?: number | null
          description?: string | null
          duration?: string | null
          eligibility?: string | null
          end_date?: string | null
          external_url?: string | null
          id?: string
          image_url?: string | null
          is_active?: boolean | null
          is_featured?: boolean | null
          is_free?: boolean | null
          location?: string | null
          locations?: string[] | null
          max_participants?: number | null
          metadata?: Json | null
          mode?: Database["public"]["Enums"]["opportunity_mode"] | null
          opportunity_type: Database["public"]["Enums"]["opportunity_type"]
          organizer_logo?: string | null
          organizer_name?: string | null
          price?: number | null
          prize_description?: string | null
          prize_pool?: number | null
          registration_deadline?: string | null
          required_skills?: string[] | null
          short_description?: string | null
          start_date?: string | null
          stipend_max?: number | null
          stipend_min?: number | null
          tags?: string[] | null
          title: string
          updated_at?: string
          views_count?: number | null
        }
        Update: {
          banner_url?: string | null
          company_id?: string | null
          created_at?: string
          currency?: string | null
          current_participants?: number | null
          description?: string | null
          duration?: string | null
          eligibility?: string | null
          end_date?: string | null
          external_url?: string | null
          id?: string
          image_url?: string | null
          is_active?: boolean | null
          is_featured?: boolean | null
          is_free?: boolean | null
          location?: string | null
          locations?: string[] | null
          max_participants?: number | null
          metadata?: Json | null
          mode?: Database["public"]["Enums"]["opportunity_mode"] | null
          opportunity_type?: Database["public"]["Enums"]["opportunity_type"]
          organizer_logo?: string | null
          organizer_name?: string | null
          price?: number | null
          prize_description?: string | null
          prize_pool?: number | null
          registration_deadline?: string | null
          required_skills?: string[] | null
          short_description?: string | null
          start_date?: string | null
          stipend_max?: number | null
          stipend_min?: number | null
          tags?: string[] | null
          title?: string
          updated_at?: string
          views_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "opportunities_company_id_fkey"
            columns: ["company_id"]
            isOneToOne: false
            referencedRelation: "companies"
            referencedColumns: ["id"]
          },
        ]
      }
      opportunity_registrations: {
        Row: {
          certificate_url: string | null
          completed_at: string | null
          id: string
          metadata: Json | null
          opportunity_id: string
          registered_at: string
          score: number | null
          status: string | null
          user_id: string
        }
        Insert: {
          certificate_url?: string | null
          completed_at?: string | null
          id?: string
          metadata?: Json | null
          opportunity_id: string
          registered_at?: string
          score?: number | null
          status?: string | null
          user_id: string
        }
        Update: {
          certificate_url?: string | null
          completed_at?: string | null
          id?: string
          metadata?: Json | null
          opportunity_id?: string
          registered_at?: string
          score?: number | null
          status?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "opportunity_registrations_opportunity_id_fkey"
            columns: ["opportunity_id"]
            isOneToOne: false
            referencedRelation: "opportunities"
            referencedColumns: ["id"]
          },
        ]
      }
      posts: {
        Row: {
          comments_count: number | null
          content: string
          created_at: string
          id: string
          image_urls: string[] | null
          likes_count: number | null
          shares_count: number | null
          updated_at: string
          user_id: string
          video_url: string | null
          visibility: string | null
        }
        Insert: {
          comments_count?: number | null
          content: string
          created_at?: string
          id?: string
          image_urls?: string[] | null
          likes_count?: number | null
          shares_count?: number | null
          updated_at?: string
          user_id: string
          video_url?: string | null
          visibility?: string | null
        }
        Update: {
          comments_count?: number | null
          content?: string
          created_at?: string
          id?: string
          image_urls?: string[] | null
          likes_count?: number | null
          shares_count?: number | null
          updated_at?: string
          user_id?: string
          video_url?: string | null
          visibility?: string | null
        }
        Relationships: []
      }
      profiles: {
        Row: {
          avatar_url: string | null
          banner_url: string | null
          bio: string | null
          college_id: string | null
          created_at: string
          date_of_birth: string | null
          email: string
          full_name: string | null
          gender: string | null
          github_url: string | null
          headline: string | null
          id: string
          is_available: boolean | null
          linkedin_url: string | null
          location: string | null
          phone: string | null
          portfolio_url: string | null
          profile_completion: number | null
          resume_url: string | null
          updated_at: string
          user_id: string
          website: string | null
        }
        Insert: {
          avatar_url?: string | null
          banner_url?: string | null
          bio?: string | null
          college_id?: string | null
          created_at?: string
          date_of_birth?: string | null
          email: string
          full_name?: string | null
          gender?: string | null
          github_url?: string | null
          headline?: string | null
          id?: string
          is_available?: boolean | null
          linkedin_url?: string | null
          location?: string | null
          phone?: string | null
          portfolio_url?: string | null
          profile_completion?: number | null
          resume_url?: string | null
          updated_at?: string
          user_id: string
          website?: string | null
        }
        Update: {
          avatar_url?: string | null
          banner_url?: string | null
          bio?: string | null
          college_id?: string | null
          created_at?: string
          date_of_birth?: string | null
          email?: string
          full_name?: string | null
          gender?: string | null
          github_url?: string | null
          headline?: string | null
          id?: string
          is_available?: boolean | null
          linkedin_url?: string | null
          location?: string | null
          phone?: string | null
          portfolio_url?: string | null
          profile_completion?: number | null
          resume_url?: string | null
          updated_at?: string
          user_id?: string
          website?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profiles_college_id_fkey"
            columns: ["college_id"]
            isOneToOne: false
            referencedRelation: "colleges"
            referencedColumns: ["id"]
          },
        ]
      }
      projects: {
        Row: {
          created_at: string
          description: string | null
          end_date: string | null
          github_url: string | null
          id: string
          image_url: string | null
          is_featured: boolean | null
          project_url: string | null
          start_date: string | null
          technologies: string[] | null
          title: string
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          end_date?: string | null
          github_url?: string | null
          id?: string
          image_url?: string | null
          is_featured?: boolean | null
          project_url?: string | null
          start_date?: string | null
          technologies?: string[] | null
          title: string
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          description?: string | null
          end_date?: string | null
          github_url?: string | null
          id?: string
          image_url?: string | null
          is_featured?: boolean | null
          project_url?: string | null
          start_date?: string | null
          technologies?: string[] | null
          title?: string
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      saved_jobs: {
        Row: {
          created_at: string
          id: string
          job_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          job_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          job_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "saved_jobs_job_id_fkey"
            columns: ["job_id"]
            isOneToOne: false
            referencedRelation: "jobs"
            referencedColumns: ["id"]
          },
        ]
      }
      saved_opportunities: {
        Row: {
          created_at: string
          id: string
          opportunity_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          opportunity_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          opportunity_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "saved_opportunities_opportunity_id_fkey"
            columns: ["opportunity_id"]
            isOneToOne: false
            referencedRelation: "opportunities"
            referencedColumns: ["id"]
          },
        ]
      }
      search_history: {
        Row: {
          created_at: string
          id: string
          query: string
          result_count: number | null
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          query: string
          result_count?: number | null
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          query?: string
          result_count?: number | null
          user_id?: string
        }
        Relationships: []
      }
      skills: {
        Row: {
          category: string | null
          created_at: string
          id: string
          name: string
        }
        Insert: {
          category?: string | null
          created_at?: string
          id?: string
          name: string
        }
        Update: {
          category?: string | null
          created_at?: string
          id?: string
          name?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
      user_skills: {
        Row: {
          created_at: string
          id: string
          proficiency_level: number | null
          skill_id: string
          user_id: string
          years_experience: number | null
        }
        Insert: {
          created_at?: string
          id?: string
          proficiency_level?: number | null
          skill_id: string
          user_id: string
          years_experience?: number | null
        }
        Update: {
          created_at?: string
          id?: string
          proficiency_level?: number | null
          skill_id?: string
          user_id?: string
          years_experience?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "user_skills_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      get_user_role: {
        Args: { _user_id: string }
        Returns: Database["public"]["Enums"]["app_role"]
      }
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
    }
    Enums: {
      app_role: "student" | "company" | "college_admin" | "super_admin"
      application_status:
        | "applied"
        | "under_review"
        | "shortlisted"
        | "interview"
        | "offer"
        | "hired"
        | "rejected"
      connection_status: "pending" | "accepted" | "rejected"
      job_type: "full_time" | "internship" | "contract" | "part_time"
      opportunity_mode: "online" | "offline" | "hybrid" | "wfh"
      opportunity_type:
        | "internship"
        | "job"
        | "competition"
        | "mock_test"
        | "mentorship"
        | "course"
      verification_status: "pending" | "approved" | "rejected"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["student", "company", "college_admin", "super_admin"],
      application_status: [
        "applied",
        "under_review",
        "shortlisted",
        "interview",
        "offer",
        "hired",
        "rejected",
      ],
      connection_status: ["pending", "accepted", "rejected"],
      job_type: ["full_time", "internship", "contract", "part_time"],
      opportunity_mode: ["online", "offline", "hybrid", "wfh"],
      opportunity_type: [
        "internship",
        "job",
        "competition",
        "mock_test",
        "mentorship",
        "course",
      ],
      verification_status: ["pending", "approved", "rejected"],
    },
  },
} as const
