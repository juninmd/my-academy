import 'package:firebase_auth/firebase_auth.dart';

User? FireBaseUser;

String getDateNow() {
  final date = DateTime.now();
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}
