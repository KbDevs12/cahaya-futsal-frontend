import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../storage/token_storage.dart';

class FcmService {
  FcmService({required Dio dio, required TokenStorage tokenStorage})
    : _dio = dio,
      _tokenStorage = tokenStorage;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _bookingTapController =
      StreamController<String>.broadcast();

  bool _initialized = false;
  String? _initialBookingId;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  static const AndroidNotificationChannel _paymentChannel =
      AndroidNotificationChannel(
        'payment_status',
        'Status Pembayaran',
        description: 'Notifikasi konfirmasi dan penolakan pembayaran booking.',
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _adminBookingChannel =
      AndroidNotificationChannel(
        'new_booking',
        'Booking Baru',
        description: 'Notifikasi booking/order baru untuk admin.',
        importance: Importance.high,
      );

  Stream<String> get bookingTapStream => _bookingTapController.stream;

  String? takeInitialBookingId() {
    final value = _initialBookingId;
    _initialBookingId = null;
    return value;
  }

  Future<void> initializeAndRegister() async {
    if (!_initialized) {
      await _requestPermission();
      await _setupLocalNotifications();
      await _setupMessageHandlers();
      _initialized = true;
    }

    await registerCurrentToken();
  }

  Future<void> registerCurrentToken() async {
    final jwt = await _tokenStorage.readToken();
    if (jwt == null || jwt.isEmpty) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await _sendTokenToBackend(token);
    }

    _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) async {
          final activeJwt = await _tokenStorage.readToken();
          if (activeJwt == null || activeJwt.isEmpty) return;
          await _sendTokenToBackend(newToken);
        });
  }

  Future<void> unregisterCurrentToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await _dio.delete<Map<String, dynamic>>(
        '/user/fcm-token',
        data: {'token': token, 'platform': defaultTargetPlatform.name},
      );
    } catch (_) {
      // Logout must not be blocked by a best-effort token cleanup.
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _bookingTapController.close();
  }

  Future<void> _sendTokenToBackend(String token) async {
    await _dio.post<Map<String, dynamic>>(
      '/user/fcm-token',
      data: {'token': token, 'platform': defaultTargetPlatform.name},
    );
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final bookingId = response.payload;
        if (bookingId != null && bookingId.isNotEmpty) {
          _bookingTapController.add(bookingId);
        }
      },
    );

    final androidNotifications = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidNotifications?.createNotificationChannel(_paymentChannel);
    await androidNotifications?.createNotificationChannel(_adminBookingChannel);
  }

  Future<void> _setupMessageHandlers() async {
    _messageSubscription ??= FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    _openedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageTap,
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    _initialBookingId = _bookingIdFrom(initialMessage);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final bookingId = message.data['booking_id']?.toString();
    final channel = message.data['type'] == 'new_booking'
        ? _adminBookingChannel
        : _paymentChannel;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: bookingId,
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    final bookingId = _bookingIdFrom(message);
    if (bookingId != null && bookingId.isNotEmpty) {
      _bookingTapController.add(bookingId);
    }
  }

  String? _bookingIdFrom(RemoteMessage? message) {
    final bookingId = message?.data['booking_id']?.toString();
    if (bookingId == null || bookingId.isEmpty) return null;
    return bookingId;
  }
}
