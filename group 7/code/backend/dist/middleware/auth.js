import { verifyToken } from '../utils/jwt.js';
export const authMiddleware = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Missing or invalid authorization header' });
        }
        const token = authHeader.substring(7);
        const decoded = verifyToken(token);
        req.userId = decoded.userId;
        req.email = decoded.email;
        req.role = decoded.role;
        next();
    }
    catch (error) {
        res.status(401).json({ error: 'Invalid or expired token' });
    }
};
export const optionalAuthMiddleware = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (authHeader && authHeader.startsWith('Bearer ')) {
            const token = authHeader.substring(7);
            const decoded = verifyToken(token);
            req.userId = decoded.userId;
            req.email = decoded.email;
            req.role = decoded.role;
        }
        next();
    }
    catch (error) {
        next();
    }
};
//# sourceMappingURL=auth.js.map