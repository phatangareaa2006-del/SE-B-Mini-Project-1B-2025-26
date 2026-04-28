

# 🎓 PlacementHub - Multi-College Placement Portal

## Vision
A professional-grade placement portal combining LinkedIn's social networking with Naukri's job matching, designed for multi-college campus recruitment. Real companies post real jobs, students build professional profiles, and AI powers intelligent matching.

---

## 🔐 Phase 1: Authentication & Core Foundation

### Login/Signup System
- **Beautiful auth page** with gradient design, animated transitions
- **Email + Password** with strong validation:
  - Minimum 8 characters
  - At least 1 uppercase, 1 lowercase, 1 number, 1 special character
  - Real-time validation feedback
- **Google OAuth** integration
- **LinkedIn OAuth** integration
- **Forgot Password** with email reset flow
- **Role selection during signup**: Student, Company Representative, College Admin

### Multi-College Architecture
- Colleges register and get approved by super-admin
- Each college has its own admin managing students
- Students select their college during registration
- Companies can target specific colleges or all colleges

---

## 👨‍🎓 Phase 2: Student Dashboard (LinkedIn-style Profile)

### Comprehensive Profile Section
- **Profile Header**: Photo, name, headline, location, availability status
- **About Section**: Professional summary, career objectives
- **Education**: Multiple entries with degrees, institutions, years, CGPA
- **Work Experience**: Internships, jobs with dates and descriptions
- **Skills**: Searchable skill tags with proficiency levels
- **Projects**: Portfolio with links, descriptions, technologies used
- **Certifications**: Upload certificates, add verification links
- **Resume**: PDF upload with AI-powered parsing to auto-extract skills
- **Languages**: Spoken languages with proficiency
- **Achievements**: Awards, publications, extracurriculars

### Job Search & Application
- **Smart Job Feed**: Infinite scroll with lazy loading
- **Advanced Filters**: 
  - Job type (Full-time, Internship, Contract)
  - Location (city-wise)
  - Salary range (₹ LPA)
  - Required skills
  - Experience level
  - Company industry
- **Skill Match Indicator**: Show % match between student skills and job requirements
- **Apply Gate**: Only allow applications when skill match exceeds 40%
- **One-click Apply** with confirmation modal
- **Save Jobs** for later
- **Application Tracker**:
  - Status badges: Applied → Under Review → Shortlisted → Interview → Offer/Rejected
  - Timeline view showing application journey
  - Company feedback visible when provided

### AI-Powered Features
- **Resume Parser**: Upload PDF, AI extracts skills, experience, education automatically
- **Job Recommendations**: Based on skills, preferences, and application history
- **Skill Gap Analysis**: Shows which skills to learn for dream jobs
- **AI Career Assistant**: Chatbot for career guidance and job questions

---

## 🏢 Phase 3: Company Dashboard

### Company Profile
- Logo, banner, company description
- Industry, size, headquarters, website
- Company culture, benefits, perks
- Photos/videos of workplace
- Employee testimonials

### Job Posting System
- **Create Job Post**:
  - Title, department, job type
  - Detailed description with rich text editor
  - Required skills (searchable tags)
  - Preferred skills
  - Minimum qualifications (degree, CGPA, experience)
  - Salary range (₹ LPA)
  - Location(s)
  - Application deadline
  - Number of openings
- **Target Colleges**: Select specific colleges or open to all
- **Job Templates**: Save and reuse common job structures

### Applicant Management
- **Applicant Pipeline View**:
  - Kanban-style board: Applied → Screening → Interview → Offer → Hired/Rejected
  - Drag-and-drop to change status
- **Applicant Cards**: Quick view of skills, education, match %
- **Resume Download**: Individual or bulk download
- **Shortlist/Reject** with optional feedback
- **Schedule Interviews**: Calendar integration
- **Bulk Actions**: Email multiple candidates
- **AI Sentiment Analysis**: Analyze candidate feedback and notes

### Analytics Dashboard
- Total views per job
- Application funnel metrics
- Hiring velocity
- Top skills in applicant pool

---

## 🎓 Phase 4: College Admin Dashboard

### Student Management
- View all registered students from their college
- Approve/reject student registrations
- Monitor student profiles and completion status
- Bulk import students via CSV

### Company Relations
- Invite companies to recruit from their college
- View companies interested in their students
- Track placement drives and schedules

