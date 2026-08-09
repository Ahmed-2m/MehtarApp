import 'dart:developer';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// جلب موقع المستخدم الفعلي والحي المباشر عبر الـ GPS بدون تثبيت أي نص يدوي
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // 1. التأكد من تشغيل الـ GPS في هاتف المستخدم
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log("GPS معطل في جهاز المستخدم");
        return null;
      }

      // 2. فحص وطلب إذن الوصول للموقع عند فتح التطبيق
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log("تم رفض إذن الموقع من قبل المستخدم");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log("إذن الموقع مرفوض دائماً من إعدادات النظام");
        return null;
      }

      // 3. جلب الإحداثيات الحقيقية المباشرة بجودة عالية ودقة للمستخدم الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // 👈 متوافق مع كافة الإصدارات
        timeLimit: const Duration(seconds: 12),
      );

      log(
        "📍 الموقع الحقيقي المباشر للمستخدم: Lat: ${position.latitude}, Long: ${position.longitude}",
      );
      return position; // إرجاع موقع المستخدم الحقيقي الديناميكي
    } catch (e) {
      log("خطأ في جلب موقع المستخدم: $e");
      return null;
    }
  }
}
