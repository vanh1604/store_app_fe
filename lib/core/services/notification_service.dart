import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanh_store_app/core/config/global_variables.dart';
import 'package:vanh_store_app/features/orders/screens/order_screen.dart';

/// Top-level background message handler – must NOT be a class member.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message received: ${message.notification?.title}');
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channelId = 'high_importance_channel';
  static const _channelName = 'High Importance Notifications';
  static const _channelDesc = 'Thông báo sản phẩm, đơn hàng và cập nhật';

  /// Provide this key to MaterialApp.navigatorKey for in-app navigation.
  static final navigatorKey = GlobalKey<NavigatorState>();

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Call once after the user has logged in successfully.
  static Future<void> initialize() async {
    try {
      await _requestPermission();
      await _initLocalNotifications();

      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Device token: $token');
        await _registerTokenWithBackend(token);

        _messaging.onTokenRefresh.listen((newToken) {
          _registerTokenWithBackend(newToken);
        });
      }

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('[FCM] NotificationService.initialize error: $e');
    }
  }

  /// Call before clearing auth tokens on logout.
  static Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth-token');
      if (authToken == null) return;

      await http.delete(
        Uri.parse('$uri/api/notifications/remove-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (e) {
      debugPrint('[FCM] unregisterToken error: $e');
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleLocalNotificationTap(details.payload);
      },
    );

    // Create high-importance Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );

    // Do not show FCM default heads-up in foreground; we handle it ourselves.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
  }

  static Future<void> _registerTokenWithBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth-token');
      if (authToken == null) return;

      await http.post(
        Uri.parse('$uri/api/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
      );
      debugPrint('[FCM] Token registered with backend');
    } catch (e) {
      debugPrint('[FCM] _registerTokenWithBackend error: $e');
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] Notification tapped: ${message.data}');
    _navigateByType(message.data['type'] as String?);
  }

  static void _handleLocalNotificationTap(String? payload) {
    if (payload == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _navigateByType(data['type'] as String?);
    } catch (_) {}
  }

  static void _navigateByType(String? type) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (type == 'order_update') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderScreen()),
      );
    }
    // new_product / new_store: simply bring the app to foreground (no navigation needed)
  }
}
