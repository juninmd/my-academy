String getDateNow() {
  final date = DateTime.now();
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}

String getDayOfWeekName(int dayOfWeek) {
  switch (dayOfWeek) {
    case 1:
      return 'Segunda';
    case 2:
      return 'Terça';
    case 3:
      return 'Quarta';
    case 4:
      return 'Quinta';
    case 5:
      return 'Sexta';
    case 6:
      return 'Sábado';
    case 7:
      return 'Domingo';
    default:
      return '';
  }
}
