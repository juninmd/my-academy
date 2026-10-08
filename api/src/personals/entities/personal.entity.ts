import { Users } from '@prisma/client';

export class Personal {
  id: number;
  studentUserId: string;
  personalUserId: string;
  StudentUser?: Users;
  PersonalUser?: Users;
}
