import express from 'express';
import { Response } from 'express';
import { query } from '../db/connection.js';
import { authMiddleware, AuthRequest } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Get user's messages
router.get('/', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      `SELECT m.*, s.full_name as sender_name, r.full_name as receiver_name 
       FROM messages m 
       JOIN profiles s ON m.sender_id = s.user_id 
       JOIN profiles r ON m.receiver_id = r.user_id 
       WHERE m.sender_id = $1 OR m.receiver_id = $1 
       ORDER BY m.created_at DESC`,
      [req.userId]
    );

    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get conversation with specific user
router.get('/:userId/conversation', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.params;

    const result = await query(
      `SELECT m.*, s.full_name as sender_name 
       FROM messages m 
       JOIN profiles s ON m.sender_id = s.user_id 
       WHERE (m.sender_id = $1 AND m.receiver_id = $2) OR (m.sender_id = $2 AND m.receiver_id = $1)
       ORDER BY m.created_at ASC`,
      [req.userId, userId]
    );

    // Mark messages as read
    await query(
      'UPDATE messages SET is_read = true WHERE receiver_id = $1 AND sender_id = $2 AND is_read = false',
      [req.userId, userId]
    );

    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Send message
router.post('/', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { receiverId, content } = req.body;

    if (!content || !receiverId) {
      return res.status(400).json({ error: 'Content and receiverId are required' });
    }

    if (receiverId === req.userId) {
      return res.status(400).json({ error: 'Cannot send message to yourself' });
    }

    const result = await query(
      'INSERT INTO messages (id, sender_id, receiver_id, content, created_at) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [uuidv4(), req.userId, receiverId, content, new Date()]
    );

    res.status(201).json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get unread message count
router.get('/unread/count', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      'SELECT COUNT(*) as unread_count FROM messages WHERE receiver_id = $1 AND is_read = false',
      [req.userId]
    );

    res.json({ unreadCount: result.rows[0].unread_count });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
