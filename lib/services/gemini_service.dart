import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static Future<String> correctText(String text) async {
    final String inputText = text;
    try {
      final dio = Dio();
      final response = await dio.post(
        '$apiUrl?key=$apiKey',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "contents": [
            {
              "parts": [
                {"text": "Corrige uniquement les fautes de grammaire et d'orthographe dans ce texte en français, sans modifier son style: $inputText"}
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        String correctedText = response.data["candidates"][0]["content"]["parts"][0]["text"];
        return correctedText;
      } else {
        return "Erreur lors de la correction.";
      }
    } catch (e) {
      return "Erreur lors de la correction.";
    }
  }
}
