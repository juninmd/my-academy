import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TelegramButton extends StatelessWidget {
  final String channelName;
  final String message;

  TelegramButton({required this.channelName, required this.message});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        const botToken = String.fromEnvironment('TELEGRAM_TOKEN');
        final chatId = channelName; // use o nome do canal com o @
        final url = Uri.https('api.telegram.org', '/bot$botToken/sendMessage', {
          'chat_id': chatId,
          'text': message,
        });
        http.post(url);
      },
      label: Text("Salvar treino"),
      icon: const Icon(Icons.telegram),
    );
  }
}