export interface JWTPayload {
    userId: string;
    email: string;
    role: string;
}
export declare const generateToken: (payload: JWTPayload) => string;
export declare const verifyToken: (token: string) => JWTPayload;
export declare const generateRefreshToken: (userId: string) => string;
//# sourceMappingURL=jwt.d.ts.map