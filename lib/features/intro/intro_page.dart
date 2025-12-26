import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_html/flutter_html.dart';

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
  String? _titleHtml;
  String? _subtitleHtml;
  String? _imageUrl;

  bool _loading = true;
  Timer? _timer;

  /// HTML 태그 변환
  String htmlProcessed(String raw) {
    return raw
        // 파랑
        .replaceAll('<b>', '<span style="color:#7AD7F0;">')
        .replaceAll('</b>', '</span>')
        // 파랑 + 볼드
        .replaceAll('<bb>', '<span style="color:#7AD7F0; font-weight:bold;">')
        .replaceAll('</bb>', '</span>')
        // 핑크 + 볼드
        .replaceAll('<pb>', '<span style="color:#EA6AA3; font-weight:bold;">')
        .replaceAll('</pb>', '</span>');
  }

  @override
  void initState() {
    super.initState();
    _loadIntro();
  }

  Future<void> _loadIntro() async {
    try {
      final res = await Supabase.instance.client
          .from('app_intro')
          .select()
          .limit(1)
          .single();

      setState(() {
        _titleHtml = htmlProcessed(res['title'] ?? '');
        _subtitleHtml = htmlProcessed(res['subtitle'] ?? '');
        _imageUrl = res['image_url'];
        _loading = false;
      });

      _startTimer();
    } catch (_) {
      // fallback
      setState(() {
        _titleHtml = htmlProcessed('나도 예전엔<br>오나전 멋진');
        _subtitleHtml = htmlProcessed('<pb>X세대</pb>였었지..');
        _imageUrl = null;
        _loading = false;
      });

      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, WordPagerPage.routeName);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 110),

          /// ================= 텍스트 영역 =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 55),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 메인 문구
                Html(
                  data: _titleHtml!,
                  style: _introHtmlStyle(AppTextStyles.introMain),
                ),

                const SizedBox(height: 4),

                /// 서브 문구
                Html(
                  data: _subtitleHtml!,
                  style: _introHtmlStyle(AppTextStyles.introSub),
                ),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.07),

          /// ================= 이미지 영역 =================
          Padding(
            // 👇 여기만 따로 조절
            padding: const EdgeInsets.symmetric(horizontal: 25), // or 10, 20
            child: Center(child: _buildImage(context)),
          ),
        ],
      ),
    );
  }

  /// HTML → Flutter Text 느낌으로 만드는 핵심 스타일
  Map<String, Style> _introHtmlStyle(TextStyle base) {
    final double effectiveLineHeight = base.height ?? 1.15;

    return {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(base.fontSize ?? 16),
        fontWeight: base.fontWeight,
        color: base.color,
        lineHeight: LineHeight(effectiveLineHeight), // ✅ 단일 진실 사용
        whiteSpace: WhiteSpace.normal,
      ),
      'p': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        lineHeight: LineHeight(effectiveLineHeight),
      ),
      'span': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
      'br': Style(display: Display.block, margin: Margins.only(bottom: 0)),
    };
  }

  /// 이미지 fallback 포함
  Widget _buildImage(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 1;

    if (_imageUrl == null || _imageUrl!.isEmpty) {
      return Image.asset(
        'assets/images/mainCharacter.png',
        width: width,
        fit: BoxFit.contain,
      );
    }

    return Image.network(
      _imageUrl!,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          'assets/images/mainCharacter.png',
          width: width,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
