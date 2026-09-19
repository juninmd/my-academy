import type { Mock, MockInstance } from 'vitest';
import { PreauthMiddleware } from './firebase.auth.js';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import configs from '../configs/index.js';
import { Request, Response } from 'express';

vi.mock('firebase-admin/app', () => ({
  initializeApp: vi.fn(() => ({})),
  cert: vi.fn(),
}));
vi.mock('firebase-admin/auth', () => ({ getAuth: vi.fn() }));

vi.mock('../configs/index.js', () => ({
  default: {
    serviceAccount: {},
    authMoc: {
      enabled: 'false',
      json: '{"uid": "mocked"}',
    },
  },
}));

describe('PreauthMiddleware', () => {
  let middleware: PreauthMiddleware;
  let mockVerifyIdToken: Mock;
  let mockConsoleError: MockInstance;

  beforeEach(() => {
    mockConsoleError = vi.spyOn(console, 'error').mockImplementation(() => {});
    mockVerifyIdToken = vi.fn();
    (getAuth as Mock).mockReturnValue({ verifyIdToken: mockVerifyIdToken });

    // Reset configs
    (configs as any).authMoc.enabled = 'false';

    middleware = new PreauthMiddleware();
  });

  afterEach(() => {
    mockConsoleError.mockRestore();
    vi.clearAllMocks();
  });

  it('does not initialize Firebase until a real token must be verified', async () => {
    expect(initializeApp).not.toHaveBeenCalled();
    mockVerifyIdToken.mockResolvedValue({ uid: 'u' });
    const req = { headers: { authorization: 'Bearer a' } } as Request;
    await middleware.use(req, {} as Response, vi.fn());
    await middleware.use(req, {} as Response, vi.fn());
    expect(initializeApp).toHaveBeenCalledTimes(1);
  });

  it('should use mock auth if enabled', async () => {
    (configs as any).authMoc.enabled = 'true';
    (configs as any).authMoc.token = 'test-token';
    const req = {
      headers: { authorization: 'Bearer test-token' },
    } as Request;
    const res = {} as Response;
    const next = vi.fn();

    await middleware.use(req, res, next);

    expect(req['user']).toEqual({ uid: 'mocked' });
    expect(next).toHaveBeenCalled();
  });

  it('should return 403 if no token provided', async () => {
    const req = { headers: {}, url: '/test' } as Request;
    const res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    } as unknown as Response;
    const next = vi.fn();

    await middleware.use(req, res, next);

    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'token required' }),
    );
    expect(next).not.toHaveBeenCalled();
  });

  it('should verify token successfully', async () => {
    const req = { headers: { authorization: 'Bearer valid' } } as Request;
    const res = {} as Response;
    const next = vi.fn();
    const decoded = { uid: 'user1' };

    mockVerifyIdToken.mockResolvedValue(decoded);

    await middleware.use(req, res, next);

    expect(mockVerifyIdToken).toHaveBeenCalledWith('valid');
    expect(req['user']).toBe(decoded);
    expect(next).toHaveBeenCalled();
  });

  it('should return 403 if token verification fails', async () => {
    const req = {
      headers: { authorization: 'Bearer invalid' },
      url: '/test',
    } as Request;
    const res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    } as unknown as Response;
    const next = vi.fn();

    mockVerifyIdToken.mockRejectedValue(new Error('Invalid token'));

    await middleware.use(req, res, next);

    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Access Denied' }),
    );
    expect(next).not.toHaveBeenCalled();
  });

  it('should skip auth for /health', async () => {
    const req = { url: '/health' } as Request;
    const res = {} as Response;
    const next = vi.fn();

    await middleware.use(req, res, next);
    expect(next).toHaveBeenCalled();
  });

  it('should skip auth for /api/health', async () => {
    const req = { url: '/api/health' } as Request;
    const res = {} as Response;
    const next = vi.fn();

    await middleware.use(req, res, next);
    expect(next).toHaveBeenCalled();
  });

  it('should not use mock auth if token does not match', async () => {
    (configs as any).authMoc.enabled = 'true';
    (configs as any).authMoc.token = 'test-token';
    const req = {
      headers: { authorization: 'Bearer wrong-token' },
      url: '/test',
    } as Request;
    const res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    } as unknown as Response;
    const next = vi.fn();

    await middleware.use(req, res, next);

    expect(mockVerifyIdToken).toHaveBeenCalledWith('wrong-token');
  });

  it('should handle undefined headers safely', async () => {
    (configs as any).authMoc.enabled = 'true';
    const req = { url: '/test' } as Request;
    const res = {
      status: vi.fn().mockReturnThis(),
      json: vi.fn(),
    } as unknown as Response;
    const next = vi.fn();

    await middleware.use(req, res, next);

    expect(res.status).toHaveBeenCalledWith(403);
  });
});
