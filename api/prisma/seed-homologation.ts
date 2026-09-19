import { PrismaClient, Role } from '@prisma/client';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';

// Idempotent fixtures for the three homologation personas (see docker-compose.yml).
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter: new PrismaPg(pool) });

const users = [
  {
    id: 'hml-student',
    email: 'aluno@myacademy.dev',
    name: 'Ana Aluna',
    role: Role.STUDENT,
  },
  {
    id: 'hml-personal',
    email: 'personal@myacademy.dev',
    name: 'Paulo Personal',
    role: Role.PERSONAL,
  },
  {
    id: 'hml-owner',
    email: 'dono@myacademy.dev',
    name: 'Otávio Dono',
    role: Role.OWNER,
  },
];

const methods = [
  {
    name: 'Drop-set',
    description:
      'Ao atingir a falha, reduza a carga em ~20% e continue sem descanso.',
  },
  {
    name: 'Bi-set',
    description:
      'Dois exercícios executados em sequência, sem descanso entre eles.',
  },
  {
    name: 'Rest-pause',
    description:
      'Pausas de 10–15s após a falha para completar repetições extras.',
  },
];

async function main() {
  for (const user of users) {
    // Seeded personas are returning users; hml-newbie walks the onboarding.
    const onboardedAt = new Date();
    await prisma.users.upsert({
      where: { id: user.id },
      update: { role: user.role, onboardedAt },
      create: { ...user, onboardedAt },
    });
  }

  if ((await prisma.methods.count()) === 0) {
    await prisma.methods.createMany({ data: methods });
  }

  await prisma.personalProfile.upsert({
    where: { userId: 'hml-personal' },
    update: {},
    create: {
      userId: 'hml-personal',
      cref: '123456-G/SP',
      specialties: 'Hipertrofia,Emagrecimento',
      bio: 'Personal há 10 anos.',
    },
  });

  const contract = await prisma.personals.upsert({
    where: {
      studentUserId_personalUserId: {
        studentUserId: 'hml-student',
        personalUserId: 'hml-personal',
      },
    },
    update: {},
    create: { studentUserId: 'hml-student', personalUserId: 'hml-personal' },
  });
  if (
    (await prisma.personalClassSchedule.count({
      where: { personalsId: contract.id },
    })) === 0
  ) {
    await prisma.personalClassSchedule.createMany({
      data: [
        { personalsId: contract.id, dayOfWeek: 1, time: '07:00' },
        { personalsId: contract.id, dayOfWeek: 3, time: '07:00' },
      ],
    });
  }

  let gym = await prisma.gym.findFirst({ where: { ownerId: 'hml-owner' } });
  gym ??= await prisma.gym.create({
    data: {
      name: 'Academia Homologação',
      address: 'Rua dos Testes, 100 - São Paulo',
      ownerId: 'hml-owner',
      plans: {
        create: [
          { name: 'Mensal', price: 119.9, durationMonths: 1 },
          { name: 'Trimestral', price: 329.9, durationMonths: 3 },
        ],
      },
    },
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
