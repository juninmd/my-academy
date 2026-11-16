const Map<String, String> _names = {
  'chest': 'Peito',
  'back': 'Costas',
  'traps': 'Trapézio',
  'shoulders': 'Ombros',
  'biceps': 'Bíceps',
  'triceps': 'Tríceps',
  'forearms': 'Antebraços',
  'abs': 'Abdômen',
  'lower_back': 'Lombar',
  'glutes': 'Glúteos',
  'quads': 'Quadríceps',
  'hamstrings': 'Posteriores',
  'adductors': 'Adutores',
  'calves': 'Panturrilhas',
};

String muscleName(String slug) => _names[slug] ?? slug;
