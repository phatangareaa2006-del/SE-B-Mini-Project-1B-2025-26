import express from 'express';
import { Response } from 'express';
import { query } from '../db/connection.js';
import { authMiddleware, AuthRequest, optionalAuthMiddleware } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Get all opportunities
router.get('/', optionalAuthMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { type, featured, limit = 20, search } = req.query;

    let queryStr = 'SELECT * FROM opportunities WHERE is_active = true';
    const params: any[] = [];
    let paramIndex = 1;

    if (type) {
      queryStr += ` AND opportunity_type = $${paramIndex}`;
      params.push(type);
      paramIndex++;
    }

    if (featured === 'true') {
      queryStr += ` AND is_featured = true`;
    }

    if (search) {
      queryStr += ` AND title ILIKE $${paramIndex}`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    queryStr += ` ORDER BY created_at DESC LIMIT ${Math.min(parseInt(limit as string) || 20, 100)}`;

    const result = await query(queryStr, params);
    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get single opportunity
router.get('/:id', optionalAuthMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'SELECT * FROM opportunities WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Opportunity not found' });
    }

    res.json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Register for opportunity
router.post('/:id/register', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    // Check if already registered
    const existing = await query(
      'SELECT id FROM opportunity_registrations WHERE opportunity_id = $1 AND user_id = $2',
      [id, req.userId]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Already registered for this opportunity' });
    }

    const result = await query(
      'INSERT INTO opportunity_registrations (id, opportunity_id, user_id, status, registered_at) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [uuidv4(), id, req.userId, 'registered', new Date()]
    );

    res.status(201).json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Unregister from opportunity
router.delete('/:id/register', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'DELETE FROM opportunity_registrations WHERE opportunity_id = $1 AND user_id = $2 RETURNING id',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Registration not found' });
    }

    res.json({ message: 'Unregistered from opportunity' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Save opportunity
router.post('/:id/save', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const existing = await query(
      'SELECT id FROM saved_opportunities WHERE opportunity_id = $1 AND user_id = $2',
      [id, req.userId]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Already saved' });
    }

    const result = await query(
      'INSERT INTO saved_opportunities (id, opportunity_id, user_id, created_at) VALUES ($1, $2, $3, $4) RETURNING *',
      [uuidv4(), id, req.userId, new Date()]
    );

    res.status(201).json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Unsave opportunity
router.delete('/:id/save', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'DELETE FROM saved_opportunities WHERE opportunity_id = $1 AND user_id = $2 RETURNING id',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Saved opportunity not found' });
    }

    res.json({ message: 'Opportunity unsaved' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
