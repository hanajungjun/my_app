import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:my_app/app/app.dart';
import 'package:my_app/supabase/supabase.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 [백그라운드 메시지] ${message.messageId}");
}

final FlutterLocalNotificationsPlugin localNoti =
    FlutterLocalNotificationsPlugin();

String? pendingFcmToken;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;

  // -----------------------------------------------------
  // 🔥🔥 iOS Foreground 알림 표시 허용 (핵심 추가)
  // -----------------------------------------------------
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // -----------------------------------------------------

  // 권한 요청
  final settings = await messaging.requestPermission(
    alert: true,
    sound: true,
    badge: true,
  );
  print("📌 Notification permission: ${settings.authorizationStatus}");

  // 🔥 토큰 요청 (시뮬레이터든 실기기든 무조건 시도)
  String? token;
  try {
    token = await messaging.getToken();
    print("🔥 [FCM Token] $token");
  } catch (e) {
    print("🚫 FCM 토큰 요청 실패 (시뮬레이터일 가능성 높음): $e");
  }

  pendingFcmToken = token;

  // APNS 토큰도 시도
  try {
    final apns = await messaging.getAPNSToken();
    print("🍏 [APNS Token] $apns");
  } catch (e) {
    print("🚫 APNS 토큰 요청 실패: $e");
  }

  // 토큰 갱신
  messaging.onTokenRefresh.listen((t) {
    print("🔄 [토큰 갱신] $t");
    pendingFcmToken = t;
    _trySaveToken();
  });

  // 🔥 Supabase 초기화
  await AppBootstrap.run();
  print("🚀 Supabase 초기화 완료됨");

  // 토큰 저장 시도
  _trySaveToken();

  runApp(const MyApp());
}

Future<void> _trySaveToken() async {
  if (pendingFcmToken == null) return;

  final client = SupabaseManager.client;

  try {
    await client.from("fcm_tokens").upsert({
      "token": pendingFcmToken,
    }, onConflict: "token");
    print("📌 토큰 Supabase 저장 성공!");
  } catch (e) {
    print("❌ 토큰 저장 실패: $e");
  }
}
