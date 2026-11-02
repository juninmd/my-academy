import { PrismaClient } from '@prisma/client'
import { Pool } from 'pg'
import { PrismaPg } from '@prisma/adapter-pg'
import { EXERCISE_MEDIA, exerciseImage } from './exercise-media.js'
import { SEED_MUSCLES } from './seed-muscles.js'

const connectionString = process.env.DATABASE_URL
if (!connectionString) {
  throw new Error('DATABASE_URL is not set')
}
const pool = new Pool({ connectionString })
const adapter = new PrismaPg(pool)
const prisma = new PrismaClient({ adapter })

async function main() {

  await prisma.exercises.upsert({
    where: { name: "Crucifixo Reto" },
    update: {},
    create: {
      name: "Crucifixo Reto",
      image: exerciseImage("Crucifixo Reto"),
      tips:
        "Mantenha os braços estendidos durante todo o movimento, Mantenha os cotovelos levemente flexionados para evitar estresse nas articulações,Mantenha os ombros relaxados e evite arquear as costas.",
      mistakes: "Realizar o movimento com os braços flexionados.,Realizar o movimento com uma carga muito pesada, comprometendo a técnica e colocando em risco a integridade dos ombros."
    },
  });

  await prisma.exercises.upsert({
    where: { name: "Supino com halteres" },
    update: {},
    create: {
      name: "Supino com halteres",
      image: exerciseImage("Supino com halteres"),
      tips:
        "Mantenha os cotovelos em um ângulo de 90 graus.,Inspire durante a descida dos halteres e expire ao empurrá-los para cima.,Evite mover a cabeça ou o pescoço durante o exercício.",
      mistakes:
        "Usar uma carga muito pesada e comprometer a técnica.,Levantar as costas da bancada ao empurrar os halteres, causando estresse na coluna."
    },
  });

  await prisma.exercises.upsert({
    where: { name: "Supino inclinado com barra" },
    update: {},
    create: {
      name: "Supino inclinado com barra",
      image: exerciseImage("Supino inclinado com barra"),
      tips:
        "Mantenha a barra alinhada com a linha média do peito.,Mantenha os cotovelos em um ângulo de 45 graus em relação ao tronco.,Mantenha os pés firmemente plantados no chão para manter a estabilidade.",
      mistakes:
        "Usar uma carga muito pesada e comprometer a técnica.,Arquear as costas ou levantar as nádegas da bancada ao empurrar a barra, causando estresse na coluna."
    },
  });

  await prisma.exercises.upsert({
    where: { name: "Crucifixo Inclinado Com Halteres" },
    update: {},
    create: {
      name: "Crucifixo Inclinado Com Halteres",
      image: exerciseImage("Crucifixo Inclinado Com Halteres"),
      tips:
        "Mantenha os braços estendidos durante todo o movimento.,Mantenha os cotovelos levemente flexionados para evitar estresse nas articulações.,Mantenha os ombros relaxados e evite arquear as costas.",
      mistakes:
        "Realizar o movimento com os braços flexionados.,Realizar o movimento com uma carga muito pesada, comprometendo a técnica e colocando em risco a integridade dos ombros."
    },
  });

  await prisma.exercises.upsert({
    where: { name: "Tríceps Testa Barra W" },
    update: {},
    create: {
      name: "Tríceps Testa Barra W",
      image: exerciseImage("Tríceps Testa Barra W"),
      tips: "Mantenha o cotovelo próximo à cabeça, Não deixe o pulso dobrar",
      mistakes: "Arquear as costas, Usar peso excessivo",
    }
  });

  // Ombro
  await prisma.exercises.upsert({
    where: { name: "Desenvolvimento com halteres" },
    update: {},
    create: {
      tips: "Mantenha a coluna ereta, Estenda totalmente os braços",
      mistakes:
        "Fazer o movimento com impulso,Não realizar a amplitude completa",
      name: "Desenvolvimento com halteres",
      image: exerciseImage("Desenvolvimento com halteres"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Elevação Frontal" },
    update: {},
    create: {
      tips: "Mantenha os cotovelos elevados, Não deixe o peso balançar",
      mistakes: "Usar peso excessivo, Mover o corpo para ajudar o movimento",
      name: "Elevação Frontal",
      image: exerciseImage("Elevação Frontal"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Remada Alta" },
    update: {},
    create: {
      tips: "Mantenha os ombros para baixo e para trás durante o movimento.",
      mistakes: "Não puxe com as costas.",
      name: "Remada Alta",
      image: exerciseImage("Remada Alta"),
    }
  });
  await prisma.exercises.upsert({
    where: { name: "Elevação lateral" },
    update: {},
    create: {
      tips: "Use um peso leve para iniciar o movimento.",
      mistakes: "Não jogue os halteres para cima.",
      name: "Elevação lateral",
      image: exerciseImage("Elevação lateral"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Rosca de bíceps com barra W" },
    update: {},
    create: {
      tips: "Mantenha os cotovelos próximos ao corpo durante o movimento.",
      mistakes: "Não arqueie as costas.",
      name: "Rosca de bíceps com barra W",
      image: exerciseImage("Rosca de bíceps com barra W"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Rosca Concentrada" },
    update: {},
    create: {
      tips: "Mantenha o cotovelo fixo no apoio.",
      mistakes: "Não mova o cotovelo durante o movimento.",
      name: "Rosca Concentrada",
      image: exerciseImage("Rosca Concentrada"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Rosca de martelo alternada" },
    update: {},
    create: {
      tips: "Mantenha os cotovelos próximos ao corpo durante o movimento.",
      mistakes: "Não balance o corpo para ajudar no movimento.",
      name: "Rosca de martelo alternada",
      image: exerciseImage("Rosca de martelo alternada"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Tríceps Barra (polia alta)" },
    update: {},
    create: {
      tips: "Mantenha os cotovelos próximos ao corpo durante o movimento.",
      mistakes: "Não arqueie as costas.",
      name: "Tríceps Barra (polia alta)",
      image: exerciseImage("Tríceps Barra (polia alta)"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Tríceps Corda" },
    update: {},
    create: {
      tips: "Mantenha os cotovelos próximos ao corpo durante o movimento.",
      mistakes: "Não use um peso excessivo.",
      name: "Tríceps Corda",
      image: exerciseImage("Tríceps Corda"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Tríceps Francês Halteres" },
    update: {},
    create: {
      tips: "Use um peso leve para iniciar o movimento.",
      mistakes: "Não desça o halter além da cabeça.",
      name: "Tríceps Francês Halteres",
      image: exerciseImage("Tríceps Francês Halteres"),
    }
  });

  // Pernas
  await prisma.exercises.upsert({
    where: { name: "Cadeira Extensora" },
    update: {},
    create: {
      tips: "Mantenha as costas apoiadas no banco durante o movimento.",
      mistakes: "Não levante os quadris do banco.",
      name: "Cadeira Extensora",
      image: exerciseImage("Cadeira Extensora"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Leg Pres" },
    update: {},
    create: {
      tips:
        "Mantenha os joelhos alinhados com os dedos dos pés durante o movimento.",
      mistakes: "Não trave os joelhos no final do movimento.",
      name: "Leg Pres",
      image: exerciseImage("Leg Pres"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Adutor de Coxas" },
    update: {},
    create: {
      tips: "Mantenha o tronco ereto durante o movimento.",
      mistakes: "Não use um peso excessivo.",
      name: "Adutor de Coxas",
      image: exerciseImage("Adutor de Coxas"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Hack" },
    update: {},
    create: {
      tips: "Mantenha as costas retas durante o movimento.",
      mistakes: "Não mova os joelhos para os lados.",
      name: "Hack",
      image: exerciseImage("Hack"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Mesa Flexora" },
    update: {},
    create: {
      tips: "Mantenha as costas apoiadas no banco durante o movimento.",
      mistakes: "Não use um peso excessivo.",
      name: "Mesa Flexora",
      image: exerciseImage("Mesa Flexora"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Cadeira Flexora" },
    update: {},
    create: {
      tips: "Mantenha o tronco ereto durante o movimento.",
      mistakes: "Não mova o tronco para ajudar no movimento.",
      name: "Cadeira Flexora",
      image: exerciseImage("Cadeira Flexora"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Flexora em pé unilateral (Vertical)" },
    update: {},
    create: {
      tips: "Mantenha o tronco ereto durante o movimento.",
      mistakes: "Não mova o tronco para ajudar no movimento.",
      name: "Flexora em pé unilateral (Vertical)",
      image: exerciseImage("Flexora em pé unilateral (Vertical)"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Elevação Frontal com Kettlebel" },
    update: {},
    create: {
      tips: "Mantenha o tronco ereto durante o movimento.",
      mistakes: "Não mova o tronco para ajudar no movimento.",
      name: "Elevação Frontal com Kettlebel",
      image: exerciseImage("Elevação Frontal com Kettlebel"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Abdução de Quadril Máquina" },
    update: {},
    create: {
      tips: "Mantenha o tronco ereto durante o movimento.",
      mistakes: "Não mova o tronco para ajudar no movimento.",
      name: "Abdução de Quadril Máquina",
      image: exerciseImage("Abdução de Quadril Máquina"),
    }
  });

  await prisma.exercises.upsert({
    where: { name: "Elevação de Quadril com Step" },
    update: {},
    create: {
      tips: "Mantenha o tronco ereto durante o movimento.",
      mistakes: "Não mova o tronco para ajudar no movimento.",
      name: "Elevação de Quadril com Step",
      image: exerciseImage("Elevação de Quadril com Step"),
    }
  });

  // Rows seeded before the bucket move still point at bundled GIFs.
  for (const name of Object.keys(EXERCISE_MEDIA)) {
    await prisma.exercises.updateMany({
      where: { name, image: { startsWith: 'assets/' } },
      data: { image: exerciseImage(name) },
    });
  }
  // Seeded workout groups used this GIF as their cover.
  await prisma.workoutsGroups.updateMany({
    where: { image: 'assets/images/supino_halteres.gif' },
    data: { image: exerciseImage('Supino com halteres') },
  });

  await prisma.users.upsert({
    where: { email: 'jr_acn@hotmail.com' },
    update: {},
    create: {
      id: 'db6i035Vjtb77a7cBDnXQVPd3oL2',
      email: 'jr_acn@hotmail.com',
      name: 'Antonio',
      photoUrl: ''
    }
  });

  await prisma.workoutsGroups.upsert({
    where: { userId_name: { userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2', name: 'Peitos' } },
    update: {},
    create: {
      image: exerciseImage('Supino com halteres'),
      name: 'Peitos',
      userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2',
    }
  });

  await prisma.workoutsGroups.upsert({
    where: { userId_name: { userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2', name: 'Pernas' } },
    update: {},
    create: {
      image: exerciseImage('Supino com halteres'),
      name: 'Pernas',
      userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2',
    }
  });

  await prisma.workoutsGroups.upsert({
    where: { userId_name: { userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2', name: 'Ombros' } },
    update: {},
    create: {
      image: exerciseImage('Supino com halteres'),
      name: 'Ombros',
      userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2',
    }
  });

  await prisma.workoutsGroups.upsert({
    where: { userId_name: { userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2', name: 'Costas' } },
    update: {},
    create: {
      image: exerciseImage('Supino com halteres'),
      name: 'Costas',
      userId: 'db6i035Vjtb77a7cBDnXQVPd3oL2',
    }
  });

  // Worked muscles, primary first (feeds /progress/muscles).
  for (const [name, muscles] of Object.entries(SEED_MUSCLES)) {
    await prisma.exercises.updateMany({ where: { name }, data: { muscles } });
  }
}
main()
  .then(async () => {
    await prisma.$disconnect()
  })
  .catch(async (e) => {
    console.error(e)

    await prisma.$disconnect()

    process.exit(1)
  })