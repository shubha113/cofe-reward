import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedSubCategory;

  // Sample product data structure
  final Map<String, Map<String, List<Map<String, String>>>> _categories = {
    'Accessories': {
      'Camera Accessories': [
        {'name': 'PFB204W', 'image': '📷'},
        {'name': 'DH-PFA6400SA', 'image': '📦'},
        {'name': 'DH-PFA820', 'image': '🔧'},
      ],
      'Cabling': [
        {'name': 'DH-PFM922I-6U', 'image': '🔌'},
        {'name': 'DH-PFM976-631', 'image': '📦'},
        {'name': 'CAT6-Cable', 'image': '🔌'},
      ],
      'Detector': [
        {'name': 'DH-PFB510W', 'image': '📡'},
        {'name': 'DH-PFR4K-D450', 'image': '📡'},
        {'name': 'Motion-Sensor', 'image': '📡'},
      ],
    },
    'Transmission': {
      'Network Equipment': [
        {'name': 'Switch-24P', 'image': '🌐'},
        {'name': 'Router-Pro', 'image': '🌐'},
      ],
      'Converters': [
        {'name': 'Media-Conv', 'image': '🔄'},
        {'name': 'Fiber-Conv', 'image': '🔄'},
      ],
    },
    'Storage': {
      'HDD': [
        {'name': 'WD-Purple-2TB', 'image': '💾'},
        {'name': 'Seagate-4TB', 'image': '💾'},
      ],
      'NVR': [
        {'name': 'NVR-16CH', 'image': '📹'},
        {'name': 'NVR-32CH', 'image': '📹'},
      ],
    },
    'Security': {
      'Cameras': [
        {'name': 'Dome-Cam', 'image': '📷'},
        {'name': 'Bullet-Cam', 'image': '📷'},
      ],
      'Access Control': [
        {'name': 'Card-Reader', 'image': '🔐'},
        {'name': 'Fingerprint', 'image': '🔐'},
      ],
    },
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetToCategories() {
    setState(() {
      _selectedCategory = null;
      _selectedSubCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Search
            _buildTopBar(),

            // Breadcrumb Navigation
            if (_selectedCategory != null) _buildBreadcrumb(),

            // Content
            Expanded(
              child: _selectedCategory == null
                  ? _buildCategoriesView()
                  : _selectedSubCategory == null
                  ? _buildSubCategoriesView()
                  : _buildProductsView(),
            ),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_selectedCategory != null)
                IconButton(
                  onPressed: () {
                    if (_selectedSubCategory != null) {
                      setState(() {
                        _selectedSubCategory = null;
                      });
                    } else {
                      _resetToCategories();
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.greyBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.darkText,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.inventory_2,
                  color: AppColors.primaryRed,
                  size: 28,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _selectedSubCategory ?? _selectedCategory ?? 'Products',
                  style: AppTextStyles.header2.copyWith(fontSize: 24),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.filter_list,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.greyBackground,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: AppTextStyles.inputHint,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.greyText,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.greyText,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
                    : IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.primaryRed,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR Scanner opened!'),
                      ),
                    );
                  },
                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.white,
      child: Row(
        children: [
          InkWell(
            onTap: _resetToCategories,
            child: Text(
              'Categories',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.illustrationDarkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_selectedCategory != null) ...[
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.greyText,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedSubCategory = null;
                });
              },
              child: Text(
                _selectedCategory!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _selectedSubCategory == null
                      ? AppColors.primaryRed
                      : AppColors.illustrationDarkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (_selectedSubCategory != null) ...[
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.greyText,
            ),
            Text(
              _selectedSubCategory!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesView() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: _categories.keys.length,
      itemBuilder: (context, index) {
        final category = _categories.keys.elementAt(index);
        final subCategoriesCount = _categories[category]!.keys.length;

        return _buildCategoryCard(
          title: category,
          subCategoriesCount: subCategoriesCount,
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
        );
      },
    );
  }

  Widget _buildSubCategoriesView() {
    final subCategories = _categories[_selectedCategory!]!;

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: subCategories.keys.length,
      itemBuilder: (context, index) {
        final subCategory = subCategories.keys.elementAt(index);
        final productsCount = subCategories[subCategory]!.length;

        return _buildSubCategoryCard(
          title: subCategory,
          productsCount: productsCount,
          onTap: () {
            setState(() {
              _selectedSubCategory = subCategory;
            });
          },
        );
      },
    );
  }

  Widget _buildProductsView() {
    final products =
    _categories[_selectedCategory!]![_selectedSubCategory!]!;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required int subCategoriesCount,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
              border: Border.all(
                color: AppColors.borderGrey,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lightRed.withValues(alpha: 0.2),
                        AppColors.primaryRed.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: AppColors.primaryRed,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.header3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$subCategoriesCount subcategories',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.greyBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryCard({
    required String title,
    required int productsCount,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              border: Border.all(
                color: AppColors.borderGrey,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.illustrationBlue.withValues(alpha: 0.2),
                        AppColors.illustrationDarkBlue.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    color: AppColors.illustrationDarkBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$productsCount products',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.greyText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: AppColors.borderGrey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image/Icon
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.greyBackground,
                      borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    ),
                    child: Center(
                      child: Text(
                        product['image']!,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Product Name
                Text(
                  product['name']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // In Stock Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'In Stock',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}