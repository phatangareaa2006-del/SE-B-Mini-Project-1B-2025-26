import express from 'express';
import { Response } from 'express';
import { query } from '../db/connection.js';
import { authMiddleware, AuthRequest } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Get user's notifications
router.get('/', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { limit = 50, isRead } = req.query;

    let queryStr = 'SELECT * FROM notifications WHERE user_id = $1';
    const params: any[] = [req.userId];

    if (isRead !== undefined) {
      queryStr += ` AND is_read = ${isRead === 'true'}`;
    }

    queryStr += ` ORDER BY created_at DESC LIMIT ${Math.min(parseInt(limit as string) || 50, 100)}`;

    const result = await query(queryStr, params);
    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Mark notification as read
router.put('/:id/read', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    res.json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Mark all as read
router.put('/all/read', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    await query(
      'UPDATE notifications SET is_read = true WHERE user_id = $1 AND is_read = false',
      [req.userId]
    );

    res.json({ message: 'All notifications marked as read' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get unread count
router.get('/unread/count', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      'SELECT COUNT(*) as unread_count FROM notifications WHERE user_id = $1 AND is_read = false',
      [req.userId]
    );

    res.json({ unreadCount: result.rows[0].unread_count });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
