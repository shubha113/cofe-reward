import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sample user data
  final Map<String, String> _userData = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+91 98765 43210',
    'company': 'Tech Solutions Pvt Ltd',
    'jobTitle': 'Sales Manager',
    'location': 'Punjab, Ludhiana',
    'providerType': 'Installer',
    'joinDate': 'January 2026',
  };

  // Sample favorites
  final List<Map<String, String>> _favorites = [
    {'name': 'PFB204W', 'category': 'Camera Accessories', 'image': '📷'},
    {'name': 'DH-PFM922I-6U', 'category': 'Cabling', 'image': '🔌'},
    {'name': 'DH-PFB510W', 'category': 'Detector', 'image': '📡'},
    {'name': 'Dome-Cam', 'category': 'Security Cameras', 'image': '📷'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(),

            // Profile Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(),

                    const SizedBox(height: AppSpacing.lg),

                    // User Details Card
                    _buildUserDetailsCard(),

                    const SizedBox(height: AppSpacing.lg),

                    // My Favorites Section
                    _buildFavoritesSection(),

                    const SizedBox(height: AppSpacing.lg),

                    // Account Actions
                    _buildAccountActions(),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
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
      child: Row(
        children: [
          const Icon(Icons.person, color: AppColors.primaryRed, size: 28),
          const SizedBox(width: AppSpacing.md),
          Text(
            'My Profile',
            style: AppTextStyles.header2.copyWith(fontSize: 24),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // Navigate to edit profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit,
                color: AppColors.darkText,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lightRed, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppColors.primaryRed,
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          //User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData['name']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),

                const SizedBox(height: 4),

                //Job Title
                Text(
                  _userData['jobTitle']!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                //Provider Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.verified_user,
                        size: 16,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Verifies Provider',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: AppTextStyles.header3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _userData['email']!,
          ),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _userData['phone']!,
          ),
          _buildDetailRow(
            icon: Icons.business_outlined,
            label: 'Company',
            value: _userData['company']!,
          ),
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: _userData['location']!,
          ),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: _userData['joinDate']!,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.greyBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryRed, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.borderGrey.withValues(alpha: 0.05),
            height: 1,
          ),
      ],
    );
  }

  Widget _buildFavoritesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.primaryRed, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'My Favorites',
                style: AppTextStyles.header3.copyWith(fontSize: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_favorites.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_favorites.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: AppColors.greyText.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No favorites yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final item = _favorites[index];
                return _buildFavoriteItem(item, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(Map<String, String> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Center(
              child: Text(item['image']!, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['category']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),

          // Remove Button
          IconButton(
            onPressed: () {
              setState(() {
                _favorites.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} removed from favorites'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.favorite, color: AppColors.primaryRed),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and configurations',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
          Divider(
            color: AppColors.borderGrey.withValues(alpha: 0.5),
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
          _buildActionTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
          Divider(
            color: AppColors.borderGrey.withValues(alpha: 0.5),
            height: 1,
            indent: AppSpacing.lg,
            endIndent: AppSpacing.lg,
          ),
          _buildActionTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            textColor: AppColors.primaryRed,
            iconColor: AppColors.primaryRed,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.darkText).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.darkText, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.darkText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.greyText),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: textColor ?? AppColors.greyText,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AppColors.primaryRed),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          title: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.lightRed, AppColors.primaryRed],
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: const Icon(
                  Icons.coffee,
                  size: 40,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Cofe Reward'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Version 1.0.0', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              Text(
                '© 2026 Cofe Technologies',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Partner Reward Program',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
