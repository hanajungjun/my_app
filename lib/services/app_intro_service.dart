import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_intro_model.dart';

class AppIntroService {
  final _client = Supabase.instance.client;

  Future<AppIntroModel?> fetchIntro() async {
    final res = await _client.from('appintro').select().limit(1).maybeSingle();

    if (res == null) return null;
    return AppIntroModel.fromJson(res);
  }
}