### Placement Analytics
- Placement rate by department
- Average package statistics
- Company-wise hiring data
- Year-over-year trends
- Skill demand trends

---

## 👑 Phase 5: Super Admin Dashboard

### Platform Management
- **College Management**: Approve/reject college registrations
- **Company Verification**: Verify company legitimacy
- **User Management**: View all users, handle disputes
- **Content Moderation**: Flag inappropriate content

### Platform Analytics
- Total registrations across all roles
- Active users, daily/monthly
- Jobs posted and filled
- Top performing colleges
- Industry hiring trends
- Skill gap insights across platform

---

## 🤝 Phase 6: Social & Networking Features (LinkedIn-style)

### Connections System
- Send/accept connection requests
- View mutual connections
- Search and discover users
- Connection recommendations

### Posts & Feed
- Create text, image, video posts
- Like, comment, share functionality
- News feed with algorithmic sorting
- Hashtag support
- Post visibility controls

### Messaging System
- Real-time chat with connections
- Message requests from non-connections
- File/document sharing
- Read receipts
- Online status indicators

### Groups
- College-wise groups
- Industry/skill-based groups
- Discussion forums

---

## 🔔 Phase 7: Notifications & Engagement

### Real-time Notifications
- New job matching your profile
- Application status updates
- Connection requests
- Messages
- Job deadline reminders

### Email Notifications
- Weekly job digest
- Application updates
- Important announcements

---

## 🎨 Phase 8: UI/UX Excellence

### Design System
- Clean, modern design inspired by LinkedIn/Naukri
- Consistent color scheme with professional blue accent
- **Dark Mode** toggle with smooth transition
- Card-based layouts with subtle shadows

### Navigation
- **Sticky Navbar**: Role-based menu items
  - Students: Home, Jobs, My Applications, Network, Messages, Profile
  - Companies: Dashboard, Post Job, Applicants, Analytics, Profile
  - Admin: Dashboard, Users, Companies, Analytics, Settings
- Mobile hamburger menu with slide-in drawer
- Breadcrumb navigation

### Responsiveness
- Mobile-first design
- Optimized for all screen sizes
- Touch-friendly interactions
- Progressive loading for images

### Accessibility
- ARIA labels on all interactive elements
- Keyboard navigation support
- Focus indicators
- Screen reader friendly
- Color contrast compliance

### Micro-interactions
- Smooth hover effects
- Loading skeletons
- Success/error animations
- Toast notifications for all actions
- Progress indicators for multi-step forms

---

## 🛠️ Technical Architecture

### Frontend (React + TypeScript)
- React Router for navigation
- TailwindCSS for styling
- shadcn/ui component library
- React Query for data fetching
- React Hook Form + Zod for form validation

### Backend (Supabase)
- **PostgreSQL Database**: All data persisted
- **Row Level Security**: Role-based access control
- **Authentication**: Email, Google, LinkedIn OAuth
- **Storage**: Resumes, profile pictures, certificates
- **Realtime**: Live notifications, messaging, presence
- **Edge Functions**: AI integrations, email sending

### AI Integration (Lovable AI Gateway)
- Resume parsing with skill extraction
- Job recommendation engine
- Skill gap analysis
- Career guidance chatbot
- Sentiment analysis for feedback

---

## 📊 Database Schema Overview

### Core Tables
- `profiles` - User profile data
- `user_roles` - Role assignments (student/company/admin)
- `colleges` - College information
- `companies` - Company profiles
- `jobs` - Job postings
- `applications` - Job applications with status
- `skills` - Master skills list
- `user_skills` - User skill mappings
- `job_skills` - Job required skills
- `education` - User education entries
- `experience` - Work experience entries
- `projects` - Portfolio projects
- `certifications` - User certifications

### Social Tables
- `connections` - User connections
- `posts` - Feed posts
- `comments` - Post comments
- `likes` - Post/comment likes
- `messages` - Chat messages
- `notifications` - User notifications

---

## 🚀 Implementation Approach

Building this comprehensive platform in manageable phases, starting with the core job portal functionality and progressively adding social features. Each phase will be fully functional before moving to the next, ensuring a stable, production-ready application.

**All user data will be persisted in Supabase** - profiles, applications, messages, everything is saved and available across sessions.

