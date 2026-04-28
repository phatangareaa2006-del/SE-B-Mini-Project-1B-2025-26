import pg from 'pg';
declare let pool: pg.Pool;
export declare const query: (text: string, params?: unknown[]) => Promise<pg.QueryResult<any>>;
export declare const getClient: () => Promise<pg.PoolClient>;
export declare const isDbConnected: () => boolean;
export default pool;
//# sourceMappingURL=connection.d.ts.map