import 'package:catalyst/data/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Background message handler — MUST be a top-level function.
/// Runs in a separate isolate when app is terminated/background.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
  // Firebase Core is already initialized by the time this is called.
  // Add any background processing logic here if needed.
}

/// Handles all Firebase Messaging setup:
///   - Initialization
///   - Permission request
///   - Token fetch & upload to backend
///   - Foreground / background / terminated message handlers
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();

  /// Call once from main() after Firebase.initializeApp()
  Future<void> init() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Request permission (iOS asks a dialog, Android 13+ also needs it)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.notification?.title}');
      // TODO: show in-app notification or snackbar if needed
    });

    // App opened from a notification (background → foreground)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification tapped: ${message.data}');
      // TODO: navigate based on message.data payload
    });

    // Check if app was launched from a terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App launched from notification: ${initialMessage.data}');
    }

    // Listen for token refresh — update backend whenever token changes
    _messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  /// Fetch the current FCM token and send it to the backend.
  /// Call this after a successful login or register.
  Future<void> uploadTokenToBackend() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM] Token: $token');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] Failed to upload token: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _authService.updateFcmToken(token);
      debugPrint('[FCM] Token sent to backend successfully');
    } catch (e) {
      // Non-critical — don't crash the app if this fails
      debugPrint('[FCM] Failed to send token to backend: $e');
    }
  }
}
