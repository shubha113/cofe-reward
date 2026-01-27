import '../config/api_config.dart';
import '../models/category.dart';
import 'api_client.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  // Get all main categories
  Future<List<MainCategory>> getMainCategories() async {
    try {
      final response = await _apiClient.get(ApiConfig.categories);

      final categories = (response['data'] as List)
          .map((cat) => MainCategory.fromJson(cat))
          .toList();

      // Sort by priority
      categories.sort((a, b) => a.priority.compareTo(b.priority));

      return categories;
    } catch (e) {
      rethrow;
    }
  }

  // Get product categories under a main category (using ID)
  Future<List<ProductCategory>> getCategoriesByMainCategoryId(int mainCategoryId) async {
    try {
      final response = await _apiClient.get(
        ApiConfig.categorySubcategories(mainCategoryId),
      );

      final categories = (response['data'] as List)
          .map((cat) => ProductCategory.fromJson(cat))
          .toList();

      // Sort by priority
      categories.sort((a, b) => a.priority.compareTo(b.priority));

      return categories;
    } catch (e) {
      rethrow;
    }
  }
}