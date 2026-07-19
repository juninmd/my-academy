import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from './../src/app.module';
import { PrismaService } from '../src/prisma.service';
import { TelegramService } from '../src/telegram/telegram.service';

describe('Homologation (e2e)', () => {
  let app: INestApplication;

  const mockPrisma = {
    users: {
      findUnique: jest.fn(),
      findUniqueOrThrow: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    exercises: {
      findUnique: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
    },
    workoutsGroups: {
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      findUniqueOrThrow: jest.fn(),
    },
    workoutsSessions: {
      create: jest.fn(),
    },
    workoutSessions: {
      create: jest.fn(),
      findFirst: jest.fn(),
      findMany: jest.fn(),
    },
    exerciseLog: {
      create: jest.fn(),
    },
    personals: {
      create: jest.fn(),
      findMany: jest.fn(),
      findFirst: jest.fn(),
    },
    $transaction: jest.fn().mockImplementation((cb) => cb(mockPrisma)),
  };

  const mockTelegram = {
    postChannelMessage: jest.fn().mockResolvedValue({}),
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(mockPrisma)
      .overrideProvider(TelegramService)
      .useValue(mockTelegram)
      .compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, transform: true }),
    );

    // Middleware to inject user for E2E tests
    app.use((req, res, next) => {
      req.user = { uid: 'user-1' };
      next();
    });

    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('1. Users & Auth', () => {
    it('should create a new student', () => {
      const dto = { Workouts: [],
        id: 'user-1',
        name: 'Student One',
        email: 'student@test.com',
        photoUrl: 'https://example.com/photo.jpg',
      };
      mockPrisma.users.findUnique.mockResolvedValue(null);
      mockPrisma.users.create.mockResolvedValue({ ...dto, role: 'STUDENT' });

      return request(app.getHttpServer())
        .post('/users')
        .send(dto)
        .expect(201)
        .expect((res) => {
          expect(res.body.role).toBe('STUDENT');
        });
    });
  });

  describe('2. Exercises', () => {
    it('should list exercises', () => {
      mockPrisma.exercises.findMany.mockResolvedValue([
        { id: 1, name: 'Supino' },
      ]);

      return request(app.getHttpServer())
        .get('/exercises')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveLength(1);
        });
    });
  });

  describe('3. Workouts', () => {
    it('should create a workout group', () => {
      const dto = { Workouts: [],
        name: 'Treino A',
        image: 'image.jpg',
        userId: 'user-1',
        workouts: [
          {
            exerciseId: 1,
            description: 'desc',
            workoutSeries: [{ repetitions: 12, weight: 50, rest: 60 }],
          },
        ],
      };
      mockPrisma.workoutsGroups.create.mockResolvedValue({ id: 10, ...dto });

      return request(app.getHttpServer())
        .post('/workouts-groups')
        .send(dto)
        .expect(201)
        .expect((res) => {
          expect(res.body.id).toBe(10);
        });
    });
  });

  describe('4. Sessions', () => {
    it('should register a workout session', () => {
      const dto = { Workouts: [],
        workoutGroupId: 10,
        date: new Date().toISOString(),
      };
      mockPrisma.users.findUniqueOrThrow.mockResolvedValue({
        id: 'user-1',
        telegramId: '123',
      });
      mockPrisma.workoutsGroups.findUniqueOrThrow.mockResolvedValue({
        id: 10,
        name: 'Treino A',
      });
      mockPrisma.workoutSessions.create.mockResolvedValue({ id: 100, ...dto });

      return request(app.getHttpServer())
        .post('/workouts-sessions')
        .send(dto)
        .expect(201);
    });
  });

  describe('5. Personal Trainer', () => {
    it('should link student to personal', () => {
      const dto = { Workouts: [],
        studentUserId: 'user-1',
        personalUserId: 'personal-1',
      };
      mockPrisma.personals.create.mockResolvedValue({ id: 50, ...dto });

      return request(app.getHttpServer())
        .post('/personals')
        .send(dto)
        .expect(201);
    });
  });

  describe('6. Workout Summary & Sequences', () => {
    it('should return workout summary with correct sequence', async () => {
      const userId = 'user-1';
      mockPrisma.personals.findMany.mockResolvedValue([]);
      mockPrisma.personals.findFirst.mockResolvedValue(null);
      mockPrisma.workoutsGroups.findMany.mockResolvedValue([
        { id: 10, name: 'Treino A' },
      ]);

      const today = new Date();
      const yesterday = new Date();
      yesterday.setDate(today.getDate() - 1);

      mockPrisma.workoutSessions.findFirst.mockResolvedValue({
        id: 100,
        date: yesterday,
        workoutGroupId: 10,
        workoutsGroups: { id: 10, name: 'Treino A' },
      });

      mockPrisma.workoutSessions.findMany.mockResolvedValue([
        { id: 99, date: yesterday, workoutGroupId: 10 },
      ]);

      const res = await request(app.getHttpServer())
        .get(`/workouts-sessions/${userId}/summary`)
        .expect(200);

      expect(res.body.counter).toBeDefined();
    });
  });
});
