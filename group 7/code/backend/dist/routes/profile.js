import express from 'express';
import { query, isDbConnected } from '../db/connection.js';
import { authMiddleware } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';
import { getDemoProfile, updateDemoProfile } from '../utils/demoMode.js';
const router = express.Router();
// Get user profile
router.get('/', authMiddleware, async (req, res) => {
    try {
        if (!req.userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }
        console.log(`[Profile GET] userId: ${req.userId}`);
        // Check demo mode first
        if (!isDbConnected()) {
            const demoProfile = getDemoProfile(req.userId);
            if (demoProfile) {
                console.log(`[Profile GET] Returning demo profile`);
                return res.json(demoProfile);
            }
        }
        const result = await query('SELECT * FROM profiles WHERE user_id = $1', [req.userId]);
        console.log(`[Profile GET] Query completed, rows: ${result.rows.length}`);
        if (result.rows.length === 0) {
            console.log(`[Profile GET] No profile found for user ${req.userId}`);
            // Create a default profile if it doesn't exist
            const profileId = uuidv4();
            await query('INSERT INTO profiles (id, user_id, email, created_at, updated_at) VALUES ($1, $2, $3, $4, $5)', [profileId, req.userId, 'unknown@example.com', new Date(), new Date()]);
            const newProfile = await query('SELECT * FROM profiles WHERE id = $1', [profileId]);
            return res.json(newProfile.rows[0]);
        }
        console.log(`[Profile GET] Returning profile`);
        res.json(result.rows[0]);
    }
    catch (error) {
        console.error('[Profile GET] Error:', error);
        res.status(500).json({ error: error.message });
    }
});
// Update profile
router.put('/', authMiddleware, async (req, res) => {
    try {
        if (!req.userId) {
            return res.status(401).json({ error: 'Unauthorized' });
        }
        const updates = req.body;
        const allowedFields = [
            'full_name', 'headline', 'bio', 'phone', 'location', 'website',
            'linkedin_url', 'github_url', 'portfolio_url', 'avatar_url',
            'banner_url', 'resume_url', 'is_available'
        ];
        // Filter only allowed fields
        const filteredUpdates = {};
        allowedFields.forEach(field => {
            if (field in updates) {
                filteredUpdates[field] = updates[field];
            }
        });
        if (Object.keys(filteredUpdates).length === 0) {
            return res.status(400).json({ error: 'No valid fields to update' });
        }
        // Handle demo mode
        if (!isDbConnected()) {
            let demoProfile = getDemoProfile(req.userId);
            if (!demoProfile) {
                demoProfile = {
                    id: uuidv4(),
                    user_id: req.userId,
                    email: 'unknown@example.com',
                    full_name: null,
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
            }
            // Apply updates to demo profile
            Object.assign(demoProfile, filteredUpdates, { updated_at: new Date().toISOString() });
            updateDemoProfile(req.userId, filteredUpdates);
            return res.json(demoProfile);
        }
        const setClause = Object.keys(filteredUpdates)
            .map((key, idx) => `${key} = $${idx + 1}`)
            .join(', ');
        const values = Object.values(filteredUpdates);
        const updateQuery = `UPDATE profiles SET ${setClause}, updated_at = NOW() WHERE user_id = $${values.length + 1} RETURNING *`;
        const result = await query(updateQuery, [...values, req.userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Profile not found' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Get education records
router.get('/education', authMiddleware, async (req, res) => {
    try {
        const result = await query('SELECT * FROM education WHERE user_id = $1 ORDER BY start_date DESC', [req.userId]);
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Add education
router.post('/education', authMiddleware, async (req, res) => {
    try {
        const { institution, degree, field_of_study, start_date, end_date, is_current, grade, cgpa } = req.body;
        const result = await query('INSERT INTO education (id, user_id, institution, degree, field_of_study, start_date, end_date, is_current, grade, cgpa, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *', [uuidv4(), req.userId, institution, degree, field_of_study, start_date, end_date, is_current, grade, cgpa, new Date(), new Date()]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Update education
router.put('/education/:id', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        const allowedFields = ['institution', 'degree', 'field_of_study', 'start_date', 'end_date', 'is_current', 'grade', 'cgpa'];
        const filteredUpdates = {};
        allowedFields.forEach(field => {
            if (field in updates) {
                filteredUpdates[field] = updates[field];
            }
        });
        const setClause = Object.keys(filteredUpdates)
            .map((key, idx) => `${key} = $${idx + 1}`)
            .join(', ');
        const values = Object.values(filteredUpdates);
        const updateQuery = `UPDATE education SET ${setClause}, updated_at = NOW() WHERE id = $${values.length + 1} AND user_id = $${values.length + 2} RETURNING *`;
        const result = await query(updateQuery, [...values, id, req.userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Education record not found' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Delete education
router.delete('/education/:id', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const result = await query('DELETE FROM education WHERE id = $1 AND user_id = $2 RETURNING id', [id, req.userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Education record not found' });
        }
        res.json({ message: 'Education record deleted' });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Get experience records
router.get('/experience', authMiddleware, async (req, res) => {
    try {
        const result = await query('SELECT * FROM experience WHERE user_id = $1 ORDER BY start_date DESC', [req.userId]);
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Add experience
router.post('/experience', authMiddleware, async (req, res) => {
    try {
        const { company_name, title, employment_type, location, start_date, end_date, is_current, description } = req.body;
        const result = await query('INSERT INTO experience (id, user_id, company_name, title, employment_type, location, start_date, end_date, is_current, description, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *', [uuidv4(), req.userId, company_name, title, employment_type, location, start_date, end_date, is_current, description, new Date(), new Date()]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Update experience
router.put('/experience/:id', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        const allowedFields = ['company_name', 'title', 'employment_type', 'location', 'start_date', 'end_date', 'is_current', 'description'];
        const filteredUpdates = {};
        allowedFields.forEach(field => {
            if (field in updates) {
                filteredUpdates[field] = updates[field];
            }
        });
        const setClause = Object.keys(filteredUpdates)
            .map((key, idx) => `${key} = $${idx + 1}`)
            .join(', ');
        const values = Object.values(filteredUpdates);
        const updateQuery = `UPDATE experience SET ${setClause}, updated_at = NOW() WHERE id = $${values.length + 1} AND user_id = $${values.length + 2} RETURNING *`;
        const result = await query(updateQuery, [...values, id, req.userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Experience record not found' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Delete experience
router.delete('/experience/:id', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const result = await query('DELETE FROM experience WHERE id = $1 AND user_id = $2 RETURNING id', [id, req.userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Experience record not found' });
        }
        res.json({ message: 'Experience record deleted' });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
export default router;
//# sourceMappingURL=profile.js.map