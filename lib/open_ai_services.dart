import 'dart:convert';
import 'package:voice_assistent/secrate_data.dart'; // keep your geminiApiKey here
import 'package:http/http.dart' as http;

class GeminiService {
  final List<Map<String, String>> messages = [];

  /// Main handler
  Future<String> handlePrompt(String prompt) async {
    try {
      // Check if user wants an image/art
      final isArt = await isArtPromptAPI(prompt);

      if (isArt) {
        final res = await geminiImageAPI(prompt);
        return res;
      } else {
        final res = await geminiChatAPI(prompt);
        return res;
      }
    } catch (e) {
      return e.toString();
    }
  }

  /// Detects if the prompt is asking for image generation
  Future<bool> isArtPromptAPI(String prompt) async {
    final res = await geminiChatAPI(
      'Does this message want to generate an AI picture, image, art, or anything similar? $prompt . Simply answer with a yes or no.',
    );

    switch (res.toLowerCase().trim()) {
      case 'yes':
      case 'yes.':
        return true;
      default:
        return false;
    }
  }

  /// Chat Completion with Gemini
  Future<String> geminiChatAPI(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});

    try {
      final res = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$openAIAPIKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        // Gemini returns content differently from OpenAI
        final content =
            json['candidates'][0]['content']['parts'][0]['text'] ?? '';

        messages.add({'role': 'assistant', 'content': content});

        return content.trim();
      }
      return 'Error: ${res.statusCode} ${res.body}';
    } catch (e) {
      return e.toString();
    }
  }

  /// Image Generation (using Gemini's image endpoint)
  Future<String> geminiImageAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/imagegeneration:generateImage?key=$openAIAPIKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': {'text': prompt},
          'image': {'mimeType': 'image/png'},
        }),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);

        // Gemini returns base64 encoded images
        final base64Image = json['generatedImages'][0]['image']['data'];
        return "data:image/png;base64,$base64Image"; // you can show this in Flutter Image.memory
      }
      return 'Error: ${res.statusCode} ${res.body}';
    } catch (e) {
      return e.toString();
    }
  }
}
