import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_word.dart';

class DailyWordService {
  final supabase = Supabase.instance.client;

  Future<void> saveDailyWord(DailyWord word) async {
    await supabase.from('daily_words').insert(word.toMap());
  }

  Future<DailyWord?> getDailyWord(String date) async {
    final data = await supabase
        .from('daily_words')
        .select()
        .eq('date', date)
        .maybeSingle();

    if (data == null) return null;

    return DailyWord.fromMap(data);
  }

  Future<List<DailyWord>> getAllWords() async {
    final result = await supabase
        .from('daily_words')
        .select()
        .order('date_timestamp', ascending: false);

    return result.map<DailyWord>((row) => DailyWord.fromMap(row)).toList();
  }
}
