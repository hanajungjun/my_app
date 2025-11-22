class DailyWord {
  final String id;
  final String date;
  final DateTime dateTimestamp;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime updatedAt;

  DailyWord({
    required this.id,
    required this.date,
    required this.dateTimestamp,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.updatedAt,
  });

  factory DailyWord.fromMap(Map<String, dynamic> map) {
    return DailyWord(
      id: map['id'],
      date: map['date'],
      dateTimestamp: DateTime.parse(map['date_timestamp']),
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'],
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'date_timestamp': dateTimestamp.toIso8601String(),
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
