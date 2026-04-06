-- AlterTable
ALTER TABLE "exercise_log_sets" ADD COLUMN     "type" TEXT NOT NULL DEFAULT 'normal';

-- AlterTable
ALTER TABLE "exercises" ADD COLUMN     "description" TEXT;