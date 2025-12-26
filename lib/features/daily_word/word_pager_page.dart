import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:my_app/core/constants/app_colors.dart';
import 'package:my_app/shared/styles/text_styles.dart';

import 'package:my_app/services/daily_word_service.dart';

class WordPagerPage extends StatelessWidget {
  static const routeName = '/words';

  const WordPagerPage({super.key});

  /// 오늘 날짜 키 생성 (예: 20251119)
  String _todayKey() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}';
  }

  /// <pink> 태그 변환
  String htmlProcessed(String raw) {
    return raw
        .replaceAll('<pb>', '<span style="color:#EA6AA3; font-weight:bold;">')
        .replaceAll('</pb>', '</span>')
        .replaceAll('<p>', '<span style="color:#EA6AA3;">')
        .replaceAll('</p>', '</span>');
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayKey();
    final dailyWordService = DailyWordService(); // ⭐ 서비스 사용

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder(
          future: dailyWordService.getDailyWord(today),
          builder: (context, snapshot) {
            // 로딩
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            // 오류
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '데이터 불러오기 실패 🥲\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              );
            }

            // 데이터 없음 (DB 자체가 비었을 때)
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  '오늘의 단어가 아직 없어요.\n($today)',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
              );
            }

            // 단어 데이터
            final word = snapshot.data!;
            final title = word.title;
            final description = word.description;
            final imageUrl = word.imageUrl;

            final htmlBody = htmlProcessed(description);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      shadows: [
                        Shadow(
                          color: AppColors.textcolor02.withOpacity(0.05),
                          offset: const Offset(5, 5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Html(
                      data: htmlBody,
                      style: {"body": Style.fromTextStyle(AppTextStyles.body)},
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (imageUrl != null && imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        // color: Colors.black26,
                        // padding: const EdgeInsets.all(8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                    child: CircularProgressIndicator(
                                      value: progress.progress,
                                      color: Colors.white70,
                                    ),
                                  ),
                              errorWidget: (_, __, ___) =>
                                  const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                /// ---------------- 광고 영역 ----------------
                Container(
                  height: 50, // ⭐ 광고 높이
                  width: double.infinity, // ⭐ 좌우 풀
                  color: const Color.fromARGB(
                    255,
                    255,
                    70,
                    70,
                  ), // 테스트용 (나중에 제거)
                  alignment: Alignment.center,
                  child: const Text(
                    '광고영역',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
