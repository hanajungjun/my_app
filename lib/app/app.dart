import 'package:flutter/material.dart';
import 'package:my_app/features/intro/intro_page.dart';
import 'package:my_app/features/daily_word/word_pager_page.dart';
import '../supabase/supabase.dart';

class AppBootstrap {
  static Future<void> run() async {
    // 🔥 Supabase 초기화
    await SupabaseManager.initialize();

    final supabase = SupabaseManager.client;

    // 🔐 관리자 자동 로그인
    if (supabase.auth.currentSession == null) {
      print("➡️ 관리자 자동 로그인 시도...");
      try {
        final res = await supabase.auth.signInWithPassword(
          email: "kodero@kakao.com",
          password: "0000",
        );
        print("🔐 관리자 로그인 성공: ${res.user?.email}");
      } catch (e) {
        print("❌ 관리자 로그인 실패: $e");
      }
    } else {
      print("🔐 이미 로그인됨");
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ⭐ navigatorKey 추가 (필수!!)
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HJ Communication',
      debugShowCheckedModeBanner: false,

      // ⭐ navigatorKey 연결
      navigatorKey: MyApp.navigatorKey,

      initialRoute: IntroPage.routeName,
      routes: {
        IntroPage.routeName: (context) => const IntroPage(),
        WordPagerPage.routeName: (context) => const WordPagerPage(),
      },
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
    );
  }
}
