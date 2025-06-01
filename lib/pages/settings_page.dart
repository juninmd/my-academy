import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants.dart';
import '../models/user.dart';
import '../services/my_academy/user_api.dart';

final settingsPageStoreProvider =
    ChangeNotifierProvider((ref) => SettingsPageStore());

class SettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SettingsPageStore store = ref.watch(settingsPageStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Name"),
                controller: TextEditingController(
                  text: store.user.name,
                ),
                readOnly: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(labelText: "Email"),
                controller: TextEditingController(
                  text: store.user.name,
                ),
                readOnly: true,
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(labelText: "Telegram ID"),
                controller: TextEditingController(
                  text: store.user.telegramId,
                ),
                readOnly: true,
              ),
              SizedBox(height: 16.0),
              // TextField(
              //   decoration: InputDecoration(labelText: "Phone Number"),
              //   initialValue: user.phoneNumber,
              //   onChanged: (value) {
              //     // Atualiza o número celular do usuário
              //     ref.read(userProvider.notifier).state.phoneNumber = value;
              //   },
              // ),
              // SizedBox(height: 16.0),
              CheckboxListTile(
                value: true,
                onChanged: (value) {
                  // Atualiza se o usuário é personal
                  print(value);
                },
                title: Text("I'm a Personal Trainer"),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Mostra uma mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User saved successfully!")),
                  );
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPageStore extends ChangeNotifier {
  Users user = Users(id: FireBaseUser!.uid!, name: '', email: '', photoUrl: '');
  bool isLoading = true;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      user = await getUserById(FireBaseUser!.uid);
    } catch (error) {
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
