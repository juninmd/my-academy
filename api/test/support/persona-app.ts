import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import type { PrismaService } from '../../src/prisma.service.js';

export const realDbUrl = process.env.E2E_DATABASE_URL;

const run = `e2e${Date.now().toString(36)}`;
const persona = (key: string, role: string) => ({
  uid: `${run}-${key}`,
  email: `${run}-${key}@myacademy.dev`,
  name: `E2E ${key}`,
  role,
});

export const personas = {
  student: persona('student', 'STUDENT'),
  personal: persona('personal', 'PERSONAL'),
  owner: persona('owner', 'OWNER'),
  // Registered as a student; promoted in the DB (ADMIN is never self-assigned).
  admin: persona('admin', 'STUDENT'),
  stranger: persona('stranger', 'STUDENT'),
};
export type Persona = (typeof personas)[keyof typeof personas];

const TOKEN = 'e2e-token';

/** Boots the real AppModule (Postgres + Redis) with multi-persona mock auth. */
export async function bootPersonaApp(): Promise<{
  app: INestApplication;
  prisma: PrismaService;
}> {
  // Must be set before AppModule (and its config) is imported.
  Object.assign(process.env, {
    DATABASE_URL: realDbUrl,
    REDIS_URL: process.env.E2E_REDIS_URL ?? '',
    FIREBASE_ENABLED: 'true',
    AUTH_MOC_ENABLED: 'true',
    AUTH_MOC_TOKEN: TOKEN,
    AUTH_MOC_JSON: JSON.stringify(
      Object.values(personas).map((p) => ({ uid: p.uid, email: p.email })),
    ),
  });
  const { AppModule } = await import('../../src/app.module.js');
  const { configureApp } = await import('../../src/app.setup.js');
  const { PrismaService } = await import('../../src/prisma.service.js');
  const moduleRef = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();
  const app = moduleRef.createNestApplication();
  configureApp(app);
  await app.init();
  return { app, prisma: app.get(PrismaService) };
}

export function as(app: INestApplication, who: Persona) {
  const auth = `Bearer ${TOKEN}:${who.uid}`;
  const agent = request(app.getHttpServer());
  return {
    get: (url: string) => agent.get(url).set('Authorization', auth),
    post: (url: string, body: object) =>
      agent.post(url).set('Authorization', auth).send(body),
    patch: (url: string, body: object) =>
      agent.patch(url).set('Authorization', auth).send(body),
    delete: (url: string) => agent.delete(url).set('Authorization', auth),
  };
}

/** Removes every row owned by this run's personas (FKs without cascade first). */
export async function cleanup(prisma: PrismaService, exerciseIds: number[]) {
  const userId = { in: Object.values(personas).map((p) => p.uid) };
  const gyms = { ownerId: userId };
  await prisma.payment.deleteMany({ where: { userId } });
  await prisma.subscription.deleteMany({ where: { userId } });
  await prisma.plan.deleteMany({ where: { gym: gyms } });
  await prisma.gym.deleteMany({ where: gyms });
  await prisma.assessment.deleteMany({ where: { studentId: userId } });
  await prisma.exercises.deleteMany({ where: { id: { in: exerciseIds } } });
  await prisma.users.deleteMany({ where: { id: userId } });
}
