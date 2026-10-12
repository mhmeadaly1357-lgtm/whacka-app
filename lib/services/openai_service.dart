import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  Future<String> getEmotionalResponse(String message) async {
    if (_apiKey.isEmpty) {
      return 'أضف مفتاح OpenAI API في متغيرات البيئة لتفعيل الذكاء الاصطناعي.';
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'أنت مساعد عربي متعاطف، ودود، ومفيد. قم بالرد باحترام ووضوح، واجعل الرد قصيراً ومريحاً.',
          },
          {'role': 'user', 'content': message},
        ],
        'temperature': 0.8,
        'max_tokens': 220,
      }),
    );

    if (response.statusCode != 200) {
      return 'حدث خطأ في الاتصال بخدمة الذكاء الاصطناعي.';
    }

    final decoded = jsonDecode(response.body);
    return decoded['choices'][0]['message']['content'] ??
        'لا يوجد رد متاح في الوقت الحالي.';
  }

  Future<String> getResponseByEmotion(String emotion, String message) async {
    final prompt = 'المستخدم يشعر بـ "$emotion". استجب بشكل دافئ، مُطمئن، ومؤيد.';
    return getEmotionalResponse('$prompt\n\n$message');
  }
}
