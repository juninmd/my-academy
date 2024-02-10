var idUser = 1;

String getDateNow() {
  final date = DateTime.now();
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}