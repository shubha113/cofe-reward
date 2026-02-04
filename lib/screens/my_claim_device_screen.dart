import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../services/claim_service.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({Key? key}) : super(key: key);

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  final ClaimService _claimService = ClaimService();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  List<Map<String, dynamic>> _allClaims = [];
  Map<int, List<Map<String, dynamic>>> _grouped = {};
  Map<int, List<File>> _pendingPhotos = {};
  Map<int, bool> _uploadingBatch = {};
  Map<int, bool> _submittingBatch = {};

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    setState(() => _loading = true);

    final result = await _claimService.getMyBatches();

    if (!mounted) return;

    if (result['success'] == true) {
      final List<dynamic> rawData = result['data'] ?? [];
      final List<Map<String, dynamic>> claims = rawData
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      final grouped = <int, List<Map<String, dynamic>>>{};

      for (final c in claims) {
        final bId = c['batch_id'] as int;
        grouped.putIfAbsent(bId, () => <Map<String, dynamic>>[]);
        grouped[bId]!.add(c);
      }

      setState(() {
        _allClaims = claims;
        _grouped = grouped;
        _loading = false;
      });

      print('Loaded ${claims.length} claims in ${grouped.length} batches');
    } else {
      setState(() => _loading = false);
      _showSnack(result['message'] ?? 'Failed to load claims');
    }
  }

  Future<void> _pickPhotos(int batchId) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Add Bill Photos',
              style: AppTextStyles.header3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.selectedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: AppColors.primaryRed,
                ),
              ),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.selectedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryRed,
                ),
              ),
              title: const Text('Gallery'),
              subtitle: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );

    if (source == null) return;

    List<File> files = [];

    if (source == ImageSource.camera) {
      // Single photo from camera
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        files.add(File(image.path));
      }
    } else {
      // Multiple photos from gallery
      final images = await _picker.pickMultiImage();
      files = images.map<File>((img) => File(img.path)).toList();
    }

    if (files.isEmpty) return;

    setState(() {
      _pendingPhotos.putIfAbsent(batchId, () => <File>[]);
      _pendingPhotos[batchId]!.addAll(files);
    });
  }

  // ✅ UPDATED - Remove a specific photo
  void _removePhoto(int batchId, int photoIndex) {
    setState(() {
      _pendingPhotos[batchId]?.removeAt(photoIndex);
      if (_pendingPhotos[batchId]?.isEmpty ?? false) {
        _pendingPhotos.remove(batchId);
      }
    });
  }

  Future<void> _uploadAndSubmit(int batchId) async {
    final photos = _pendingPhotos[batchId] ?? [];
    if (photos.isEmpty) {
      _showSnack('Please add at least 1 bill photo');
      return;
    }

    setState(() => _uploadingBatch[batchId] = true);

    final uploadResult = await _claimService.uploadDocuments(
      batchId: batchId,
      photos: photos,
    );

    if (!mounted) return;

    if (uploadResult['success'] != true) {
      setState(() => _uploadingBatch[batchId] = false);
      _showSnack(uploadResult['message'] ?? 'Upload failed');
      return;
    }

    setState(() {
      _uploadingBatch[batchId] = false;
      _submittingBatch[batchId] = true;
    });

    final submitResult = await _claimService.submitBatch(batchId: batchId);

    if (!mounted) return;

    setState(() => _submittingBatch[batchId] = false);

    if (submitResult['success'] == true) {
      _pendingPhotos.remove(batchId);
      _showSnack('Claim submitted for review!', isSuccess: true);
      _loadClaims();
    } else {
      _showSnack(submitResult['message'] ?? 'Submit failed');
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
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
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    )
                  : _grouped.isEmpty
                  ? _buildEmptyState()
                  : _buildClaimsList(),
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
                  '${_allClaims.length} device${_allClaims.length != 1 ? 's' : ''} total',
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

  Widget _buildClaimsList() {
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
    final isUploading = _uploadingBatch[batchId] == true;
    final isSubmitting = _submittingBatch[batchId] == true;
    final selectedPhotos = _pendingPhotos[batchId] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          // Batch Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batch #$batchId',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${claims.length} device${claims.length != 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                _statusBadge(batchStatus),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderGrey),

          // Serial Numbers
          ...claims.map((c) => _buildClaimRow(c)),

          if (batchStatus == 'draft') ...[
            const Divider(height: 1, color: AppColors.borderGrey),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bill Photos',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Photo Grid with delete button
                  if (selectedPhotos.isNotEmpty) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: selectedPhotos.length,
                      itemBuilder: (_, idx) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.small,
                            ),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: AppColors.greyBackground,
                              child: Image.file(
                                selectedPhotos[idx],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removePhoto(batchId, idx),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // Pick + Submit buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isUploading || isSubmitting
                              ? null
                              : () => _pickPhotos(batchId),
                          icon: const Icon(Icons.add_photo_alternate, size: 18),
                          label: Text(
                            selectedPhotos.isEmpty ? 'Add Photos' : 'Add More',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryRed,
                            side: const BorderSide(color: AppColors.primaryRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.small,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (selectedPhotos.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUploading || isSubmitting
                                ? null
                                : () => _uploadAndSubmit(batchId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppBorderRadius.small,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            child: isUploading || isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClaimRow(Map<String, dynamic> claim) {
    final status = claim['status'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.greyBackground,
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: const Center(
              child: Icon(Icons.memory, size: 18, color: AppColors.greyText),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claim['serial_number'] as String,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  claim['product_name'] as String,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'approved':
        bg = Colors.green.withValues(alpha: 0.12);
        fg = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        bg = AppColors.primaryRed.withValues(alpha: 0.12);
        fg = AppColors.primaryRed;
        label = 'Rejected';
        break;
      case 'submitted':
        bg = Colors.blue.withValues(alpha: 0.12);
        fg = Colors.blue;
        label = 'Submitted';
        break;
      case 'draft':
        bg = Colors.amber.withValues(alpha: 0.12);
        fg = Colors.amber.shade800;
        label = 'Draft';
        break;
      default:
        bg = Colors.orange.withValues(alpha: 0.12);
        fg = Colors.orange.shade800;
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
