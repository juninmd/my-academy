# 🧠 Regras de Negócio e Funcionalidades - My Academy

## 1. Módulo de Usuários e Autenticação
**Funcionalidades:**
- Autenticação e Login baseados em Firebase (com suporte a mock para desenvolvimento).
- Gestão de Perfis de Usuário.
- Sistema de Onboarding para preenchimento de dados iniciais.

**Regras de Negócio:**
- **Roles:** O sistema divide os usuários em três perfis estritos: `ADMIN`, `PERSONAL` e `STUDENT`.
- **Perfil Estendido (Personal):** Usuários com role `PERSONAL` possuem uma entidade vinculada `PersonalProfile` obrigatória, contendo `CREF`, especialidades e biografia.

## 2. Módulo de Exercícios (Exercises)
**Funcionalidades:**
- Catálogo global de exercícios com instruções (dicas, erros comuns e descrição) e mídia (imagem).

**Regras de Negócio:**
- **Classificação:** Cada exercício é estritamente tipado como Força (`STRENGTH`) ou Cárdio (`CARDIO`).
- **Unicidade:** O nome do exercício é único no banco de dados.

## 3. Módulo de Fichas de Treino (Workouts & Groups)
**Funcionalidades:**
- Criação de Fichas/Grupos de Treino (ex: Treino A, Treino B) nomeadas e ilustradas por usuário.
- Montagem estruturada do treino contendo o Exercício, Séries, e associação opcional a Métodos avançados (ex: Drop-set).
- Suporte a métricas distintas para Força (Repetições, Carga, Descanso) e Cárdio (Tempo, Distância, Velocidade).

**Regras de Negócio:**
- **Unicidade no Grupo:** Um mesmo exercício não pode ser adicionado duplicado dentro de um mesmo Grupo de Treino.
- **Transação de Atualização:** A edição de um Grupo de Treino segue uma regra de "replace"; as métricas antigas são deletadas e as novas recriadas via transação atômica no banco de dados.
- **Cascata:** A exclusão de um Grupo de Treino deleta todos os treinos e séries vinculadas.

## 4. Módulo de Histórico e Acompanhamento (Logs & Sessions)
**Funcionalidades:**
- Registro de Sessões de Treino (`WorkoutSessions`) para marcar a conclusão da ficha em determinado dia.
- Log detalhado de execução (`ExerciseLog` e `ExerciseLogSet`) permitindo ao usuário registrar a carga levantada, repetições feitas e índice de percepção de esforço (RPE).

**Regras de Negócio:**
- **Data e Vinculação:** Cada sessão concluída referencia diretamente o Grupo de Treino executado e a data em que ocorreu, permitindo construção de mapas de calor (calendar).

## 5. Módulo de Personal Trainer (Contratos e Agenda)
**Funcionalidades:**
- Associação de Vínculo entre Personal e Aluno (`Personals`).
- Gerenciamento de Cronograma de Aulas (`PersonalClassSchedule`) definindo os dias da semana e horários da consultoria.
- Visualização de painel do Personal contendo a lista de alunos e agendas.

**Regras de Negócio:**
- **Unicidade de Vínculo:** É permitido apenas um registro de contrato ativo entre um mesmo Personal e um mesmo Aluno.
- **Dependência de Agenda:** A remoção do vínculo contratual Personal-Aluno destrói toda a agenda programada em cascata.

## 6. Módulo de Avaliações Físicas (Assessments)
**Funcionalidades:**
- Registro de medidas corporais (Peso, Altura, IMC, Percentual de Gordura).
- Registro clínico de dobras cutâneas (tríceps, bíceps, abdominal, etc.) e circunferências (cintura, quadril, braço, etc.).

**Regras de Negócio:**
- **Auditoria:** Toda avaliação física exige obrigatoriamente a assinatura (vínculo) de quem avaliou (`personalId`) e quem foi avaliado (`studentId`).

## 7. Módulo de Academias e Planos Financeiros
**Funcionalidades:**
- Cadastro de Academias (`Gym`) e seus administradores.
- Gestão de Planos (`Plan`) de uso com valores e durações definidas.
- Assinaturas (`Subscription`) e registro de Pagamentos (`Payment`).

**Regras de Negócio:**
- **Ciclo de Vida de Assinatura:** Status transitam estritamente entre `ACTIVE`, `INACTIVE`, `CANCELLED`, `EXPIRED`.
- **Entidades de Pagamento:** Um pagamento sempre está amarrado ao seu propósito, seja uma assinatura de academia (`subscriptionId`) ou um contrato de Personal (`personalContractId`).
- **Estado do Pagamento:** Pagamentos transitam entre `PENDING`, `PAID`, `OVERDUE` e `CANCELLED`.
