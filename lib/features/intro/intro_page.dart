import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_app/features/daily_word/word_pager_page.dart';
import 'package:my_app/core/constants/app_colors.dart';
import 'package:my_app/shared/styles/text_styles.dart';

class IntroPage extends StatefulWidget {
  static const routeName = '/intro';
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, WordPagerPage.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start, // ⭐ 글씨 위로 배치
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),

                      // 첫 번째 문장
                      const Text(
                        "나도 예전엔\n오나전 멋진",
                        textAlign: TextAlign.left,
                        style: AppTextStyles.introMain,
                      ),

                      const SizedBox(height: 5),

                      // 두 번째 문장 → X세대(핑크) + 였었지..(파랑)
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "X세대",
                              style: AppTextStyles.introSub,
                            ),
                            TextSpan(
                              text: "였었지..",
                              style: AppTextStyles.introSub.copyWith(
                                color: AppColors.textcolor02,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.11,
                      ),

                      // 이미지 크게 + 중앙 정렬
                      Center(
                        child: Image.asset(
                          'assets/images/mainCharacter.png',
                          width: MediaQuery.of(context).size.width * 1, // ← 70%
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
