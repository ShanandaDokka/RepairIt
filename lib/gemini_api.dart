import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiApi {
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  GeminiApi();

  Future<String?> fetchData(String text) async {
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text(text)];
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }
}
