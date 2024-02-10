import 'package:http/http.dart' as http;

void postChannelMessage(message) {
  const botToken = String.fromEnvironment('TELEGRAM_TOKEN');
  const chatId = '-1001661357785';
  final url = Uri.https('api.telegram.org', '/bot$botToken/sendMessage', {
    'chat_id': chatId,
    'text': message,
  });
  http.post(url);
}