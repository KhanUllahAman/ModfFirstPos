import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiKey => dotenv.env['BASE_URL'] ?? '';
  static String get xApiKey => dotenv.env['X_API_KEY'] ?? '';
  static String get xApiPassword => dotenv.env['X_API_PASSWORD'] ?? '';

  static void validate() {
    if (apiKey.isEmpty || xApiKey.isEmpty || xApiPassword.isEmpty) {
      throw Exception('One or more API credentials are not configured in .env file');
    }
  }
}