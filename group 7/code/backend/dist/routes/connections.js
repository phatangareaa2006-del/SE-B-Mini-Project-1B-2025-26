import express from 'express';
import { query } from '../db/connection.js';
import { authMiddleware } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';
const router = express.Router();
// Get user's connections
router.get('/', authMiddleware, async (req, res) => {
    try {
        const result = await query(`SELECT c.*, p.full_name, p.avatar_url, p.headline 
       FROM connections c 
       JOIN profiles p ON c.addressee_id = p.user_id 
       WHERE c.requester_id = $1 AND c.status = 'accepted'
       UNION
       SELECT c.*, p.full_name, p.avatar_url, p.headline 
       FROM connections c 
       JOIN profiles p ON c.requester_id = p.user_id 
       WHERE c.addressee_id = $1 AND c.status = 'accepted'
       ORDER BY id DESC`, [req.userId]);
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Get pending connection requests
router.get('/pending/requests', authMiddleware, async (req, res) => {
    try {
        const result = await query(`SELECT c.*, p.full_name, p.avatar_url, p.headline 
       FROM connections c 
       JOIN profiles p ON c.requester_id = p.user_id 
       WHERE c.addressee_id = $1 AND c.status = 'pending'
       ORDER BY c.created_at DESC`, [req.userId]);
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Send connection request
router.post('/request', authMiddleware, async (req, res) => {
    try {
        const { addresseeId } = req.body;
        if (addresseeId === req.userId) {
            return res.status(400).json({ error: 'Cannot connect with yourself' });
        }
        const existing = await query('SELECT id FROM connections WHERE (requester_id = $1 AND addressee_id = $2) OR (requester_id = $2 AND addressee_id = $1)', [req.userId, addresseeId]);
        if (existing.rows.length > 0) {
            return res.status(409).json({ error: 'Already connected or request pending' });
        }
        const result = await query('INSERT INTO connections (id, requester_id, addressee_id, status, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *', [uuidv4(), req.userId, addresseeId, 'pending', new Date(), new Date()]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Accept connection request
router.put('/:connectionId/accept', authMiddleware, async (req, res) => {
    try {
        const { connectionId } = req.params;
        const result = await query('UPDATE connections SET status = $1, updated_at = NOW() WHERE id = $2 AND addressee_id = $3 RETURNING *', ['accepted', connectionId, req.userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Connection request not found' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Reject connection request
router.put('/:connectionId/reject', authMiddleware, async (req, res) => {
    try {
        const { connectionId } = req.params;
        const result = await query('UPDATE connections SET status = $1, updated_at = NOW() WHERE id = $2 AND addressee_id = $3 RETURNING *', ['rejected', connectionId, req.userId]);
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Connection request not found' });
        }
        res.json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
export default router;
//# sourceMappingURL=connections.js.map