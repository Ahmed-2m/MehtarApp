import 'package:flutter/material.dart';
import 'dart:async'; // 👈 إضافة الاستيراد اللازم للمؤقت
import '../core/ai_service.dart';
import 'result_screen.dart';
import '../core/location_service.dart';
import 'wheel_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final List<String> _userAnswers = [];
  bool _isLoading = false;

  // 📝 قائمة الجمل المتنوعة للتحميل
  final List<String> _loadingMessages = [
    'جاري تحليل المزاج واختيار أشهى الوجبات... 🧠🍕',
    'نبحث لك عن مطاعم قريبة ورهيبة... 🧭✨',
    'ثواني وبنضبطك باقتراح ينهي حيرتك... ⏳😋',
    'جاري فحص قائمة الطعام الذكية... 📋🧐',
    'صبرك علينا، الأكل الطيب يستاهل الانتظار... 🍲🔥',
    'تقريباً انتهينا، جهز نفسك لوليمة... 🎉🍗',
  ];

  int _currentMessageIndex = 0;
  Timer? _loadingTimer; // 👈 متغير حفظ المؤقت

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
        'مع الشباب / الصبايا 🥳',
        'جمعة أهل وفيلم 🎬',
      ],
    },
  ];

  // 📝 دالة لبدء التبديل التلقائي بين الجمل
  void _startLoadingTimer() {
    _currentMessageIndex = 0;
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel(); // إيقاف المؤقت عند الخروج
    super.dispose();
  }

  void _answerQuestion(String selectedOption) async {
    _userAnswers.add(
      'سؤال: ${_questions[_currentQuestionIndex]['question']} - الإجابة: $selectedOption',
    );

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // 📍 1. إظهار نافذة استئذان وتوضيح سبب طلب الموقع للمستخدم
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.deepOrange, size: 28),
              SizedBox(width: 8),
              Text(
                'تحديد موقعك الجغرافي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'نحتاج للوصول إلى موقعك الحالي لإظهار المطاعم الحقيقية والقريبة منك في منطقتك بدقة 📍.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'موافق، ابدأ البحث 🚀',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      setState(() {
        _isLoading = true;
      });

      // 📝 بدء التبديل بين الجمل أثناء انتظار استجابة الـ API
      _startLoadingTimer();

      // 📍 2. جلب الموقع الجغرافي الحقيقي للمستخدم
      final userLocation = await LocationService.getCurrentLocation();

      // إرسال الإجابات والموقع للذكاء الاصطناعي
      final recommendationData = await AIService.getStructuredRecommendation(
        _userAnswers,
        userLocation: userLocation,
      );

      // 📝 إيقاف المؤقت فور استلام البيانات
      _loadingTimer?.cancel();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(data: recommendationData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentQuestionIndex];
    final double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'محتار 🤔',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.stars_rounded,
              color: Colors.deepOrange,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WheelScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange,
                      strokeWidth: 5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _loadingMessages[_currentMessageIndex],
                        key: ValueKey<int>(
                          _currentMessageIndex,
                        ), // مفتاح متغيّر لتحفيز حركة AnimatedSwitcher
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF374151),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // شريط التقدم
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'السؤال ${_currentQuestionIndex + 1} من ${_questions.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // نص السؤال
                  Text(
                    currentQ['question'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // الخيارات بكروت تفاعلية
                  Expanded(
                    child: ListView.builder(
                      itemCount: (currentQ['options'] as List).length,
                      itemBuilder: (context, index) {
                        final option = currentQ['options'][index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () => _answerQuestion(option),
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
