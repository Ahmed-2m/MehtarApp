import 'package:flutter/material.dart';
import '../core/ai_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final List<String> _userAnswers = [];
  bool _isLoading = false;

  // الأسئلة الديناميكية للتطبيق
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'وش الجو اللي يدور في راسك الحين؟ 🤔',
      'options': [
        'أبي شي ثقيل ومشبع 🍔',
        'خفيف ولطيف 🥗',
        'مشويات وجو جمر 🍢',
        'شي حار وسريع 🍕',
      ],
    },
    {
      'question': 'كم الميزانية التقريبية لوجبتك اليوم؟ 💰',
      'options': [
        'اقتصادي (أقل من 30 ر.س) 💵',
        'متوسط (30 - 60 ر.س) 💳',
        'راهي ودلع نفسك (60+ ر.س) 👑',
      ],
    },
    {
      'question': 'من بيشاركك الوجبة؟ 👥',
      'options': [
        'لحالي ومروق 🎧',
        'مع الشباب / الشبابيك 🥳',
        'جمعة أهل وفيلم 🎬',
      ],
    },
  ];

  void _answerQuestion(String selectedOption) async {
    _userAnswers.add(
      'سؤال: ${_questions[_currentQuestionIndex]['question']} - الإجابة: $selectedOption',
    );

    // إذا بقي أسئلة ننتقل للسؤال التالي
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // انتهت الأسئلة! نرسل الأجوبة للذكاء الاصطناعي
      setState(() {
        _isLoading = true;
      });

      final recommendation = await AIService.getFoodRecommendation(
        _userAnswers,
      );

      if (!mounted) return;

      // الانتقال لشاشة النتيجة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(recommendation: recommendation),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'محتار 🤔',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'جاري تحليل مزاجك واختيار أحسن وجبة... 🧠🍕',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // مؤشر التقدم (Progress Indicator)
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey[200],
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 30),

                  // نص السؤال
                  Text(
                    currentQ['question'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // خيارات الإجابة
                  ...(currentQ['options'] as List<String>).map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 2,
                        ),
                        onPressed: () => _answerQuestion(option),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
