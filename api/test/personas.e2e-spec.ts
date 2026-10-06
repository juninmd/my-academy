import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import type { PrismaService } from '../src/prisma.service.js';
import {
  as,
  bootPersonaApp,
  cleanup,
  personas,
  realDbUrl,
} from './support/persona-app.js';

const { student, personal, owner, admin, stranger } = personas;

describe.skip(
  'Personas homologation (real Postgres + Redis)',
  () => {
    let app: INestApplication;
    let prisma: PrismaService;
    const exerciseIds: number[] = [];
    let exerciseId: number;
    let groupId: number;

    beforeAll(async () => {
      ({ app, prisma } = await bootPersonaApp());
      await cleanup(prisma, []);
      for (const p of Object.values(personas)) {
        const res = await as(app, p).post('/api/users', {
          id: p.uid,
          name: p.name,
          email: p.email,
          photoUrl: 'https://myacademy.dev/avatar.png',
          role: p.role,
        });
        if (res.status !== 201 && res.status !== 409) {
          throw new Error(`Failed to seed user ${p.email}: ${res.status}`);
        }
      }
      await prisma.users.update({
        where: { id: admin.uid },
        data: { role: 'ADMIN' },
      });
    });

    afterAll(async () => {
      await cleanup(prisma, exerciseIds);
      await app.close();
    });

    it('serves health without a token', async () => {
      await request(app.getHttpServer()).get('/health').expect(200);
    });

    it('forbids registering a profile for someone else', async () => {
      await as(app, stranger)
        .post('/api/users', {
          id: student.uid,
          name: student.name,
          email: student.email,
          photoUrl: 'https://myacademy.dev/avatar.png',
        })
        .expect(403);
    });

    it('nobody can grant themselves ADMIN', async () => {
      await as(app, stranger)
        .patch(`/api/users/${stranger.uid}`, { role: 'ADMIN' })
        .expect(400);
    });

    it('admin manages the catalog and the cache is invalidated', async () => {
      await as(app, student).get('/api/exercises').expect(200);
      const name = `E2E Supino ${Date.now()}`;
      const body = {
        name,
        image: 'https://x.dev/i.png',
        tips: 't',
        mistakes: 'm',
      };
      await as(app, student).post('/api/exercises', body).expect(403);
      await as(app, owner).post('/api/exercises', body).expect(403);
      const created = await as(app, admin)
        .post('/api/exercises', body)
        .expect(201);
      exerciseId = created.body.id;
      exerciseIds.push(exerciseId);
      const list = await as(app, student).get('/api/exercises').expect(200);
      expect(list.body.map((e: { name: string }) => e.name)).toContain(name);
    });

    it('admin curates training methods', async () => {
      const method = { name: `E2E Drop-set ${Date.now()}`, description: 'x' };
      await as(app, personal).post('/api/methods', method).expect(403);
      const created = await as(app, admin)
        .post('/api/methods', method)
        .expect(201);
      const url = `/api/methods/${created.body.id}`;
      await as(app, admin)
        .patch(url, { description: 'Reduce load' })
        .expect(200);
      await as(app, admin).delete(url).expect(200);
    });

    it('student builds a workout with fractional loads and logs a session', async () => {
      const group = {
        name: 'Treino A',
        image: 'https://x.dev/a.png',
        userId: student.uid,
        workouts: [
          {
            exerciseId,
            workoutSeries: [{ repetitions: 10, weight: 22.5, rest: 60 }],
          },
        ],
      };
      const created = await as(app, student)
        .post('/api/workouts-groups', group)
        .expect(201);
      groupId = created.body.id;
      await as(app, student).post('/api/workouts-groups', group).expect(409);

      const now = new Date();
      await as(app, student)
        .post('/api/workouts-sessions', {
          workoutGroupId: groupId,
          date: now.toISOString(),
          workouts: [{ exerciseId, sets: [{ reps: 8, weight: 17.5 }] }],
        })
        .expect(201);
      const month = `year=${now.getFullYear()}&month=${now.getMonth() + 1}`;
      const sessions = await as(app, student)
        .get(`/api/workouts-sessions/${student.uid}?${month}`)
        .expect(200);
      expect(sessions.body).toHaveLength(1);
    });

    it('keeps strangers out of the student data', async () => {
      await as(app, stranger)
        .get(`/api/workouts-groups/user/${student.uid}`)
        .expect(403);
      await as(app, stranger)
        .get(`/api/workouts-groups/${groupId}`)
        .expect(403);
      await as(app, stranger)
        .post('/api/workouts-sessions', {
          workoutGroupId: groupId,
          date: new Date(),
        })
        .expect(403);
    });

    it('personal signs a student, prescribes a workout and assesses them', async () => {
      const contract = {
        personalUserId: personal.uid,
        studentUserId: student.uid,
      };
      await as(app, student).post('/api/personals', contract).expect(403);
      await as(app, personal).post('/api/personals', contract).expect(201);
      await as(app, personal).post('/api/personals', contract).expect(409);

      const students = await as(app, personal)
        .get(`/api/personals/${personal.uid}/students`)
        .expect(200);
      expect(JSON.stringify(students.body)).toContain(student.uid);

      await as(app, personal)
        .post('/api/workouts-groups', {
          name: 'Treino do Personal',
          userId: student.uid,
        })
        .expect(201);
      await as(app, personal)
        .post('/api/assessments', {
          studentId: student.uid,
          personalId: personal.uid,
          weight: 80.5,
          height: 1.8,
        })
        .expect(201);
      const mine = await as(app, student)
        .get(`/api/assessments?studentId=${student.uid}`)
        .expect(200);
      expect(mine.body).toHaveLength(1);
      await as(app, stranger)
        .get(`/api/assessments?studentId=${student.uid}`)
        .expect(403);
    });

    it('gym owner enrolls a student and collects the first payment', async () => {
      await as(app, student).post('/api/gyms', { name: 'Fake' }).expect(403);
      const gym = await as(app, owner)
        .post('/api/gyms', { name: 'Academia E2E', address: 'Rua 1' })
        .expect(201);
      const base = `/api/gyms/${gym.body.id}`;
      const plan = await as(app, owner)
        .post(`${base}/plans`, {
          name: 'Mensal',
          price: 119.9,
          durationMonths: 1,
        })
        .expect(201);

      const enroll = { email: student.email, planId: plan.body.id };
      await as(app, owner).post(`${base}/subscriptions`, enroll).expect(201);
      await as(app, owner).post(`${base}/subscriptions`, enroll).expect(409);
      await as(app, stranger).get(`${base}/dashboard`).expect(403);

      const payments = await as(app, owner).get(`${base}/payments`).expect(200);
      expect(payments.body).toHaveLength(1);
      expect(payments.body[0].status).toBe('PENDING');
      await as(app, owner)
        .patch(`${base}/payments/${payments.body[0].id}`, { status: 'PAID' })
        .expect(200);

      const dashboard = await as(app, owner)
        .get(`${base}/dashboard`)
        .expect(200);
      expect(dashboard.body).toMatchObject({
        activeMembers: 1,
        pendingPayments: 0,
        revenueThisMonth: 119.9,
      });
      const memberships = await as(app, student)
        .get('/api/gyms/subscriptions/me')
        .expect(200);
      expect(memberships.body).toHaveLength(1);
    });
  },
);
