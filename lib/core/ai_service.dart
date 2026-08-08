import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // ملاحظة: يمكنك وضع API Key الخاص بك هنا لاحقاً
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// إرسال الإجابات للذكاء الاصطناعي وتحليلها لإعطاء اقتراح وجبة ذكي
  static Future<String> getFoodRecommendation(List<String> userAnswers) async {
    final prompt =
        '''
أنت مساعد ذكي متخصص في الأكل والوجبات باسم "محتار".
المستخدم أجاب على الأسئلة التالية بخصوص ما يريد أكله اليوم:
${userAnswers.join("\n")}

بناءً على إجاباته وتحليلك الذكي لمزاجه وميزانيته:
1. اقترح عليه وجبة محددة ومناسبة جداً لمزاجه.
2. اقترح نوع المطعم أو اسم مطعم مشهور يقدمها.
3. أعطه سبب الاقتراح بأسلوب لطيف، مشجع، وبلهجة خفيفة وممتعة.
اجعل الإجابة مختصرة ومرتبة في نقاط بأسلوب ممتع.
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text =
            data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        return 'حدث خطأ في التواصل مع حبيبنا "محتار الذكي"، جرب مرة ثانية! 🍕';
      }
    } catch (e) {
      return 'تأكد من اتصالك بالإنترنت ليعطيك "محتار" أحسن اقتراح! 🌐';
    }
  }
}
