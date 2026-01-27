import '../config/api_config.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  // Get all products with pagination
  Future<PaginatedProducts> getAllProducts({int page = 1, int perPage = 12}) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.products}?page=$page&per_page=$perPage',
      );

      return PaginatedProducts.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Search products
  Future<PaginatedProducts> searchProducts({
    required String query,
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.productSearch}?search=$query&page=$page&per_page=$perPage',
      );

      return PaginatedProducts.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Get product by ID (using ID instead of slug)
  Future<Product> getProductById(int id) async {
    try {
      final response = await _apiClient.get(ApiConfig.productById(id));

      return Product.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Get products by main category ID
  Future<Map<String, dynamic>> getProductsByMainCategoryId({
    required int mainCategoryId,
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.productsByMainCategoryId(mainCategoryId)}?page=$page&per_page=$perPage',
      );

      final data = response['data'];
      return {
        'mainCategory': MainCategory.fromJson(data['mainCategory']),
        'products': PaginatedProducts.fromJson(data['products']),
      };
    } catch (e) {
      rethrow;
    }
  }

  // Get products by product category ID
  Future<Map<String, dynamic>> getProductsByCategoryId({
    required int categoryId,
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.productsByCategoryId(categoryId)}?page=$page&per_page=$perPage',
      );

      final data = response['data'];
      return {
        'mainCategory': MainCategory.fromJson(data['mainCategory']),
        'category': ProductCategory.fromJson(data['category']),
        'products': PaginatedProducts.fromJson(data['products']),
      };
    } catch (e) {
      rethrow;
    }
  }

  // Get products by subcategory ID
  Future<Map<String, dynamic>> getProductsBySubcategoryId({
    required int subcategoryId,
    int page = 1,
    int perPage = 12,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.productsBySubcategoryId(subcategoryId)}?page=$page&per_page=$perPage',
      );

      final data = response['data'];
      return {
        'mainCategory': MainCategory.fromJson(data['mainCategory']),
        'category': ProductCategory.fromJson(data['category']),
        'subcategory': ProductSubCategory.fromJson(data['subcategory']),
        'products': PaginatedProducts.fromJson(data['products']),
      };
    } catch (e) {
      rethrow;
    }
  }
}