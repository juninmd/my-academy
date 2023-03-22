import '../models/exercise.dart';

List<Exercise> exercises = [
  // Peito
  Exercise(
      id: 1,
      name: "Crucifixo Reto",
      image: "assets/images/crucifixo_reto.gif",
      sets: 4,
      reps: 12,
      weight: 12,
      exerciseGroup: 1,
      tips: [
        "Mantenha os braços estendidos durante todo o movimento.",
        "Mantenha os cotovelos levemente flexionados para evitar estresse nas articulações.",
        "Mantenha os ombros relaxados e evite arquear as costas."
      ],
      errors: [
        "Realizar o movimento com os braços flexionados.",
        "Realizar o movimento com uma carga muito pesada, comprometendo a técnica e colocando em risco a integridade dos ombros."
      ]),
  Exercise(
      id: 2,
      name: "Supino com halteres",
      image: "assets/images/supino_halteres.gif",
      sets: 4,
      reps: 20,
      weight: 12,
      exerciseGroup: 1,
      tips: [
        "Mantenha os cotovelos em um ângulo de 90 graus.",
        "Inspire durante a descida dos halteres e expire ao empurrá-los para cima.",
        "Evite mover a cabeça ou o pescoço durante o exercício."
      ],
      errors: [
        "Usar uma carga muito pesada e comprometer a técnica.",
        "Levantar as costas da bancada ao empurrar os halteres, causando estresse na coluna."
      ]),
  Exercise(
      id: 3,
      name: "Supino inclinado com barra",
      image: "assets/images/supino_halteres.gif",
      sets: 4,
      reps: 12,
      weight: 12,
      exerciseGroup: 1,
      tips: [
        "Mantenha a barra alinhada com a linha média do peito.",
        "Mantenha os cotovelos em um ângulo de 45 graus em relação ao tronco.",
        "Mantenha os pés firmemente plantados no chão para manter a estabilidade."
      ],
      errors: [
        "Usar uma carga muito pesada e comprometer a técnica.",
        "Arquear as costas ou levantar as nádegas da bancada ao empurrar a barra, causando estresse na coluna."
      ]),
  Exercise(
      id: 4,
      name: "Crucifixo Inclinado Com Halteres",
      image: "assets/images/crucifixo_inclinado_halteres.gif",
      sets: 4,
      reps: 15,
      weight: 12,
      exerciseGroup: 1,
      tips: [
        "Mantenha os braços estendidos durante todo o movimento.",
        "Mantenha os cotovelos levemente flexionados para evitar estresse nas articulações.",
        "Mantenha os ombros relaxados e evite arquear as costas."
      ],
      errors: [
        "Realizar o movimento com os braços flexionados.",
        "Realizar o movimento com uma carga muito pesada, comprometendo a técnica e colocando em risco a integridade dos ombros."
      ]),
  Exercise(
      id: 5,
      tips: [
        "Mantenha o cotovelo próximo à cabeça",
        "Não deixe o pulso dobrar"
      ],
      errors: ["Arquear as costas", "Usar peso excessivo"],
      name: "Tríceps Testa Barra W",
      image: "assets/images/tricepes_testa_barra_w.gif",
      sets: 3,
      reps: 20,
      weight: 8,
      exerciseGroup: 1),
// Ombro
  Exercise(
      id: 6,
      tips: ["Mantenha a coluna ereta", "Estenda totalmente os braços"],
      errors: [
        "Fazer o movimento com impulso",
        "Não realizar a amplitude completa"
      ],
      name: "Desenvolvimento com halteres",
      image: "assets/images/desenvolvimento_halteres.gif",
      sets: 4,
      reps: 20,
      weight: 8,
      exerciseGroup: 2),
  Exercise(
      id: 7,
      tips: ["Mantenha os cotovelos elevados", "Não deixe o peso balançar"],
      errors: ["Usar peso excessivo", "Mover o corpo para ajudar o movimento"],
      name: "Elevação Frontal",
      image: "assets/images/elevacao_frontal.gif",
      sets: 4,
      reps: 12,
      weight: 6,
      exerciseGroup: 2),
  Exercise(
      id: 8,
      tips: ["Mantenha os ombros para baixo e para trás durante o movimento."],
      errors: ["Não puxe com as costas."],
      name: "Remada Alta",
      image: "assets/images/remada_alta.gif",
      sets: 4,
      reps: 15,
      weight: 60,
      exerciseGroup: 2),
  Exercise(
      id: 9,
      tips: ["Use um peso leve para iniciar o movimento."],
      errors: ["Não jogue os halteres para cima."],
      name: "Elevação lateral",
      image: "assets/images/elevacao_lateral.gif",
      sets: 4,
      reps: 15,
      weight: 6,
      exerciseGroup: 2),
// Costas
  Exercise(
      id: 10,
      tips: ["Mantenha os cotovelos próximos ao corpo durante o movimento."],
      errors: ["Não arqueie as costas."],
      name: "Rosca de bíceps com barra W",
      image: "assets/images/rosca_biceps_barra_w.gif",
      sets: 4,
      reps: 12,
      weight: 8,
      exerciseGroup: 3),
  Exercise(
      id: 11,
      tips: ["Mantenha o cotovelo fixo no apoio."],
      errors: ["Não mova o cotovelo durante o movimento."],
      name: "Rosca Concentrada",
      image: "assets/images/rosca_concentrada.gif",
      sets: 4,
      reps: 15,
      weight: 8,
      exerciseGroup: 3),
  Exercise(
      id: 12,
      tips: ["Mantenha os cotovelos próximos ao corpo durante o movimento."],
      errors: ["Não balance o corpo para ajudar no movimento."],
      name: "Rosca de martelo alternada",
      image: "assets/images/rosca_martelo_alternada.gif",
      sets: 4,
      reps: 12,
      weight: 6,
      exerciseGroup: 3),
  Exercise(
      id: 13,
      tips: ["Mantenha os cotovelos próximos ao corpo durante o movimento."],
      errors: ["Não arqueie as costas."],
      name: "Tríceps Barra (polia alta)",
      image: "assets/images/tricepes_barra_polia_alta.gif",
      sets: 4,
      reps: 15,
      weight: 30,
      exerciseGroup: 3),
  Exercise(
      id: 14,
      tips: ["Mantenha os cotovelos próximos ao corpo durante o movimento."],
      errors: ["Não use um peso excessivo."],
      name: "Tríceps Corda",
      image: "assets/images/tricepes_corda.gif",
      sets: 4,
      reps: 12,
      weight: 40,
      exerciseGroup: 3),
  Exercise(
      id: 15,
      tips: ["Use um peso leve para iniciar o movimento."],
      errors: ["Não desça o halter além da cabeça."],
      name: "Tríceps Francês Halteres",
      image: "assets/images/tricepes_frances_halter.gif",
      sets: 3,
      reps: 6,
      weight: 140,
      exerciseGroup: 3),
// Pernas
  Exercise(
      id: 16,
      tips: ["Mantenha as costas apoiadas no banco durante o movimento."],
      errors: ["Não levante os quadris do banco."],
      name: "Cadeira Extensora",
      image: "assets/images/cadeira_extensora.gif",
      sets: 4,
      reps: 20,
      weight: 60,
      exerciseGroup: 4),
  Exercise(
      id: 17,
      tips: [
        "Mantenha os joelhos alinhados com os dedos dos pés durante o movimento."
      ],
      errors: ["Não trave os joelhos no final do movimento."],
      name: "Leg Pres",
      image: "assets/images/leg_press.gif",
      sets: 4,
      reps: 20,
      weight: 180,
      exerciseGroup: 4),
  Exercise(
      id: 18,
      tips: ["Mantenha o tronco ereto durante o movimento."],
      errors: ["Não use um peso excessivo."],
      name: "Adutor de Coxas",
      image: "assets/images/adutor_coxas.gif",
      sets: 4,
      reps: 15,
      weight: 60,
      exerciseGroup: 4),
  Exercise(
      id: 19,
      tips: ["Mantenha as costas retas durante o movimento."],
      errors: ["Não mova os joelhos para os lados."],
      name: "Hack",
      image: "assets/images/hack_machine.gif",
      sets: 4,
      reps: 20,
      weight: 180,
      exerciseGroup: 4),
  Exercise(
      id: 20,
      tips: ["Mantenha as costas apoiadas no banco durante o movimento."],
      errors: ["Não use um peso excessivo."],
      name: "Mesa Flexora",
      image: "assets/images/mesa_flexora.gif",
      sets: 4,
      reps: 15,
      weight: 25,
      exerciseGroup: 4),
  Exercise(
      id: 21,
      tips: ["Mantenha o tronco ereto durante o movimento."],
      errors: ["Não mova o tronco para ajudar no movimento."],
      name: "Cadeira Flexora",
      image: "assets/images/cadeira_flexora.gif",
      sets: 4,
      reps: 12,
      weight: 60,
      exerciseGroup: 4),
];
// Exercise(name: "Elevação Lateral Sentado Sem Apoio", image: "assets/images/deadlift.gif", sets: 3, reps: 6, weight: 140, exerciseGroup: 1),
