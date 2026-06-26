import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiKey => dotenv.env['BASE_URL'] ?? '';
  
  static void validate() {
    if (apiKey.isEmpty) {
      throw Exception('API_KEY is not configured in .env file');
    }
  }
}