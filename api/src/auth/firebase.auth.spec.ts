import { PreauthMiddleware } from './firebase.auth';
import * as firebase from 'firebase-admin';
import configs from '../configs';
import { Request, Response } from 'express';

jest.mock('firebase-admin', () => {
  return {
    initializeApp: jest.fn(),
    credential: {
      cert: jest.fn(),
    },
  };
});

jest.mock('../configs', () => ({
  default: {
    serviceAccount: {},
    authMoc: {
      enabled: 'false',
      json: '{"uid": "mocked"}',
    },
  },
  __esModule: true,
}));

describe('PreauthMiddleware', () => {
  let middleware: PreauthMiddleware;
  let mockVerifyIdToken: jest.Mock;
  let mockConsoleError: jest.SpyInstance;

  beforeEach(() => {
    mockConsoleError = jest
      .spyOn(console, 'error')
      .mockImplementation(() => {});
    mockVerifyIdToken = jest.fn();
    (firebase.initializeApp as jest.Mock).mockReturnValue({
      auth: () => ({
        verifyIdToken: mockVerifyIdToken,
      }),
    });

    // Reset configs
    (configs as any).authMoc.enabled = 'false';

    middleware = new PreauthMiddleware();
  });

  afterEach(() => {
    mockConsoleError.mockRestore();
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(middleware).toBeDefined();
  });

  it('should use mock auth if enabled', async () => {
    (configs as any).authMoc.enabled = 'true';
    (configs as any).authMoc.token = 'test-token';
    const req = {
      headers: { authorization: 'Bearer test-token' },
    } as Request;
    const res = {} as Response;
    const next = jest.fn();

    await middleware.use(req, res, next);

    expect(req['user']).toEqual({ uid: 'mocked' });
    expect(next).toHaveBeenCalled();
  });

  it('should return 403 if no token provided', async () => {
    const req = { headers: {}, url: '/test' } as Request;
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    } as unknown as Response;
    const next = jest.fn();

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
    const next = jest.fn();
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
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    } as unknown as Response;
    const next = jest.fn();

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
    const next = jest.fn();

    await middleware.use(req, res, next);
    expect(next).toHaveBeenCalled();
  });

  it('should skip auth for /api/health', async () => {
    const req = { url: '/api/health' } as Request;
    const res = {} as Response;
    const next = jest.fn();

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
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    } as unknown as Response;
    const next = jest.fn();

    await middleware.use(req, res, next);

    expect(mockVerifyIdToken).toHaveBeenCalledWith('wrong-token');
  });

  it('should handle undefined headers safely', async () => {
    (configs as any).authMoc.enabled = 'true';
    const req = { url: '/test' } as Request;
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    } as unknown as Response;
    const next = jest.fn();

    await middleware.use(req, res, next);

    expect(res.status).toHaveBeenCalledWith(403);
  });
});
