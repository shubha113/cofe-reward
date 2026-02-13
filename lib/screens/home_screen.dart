import 'package:cofeReward/screens/notification_screen.dart';
import 'package:cofeReward/screens/reward_mall_screen.dart';
import 'package:cofeReward/screens/tool_kit_screen.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:cofeReward/screens/my_claim_device_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Top Navigation Items
  final List<Map<String, dynamic>> _topNavItems = [
    {
      'icon': Icons.build_outlined,
      'label': 'Tool Kit',
      'color': const Color(0xFFE01C08),
    },
    {
      'icon': Icons.assignment_turned_in_outlined,
      'label': 'My Claims',
      'color': const Color(0xFFE01C08),
    },
    {
      'icon': Icons.store_outlined,
      'label': 'Rewards Mall',
      'color': const Color(0xFFE01C08),
    },
    {
      'icon': Icons.settings_outlined,
      'label': 'Config',
      'color': const Color(0xFFE01C08),
    },
    {
      'icon': Icons.school_outlined,
      'label': 'Training',
      'color': const Color(0xFFE01C08),
    },
    {
      'icon': Icons.more_horiz,
      'label': 'More',
      'color': const Color(0xFFE01C08),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildFloatingTopHeader(context),
            _buildTopNavigation(),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    "Discover",
                    style: AppTextStyles.header3.copyWith(fontSize: 20),
                  ),
                  const Spacer(),
                  Text(
                    "View All",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPremiumCard(
                    title: 'Featured Product',
                    subtitle: 'Check out our latest offerings',
                    icon: Icons.local_fire_department,
                    color: AppColors.primaryRed,
                    tag: "NEW",
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildPremiumCard(
                    title: 'Trending Now',
                    subtitle: 'Most popular items this week',
                    icon: Icons.trending_up,
                    color: Colors.orange,
                    tag: "HOT",
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildPremiumCard(
                    title: 'Special Offers',
                    subtitle: 'Limited time deals',
                    icon: Icons.star,
                    color: Colors.amber,
                    tag: "SALE",
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String tag,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Decorative Circle
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: color.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Modern Icon Container
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15),
                          color.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 16),
                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: AppTextStyles.header3.copyWith(
                            fontSize: 17,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.greyBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.darkText,
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

  Widget _buildFloatingTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/images/cofee.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const Spacer(),

          // Notification Button
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.darkText,
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
        children: _topNavItems.map((item) => _buildSmartNavItem(item)).toList(),
      ),
    );
  }

  Widget _buildSmartNavItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        switch (item['label']) {
          case 'Tool Kit':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ToolKitScreen()),
            );
            break;

          case 'My Claims':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyClaimsScreen()),
            );
            break;

          case 'Rewards Mall':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RewardsMallScreen()),
            );
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item['color'].withOpacity(0.15),
                  item['color'].withOpacity(0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: item['color'].withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(item['icon'], color: item['color'], size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            item['label'],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkText.withValues(alpha: 0.8),
              fontSize: 10,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
