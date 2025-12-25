class AppIntroModel {
  final String mainText1;
  final String mainText2;
  final String? imageUrl;

  AppIntroModel({
    required this.mainText1,
    required this.mainText2,
    this.imageUrl,
  });

  factory AppIntroModel.fromJson(Map<String, dynamic> json) {
    return AppIntroModel(
      mainText1: json['main_text_1'] ?? '',
      mainText2: json['main_text_2'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}
