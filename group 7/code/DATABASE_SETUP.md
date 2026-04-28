# PostgreSQL Connection Setup Guide

The application requires PostgreSQL to be installed and running. The backend is currently failing to connect because the database credentials are incorrect.

## Quick Setup Solutions

### Option 1: Configure Your Existing PostgreSQL (Recommended)

1. **Find your PostgreSQL password:**
   - If you installed PostgreSQL recently, the password you set during installation is needed
   - If you don't remember it, you can reset it

2. **Update the `.env` file:**
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=postgres
   DB_USER=postgres
   DB_PASSWORD=<your-actual-postgres-password>
   ```

3. **Restart the backend:**
   ```bash
   cd backend
   npm run build
   node dist/index.js
   ```

### Option 2: Reset PostgreSQL Password (Windows)

1. Open PowerShell as Administrator
2. Stop PostgreSQL service:
   ```powershell
   Stop-Service -Name postgresql-x64-15  # or your version
   ```

3. Open `pg_hba.conf` file (usually at `C:\Program Files\PostgreSQL\<version>\data\pg_hba.conf`)

4. Change the authentication method for local connections from `scram-sha-256` to `trust` temporarily:
   ```
   # Change this line:
   local   all             all                                     scram-sha-256
   # To:
   local   all             all                                     trust
   ```

5. Restart PostgreSQL:
   ```powershell
   Start-Service -Name postgresql-x64-15
   ```

6. Update `.env` to use empty password:
   ```
   DB_PASSWORD=
   ```

### Option 3: Create a Fresh Database User

1. Open PostgreSQL command line (psql):
   ```bash
   psql -U postgres
   ```

2. Create a new user:
   ```sql
   CREATE USER placementhub WITH PASSWORD 'password123';
   ALTER USER placementhub CREATEDB;
   ```

3. Create database:
   ```sql
   CREATE DATABASE placementhub_db OWNER placementhub;
   ```

4. Update `.env`:
   ```
   DB_USER=placementhub
   DB_PASSWORD=password123
   DB_NAME=placementhub_db
   ```

## Verify Connection

After updating `.env`, test the connection by running the backend. You should see:
```
✓ Database connected successfully
```

Instead of:
```
⚠️  Database connection failed
```

## Current Status

- ✅ Frontend: http://localhost:8080 (running)
- ✅ Backend API: http://localhost:3000 (running) 
- ❌ Database: Not connected (authentication required)

Once you configure the database, the signup form should work properly.
