class PostModel {
  final String title;
  final String description;
  final List<String> imageUrls; // 이미지 URL 리스트
  final List<String> tags; // 태그 리스트
  final String uploader; // 업로더 이메일 또는 이름

  // 생성자
  PostModel({
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.tags,
    required this.uploader,
  });

  // factory 메서드
  factory PostModel.fromFirestore(Map<String, dynamic> data) {
    return PostModel(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      uploader: data['uploader'] ?? 'Unknown',
    );
  }

  // 데이터를 Firestore에 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'tags': tags,
      'uploader': uploader,
    };
  }

  // 첫 번째 이미지 URL을 반환하는 computed property
  String? get firstImageUrl {
    if (imageUrls.isNotEmpty) {
      return imageUrls.first;
    }
    return null;
  }
}
