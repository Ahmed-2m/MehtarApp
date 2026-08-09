import 'package:flutter/material.dart';
import 'screens/quiz_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // 👈 تحميل الملف
  runApp(const MehtarApp());
}

class MehtarApp extends StatelessWidget {
  const MehtarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محتار',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      home: const QuizScreen(), // 👈 هنا التعديل المهم لفتح شاشة الأسئلة مباشرة
    );
  }
}
