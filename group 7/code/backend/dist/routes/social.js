import express from 'express';
import { query } from '../db/connection.js';
import { authMiddleware, optionalAuthMiddleware } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';
const router = express.Router();
// Get posts feed
router.get('/', optionalAuthMiddleware, async (req, res) => {
    try {
        const { limit = 20, offset = 0 } = req.query;
        const result = await query('SELECT p.*, u.full_name, u.avatar_url FROM posts p JOIN profiles u ON p.user_id = u.user_id WHERE p.visibility = $1 ORDER BY p.created_at DESC LIMIT $2 OFFSET $3', ['public', Math.min(parseInt(limit) || 20, 100), parseInt(offset) || 0]);
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Create post
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { content, imageUrls, videoUrl, visibility = 'public' } = req.body;
        if (!content) {
            return res.status(400).json({ error: 'Content is required' });
        }
        const result = await query('INSERT INTO posts (id, user_id, content, image_urls, video_url, visibility, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *', [uuidv4(), req.userId, content, imageUrls || [], videoUrl, visibility, new Date(), new Date()]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Like post
router.post('/:id/like', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const existing = await query('SELECT id FROM likes WHERE user_id = $1 AND post_id = $2', [req.userId, id]);
        if (existing.rows.length > 0) {
            return res.status(409).json({ error: 'Already liked' });
        }
        await query('INSERT INTO likes (id, user_id, post_id, created_at) VALUES ($1, $2, $3, $4)', [uuidv4(), req.userId, id, new Date()]);
        await query('UPDATE posts SET likes_count = likes_count + 1 WHERE id = $1', [id]);
        res.json({ message: 'Post liked' });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Unlike post
router.delete('/:id/like', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        await query('DELETE FROM likes WHERE user_id = $1 AND post_id = $2', [req.userId, id]);
        await query('UPDATE posts SET likes_count = likes_count - 1 WHERE id = $1', [id]);
        res.json({ message: 'Post unliked' });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Get post comments
router.get('/:id/comments', optionalAuthMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const result = await query('SELECT c.*, u.full_name, u.avatar_url FROM comments c JOIN profiles u ON c.user_id = u.user_id WHERE c.post_id = $1 ORDER BY c.created_at ASC', [id]);
        res.json(result.rows);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// Add comment
router.post('/:id/comments', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const { content } = req.body;
        if (!content) {
            return res.status(400).json({ error: 'Content is required' });
        }
        const result = await query('INSERT INTO comments (id, post_id, user_id, content, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *', [uuidv4(), id, req.userId, content, new Date(), new Date()]);
        await query('UPDATE posts SET comments_count = comments_count + 1 WHERE id = $1', [id]);
        res.status(201).json(result.rows[0]);
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
});
export default router;
//# sourceMappingURL=social.js.map