import 'package:flutter/material.dart';
import 'package:daily_word_admin/supabase/supabase.dart';
import 'push_log_detail_page.dart';

class PushLogPage extends StatelessWidget {
  const PushLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseManager.client;

    return Scaffold(
      appBar: AppBar(title: const Text("알림 로그")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supabase
            .from('push_logs')
            .select()
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          // 로딩 상태
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 상태
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "불러오기 오류: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 빈 상태
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("알림 로그가 없습니다."));
          }

          final logs = snapshot.data!;

          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = logs[index];

              final mode = log['mode'] ?? 'unknown';
              final title = log['title'] ?? '(제목 없음)';
              final ts = log['created_at'] ?? '';
              final success = log['success_count'] ?? 0;
              final fail = log['fail_count'] ?? 0;

              return ListTile(
                title: Text("[$mode] $title"),
                subtitle: Text(
                  "$ts\n성공: $success / 실패: $fail",
                  style: const TextStyle(height: 1.4),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PushLogDetailPage(log: log),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
