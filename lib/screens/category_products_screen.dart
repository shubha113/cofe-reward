import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/product_service.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final MainCategory mainCategory;
  final ProductCategory productCategory;

  const CategoryProductsScreen({
    Key? key,
    required this.mainCategory,
    required this.productCategory,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  PaginatedProducts? _paginatedProducts;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _productService.getProductsByCategoryId(
        categoryId: widget.productCategory.id,
        page: page,
        perPage: 12,
      );

      if (mounted) {
        setState(() {
          _paginatedProducts = result['products'] as PaginatedProducts;
          _currentPage = page;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppColors.darkText,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productCategory.name,
                  style: AppTextStyles.header3.copyWith(fontSize: 18),
                ),
                Text(
                  widget.mainCategory.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
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
              Text('Error loading products', style: AppTextStyles.header3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: _loadProducts,
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

    if (_paginatedProducts == null || _paginatedProducts!.products.isEmpty) {
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
            Text('No products found', style: AppTextStyles.bodyLarge),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Product count and page info
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          color: AppColors.white,
          child: Row(
            children: [
              Text(
                '${_paginatedProducts!.total} Products',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_paginatedProducts!.lastPage > 1)
                Text(
                  'Page ${_paginatedProducts!.currentPage} of ${_paginatedProducts!.lastPage}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
            ],
          ),
        ),

        // Products grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.75,
            ),
            itemCount: _paginatedProducts!.products.length,
            itemBuilder: (context, index) {
              final product = _paginatedProducts!.products[index];
              return _buildProductCard(product);
            },
          ),
        ),

        // Pagination
        if (_paginatedProducts!.lastPage > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
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
                              'http://192.168.0.104:8000/storage/${product.imageUrl}',
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

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _paginatedProducts!.hasPrevPage
                ? () => _loadProducts(page: _currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.primaryRed,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Page ${_paginatedProducts!.currentPage} of ${_paginatedProducts!.lastPage}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            onPressed: _paginatedProducts!.hasNextPage
                ? () => _loadProducts(page: _currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.primaryRed,
          ),
        ],
      ),
    );
  }
}
