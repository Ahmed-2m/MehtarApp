import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class AIService {
  static String get _apiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

  static Future<Map<String, dynamic>> getStructuredRecommendation(
    dynamic answers, {
    dynamic userLocation,
  }) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final randomSeed = DateTime.now().millisecondsSinceEpoch;

    // 📍 1. معالجة الموقع ديناميكياً 100% بدون قيم افتراضية للمدن
    String locationText = "الموقع الحالي المباشر للمستخدم";

    if (userLocation is Position) {
      locationText =
          "Exact Coordinates: (Latitude: ${userLocation.latitude}, Longitude: ${userLocation.longitude})";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          userLocation.latitude,
          userLocation.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String district = place.subLocality ?? place.locality ?? '';
          String city = place.administrativeArea ?? place.country ?? '';
          String resolvedName = "$district، $city".trim();

          if (resolvedName.startsWith("،")) {
            resolvedName = resolvedName.substring(1).trim();
          }

          if (resolvedName.isNotEmpty) {
            locationText += " - Area Name: ($resolvedName)";
          }
        }
      } catch (e) {
        log("خطأ في تحديد اسم المنطقة عبر الجيوكودينق: $e");
      }
    } else if (userLocation is String && userLocation.isNotEmpty) {
      locationText = userLocation;
    }

    log("📍 الموقع المعتمد والمرسل للـ AI: $locationText");

    // 🔴 2. الـ Prompt الشديد الصرامة المعتمد على موقع المستخدم المباشر
    final promptText =
        '''
You are a highly accurate local food recommendation expert for YEMEN.

CRITICAL LOCATION CONSTRAINTS:
1. Exact User Current Location: "$locationText"
2. STRICT RULE: You MUST ONLY suggest authentic restaurants physically located IN the EXACT city/district corresponding to the provided location coordinates or area name.
3. ABSOLUTELY FORBIDDEN: Do NOT suggest restaurants from any other city or governorate (e.g., IF the user is in Taiz, DO NOT include Sana'a or Aden restaurants. IF the user is in Aden, DO NOT include Sana'a restaurants).
4. NEVER offer restaurants from outside Yemen.

User preferences / meal request: $answers
Seed: $randomSeed

Respond ONLY with raw valid JSON matching this exact structure:
{
  "meals": [
    {
      "name": "اسم الوجبة بالعربي",
      "description": "وصف قصير يشهي الوجبة",
      "image_url": "https://images.unsplash.com/photo-...",
      "restaurants": [
        {
          "name": "اسم مطعم حقيقي موجود بالقرب من موقع المستخدم المباشر",
          "location": "اسم الشارع والحي القريب من موقع المستخدم",
          "image_url": "https://images.unsplash.com/photo-..."
        }
      ]
    }
  ]
}
No markdown formatting, no explanatory text, raw JSON only.
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-chat',
          'temperature':
              0.1, // 👈 درجة حرارة منخفضة تمنع العشوائية والخلط بين المدن
          'messages': [
            {
              'role': 'system',
              'content':
                  'You output raw valid JSON only for Yemeni food recommendations. Strictly respect the exact GPS coordinates and location provided and never cross-mix cities.',
            },
            {'role': 'user', 'content': promptText},
          ],
        }),
      );

      log("API Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        String rawContent = decoded['choices'][0]['message']['content'];

        final RegExp jsonRegex = RegExp(r'\{.*\}', dotAll: true);
        final match = jsonRegex.firstMatch(rawContent);

        if (match != null) {
          final cleanJson = match.group(0)!;
          return jsonDecode(cleanJson);
        } else {
          log("JSON Regex Parsing Failed");
          return _getFallbackData();
        }
      } else {
        log("HTTP Error: ${response.statusCode}");
        return _getFallbackData();
      }
    } catch (e, stack) {
      log("AIService Exception: $e");
      log("Stacktrace: $stack");
      return _getFallbackData();
    }
  }

  static Map<String, dynamic> _getFallbackData() {
    return {
      "meals": [
        {
          "name": "وجبة محلية 🍲",
          "description": "وجبة شهية ومميزة من أقرب مطعم في منطقتك",
          "image_url":
              "https://images.unsplash.com/photo-1547592166-23ac45744acd",
          "restaurants": [
            {
              "name": "مطعم بلدي قريب",
              "location": "حسب موقعك الحالي",
              "image_url":
                  "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4",
            },
          ],
        },
      ],
    };
  }
}
