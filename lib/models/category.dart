// Main Category Model
class MainCategory {
  final int id;
  final String name;
  final String slug;
  final int priority;
  final String? seoTitle;
  final String? seoDescription;

  MainCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.priority,
    this.seoTitle,
    this.seoDescription,
  });

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    return MainCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      slug: json['slug'] ?? '',
      priority: json['priority'] ?? 0,
      seoTitle: json['seo_title'],
      seoDescription: json['seo_description'],
    );
  }
}

// Product Category Model
class ProductCategory {
  final int id;
  final String name;
  final String slug;
  final int mainCategoryId;
  final int priority;
  final String? image;
  final String? seoTitle;
  final String? seoDescription;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.mainCategoryId,
    required this.priority,
    this.image,
    this.seoTitle,
    this.seoDescription,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      slug: json['slug'] ?? '',
      mainCategoryId: json['main_category_id'],
      priority: json['priority'] ?? 0,
      image: json['image'],
      seoTitle: json['seo_title'],
      seoDescription: json['seo_description'],
    );
  }
}

// Product SubCategory Model
class ProductSubCategory {
  final int id;
  final String name;
  final String slug;
  final int productCategoryId;
  final int mainCategoryId;
  final String? seoTitle;
  final String? seoDescription;

  ProductSubCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.productCategoryId,
    required this.mainCategoryId,
    this.seoTitle,
    this.seoDescription,
  });

  factory ProductSubCategory.fromJson(Map<String, dynamic> json) {
    return ProductSubCategory(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      productCategoryId: json['product_category_id'],
      mainCategoryId: json['main_category_id'],
      seoTitle: json['seo_title'],
      seoDescription: json['seo_description'],
    );
  }
}
