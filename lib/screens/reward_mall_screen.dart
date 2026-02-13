import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/redeemable.dart';
import '../services/reward_service.dart';
import '../config/api_config.dart';
import 'rewards_history_screen.dart';

class RewardsMallScreen extends StatefulWidget {
  const RewardsMallScreen({Key? key}) : super(key: key);

  @override
  State<RewardsMallScreen> createState() => _RewardsMallScreenState();
}

class _RewardsMallScreenState extends State<RewardsMallScreen> {
  final RewardService _rewardService = RewardService();

  int _userPoints = 0;
  List<Redeemable> _availableItems = [];
  bool _isLoading = true;
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch available rewards (includes user points now)
      final rewardsResult = await _rewardService.getAvailableRewards();

      if (mounted) {
        setState(() {
          if (rewardsResult['success'] == true) {
            _availableItems = rewardsResult['data'] ?? [];
            _userPoints = rewardsResult['user_points'] ?? 0;
            print('User points: $_userPoints');
            print('Available items: ${_availableItems.length}');
          } else {
            _showSnackBar(
              rewardsResult['message'] ?? 'Failed to load rewards',
              isError: true,
            );
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error loading data: ${e.toString()}', isError: true);
        print('Error: $e');
      }
    }
  }

  Future<void> _redeemItem(Redeemable item) async {
    // Confirm redemption
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        title: Text('Confirm Redemption', style: AppTextStyles.header3),
        content: Text(
          'Do you want to redeem "${item.displayName}" for ${item.pointsRequired} points?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.greyText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              ),
            ),
            child: Text(
              'Redeem',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRedeeming = true);

    final result = await _rewardService.redeemItem(redeemableId: item.id);

    setState(() => _isRedeeming = false);

    if (result['success'] == true) {
      _showSnackBar(result['message'] ?? 'Redeemed successfully!');

      // Reload data to get updated points and available items
      _loadData();
    } else {
      _showSnackBar(result['message'] ?? 'Redemption failed', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPointsCard(),
            _buildSectionTitle(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _availableItems.isEmpty
                  ? _buildEmptyState()
                  : _buildRewardsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.darkText),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Rewards Mall',
            style: AppTextStyles.header2.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    final affordableCount = _availableItems.where((item) => item.canRedeem).length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, AppColors.lightRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Points',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_userPoints',
                      style: AppTextStyles.header1.copyWith(
                        fontSize: 32,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$affordableCount/${_availableItems.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // View History Button
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RedemptionHistoryScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, color: AppColors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'View Redemption History',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    final affordableCount = _availableItems
        .where((item) => item.canRedeem)
        .length;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Text(
            'Available Items',
            style: AppTextStyles.header3.copyWith(fontSize: 20),
          ),
          const Spacer(),
          Text(
            '$affordableCount available',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _availableItems.length,
        itemBuilder: (context, index) {
          return _buildRewardCard(_availableItems[index]);
        },
      ),
    );
  }

  Widget _buildRewardCard(Redeemable item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Stack(
          children: [
            // Greyed out overlay for items user can't afford
            if (!item.canRedeem)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppBorderRadius.large),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Item Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.greyBackground,
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.medium,
                      ),
                    ),
                    child: item.displayImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.medium,
                            ),
                            child: Image.network(
                              '${ApiConfig.storageUrl}${item.displayImage}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderIcon(item.type);
                              },
                            ),
                          )
                        : _buildPlaceholderIcon(item.type),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.type == 'gift'
                                ? Colors.purple.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.type.toUpperCase(),
                            style: TextStyle(
                              color: item.type == 'gift'
                                  ? Colors.purple
                                  : Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Item Name
                        Text(
                          item.displayName,
                          style: AppTextStyles.header3.copyWith(
                            fontSize: 16,
                            color: item.canRedeem
                                ? AppColors.darkText
                                : AppColors.greyText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Points Required
                        Row(
                          children: [
                            Icon(
                              Icons.stars,
                              size: 16,
                              color: item.canRedeem
                                  ? Colors.amber
                                  : AppColors.lightGreyText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.pointsRequired} Points',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: item.canRedeem
                                    ? AppColors.primaryRed
                                    : AppColors.greyText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Redeem Button
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: item.canRedeem && !_isRedeeming
                            ? () => _redeemItem(item)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.canRedeem
                              ? AppColors.primaryRed
                              : AppColors.greyText.withValues(alpha: 0.3),
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.greyText
                              .withValues(alpha: 0.3),
                          disabledForegroundColor: AppColors.lightGreyText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.medium,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          elevation: item.canRedeem ? 2 : 0,
                        ),
                        child: _isRedeeming
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Redeem',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: item.canRedeem
                                      ? AppColors.white
                                      : AppColors.lightGreyText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      if (!item.canRedeem) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Need ${item.pointsRequired - _userPoints}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(String type) {
    return Icon(
      type == 'gift' ? Icons.card_giftcard : Icons.shopping_bag,
      size: 40,
      color: AppColors.lightGreyText,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 80,
            color: AppColors.lightGreyText,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No items available',
            style: AppTextStyles.header3.copyWith(color: AppColors.greyText),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check back later for rewards!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightGreyText,
            ),
          ),
        ],
      ),
    );
  }
}
