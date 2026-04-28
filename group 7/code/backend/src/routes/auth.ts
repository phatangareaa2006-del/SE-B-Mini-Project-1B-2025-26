import express from 'express';
import { signup, signin, resetPassword, updatePassword } from '../controllers/auth.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

router.post('/signup', signup);
router.post('/signin', signin);
router.post('/reset-password', resetPassword);
router.post('/update-password', authMiddleware, updatePassword);

export default router;
