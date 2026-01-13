import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, String> product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  int _selectedTabIndex = 0;

  late TabController _tabController;

  final List<String> _tabs = [
    'Specifications',
    'Description',
    'User Manual',
    'Accessories',
    'Installation',
  ];

  // Sample product images (using emojis as placeholders)
  final List<String> _productImages = ['📷', '🔍', '⚙️', '📦'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.35;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Image Carousel
            _buildImageCarousel(imageHeight),

            // Product Info & Tabs
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
                        _buildSpecificationsTab(),
                        _buildDescriptionTab(),
                        _buildUserManualTab(),
                        _buildAccessoriesTab(),
                        _buildInstallationTab(),
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

  Widget _buildImageCarousel(double height) {
    return Container(
      height: height,
      color: AppColors.greyBackground,
      child: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _imagePageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _productImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.large),
                ),
                child: Center(
                  child: Text(
                    _productImages[index],
                    style: const TextStyle(fontSize: 120),
                  ),
                ),
              );
            },
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
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.darkText,
                ),
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
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.share,
                color: AppColors.darkText,
              ),
            ),
          ),

          // Image Indicators
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _productImages.length,
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
            color: Colors.black.withValues(alpha: 0.05),
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
                      widget.product['name'] ?? 'Product Name',
                      style: AppTextStyles.header2.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Model: ${widget.product['name']}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.selectedBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppColors.primaryRed,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.check_circle,
                label: 'In Stock',
                color: Colors.green,
              ),
              const SizedBox(width: AppSpacing.sm),
              _buildInfoChip(
                icon: Icons.verified,
                label: 'Verified',
                color: AppColors.illustrationDarkBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
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
          bottom: BorderSide(
            color: AppColors.borderGrey,
            width: 1,
          ),
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
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    final specifications = [
      {'label': 'Resolution', 'value': '4K (3840 × 2160)'},
      {'label': 'Lens', 'value': '2.8mm - 12mm motorized'},
      {'label': 'Night Vision', 'value': 'Up to 30m IR range'},
      {'label': 'Video Compression', 'value': 'H.265+/H.265/H.264+/H.264'},
      {'label': 'Frame Rate', 'value': 'Main Stream: 25fps'},
      {'label': 'Audio', 'value': 'Built-in microphone'},
      {'label': 'Storage', 'value': 'MicroSD up to 256GB'},
      {'label': 'Power', 'value': 'PoE / 12V DC'},
      {'label': 'Operating Temp', 'value': '-30°C to 60°C'},
      {'label': 'IP Rating', 'value': 'IP67 Weatherproof'},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ...specifications.map(
              (spec) => _buildSpecRow(spec['label']!, spec['value']!),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderGrey.withValues(alpha: 0.5),
          ),
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

  Widget _buildDescriptionTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Product Overview',
          style: AppTextStyles.header3.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'This high-performance security camera delivers exceptional 4K resolution with advanced features designed for professional surveillance applications. The motorized lens provides flexible coverage options, while intelligent analytics ensure reliable detection and monitoring.',
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Key Features',
          style: AppTextStyles.header3.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.md),
        ...[
          '4K Ultra HD resolution for crystal clear images',
          'Smart IR with up to 30m night vision',
          'Motorized varifocal lens (2.8-12mm)',
          'H.265+ compression for efficient storage',
          'Built-in analytics with AI-powered detection',
          'IP67 weatherproof rating',
          'Wide operating temperature range',
          'PoE for easy installation',
        ].map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  feature,
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildUserManualTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildDownloadCard(
          title: 'User Manual (English)',
          subtitle: 'PDF • 2.5 MB',
          icon: Icons.picture_as_pdf,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDownloadCard(
          title: 'Quick Start Guide',
          subtitle: 'PDF • 890 KB',
          icon: Icons.description,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDownloadCard(
          title: 'Configuration Tool',
          subtitle: 'Windows • 45 MB',
          icon: Icons.settings_applications,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Video Tutorials',
          style: AppTextStyles.header3.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildVideoCard(
          title: 'Installation Guide',
          duration: '5:32',
          thumbnail: '🎥',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildVideoCard(
          title: 'Configuration Setup',
          duration: '8:15',
          thumbnail: '🎥',
        ),
      ],
    );
  }

  Widget _buildDownloadCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: AppColors.borderGrey,
        ),
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
            child: Icon(
              icon,
              color: AppColors.primaryRed,
              size: 28,
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
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

  Widget _buildVideoCard({
    required String title,
    required String duration,
    required String thumbnail,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: AppColors.borderGrey,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.darkText.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.medium),
                bottomLeft: Radius.circular(AppBorderRadius.medium),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  thumbnail,
                  style: const TextStyle(fontSize: 40),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Watch tutorial video',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessoriesTab() {
    final accessories = [
      {'name': 'Junction Box', 'code': 'PFA121', 'image': '📦'},
      {'name': 'Wall Mount', 'code': 'PFA130', 'image': '🔧'},
      {'name': 'Pole Mount', 'code': 'PFA150', 'image': '⚙️'},
      {'name': 'Power Adapter', 'code': 'PFM320D', 'image': '🔌'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.9,
      ),
      itemCount: accessories.length,
      itemBuilder: (context, index) {
        final accessory = accessories[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: AppColors.borderGrey,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
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
                    child: Text(
                      accessory['image']!,
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    Text(
                      accessory['name']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accessory['code']!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstallationTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildInstallationStep(
          number: 1,
          title: 'Choose Location',
          description:
          'Select an optimal location with clear view of the area to be monitored. Ensure stable mounting surface.',
        ),
        _buildInstallationStep(
          number: 2,
          title: 'Mount the Camera',
          description:
          'Use the provided mounting bracket and screws. Ensure the camera is securely fastened.',
        ),
        _buildInstallationStep(
          number: 3,
          title: 'Connect Cables',
          description:
          'Connect the network cable for PoE or power adapter. Ensure waterproof connection for outdoor use.',
        ),
        _buildInstallationStep(
          number: 4,
          title: 'Configure Network',
          description:
          'Access the camera through web browser or mobile app. Configure network settings and user credentials.',
        ),
        _buildInstallationStep(
          number: 5,
          title: 'Adjust View & Focus',
          description:
          'Adjust the camera angle and focus using the motorized lens controls until desired view is achieved.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightBlue.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: AppColors.illustrationDarkBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.illustrationDarkBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'For detailed installation instructions, refer to the user manual.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstallationStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.lightRed, AppColors.primaryRed],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}