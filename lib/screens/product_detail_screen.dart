import 'package:cofe_reward/config/api_config.dart';
import 'package:image_picker/image_picker.dart' as img;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/app_constants.dart';
import '../services/product_service.dart';
import '../services/claim_service.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final ClaimService _claimService = ClaimService();
  final PageController _imagePageController = PageController();
  final img.ImagePicker _imagePicker = img.ImagePicker();

  int _currentImageIndex = 0;
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  bool _isFavorite = false;
  Product? _product;
  String? _error;

  late TabController _tabController;

  final List<String> _tabs = ['Description', 'Specifications', 'Documents'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _loadProduct();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final product = await _productService.getProductById(widget.productId);

      if (mounted) {
        setState(() {
          _product = product;
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

  Future<void> _toggleFavorite() async {
    if (_product == null) return;

    try {
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
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
                  Text('Error loading product', style: AppTextStyles.header3),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _error ?? 'Product not found',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.45;

    // Get valid images
    final validImages = _product!.images
        .where((img) => img.url != null)
        .toList();
    final hasImages = validImages.isNotEmpty || _product!.imageUrl != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Image Carousel (45% height)
            _buildImageCarousel(imageHeight, hasImages, validImages),

            // Product Info & Tabs (55% height)
            Expanded(
              child: Column(
                children: [
                  // Product Name & Quick Actions
                  _buildProductHeader(),

                  // Scrollable Tab Bar
                  _buildTabBar(),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDescriptionTab(),
                        _buildSpecificationsTab(),
                        _buildDocumentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(
    double height,
    bool hasImages,
    List<ProductImage> validImages,
  ) {
    return Container(
      height: height,
      color: AppColors.greyBackground,
      child: Stack(
        children: [
          // Image PageView
          if (hasImages)
            PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: validImages.isNotEmpty
                  ? validImages.length
                  : (_product!.imageUrl != null ? 1 : 0),
              itemBuilder: (context, index) {
                final imageUrl = validImages.isNotEmpty
                    ? validImages[index].url
                    : _product!.imageUrl;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.large),
                  ),
                  child: Center(
                    child: Image.network(
                      '${ApiConfig.storageUrl}$imageUrl',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: AppColors.greyText,
                        );
                      },
                    ),

                  ),
                );
              },
            )
          else
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.large),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 120,
                  color: AppColors.greyText,
                ),
              ),
            ),

          // Back Button
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.darkText),
              ),
            ),
          ),

          // Share Button
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.share, color: AppColors.darkText),
            ),
          ),

          // Image Indicators
          if (hasImages && validImages.length > 1)
            Positioned(
              bottom: AppSpacing.lg,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  validImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentImageIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? AppColors.primaryRed
                          : AppColors.borderGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product!.name,
                      style: AppTextStyles.header2.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${_product!.slug}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),

              // Claim button
              ElevatedButton(
                onPressed: _showClaimDeviceBottomSheet,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Claim',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              // Proper spacing after button
              const SizedBox(width: AppSpacing.sm),

              //Like button
              IconButton(
                onPressed: _toggleFavorite,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.selectedBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.primaryRed,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGrey, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primaryRed,
        indicatorWeight: 3,
        labelColor: AppColors.primaryRed,
        unselectedLabelColor: AppColors.greyText,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_product!.shortDescription != null) ...[
          Text('Overview', style: AppTextStyles.header3.copyWith(fontSize: 18)),
          const SizedBox(height: AppSpacing.md),
          HtmlWidget(
            _product!.shortDescription!,
            textStyle: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (_product!.description != null) ...[
          Text(
            'Description',
            style: AppTextStyles.header3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          HtmlWidget(
            _product!.description!,
            textStyle: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ],
        if (_product!.shortDescription == null &&
            _product!.description == null) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text('No description available'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecificationsTab() {
    if (_product!.attributes.isEmpty && _product!.hardwareInfo == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('No specifications available'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_product!.hardwareInfo != null) ...[
          Text(
            'Hardware Information',
            style: AppTextStyles.header3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _product!.hardwareInfo!,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (_product!.attributes.isNotEmpty) ...[
          Text(
            'Specifications',
            style: AppTextStyles.header3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._product!.attributes.map(
            (attr) => _buildSpecRow(attr.name, attr.value),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderGrey.withOpacity(0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.greyText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    final hasDocuments =
        _product!.manualUrl != null || _product!.datasheetUrl != null;

    if (!hasDocuments) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('No documents available'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        if (_product!.manualUrl != null)
          _buildDocumentCard(
            title: 'User Manual',
            subtitle: 'PDF Document',
            icon: Icons.picture_as_pdf,
            url: _product!.manualUrl!,
          ),
        if (_product!.manualUrl != null && _product!.datasheetUrl != null)
          const SizedBox(height: AppSpacing.md),
        if (_product!.datasheetUrl != null)
          _buildDocumentCard(
            title: 'Datasheet',
            subtitle: 'PDF Document',
            icon: Icons.description,
            url: _product!.datasheetUrl!,
          ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String url,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Icon(icon, color: AppColors.primaryRed, size: 28),
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
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Open URL
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Opening: $url')));
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.download,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClaimDeviceBottomSheet() {
    final TextEditingController serialController = TextEditingController();
    String? errorMessage;
    File? selectedImage;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.greyText.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.small,
                              ),
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              color: AppColors.primaryRed,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Claim Device',
                                  style: AppTextStyles.header2.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  _product?.name ?? '',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Serial Number Field
                      Text(
                        'Serial Number',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: serialController,
                        decoration: InputDecoration(
                          hintText: 'Enter device serial number',
                          prefixIcon: const Icon(
                            Icons.qr_code,
                            color: AppColors.greyText,
                          ),
                          filled: true,
                          fillColor: AppColors.greyBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.medium,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Upload Photo Section
                      Text(
                        'Installation Photo',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Photo preview or upload buttons
                      if (selectedImage != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                              child: Image.file(
                                selectedImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () {
                                  setModalState(() {
                                    selectedImage = null;
                                  });
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            // Camera button
                            InkWell(
                              onTap: () async {
                                final img.XFile? photo = await _imagePicker
                                    .pickImage(
                                      source: img.ImageSource.camera,
                                      imageQuality: 70,
                                      maxWidth: 1200,
                                    );

                                if (!mounted) return;

                                if (photo != null) {
                                  setModalState(() {
                                    selectedImage = File(photo.path);
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.greyBackground,
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium,
                                  ),
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppBorderRadius.small,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: AppColors.primaryRed,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Take Photo',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            'Use camera to capture installation',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.greyText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.greyText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Gallery button
                            InkWell(
                              onTap: () async {
                                final img.XFile? photo = await _imagePicker
                                    .pickImage(
                                      source: img.ImageSource.gallery,
                                      imageQuality: 70,
                                      maxWidth: 1200,
                                    );

                                if (!mounted) return;

                                if (photo != null) {
                                  setModalState(() {
                                    selectedImage = File(photo.path);
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: AppColors.greyBackground,
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.medium,
                                  ),
                                  border: Border.all(
                                    color: AppColors.borderGrey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppBorderRadius.small,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.photo_library,
                                        color: AppColors.primaryRed,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Choose from Gallery',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            'Select from device storage',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.greyText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.greyText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.xl),

                      if (errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),


                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  // Validate inputs
                                  if (serialController.text.trim().isEmpty) {
                                    setModalState(() {
                                      errorMessage = 'Please enter serial number';
                                    });
                                    return;
                                  }

                                  if (selectedImage == null) {
                                    setModalState(() {
                                      errorMessage = 'Please upload installation photo';
                                    });
                                    return;
                                  }

                                  setModalState(() {
                                    isSubmitting = true;
                                  });

                                  // Call backend API to claim device
                                  final result = await _claimService
                                      .claimDevice(
                                        serialNumber: serialController.text
                                            .trim(),
                                        billPhoto: selectedImage!,
                                      );

                                  if (result['success'] == true) {
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(
                                      Navigator.of(context, rootNavigator: true).context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text('Claim submitted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    setModalState(() {
                                      errorMessage = result['message'] ??
                                          'This device is already claimed or under review';
                                    });
                                  }

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.medium,
                              ),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit Claim',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
