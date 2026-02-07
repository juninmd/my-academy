class MuscleGroupMapper {
  static String getMuscleGroup(String exerciseName) {
    final name = exerciseName.toLowerCase();

    if (name.contains('supino') ||
        name.contains('crucifixo') ||
        name.contains('peitoral') ||
        name.contains('flexão') ||
        name.contains('chest')) {
      return 'Peito';
    }

    if (name.contains('puxada') ||
        name.contains('remada') ||
        name.contains('barra') ||
        name.contains('pulldown') ||
        name.contains('dorsal') ||
        name.contains('costas')) {
      return 'Costas';
    }

    if (name.contains('agachamento') ||
        name.contains('leg') ||
        name.contains('extensora') ||
        name.contains('flexora') ||
        name.contains('stiff') ||
        name.contains('terra') ||
        name.contains('afundo') ||
        name.contains('panturrilha') ||
        name.contains('adutora') ||
        name.contains('abdutora')) {
      return 'Pernas';
    }

    if (name.contains('desenvolvimento') ||
        name.contains('elevação') ||
        name.contains('ombro') ||
        name.contains('militar')) {
      return 'Ombros';
    }

    if (name.contains('rosca') ||
        name.contains('biceps') ||
        name.contains('bíceps') ||
        name.contains('scott')) {
      return 'Bíceps';
    }

    if (name.contains('triceps') ||
        name.contains('tríceps') ||
        name.contains('testa') ||
        name.contains('francês') ||
        name.contains('corda') ||
        name.contains('mergulho')) {
      return 'Tríceps';
    }

    if (name.contains('abdominal') ||
        name.contains('prancha') ||
        name.contains('crunch') ||
        name.contains('core')) {
      return 'Core';
    }

    return 'Outros';
  }
}
