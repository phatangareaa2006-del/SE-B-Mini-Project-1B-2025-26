import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.js';
import profileRoutes from './routes/profile.js';
import opportunitiesRoutes from './routes/opportunities.js';
import jobsRoutes from './routes/jobs.js';
import companiesRoutes from './routes/companies.js';
import socialRoutes from './routes/social.js';
import connectionsRoutes from './routes/connections.js';
import messagesRoutes from './routes/messages.js';
import notificationsRoutes from './routes/notifications.js';
dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;
// Middleware
app.use(helmet({
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false,
}));
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
// Request logging
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});
// Routes
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/opportunities', opportunitiesRoutes);
app.use('/api/jobs', jobsRoutes);
app.use('/api/companies', companiesRoutes);
app.use('/api/posts', socialRoutes);
app.use('/api/connections', connectionsRoutes);
app.use('/api/messages', messagesRoutes);
app.use('/api/notifications', notificationsRoutes);
// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date() });
});
// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'PlacementHub API Server',
        version: '1.0.0',
        endpoints: {
            health: '/api/health',
            auth: '/api/auth',
            profile: '/api/profile',
            jobs: '/api/jobs',
            opportunities: '/api/opportunities',
            companies: '/api/companies',
            posts: '/api/posts',
            connections: '/api/connections',
            messages: '/api/messages',
            notifications: '/api/notifications'
        }
    });
});
// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        error: err.message || 'Internal Server Error'
    });
});
// Database connection check
import { isDbConnected } from './db/connection.js';
const server = app.listen(PORT, async () => {
    console.log(`Server running on http://localhost:${PORT}`);
    // Check database connection
    try {
        const connected = isDbConnected();
        if (connected) {
            console.log('✓ Database connected successfully');
        }
        else {
            console.log('⚠️  Database not connected (demo mode enabled)');
        }
    }
    catch (err) {
        console.error('Database check error:', err);
    }
});
server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
        console.error(`Port ${PORT} is already in use`);
    }
    else {
        console.error('Server error:', err);
    }
    process.exit(1);
});
export default app;
//# sourceMappingURL=index.js.map