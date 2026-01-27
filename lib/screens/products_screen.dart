import 'package:cofe_reward/config/api_config.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'category_products_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isLoadingCategories = true;
  bool _isLoadingProducts = false;
  bool _isSearching = false;
  List<MainCategory> _mainCategories = [];
  Map<int, List<CategoryWithProducts>> _categoryProductsMap = {};
  int? _selectedCategoryId;
  String? _error;

  // Search state
  List<Product> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _loadMainCategories();

    // Listen to search field focus
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() {
          _showSearchResults = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMainCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _error = null;
    });

    try {
      final categories = await _categoryService.getMainCategories();

      if (mounted) {
        setState(() {
          _mainCategories = categories;
          _isLoadingCategories = false;
        });

        // Auto-select first category
        if (_mainCategories.isNotEmpty) {
          _selectCategory(_mainCategories.first.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _selectCategory(int categoryId) async {
    setState(() {
      _selectedCategoryId = categoryId;
      _isLoadingProducts = true;
    });

    // Check if already loaded
    if (_categoryProductsMap.containsKey(categoryId)) {
      setState(() {
        _isLoadingProducts = false;
      });
      return;
    }

    try {
      final selectedCategory = _mainCategories.firstWhere(
        (c) => c.id == categoryId,
      );

      // Get product categories under this main category (using ID)
      final productCategories = await _categoryService
          .getCategoriesByMainCategoryId(selectedCategory.id);

      // For each product category, get products
      List<CategoryWithProducts> categoryWithProductsList = [];

      for (var productCategory in productCategories) {
        try {
          final result = await _productService.getProductsByCategoryId(
            categoryId: productCategory.id,
            page: 1,
            perPage: 10, // Show max 10 products in horizontal scroll
          );

          final paginatedProducts = result['products'] as PaginatedProducts;

          categoryWithProductsList.add(
            CategoryWithProducts(
              category: productCategory,
              products: paginatedProducts.products,
              totalCount: paginatedProducts.total,
            ),
          );
        } catch (e) {
          // If no products, skip this category or add with empty list
          categoryWithProductsList.add(
            CategoryWithProducts(
              category: productCategory,
              products: [],
              totalCount: 0,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _categoryProductsMap[categoryId] = categoryWithProductsList;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingProducts = false;
        });
      }
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final paginatedProducts = await _productService.searchProducts(
        query: query.trim(),
        page: 1,
        perPage: 20,
      );

      if (mounted) {
        setState(() {
          _searchResults = paginatedProducts.products;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _showSearchResults = false;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _showSearchResults
                  ? _buildSearchResults()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGrey, width: 1),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              _searchProducts(value);
            }
          });
        },
        onSubmitted: _searchProducts,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.greyText,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.greyText,
            size: 22,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.greyText,
                    size: 20,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: AppColors.greyBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.greyText,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Error loading categories', style: AppTextStyles.header3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _loadMainCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_mainCategories.isEmpty) {
      return const Center(child: Text('No categories available'));
    }

    return Row(
      children: [
        // Left sidebar - Main categories
        _buildCategorySidebar(),

        // Right content - Product categories with products
        Expanded(child: _buildProductsContent()),
      ],
    );
  }

  Widget _buildCategorySidebar() {
    return Container(
      width: 100, // Fixed width is fine for sidebars
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          right: BorderSide(color: AppColors.borderGrey, width: 1),
        ),
      ),
      child: ListView.builder(
        // This makes it "infinite" based on your backend data
        itemCount: _mainCategories.length,
        // Ensures smooth scrolling even with many items
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final category = _mainCategories[index];
          final isSelected = _selectedCategoryId == category.id;

          return InkWell(
            onTap: () => _selectCategory(category.id),
            child: AnimatedContainer(
              // Added animation for a premium feel
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing
                    .lg, // Increased vertical padding for better touch targets
                horizontal: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryRed.withOpacity(0.08)
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected
                        ? AppColors.primaryRed
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // If you ever add icons to your categories, they go here
                  Text(
                    category.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryRed
                          : AppColors.darkText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines:
                        3, // Increased to 3 lines so long names don't vanish
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsContent() {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    if (_selectedCategoryId == null) {
      return const Center(child: Text('Select a category'));
    }

    final categoryProducts = _categoryProductsMap[_selectedCategoryId] ?? [];

    if (categoryProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.greyText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No products available', style: AppTextStyles.bodyLarge),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: categoryProducts.length,
      itemBuilder: (context, index) {
        final categoryWithProducts = categoryProducts[index];
        return _buildProductCategorySection(categoryWithProducts);
      },
    );
  }

  Widget _buildProductCategorySection(
    CategoryWithProducts categoryWithProducts,
  ) {
    final hasProducts = categoryWithProducts.products.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    categoryWithProducts.category.name,
                    style: AppTextStyles.header3.copyWith(fontSize: 16),
                  ),
                ),
                if (hasProducts && categoryWithProducts.totalCount > 4)
                  Text(
                    '${categoryWithProducts.totalCount} items',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.greyText,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Products horizontal scroll
          if (hasProducts)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                itemCount: categoryWithProducts.products.length > 4
                    ? 5 // Show 4 products + "View More" card
                    : categoryWithProducts.products.length,
                itemBuilder: (context, index) {
                  // Show "View More" card at the end if more than 4 products
                  if (index == 4 && categoryWithProducts.totalCount > 4) {
                    return _buildViewMoreCard(categoryWithProducts);
                  }

                  final product = categoryWithProducts.products[index];
                  return _buildProductCard(product);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: Text(
                  'No products in this category',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailScreen(productId: product.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          child: Container(
            decoration: BoxDecoration(color: Colors.transparent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE SECTION
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppBorderRadius.medium),
                      topRight: Radius.circular(AppBorderRadius.medium),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppBorderRadius.medium),
                      topRight: Radius.circular(AppBorderRadius.medium),
                    ),
                    child: product.imageUrl != null
                        ? Image.network(
                            '${ApiConfig.storageUrl}${product.imageUrl}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: AppColors.greyText,
                              );
                            },
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.greyText,
                          ),
                  ),
                ),

                // NAME SECTION
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 4, // Small vertical padding to keep it tight
                  ),
                  child: Text(
                    product.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    maxLines: 1, // Limited to 1 line to save space
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMoreCard(CategoryWithProducts categoryWithProducts) {
    final selectedCategory = _mainCategories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryProductsScreen(
                  mainCategory: selectedCategory,
                  productCategory: categoryWithProducts.category,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP (IMAGE-LIKE AREA)
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.medium),
                    topRight: Radius.circular(AppBorderRadius.medium),
                  ),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: AppColors.primaryRed,
                  size: 24,
                ),
              ),

              // LABEL
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                child: Text(
                  'View More',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.primaryRed,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryRed),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.greyText),
            const SizedBox(height: AppSpacing.md),
            Text('No products found', style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try different keywords',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results count
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.white,
          child: Row(
            children: [
              Text(
                '${_searchResults.length} Results',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.primaryRed,
                ),
                label: Text(
                  'Clear',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Results grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return _buildSearchProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchProductCard(Product product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(color: AppColors.borderGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.greyBackground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppBorderRadius.medium),
                      topRight: Radius.circular(AppBorderRadius.medium),
                    ),
                  ),
                  child: Center(
                    child: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppBorderRadius.medium),
                              topRight: Radius.circular(AppBorderRadius.medium),
                            ),
                            child: Image.network(
                              '${ApiConfig.storageUrl}${product.imageUrl}',
                              fit: BoxFit
                                  .cover, // Ensures image fills the 160px height
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.image_not_supported,
                                    color: AppColors.greyText,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: AppColors.greyText,
                          ),
                  ),
                ),
              ),

              // Product Info
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.shortDescription != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.shortDescription!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.greyText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.isActive ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: product.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class to hold category with its products
class CategoryWithProducts {
  final ProductCategory category;
  final List<Product> products;
  final int totalCount;

  CategoryWithProducts({
    required this.category,
    required this.products,
    required this.totalCount,
  });
}
