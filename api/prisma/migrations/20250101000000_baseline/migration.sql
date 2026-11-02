-- CreateEnum
DO $$ BEGIN
CREATE TYPE "Role" AS ENUM ('ADMIN', 'PERSONAL', 'STUDENT', 'OWNER');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- CreateEnum
DO $$ BEGIN
CREATE TYPE "ExerciseType" AS ENUM ('STRENGTH', 'CARDIO');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- CreateEnum
DO $$ BEGIN
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'PAID', 'OVERDUE', 'CANCELLED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- CreateEnum
DO $$ BEGIN
CREATE TYPE "SubscriptionStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'CANCELLED', 'EXPIRED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- CreateTable
CREATE TABLE IF NOT EXISTS "exercises" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "image" TEXT NOT NULL,
    "tips" TEXT NOT NULL,
    "mistakes" TEXT NOT NULL,
    "type" "ExerciseType" NOT NULL DEFAULT 'STRENGTH',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exercises_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "exercise_logs" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "exerciseId" INTEGER NOT NULL,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exercise_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "exercise_log_sets" (
    "id" SERIAL NOT NULL,
    "exerciseLogId" INTEGER NOT NULL,
    "reps" INTEGER NOT NULL,
    "weight" DOUBLE PRECISION NOT NULL,
    "rpe" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "exercise_log_sets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "methods" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "methods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "workouts" (
    "id" SERIAL NOT NULL,
    "exerciseId" INTEGER NOT NULL,
    "description" TEXT NOT NULL,
    "workoutsGroupsId" INTEGER NOT NULL,
    "methodId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "workouts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "workouts_groups" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "image" TEXT NOT NULL DEFAULT '',
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "workouts_groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "photoUrl" TEXT NOT NULL DEFAULT '',
    "telegramId" TEXT,
    "role" "Role" NOT NULL DEFAULT 'STUDENT',
    "onboardedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "personal_profiles" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "cref" TEXT NOT NULL,
    "bio" TEXT,
    "specialties" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "personal_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "workout_series" (
    "id" SERIAL NOT NULL,
    "workoutId" INTEGER NOT NULL,
    "repetitions" INTEGER NOT NULL DEFAULT 15,
    "weight" DOUBLE PRECISION DEFAULT 10,
    "rest" INTEGER DEFAULT 60,
    "time" INTEGER,
    "distance" DOUBLE PRECISION,
    "speed" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "workout_series_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "workout_sessions" (
    "id" SERIAL NOT NULL,
    "date" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "workoutGroupId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "workout_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "personals" (
    "id" SERIAL NOT NULL,
    "studentUserId" TEXT NOT NULL,
    "personalUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "personals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "personal_class_schedules" (
    "id" SERIAL NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "time" TEXT NOT NULL,
    "personalsId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "personal_class_schedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "assessments" (
    "id" SERIAL NOT NULL,
    "studentId" TEXT NOT NULL,
    "personalId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "weight" DOUBLE PRECISION NOT NULL,
    "height" DOUBLE PRECISION NOT NULL,
    "imc" DOUBLE PRECISION,
    "fatPercentage" DOUBLE PRECISION,
    "triceps" DOUBLE PRECISION,
    "biceps" DOUBLE PRECISION,
    "subscapular" DOUBLE PRECISION,
    "iliacCrest" DOUBLE PRECISION,
    "supraspinale" DOUBLE PRECISION,
    "abdominal" DOUBLE PRECISION,
    "thigh" DOUBLE PRECISION,
    "calf" DOUBLE PRECISION,
    "waist" DOUBLE PRECISION,
    "hip" DOUBLE PRECISION,
    "arm" DOUBLE PRECISION,
    "leg" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "assessments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "gyms" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT,
    "ownerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "gyms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "plans" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "price" DOUBLE PRECISION NOT NULL,
    "durationMonths" INTEGER NOT NULL,
    "gymId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "subscriptions" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "gymId" INTEGER NOT NULL,
    "planId" INTEGER,
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endDate" TIMESTAMP(3),
    "status" "SubscriptionStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE IF NOT EXISTS "payments" (
    "id" SERIAL NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "subscriptionId" INTEGER,
    "personalContractId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "exercises_name_key" ON "exercises"("name");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "exercise_logs_userId_idx" ON "exercise_logs"("userId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "exercise_logs_exerciseId_idx" ON "exercise_logs"("exerciseId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "exercise_log_sets_exerciseLogId_idx" ON "exercise_log_sets"("exerciseLogId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workouts_exerciseId_idx" ON "workouts"("exerciseId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workouts_workoutsGroupsId_idx" ON "workouts"("workoutsGroupsId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workouts_methodId_idx" ON "workouts"("methodId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "workouts_workoutsGroupsId_exerciseId_key" ON "workouts"("workoutsGroupsId", "exerciseId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workouts_groups_userId_idx" ON "workouts_groups"("userId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "workouts_groups_userId_name_key" ON "workouts_groups"("userId", "name");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "personal_profiles_userId_key" ON "personal_profiles"("userId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workout_series_workoutId_idx" ON "workout_series"("workoutId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workout_sessions_workoutGroupId_idx" ON "workout_sessions"("workoutGroupId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workout_sessions_date_idx" ON "workout_sessions"("date");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "workout_sessions_workoutGroupId_date_idx" ON "workout_sessions"("workoutGroupId", "date");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "personals_personalUserId_idx" ON "personals"("personalUserId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "personals_studentUserId_idx" ON "personals"("studentUserId");

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "personals_studentUserId_personalUserId_key" ON "personals"("studentUserId", "personalUserId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "personal_class_schedules_personalsId_idx" ON "personal_class_schedules"("personalsId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "assessments_studentId_idx" ON "assessments"("studentId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "assessments_personalId_idx" ON "assessments"("personalId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "gyms_ownerId_idx" ON "gyms"("ownerId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "plans_gymId_idx" ON "plans"("gymId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "subscriptions_userId_idx" ON "subscriptions"("userId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "subscriptions_gymId_idx" ON "subscriptions"("gymId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "subscriptions_planId_idx" ON "subscriptions"("planId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "payments_userId_idx" ON "payments"("userId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "payments_subscriptionId_idx" ON "payments"("subscriptionId");

-- CreateIndex
CREATE INDEX IF NOT EXISTS "payments_personalContractId_idx" ON "payments"("personalContractId");

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "exercise_logs" ADD CONSTRAINT "exercise_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "exercise_logs" ADD CONSTRAINT "exercise_logs_exerciseId_fkey" FOREIGN KEY ("exerciseId") REFERENCES "exercises"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "exercise_log_sets" ADD CONSTRAINT "exercise_log_sets_exerciseLogId_fkey" FOREIGN KEY ("exerciseLogId") REFERENCES "exercise_logs"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "workouts" ADD CONSTRAINT "workouts_exerciseId_fkey" FOREIGN KEY ("exerciseId") REFERENCES "exercises"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "workouts" ADD CONSTRAINT "workouts_methodId_fkey" FOREIGN KEY ("methodId") REFERENCES "methods"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "workouts" ADD CONSTRAINT "workouts_workoutsGroupsId_fkey" FOREIGN KEY ("workoutsGroupsId") REFERENCES "workouts_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "workouts_groups" ADD CONSTRAINT "workouts_groups_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "personal_profiles" ADD CONSTRAINT "personal_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "workout_series" ADD CONSTRAINT "workout_series_workoutId_fkey" FOREIGN KEY ("workoutId") REFERENCES "workouts"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "workout_sessions" ADD CONSTRAINT "workout_sessions_workoutGroupId_fkey" FOREIGN KEY ("workoutGroupId") REFERENCES "workouts_groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "personals" ADD CONSTRAINT "personals_studentUserId_fkey" FOREIGN KEY ("studentUserId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "personals" ADD CONSTRAINT "personals_personalUserId_fkey" FOREIGN KEY ("personalUserId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "personal_class_schedules" ADD CONSTRAINT "personal_class_schedules_personalsId_fkey" FOREIGN KEY ("personalsId") REFERENCES "personals"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "assessments" ADD CONSTRAINT "assessments_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "assessments" ADD CONSTRAINT "assessments_personalId_fkey" FOREIGN KEY ("personalId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "gyms" ADD CONSTRAINT "gyms_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "plans" ADD CONSTRAINT "plans_gymId_fkey" FOREIGN KEY ("gymId") REFERENCES "gyms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_gymId_fkey" FOREIGN KEY ("gymId") REFERENCES "gyms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_planId_fkey" FOREIGN KEY ("planId") REFERENCES "plans"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "payments" ADD CONSTRAINT "payments_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "subscriptions"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "payments" ADD CONSTRAINT "payments_personalContractId_fkey" FOREIGN KEY ("personalContractId") REFERENCES "personals"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- AddForeignKey
DO $$ BEGIN
ALTER TABLE "payments" ADD CONSTRAINT "payments_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
