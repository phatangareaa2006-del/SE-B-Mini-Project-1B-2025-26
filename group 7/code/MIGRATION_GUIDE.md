# PlacementHub - Supabase to PostgreSQL Migration Guide

## Overview

This guide provides step-by-step instructions to migrate PlacementHub from Supabase (managed backend) to a standalone PostgreSQL database with a Node.js/Express API backend.

## Phase 1: Database Setup

### Step 1.1: Install PostgreSQL

**On Windows:**
```bash
# Download PostgreSQL 14+ from https://www.postgresql.org/download/windows/
# Run installer and remember the password you set for 'postgres' user
# Default port: 5432
```

**On macOS:**
```bash
brew install postgresql
brew services start postgresql
```

**On Linux (Ubuntu):**
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
sudo service postgresql start
```

### Step 1.2: Create Database

```bash
# Connect to PostgreSQL
psql -U postgres

# Inside psql prompt, create database
CREATE DATABASE placementhub;
CREATE USER placementhub_user WITH ENCRYPTED PASSWORD 'your_secure_password';
ALTER ROLE placementhub_user SET client_encoding TO 'utf8';
ALTER ROLE placementhub_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE placementhub_user SET default_transaction_deferrable TO on;
ALTER ROLE placementhub_user SET default_transaction_level TO 'read committed';
GRANT ALL PRIVILEGES ON DATABASE placementhub TO placementhub_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO placementhub_user;

# Exit psql
\q
```

### Step 1.3: Run Schema Migration

```bash
# From backend directory
cd backend

# Run migration
psql -U placementhub_user -d placementhub -h localhost < migrations/001_initial_schema.sql
```

## Phase 2: Backend Setup

### Step 2.1: Install Dependencies

```bash
cd backend
npm install
# or
yarn install
```

### Step 2.2: Configure Environment

```bash
# Copy example file
cp .env.example .env

# Edit .env with your database credentials
DB_HOST=localhost
DB_PORT=5432
DB_NAME=placementhub
DB_USER=placementhub_user
DB_PASSWORD=your_secure_password
JWT_SECRET=your-super-secret-jwt-key-change-in-production
PORT=3000
```

### Step 2.3: Start Backend Server

```bash
npm run dev
# Server will run on http://localhost:3000
```

## Phase 3: Data Migration from Supabase

### Step 3.1: Export Data from Supabase

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Dump database
pg_dump --host="<SUPABASE_HOST>" \
        --username="postgres" \
        --password \
        --dbname="postgres" \
        --no-privileges \
        --format=plain \
        > supabase_backup.sql

# When prompted, use service_role key as password (from Supabase dashboard)
```

### Step 3.2: Transform and Clean Data

The SQL export needs adjustment for our schema. A migration script is provided:

```bash
# Run data migration script (creates clean data)
node --loader ts-node/esm backend/src/db/migrate.ts
```

### Step 3.3: Verify Data Migration

```bash
# Connect to new database
psql -U placementhub_user -d placementhub

# Check table row counts
SELECT table_name, 
       (xpath('/row', xml_agg(xml_each)))[1]::text::int as count 
FROM information_schema.tables 
WHERE table_schema='public';

# Or simple count
SELECT COUNT(*) FROM auth_users;
SELECT COUNT(*) FROM profiles;
SELECT COUNT(*) FROM jobs;
SELECT COUNT(*) FROM applications;
```

## Phase 4: Frontend Migration

### Step 4.1: Update Frontend Dependencies

```bash
cd .. # Go to frontend root

# These dependencies can be removed (no longer needed):
npm uninstall @supabase/supabase-js

# If needed, add axios or fetch-based HTTP client (already available)
```

### Step 4.2: Replace Supabase Client

Delete the Supabase client file and create new API client:
- Delete: `src/integrations/supabase/`
- Create: `src/api/client.ts` (see below)

### Step 4.3: Update AuthContext

Replace Supabase auth with JWT-based authentication using the new API client.

### Step 4.4: Update All Hooks

Convert all `supabase.from().select()` calls to API calls via HTTP requests.

## Complete API Reference

### Authentication

#### Signup
```bash
POST /api/auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure_password",
  "fullName": "User Name",
  "role": "student",
  "collegeId": "college-uuid-optional"
}

Response:
{
  "message": "User created successfully",
  "user": {
    "id": "user-uuid",
    "email": "user@example.com",
    "fullName": "User Name",
    "role": "student"
  },
  "token": "jwt-token"
}
```

