import express from 'express';
import { Response } from 'express';
import { query } from '../db/connection.js';
import { authMiddleware, AuthRequest, optionalAuthMiddleware } from '../middleware/auth.js';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

// Get all jobs
router.get('/', optionalAuthMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { search, type, isActive = 'true', limit = 20 } = req.query;

    let queryStr = 'SELECT j.*, c.name as company_name FROM jobs j JOIN companies c ON j.company_id = c.id WHERE 1=1';
    const params: any[] = [];
    let paramIndex = 1;

    if (isActive === 'true') {
      queryStr += ' AND j.is_active = true';
    }

    if (type) {
      queryStr += ` AND j.job_type = $${paramIndex}`;
      params.push(type);
      paramIndex++;
    }

    if (search) {
      queryStr += ` AND (j.title ILIKE $${paramIndex} OR c.name ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    queryStr += ` ORDER BY j.created_at DESC LIMIT ${Math.min(parseInt(limit as string) || 20, 100)}`;

    const result = await query(queryStr, params);
    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get single job with company info
router.get('/:id', optionalAuthMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'SELECT j.*, c.name as company_name, c.logo_url as company_logo FROM jobs j JOIN companies c ON j.company_id = c.id WHERE j.id = $1',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Job not found' });
    }

    res.json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Create job (company only)
router.post('/', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { title, department, jobType, description, requirements, minSalary, maxSalary, locations, openings, applicationDeadline } = req.body;

    // Get company ID for this user
    const companyRes = await query('SELECT id FROM companies WHERE user_id = $1', [req.userId]);
    if (companyRes.rows.length === 0) {
      return res.status(403).json({ error: 'User is not a company' });
    }

    const companyId = companyRes.rows[0].id;

    const result = await query(
      'INSERT INTO jobs (id, company_id, title, department, job_type, description, requirements, min_salary, max_salary, locations, openings, application_deadline, is_active, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) RETURNING *',
      [uuidv4(), companyId, title, department, jobType || 'full_time', description, requirements, minSalary, maxSalary, locations || [], openings || 1, applicationDeadline, true, new Date(), new Date()]
    );

    res.status(201).json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Apply for job
router.post('/:id/apply', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { coverLetter, resumeUrl } = req.body;

    const existing = await query(
      'SELECT id FROM applications WHERE job_id = $1 AND user_id = $2',
      [id, req.userId]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Already applied for this job' });
    }

    const result = await query(
      'INSERT INTO applications (id, job_id, user_id, status, cover_letter, resume_url, created_at, updated_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *',
      [uuidv4(), id, req.userId, 'applied', coverLetter, resumeUrl, new Date(), new Date()]
    );

    res.status(201).json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Save job
router.post('/:id/save', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const existing = await query(
      'SELECT id FROM saved_jobs WHERE job_id = $1 AND user_id = $2',
      [id, req.userId]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Already saved' });
    }

    const result = await query(
      'INSERT INTO saved_jobs (id, job_id, user_id, created_at) VALUES ($1, $2, $3, $4) RETURNING *',
      [uuidv4(), id, req.userId, new Date()]
    );

    res.status(201).json(result.rows[0]);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Unsave job
router.delete('/:id/save', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const result = await query(
      'DELETE FROM saved_jobs WHERE job_id = $1 AND user_id = $2 RETURNING id',
      [id, req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Saved job not found' });
    }

    res.json({ message: 'Job unsaved' });
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get user's applications
router.get('/user/applications', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      'SELECT a.*, j.title as job_title, c.name as company_name FROM applications a JOIN jobs j ON a.job_id = j.id JOIN companies c ON j.company_id = c.id WHERE a.user_id = $1 ORDER BY a.created_at DESC',
      [req.userId]
    );

    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

// Get user's saved jobs
router.get('/user/saved', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const result = await query(
      'SELECT j.*, c.name as company_name FROM saved_jobs sj JOIN jobs j ON sj.job_id = j.id JOIN companies c ON j.company_id = c.id WHERE sj.user_id = $1 ORDER BY sj.created_at DESC',
      [req.userId]
    );

    res.json(result.rows);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
});

export default router;
