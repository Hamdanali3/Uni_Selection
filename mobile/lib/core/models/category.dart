class Category {
  final String id;
  final String slug;
  final String name;
  final String? iconName;
  final String? description;

  const Category({
    required this.id,
    required this.slug,
    required this.name,
    this.iconName,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      iconName: json['icon_name'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'icon_name': iconName,
    'description': description,
  };
}
