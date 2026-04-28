import express from 'express';
import { Response } from 'express';
import { query } from '../db/connection.js';
import { authMiddleware, AuthRequest, optionalAuthMiddleware } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Get all companies
router.get('/', optionalAuthMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { search, limit = 20 } = req.query;

    let queryStr = 'SELECT * FROM companies WHERE verification_status = $1';
    const params: any[] = ['approved'];

    if (search) {
      queryStr += ` AND name ILIKE $2`;
      params.push(`%${search}%`);
    }

    queryStr += ` ORDER BY is_featured DESC, created_at DESC LIMIT ${Math.min(parseInt(limit as string) || 20, 100)}`;

    const result = await query(queryStr, params);
    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get single company
router.get('/:id', optionalAuthMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'SELECT * FROM companies WHERE id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Company not found' });
    }

    res.json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get or create company profile for authenticated user
router.get('/profile/me', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      'SELECT * FROM companies WHERE user_id = $1',
      [req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'No company profile found' });
    }

    res.json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Update company profile
router.put('/profile/me', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const updates = req.body;
    const allowedFields = ['name', 'description', 'industry', 'website', 'linkedin_url', 'logo_url', 'banner_url', 'company_size'];

    const filteredUpdates: any = {};
    allowedFields.forEach(field => {
      if (field in updates) {
        filteredUpdates[field] = updates[field];
      }
    });

    if (Object.keys(filteredUpdates).length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    const setClause = Object.keys(filteredUpdates)
      .map((key, idx) => `${key.toLowerCase()} = $${idx + 1}`)
      .join(', ');
    const values = Object.values(filteredUpdates);

    const updateQuery = `UPDATE companies SET ${setClause}, updated_at = NOW() WHERE user_id = $${values.length + 1} RETURNING *`;
    
    const result = await query(updateQuery, [...values, req.userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Company profile not found' });
    }

    res.json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get company's job postings
router.get('/:id/jobs', optionalAuthMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'SELECT * FROM jobs WHERE company_id = $1 AND is_active = true ORDER BY created_at DESC',
      [id]
    );

    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
