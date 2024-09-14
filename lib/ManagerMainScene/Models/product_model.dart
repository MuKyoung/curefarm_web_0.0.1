class ProductModel {
  final String title;
  final String description;
  final List<String> tags;
  final List<String> imageUrls;

  ProductModel({
    required this.title,
    required this.description,
    required this.tags,
    required this.imageUrls,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data) {
    return ProductModel(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'tags': tags,
      'imageUrls': imageUrls,
    };
  }
}
