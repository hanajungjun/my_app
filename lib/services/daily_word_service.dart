import 'package:my_app/supabase/supabase.dart';
import '../models/daily_word.dart';

class DailyWordService {
  final supabase = SupabaseManager.client;

  /// 🔥 저장 (항상 INSERT-only)
  Future<void> saveDailyWord(DailyWord word) async {
    final normalizedDate = DailyWord.normalizeDate(word.date);

    await supabase.from('daily_words').insert({
      ...word.toInsertMap(),
      'date': normalizedDate,
    });
  }

  /// 🔥 오늘 단어가 없으면 → 랜덤 1개 반환
  Future<DailyWord?> getDailyWord(String date) async {
    final today = DailyWord.normalizeDate(date);

    // 1) 오늘 단어 찾기
    final todayData = await supabase
        .from('daily_words')
        .select()
        .eq('date', today)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (todayData != null) {
      return DailyWord.fromMap(todayData);
    }

    // 2) 랜덤 조회
    final all = await supabase
        .from('daily_words')
        .select()
        .order('updated_at', ascending: false);

    if (all.isEmpty) return null;

    all.shuffle();
    return DailyWord.fromMap(all.first);
  }

  /// 🔥 전체 단어 리스트 (최신순)
  Future<List<DailyWord>> getAllWords() async {
    final result = await supabase
        .from('daily_words')
        .select()
        .order('updated_at', ascending: false);

    return result.map((r) => DailyWord.fromMap(r)).toList();
  }
}
