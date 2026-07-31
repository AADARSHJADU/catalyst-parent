import 'package:catalyst/app/routes/app_pages.dart';
import 'package:catalyst/core/network/api_client.dart';
import 'package:catalyst/core/services/fcm_service.dart';
import 'package:catalyst/data/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF141416),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Bootstrap services ───────────────────────────────────────────────────
  // 1. Local storage (token etc.)
  final storage = await StorageService.init();
  Get.put<StorageService>(storage, permanent: true);

  // 2. Dio HTTP client
  ApiClient.instance.init(storage);

  // 3. Firebase + FCM
  await Firebase.initializeApp();
  await FcmService.instance.init();

  runApp(const CatalystApp());
}
