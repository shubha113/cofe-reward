import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/claim_service.dart';
import 'batch_detail_screen.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({Key? key}) : super(key: key);

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  final ClaimService _claimService = ClaimService();
  final Map<int, bool> _pendingInstallationPhotos = {};
  String _selectedStatusFilter = 'all';
  bool _sortNewestFirst = true;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _allClaims = [];
  Map<int, List<Map<String, dynamic>>> _grouped = {};

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _claimService.getMyBatches();

    if (!mounted) return;

    if (result['success'] == true) {
      try {
        final List<dynamic> rawData = result['data'] ?? [];
        final List<Map<String, dynamic>> claims = rawData
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        //APPLY FILTER
        final filteredClaims = _selectedStatusFilter == 'all'
            ? claims
            : claims.where((c) {
                return c['batch_status'] == _selectedStatusFilter;
              }).toList();

        //APPLY SORT
        filteredClaims.sort((a, b) {
          final aDate = DateTime.parse(a['claimed_at']);
          final bDate = DateTime.parse(b['claimed_at']);
          return _sortNewestFirst
              ? bDate.compareTo(aDate)
              : aDate.compareTo(bDate);
        });

        //GROUP BY BATCH
        final grouped = <int, List<Map<String, dynamic>>>{};

        for (final c in filteredClaims) {
          final bId = c['batch_id'] as int;
          grouped.putIfAbsent(bId, () => <Map<String, dynamic>>[]);
          grouped[bId]!.add(c);
        }

        setState(() {
          _allClaims = filteredClaims;
          _grouped = grouped;
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'Error loading claims: $e';
          _loading = false;
        });
        _showSnack('Error parsing claims data');
      }
    } else {
      final errorMsg = result['message'] ?? 'Failed to load claims';
      setState(() {
        _error = errorMsg;
        _loading = false;
      });
      _showSnack(errorMsg);
    }
  }

  Future<void> _navigateToBatchDetail(
    int batchId,
    List<Map<String, dynamic>> claims,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BatchDetailScreen(
          batchId: batchId,
          claims: claims,
          batchStatus: claims.first['batch_status'] as String,
        ),
      ),
    );

    // Refresh if batch was submitted
    if (result == true) {
      _loadClaims();
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    if (msg.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : AppColors.primaryRed,
        duration: const Duration(seconds: 2),
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
            _buildFilterSortBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    )
                  : _error != null
                  ? _buildErrorState()
                  : _grouped.isEmpty
                  ? _buildEmptyState()
                  : _buildBatchesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.darkText),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Claims',
                  style: AppTextStyles.header3.copyWith(fontSize: 20),
                ),
                Text(
                  '${_grouped.length} batch${_grouped.length != 1 ? 'es' : ''} • ${_allClaims.length} device${_allClaims.length != 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadClaims,
            icon: const Icon(Icons.refresh, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          // STATUS FILTER
          DropdownButton<String>(
            value: _selectedStatusFilter,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'submitted', child: Text('Submitted')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedStatusFilter = value;
              });
              _loadClaims();
            },
          ),

          const Spacer(),

          // SORT BUTTON
          TextButton.icon(
            onPressed: () {
              setState(() {
                _sortNewestFirst = !_sortNewestFirst;
              });
              _loadClaims();
            },
            icon: Icon(
              _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
              size: 16,
            ),
            label: Text(
              _sortNewestFirst ? 'Newest' : 'Oldest',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Error Loading Claims', style: AppTextStyles.header3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error ?? 'Unknown error',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _loadClaims,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
              ),
              child: const Center(
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 48,
                  color: AppColors.greyText,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No Claims Yet', style: AppTextStyles.header3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Go to a product page and claim your devices to see them here.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchesList() {
    final batchIds = _grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: batchIds.length,
      itemBuilder: (ctx, i) {
        final bId = batchIds[i];
        final claims = _grouped[bId]!;
        return _buildBatchCard(bId, claims);
      },
    );
  }

  Widget _buildBatchCard(int batchId, List<Map<String, dynamic>> claims) {
    final batchStatus = claims.first['batch_status'] as String;
    final hasDocuments = claims.first['has_documents'] == true;
    final allHaveInstallation = claims.every(
      (c) => c['has_installation_photo'] == true,
    );
    final int batchPoints = claims.fold<int>(
      0,
      (sum, c) => sum + ((c['reward_points'] ?? 0) as int),
    );

    return GestureDetector(
      onTap: () => _navigateToBatchDetail(batchId, claims),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batch #$batchId',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${batchPoints} pts earned',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (batchStatus == 'draft') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Points will be credited after submission.',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                    Text(
                      '${claims.length} device${claims.length != 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
                _statusBadge(batchStatus),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _progressIndicator(
                  icon: Icons.camera_alt,
                  label: 'Installation',
                  completed: allHaveInstallation,
                ),
                const SizedBox(width: AppSpacing.md),
                _progressIndicator(
                  icon: Icons.receipt_long,
                  label: 'Bills',
                  completed: hasDocuments,
                ),
              ],
            ),
            if (batchStatus == 'draft') ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tap to complete submission',
                      style: TextStyle(fontSize: 12, color: AppColors.greyText),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.greyText,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _progressIndicator({
    required IconData icon,
    required String label,
    required bool completed,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: completed
              ? Colors.green.withValues(alpha: 0.1)
              : AppColors.greyBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: completed ? Colors.green : AppColors.borderGrey,
          ),
        ),
        child: Row(
          children: [
            Icon(
              completed ? Icons.check_circle : icon,
              size: 16,
              color: completed ? Colors.green : AppColors.greyText,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: completed ? Colors.green : AppColors.greyText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'submitted':
        bg = Colors.green.withValues(alpha: 0.12);
        fg = Colors.green;
        label = 'Submitted';
        break;
      case 'draft':
        bg = Colors.amber.withValues(alpha: 0.12);
        fg = Colors.amber.shade800;
        label = 'Draft';
        break;
      default:
        bg = Colors.blue.withValues(alpha: 0.12);
        fg = Colors.blue;
        label = 'Active';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
