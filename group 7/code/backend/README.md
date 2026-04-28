# PlacementHub Backend

Node.js + Express.js + PostgreSQL API Server for PlacementHub

## Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 12+
- npm or yarn

### Installation

```bash
# 1. Install dependencies
npm install

# 2. Copy environment template
cp .env.example .env

# 3. Edit .env with your settings
# Edit database credentials, JWT secret, etc.

# 4. Start development server
npm run dev

# Server will run on http://localhost:3000
```

### Production Build

```bash
npm run build
npm start
```

## API Documentation

See [../MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md) for full API endpoint reference.

### Quick Examples

**Sign Up**
```bash
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "fullName": "John Doe",
    "role": "student"
  }'
```

**Sign In**
```bash
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

**Get Profile (Authenticated)**
```bash
curl -X GET http://localhost:3000/api/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Database Setup

```bash
# Create database
createdb placementhub

# Create user (PostgreSQL)
psql -U postgres
CREATE USER placementhub_user WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE placementhub TO placementhub_user;

# Run migrations
psql -U placementhub_user -d placementhub < migrations/001_initial_schema.sql
```

## Environment Variables

- `DB_HOST` - Database host (default: localhost)
- `DB_PORT` - Database port (default: 5432)
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `JWT_SECRET` - Secret for signing JWT tokens
- `JWT_EXPIRY` - Token expiration time (default: 7d)
- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)

## Project Structure

```
src/
├── index.ts           # Main server file
├── controllers/       # Business logic
│   └── auth.ts       # Auth controller
├── routes/           # API routes
│   ├── auth.ts
│   ├── profile.ts
│   └── opportunities.ts
├── middleware/       # Express middleware
│   └── auth.ts       # JWT verification
├── utils/            # Utility functions
│   ├── jwt.ts        # Token generation/verification
│   └── crypto.ts     # Password hashing
└── db/
    └── connection.ts # Database connection pool
```

## Scripts

- `npm run dev` - Start development server with hot reload
- `npm run build` - Compile TypeScript
- `npm start` - Run compiled server
- `npm run migrate` - Run database migrations
- `npm run seed` - Seed database with sample data

## Development Tips

### Database Queries
```typescript
import { query } from '@/db/connection';

// Execute query with parameters
const result = await query(
  'SELECT * FROM users WHERE id = $1',
  [userId]
);

console.log(result.rows);
```

### JWT Tokens
```typescript
import { generateToken, verifyToken } from '@/utils/jwt';

// Create token
const token = generateToken({
  userId: user.id,
  email: user.email,
  role: user.role,
});

// Verify token
const decoded = verifyToken(token);
console.log(decoded.userId);
```

### Protected Routes
```typescript
import { authMiddleware } from '@/middleware/auth';

router.get('/protected', authMiddleware, (req, res) => {
  // req.userId is available here
  res.json({ userId: req.userId });
});
```

## Error Handling

All errors return JSON response with error message:

```json
{
  "error": "Description of what went wrong"
}
```

HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `409` - Conflict
- `500` - Server Error

## CORS Configuration

Update `src/index.ts` for your frontend domain:

```typescript
app.use(cors({
  origin: ['http://localhost:5173', 'https://yourdomain.com'],
  credentials: true,
}));
```

## Performance Tips

1. **Indexes**: Database schema includes indexes on common queries
2. **Connection Pool**: pg pool manages connections efficiently
3. **Query Optimization**: Use proper WHERE clauses and JOINs
4. **Caching**: Add Redis for session caching if needed
5. **Rate Limiting**: Add rate-limit middleware for production

## Monitoring

### Database Health
```sql
-- Check slow queries
SELECT query, mean_exec_time FROM pg_stat_statements 
ORDER BY mean_exec_time DESC LIMIT 10;

-- Check table sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) 
FROM pg_tables 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### API Logs
Add logging middleware:
```typescript
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} - ${res.statusCode} - ${duration}ms`);
  });
  next();
});
```

## Deployment

### Heroku
```bash
heroku create placementhub-api
heroku addons:create heroku-postgresql:hobby-dev
heroku config:set JWT_SECRET=your-secret-here
git push heroku main
```

### Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist ./dist
CMD ["node", "dist/index.js"]
```

## License

MIT

## Support

For issues or questions, see the main [MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md)