#### Signin
```bash
POST /api/auth/signin
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure_password"
}

Response:
{
  "message": "Signed in successfully",
  "user": {
    "id": "user-uuid",
    "email": "user@example.com",
    "role": "student"
  },
  "token": "jwt-token"
}
```

#### Update Password
```bash
POST /api/auth/update-password
Authorization: Bearer {jwt-token}
Content-Type: application/json

{
  "password": "new_secure_password"
}
```

### Profile

#### Get Profile
```bash
GET /api/profile
Authorization: Bearer {jwt-token}

Response: { profile data }
```

#### Update Profile
```bash
PUT /api/profile
Authorization: Bearer {jwt-token}
Content-Type: application/json

{
  "full_name": "New Name",
  "headline": "Job Title",
  "bio": "Bio text",
  "location": "City, Country",
  "linkedin_url": "https://...",
  "github_url": "https://...",
  "resume_url": "s3://..."
}
```

#### Education Management
```bash
GET /api/profile/education
POST /api/profile/education
PUT /api/profile/education/{id}
DELETE /api/profile/education/{id}

Same pattern for:
- /api/profile/experience
- /api/profile/certifications
- /api/profile/projects
- /api/profile/skills
```

### Opportunities

#### List Opportunities
```bash
GET /api/opportunities?type=job&featured=true&limit=20&search=query
# Optional Authorization header

Response: [{ opportunity objects }]
```

#### Get Single Opportunity
```bash
GET /api/opportunities/{id}

Response: { opportunity object }
```

#### Register for Opportunity
```bash
POST /api/opportunities/{id}/register
Authorization: Bearer {jwt-token}

Response: { registration object }
```

#### Save Opportunity
```bash
POST /api/opportunities/{id}/save
Authorization: Bearer {jwt-token}

Response: { saved opportunity object }
```

## Data Consistency Checklist

- [ ] All users migrated to `auth_users` table
- [ ] All user roles preserved in `user_roles`
- [ ] All profiles created with correct user_id references
- [ ] All education/experience/projects data intact
- [ ] All job listings and applications transferred
- [ ] Opportunity data preserved
- [ ] Foreign key integrity verified
- [ ] UUID consistency maintained
- [ ] Timestamps preserved (created_at, updated_at)
- [ ] All indexes created for performance

## Rollback Strategy

If issues occur during migration:

### Quick Rollback (Within 24 hours)
```bash
# Keep Supabase running during migration
# If new PostgreSQL backend fails, switch DNS/frontend back to Supabase
# No data loss as both systems run in parallel

# After verification, shut down Supabase
```

### Full Rollback (After Shutdown)
```bash
# Restore PostgreSQL from backup
pg_restore -U placementhub_user -d placementhub_new < backup.dump

# Restore Supabase from dumps (keep original keys)
# Re-point frontend to Supabase (revert configuration)
```

## Post-Migration Verification

### Frontend Testing
```bash
# Test all major features:
1. User signup/login
2. Profile updates
3. View opportunities
4. Upload resume/files
5. Apply for jobs
6. Search functionality
7. Save/unsave features
8. View applications
```

### Performance Testing
```bash
# Test with concurrent users
# Measure query response times
# Verify database indexes are working

# Sample performance check:
psql -U placementhub_user -d placementhub

EXPLAIN ANALYZE SELECT * FROM opportunities WHERE is_active = true;
EXPLAIN ANALYZE SELECT * FROM applications WHERE user_id = '...';
```

## Important Notes

1. **JWT Secret**: Change `JWT_SECRET` in production to a strong random string
2. **CORS**: Update CORS configuration in backend for your frontend domain
3. **File Storage**: Implement file upload backend endpoint for resume/image uploads
4. **Email Service**: For password reset emails, integrate with SendGrid, AWS SES, or similar
5. **Rate Limiting**: Add rate limiting middleware for production
6. **Database Backups**: Set up automated PostgreSQL backups
7. **SSL/TLS**: Enable SSL for backend API in production

## Support Files Provided

- `backend/package.json` - Dependencies and scripts
- `backend/tsconfig.json` - TypeScript configuration
- `backend/.env.example` - Environment template
- `backend/src/index.ts` - Main server file
- `backend/src/controllers/auth.ts` - Authentication logic
- `backend/src/routes/` - API route handlers
- `backend/src/middleware/auth.ts` - JWT verification
- `backend/migrations/001_initial_schema.sql` - Database schema

## Next Steps

1. Set up PostgreSQL locally
2. Create the database and run migrations
3. Configure backend .env file
4. Start backend server
5. Update frontend API client
6. Test authentication flow
7. Migrate all data
8. Deploy to production

See individual setup instructions in this document for detailed steps.
