import 'package:flutter/material.dart';
import 'screens/quiz_screen.dart';

void main() {
  runApp(const MehtarApp());
}

class MehtarApp extends StatelessWidget {
  const MehtarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محتار',
      debugShowCheckedModeBanner: false, // لإخفاء شريط التجربة الإعلاني
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(
          0xFFF8F9FA,
        ), // لون خلفية مريح وأنيق
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'تطبيق محتار 🍕',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
