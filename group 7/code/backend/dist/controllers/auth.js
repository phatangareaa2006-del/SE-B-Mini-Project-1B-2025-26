import { query, getClient, isDbConnected } from '../db/connection.js';
import { hashPassword, comparePasswords } from '../utils/crypto.js';
import { generateToken } from '../utils/jwt.js';
import { v4 as uuidv4 } from 'uuid';
import { setDemoProfile } from '../utils/demoMode.js';
// DEMO MODE: Return mock user when database is not connected
const getMockUser = (email, fullName, role) => {
    return {
        id: uuidv4(),
        email,
        fullName,
        role,
    };
};
// Create a minimal profile in memory for demo mode
const createDemoProfile = (userId, email, fullName) => {
    const profile = {
        id: uuidv4(),
        user_id: userId,
        email,
        full_name: fullName,
        headline: null,
        bio: null,
        location: null,
        linkedin_url: null,
        github_url: null,
        portfolio_url: null,
        avatar_url: null,
        resume_url: null,
        college_id: null,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
    };
    setDemoProfile(userId, profile);
    return profile;
};
export const signup = async (req, res) => {
    try {
        const { email, password, fullName, role, collegeId } = req.body;
        if (!email || !password || !fullName || !role) {
            return res.status(400).json({ error: 'Missing required fields' });
        }
        // If database is not connected, use mock mode
        if (!isDbConnected()) {
            console.warn('ℹ️  Database not connected, using DEMO mode');
            const user = getMockUser(email, fullName, role);
            const profile = createDemoProfile(user.id, email, fullName);
            const token = generateToken({
                userId: user.id,
                email: user.email,
                role: user.role,
            });
            return res.status(201).json({ token, user, profile });
        }
        const client = await getClient();
        try {
            await client.query('BEGIN');
            // Check if user already exists
            const existingUser = await client.query('SELECT id FROM auth_users WHERE email = $1', [email]);
            if (existingUser.rows.length > 0) {
                await client.query('ROLLBACK');
                return res.status(409).json({ error: 'User already exists' });
            }
            // Create user
            const userId = uuidv4();
            const hashedPassword = await hashPassword(password);
            await client.query('INSERT INTO auth_users (id, email, password_hash, created_at) VALUES ($1, $2, $3, $4)', [userId, email, hashedPassword, new Date()]);
            // Create user role
            await client.query('INSERT INTO user_roles (id, user_id, role, created_at) VALUES ($1, $2, $3, $4)', [uuidv4(), userId, role, new Date()]);
            // Create profile
            await client.query('INSERT INTO profiles (id, user_id, email, full_name, college_id, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7)', [uuidv4(), userId, email, fullName, collegeId || null, new Date(), new Date()]);
            await client.query('COMMIT');
            // Generate token
            const token = generateToken({
                userId,
                email,
                role,
            });
            res.status(201).json({
                message: 'User created successfully',
                user: {
                    id: userId,
                    email,
                    fullName,
                    role,
                },
                token,
            });
        }
        catch (error) {
            await client.query('ROLLBACK');
            throw error;
        }
        finally {
            client.release();
        }
    }
    catch (error) {
        console.error('Signup error:', error);
        res.status(500).json({ error: error.message });
    }
};
export const signin = async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }
        // If database is not connected, use demo mode
        if (!isDbConnected()) {
            console.warn('ℹ️  Database not connected, using DEMO mode for signin');
            // In demo mode, accept any email/password combination
            const user = getMockUser(email, 'Demo User', 'student');
            const token = generateToken({
                userId: user.id,
                email: user.email,
                role: user.role,
            });
            return res.status(200).json({ token, user });
        }
        // Get user
        const result = await query('SELECT id, email, password_hash FROM auth_users WHERE email = $1', [email]);
        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }
        const user = result.rows[0];
        // Verify password
        const isPasswordValid = await comparePasswords(password, user.password_hash);
        if (!isPasswordValid) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }
        // Get user role
        const roleResult = await query('SELECT role FROM user_roles WHERE user_id = $1 LIMIT 1', [user.id]);
        const userRole = roleResult.rows[0]?.role || 'student';
        // Generate token
        const token = generateToken({
            userId: user.id,
            email: user.email,
            role: userRole,
        });
        res.json({
            message: 'Signed in successfully',
            user: {
                id: user.id,
                email: user.email,
                role: userRole,
            },
            token,
        });
    }
    catch (error) {
        console.error('Signin error:', error);
        res.status(500).json({ error: error.message });
    }
};
export const resetPassword = async (req, res) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ error: 'Email is required' });
        }
        // Check if user exists
        const result = await query('SELECT id FROM auth_users WHERE email = $1', [email]);
        if (result.rows.length === 0) {
            // Don't reveal if email exists or not
            return res.json({ message: 'If the email exists, a reset link has been sent' });
        }
        // In production, send actual email with reset link
        // For now, just return success
        res.json({ message: 'Password reset email sent' });
    }
    catch (error) {
        console.error('Reset password error:', error);
        res.status(500).json({ error: error.message });
    }
};
export const updatePassword = async (req, res) => {
    try {
        const { password } = req.body;
        if (!password || !req.userId) {
            return res.status(400).json({ error: 'Password is required and user must be authenticated' });
        }
        const hashedPassword = await hashPassword(password);
        await query('UPDATE auth_users SET password_hash = $1 WHERE id = $2', [hashedPassword, req.userId]);
        res.json({ message: 'Password updated successfully' });
    }
    catch (error) {
        console.error('Update password error:', error);
        res.status(500).json({ error: error.message });
    }
};
//# sourceMappingURL=auth.js.map