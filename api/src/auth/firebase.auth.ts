import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response } from 'express';
import { App, cert, initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import configs from '../configs/index.js';
import { resolveMockUser } from './mock-auth.js';

const firebase_params = configs.serviceAccount;

@Injectable()
export class PreauthMiddleware implements NestMiddleware {
  private defaultApp?: App;

  private get firebaseAuth() {
    this.defaultApp ??= initializeApp({ credential: cert(firebase_params) });
    return getAuth(this.defaultApp);
  }

  async use(req: Request, res: Response, next: (error?: any) => void) {
    if (req.url === '/health' || req.url === '/api/health') {
      return next();
    }

    if (configs.authMoc.enabled === 'true') {
      const mockUser = resolveMockUser(
        req.headers?.authorization,
        configs.authMoc.token,
        configs.authMoc.json,
      );
      if (mockUser) {
        req['user'] = mockUser;
        return next();
      }
    }

    const token = req.headers?.authorization;
    if (!token) {
      return res.status(403).json({
        statusCode: 403,
        timestamp: new Date().toISOString(),
        path: req.url,
        message: 'token required',
      });
    }
    try {
      const decodedToken = await this.firebaseAuth.verifyIdToken(
        token.replace('Bearer ', ''),
      );

      req['user'] = decodedToken;
      next();
    } catch (error) {
      console.error(error);
      return res.status(403).json({
        statusCode: 403,
        timestamp: new Date().toISOString(),
        path: req.url,
        message: 'Access Denied',
      });
    }
  }
}
