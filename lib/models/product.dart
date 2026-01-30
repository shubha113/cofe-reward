// Product Model
class Product {
  final int id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? hardwareInfo;
  final String? manualUrl;
  final String? datasheetUrl;
  final String? imageUrl;
  final List<ProductImage> images;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductAttribute> attributes;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.shortDescription,
    this.description,
    this.hardwareInfo,
    this.manualUrl,
    this.datasheetUrl,
    this.imageUrl,
    required this.images,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.attributes = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,

      name: json['name'] ?? 'Unnamed Product',
      slug: json['slug'] ?? '',

      shortDescription: json['short_description'],
      description: json['description'],
      hardwareInfo: json['hardware_info'],
      manualUrl: json['manual_url'],
      datasheetUrl: json['datasheet_url'],
      imageUrl: json['image_url'],

      images:
          (json['images'] as List?)
              ?.map((img) => ProductImage.fromJson(img))
              .toList() ??
          [],

      isActive: json['is_active'] ?? true,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),

      attributes:
          (json['attributes'] as List?)
              ?.map((attr) => ProductAttribute.fromJson(attr))
              .toList() ??
          [],
    );
  }

  String get displayImage => imageUrl ?? '📦';
}

// Product Image Model
class ProductImage {
  final String? upload;
  final String? url;

  ProductImage({this.upload, this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(upload: json['upload'], url: json['url']);
  }
}

// Product Attribute Model
class ProductAttribute {
  final int id;
  final String name;
  final String value;

  ProductAttribute({required this.id, required this.name, required this.value});

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      value: json['value'] ?? '',
    );
  }
}

// Pagination Response
class PaginatedProducts {
  final List<Product> products;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginatedProducts({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    return PaginatedProducts(
      products: (json['data'] as List)
          .map((product) => Product.fromJson(product))
          .toList(),
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      total: json['total'],
      perPage: json['per_page'],
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
}
