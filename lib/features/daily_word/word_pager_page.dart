import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_app/core/constants/app_colors.dart';
import 'package:my_app/shared/styles/text_styles.dart';

class WordPagerPage extends StatelessWidget {
  static const routeName = '/words';

  const WordPagerPage({super.key});

  /// 오늘 날짜 키 생성 (예: 20251119)
  String _todayKey() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayKey();
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: supabase
              .from('daily_words')
              .select()
              .eq('date', today)
              .limit(1),
          builder: (context, snapshot) {
            // 로딩 중
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            // 오류
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '데이터를 불러오지 못했어요 🥲\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              );
            }

            // 결과 없음
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  '오늘의 단어가 아직 등록되지 않았어요.\n($today)',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
              );
            }

            final data = snapshot.data!.first;
            final title = data['title'] ?? '제목 없음';
            final description = data['description'] ?? '';
            // ✅ Supabase 테이블 컬럼 이름: image_url
            final imageUrl = data['image_url'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // 🔥 이미지 표시
                if (imageUrl != null && imageUrl.toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 280,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 280,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('이미지 없음', style: AppTextStyles.bodyMuted),
                    ),
                  ),

                const SizedBox(height: 30),

                // 🔥 제목
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title,
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 설명 (스크롤 가능)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(description, style: AppTextStyles.body),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
