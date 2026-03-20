import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/home/presentation/widgets/body_weight_dialog.dart';
import 'package:my_academy/features/profile/presentation/providers/settings_provider.dart';

class FakeSettingsNotifier extends SettingsNotifier {
  @override
  SettingsState build() {
    return SettingsState(bodyWeight: 70.0);
  }

  @override
  Future<void> setBodyWeight(double weight) async {
    state = state.copyWith(bodyWeight: weight);
  }
}

void main() {
  testWidgets('BodyWeightDialog updates weight', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsProvider.overrideWith(FakeSettingsNotifier.new)],
        child: const MaterialApp(home: BodyWeightDialog()),
      ),
    );

    expect(find.text('Registrar Peso Corporal'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });
}
