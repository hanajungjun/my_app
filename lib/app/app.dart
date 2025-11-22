import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/features/intro/intro_page.dart';
import 'package:my_app/features/daily_word/word_pager_page.dart';

class AppBootstrap {
  static Future<void> run() async {
    // ✅ 주인님 Supabase 프로젝트 설정
    await Supabase.initialize(
      url: 'https://rjevhsseixukhghfkozl.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJqZXZoc3NlaXh1a2hnaGZrb3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MDQ0NzQsImV4cCI6MjA3OTI4MDQ3NH0.pMPLn9QYg2RARl20FFiisUcKojOUOdY1_PS0kvxVx8Q',
    );

    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HJ Word App',
      debugShowCheckedModeBanner: false,
      initialRoute: IntroPage.routeName,
      routes: {
        IntroPage.routeName: (context) => const IntroPage(),
        WordPagerPage.routeName: (context) => const WordPagerPage(),
      },
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
    );
  }
}
