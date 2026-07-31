import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class GeminiService {
  static String apiUrl = '';
  static String apiKey = '';

  static bool _configLoaded = false;

  static Future<void> _loadConfig() async {
    if (_configLoaded) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('gemini')
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        apiUrl = data['apiUrl'] ?? '';
        apiKey = data['apiKey'] ?? '';
      }
      _configLoaded = true;
    } catch (_) {}
  }

  static Future<String> correctText(String text) async {
    final String inputText = text;
    await _loadConfig();

    try {
      final dio = Dio();
      final response = await dio.post(
        '$apiUrl?key=$apiKey',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text":
                      """Corrige uniquement les fautes de grammaire et d'orthographe dans ce texte en français,
                      sans modifier son style. Si le texte est déjà correct, retourne-le exactement tel quel.
                      Si le texte n'est pas en français, traduis-le en français en conservant autant que possible son sens et son style. 
                      N'ajoute aucune explication, aucun commentaire, aucune mise en forme ni aucun autre texte. 
                      Retourne uniquement le texte français corrigé, traduit ou inchangé: $inputText"""
                }
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        String correctedText =
            response.data["candidates"][0]["content"]["parts"][0]["text"];
        return correctedText;
      } else {
        return "Erreur lors de la correction.";
      }
    } on DioException catch (_) {
      return "Erreur lors de la correction.";
    } catch (e) {
      return "Erreur lors de la correction.";
    }
  }
}
