import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../core/ai_service.dart';
import '../core/location_service.dart';
import 'result_screen.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  // 🔑 استخدام .broadcast() يحل مشكلة الـ Stream المعروضة بالكامل
  final StreamController<int> selected = StreamController<int>.broadcast();

  // قوائم الوجبات للتجديد المستمر
  final List<List<String>> _mealSets = [
    [
      'شاورما 🌯',
      'برجر 🍔',
      'بيتزا 🍕',
      'كباب 🍢',
      'سوشي 🍣',
      'سلته فحسة 🍲',
      'مندي 🍗',
      'باستا 🍝',
    ],
    [
      'عقدة دجاج 🥘',
      'مظبي 🍗',
      'مشروبات باردة 🧋',
      'فطيرة ملواح 🫓',
      'بروست 🍗',
      'كريب وشوكولاتة 🥞',
      'زربيان 🍲',
      'فتة تمر 🍯',
    ],
    [
      'شيش طاووق 🍢',
      'ساندويش تونة 🥪',
      'مأكولات بحرية 🐟',
      'تاكو 🌮',
      'نودلز 🍜',
      'دجاج شواية 🍗',
      'معصوب 🍌',
      'مطبوخ خضار 🥦',
    ],
  ];

  int _currentSetIndex = 0;
  bool _isLoadingRestaurants = false;

  // 📝 جمل انتظار متغيرة أثناء جلب المطاعم
  final List<String> _loadingMessages = [
    'جاري البحث عن أفضّـل المطاعم بالقرب منك... 🧭',
    'نحلل تقييمات وجدة المطاعم للوجبة المختارة... 🌟',
    'لحظات ونجهز لك الخريطة والتفاصيل... 📍',
    'صبرك علينا، الوجبة المحظوظة بدها مطعم صح... 😋',
  ];
  int _currentMessageIndex = 0;
  Timer? _loadingTimer;

  List<String> get currentItems => _mealSets[_currentSetIndex];

  void _startLoadingTimer() {
    _currentMessageIndex = 0;
    _loadingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
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
    selected.close(); // تنظيف الـ StreamController عند الخروج
    _loadingTimer?.cancel();
    super.dispose();
  }

  void _spinWheel() {
    final randomIndex = Fortune.randomInt(0, currentItems.length);
    selected.add(randomIndex);

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _showResultDialog(currentItems[randomIndex]);
    });
  }

  void _refreshWheelItems() {
    setState(() {
      _currentSetIndex = (_currentSetIndex + 1) % _mealSets.length;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تجديد خيارات العجلة! 🔄',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Future<void> _fetchRestaurantsForWinningMeal(String mealName) async {
    Navigator.pop(context); // إغلاق الـ Dialog

    setState(() {
      _isLoadingRestaurants = true;
    });

    _startLoadingTimer(); // تشغيل مؤقت الجمل التفاعلية

    final location = await LocationService.getCurrentLocation();

    // إرسال الوجبة للذكاء الاصطناعي يجيب مطاعمها
    final data = await AIService.getStructuredRecommendation(
      "الوجبة المختارة هي: $mealName",
      userLocation: location,
    );

    _loadingTimer?.cancel(); // إيقاف المؤقت فور استلام البيانات

    if (!mounted) return;

    setState(() {
      _isLoadingRestaurants = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(data: data)),
    );
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 الوجبة المحظوظة!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'خلاص لا تحتار، هذا نصيبك اليوم! 😉',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _fetchRestaurantsForWinningMeal(result),
                  icon: const Icon(Icons.restaurant, size: 20),
                  label: const Text(
                    'أين أجد هذه الوجبة؟ 🍽️',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إغلاق ✖️',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'عجلة الحظ 🎯',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.deepOrange,
              size: 28,
            ),
            tooltip: 'تجديد الوجبات',
            onPressed: _refreshWheelItems,
          ),
        ],
      ),
      body: _isLoadingRestaurants
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.deepOrange),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _loadingMessages[_currentMessageIndex],
                      key: ValueKey<int>(_currentMessageIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'اترك القرار للعجلة! 🎡',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _refreshWheelItems,
                        child: const Text(
                          '(جدّد القائمة 🔄)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 320,
                    child: FortuneWheel(
                      selected: selected.stream,
                      animateFirst: false,
                      items: [
                        for (var item in currentItems)
                          FortuneItem(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: FortuneItemStyle(
                              color: currentItems.indexOf(item) % 2 == 0
                                  ? Colors.deepOrange
                                  : Colors.amber.shade700,
                              borderWidth: 2,
                              borderColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _spinWheel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'دَوّر العجلة 🚀',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
