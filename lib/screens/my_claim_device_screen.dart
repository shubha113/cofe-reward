import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../services/claim_service.dart';
import '../services/location_service.dart';

class MyClaimsScreen extends StatefulWidget {
  const MyClaimsScreen({Key? key}) : super(key: key);

  @override
  State<MyClaimsScreen> createState() => _MyClaimsScreenState();
}

class _MyClaimsScreenState extends State<MyClaimsScreen> {
  final ClaimService _claimService = ClaimService();
  final LocationService _locationService = LocationService();
  final ImagePicker _picker = ImagePicker();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _allClaims = [];
  Map<int, List<Map<String, dynamic>>> _grouped = {};

  // Bill photos (batch level)
  Map<int, List<File>> _pendingBillPhotos = {};

  // Installation photos (per claim)
  Map<int, File?> _pendingInstallationPhotos = {};
  Map<int, Map<String, dynamic>?> _installationLocations =
      {}; // claim_id → location data

  Map<int, bool> _uploadingBatch = {};
  Map<int, bool> _submittingBatch = {};
  Map<int, bool> _uploadingInstallation = {}; // claim_id → uploading state

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

  // Pick bill photos (batch level)
  Future<void> _pickBillPhotos(int batchId) async {
    final ImageSource? source = await _showPhotoSourceDialog();
    if (source == null) return;

    List<File> files = [];

    if (source == ImageSource.camera) {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) files.add(File(image.path));
    } else {
      final images = await _picker.pickMultiImage();
      files = images.map<File>((img) => File(img.path)).toList();
    }

    if (files.isEmpty) return;

    setState(() {
      _pendingBillPhotos.putIfAbsent(batchId, () => <File>[]);
      _pendingBillPhotos[batchId]!.addAll(files);
    });
  }

  void _removeBillPhoto(int batchId, int photoIndex) {
    setState(() {
      _pendingBillPhotos[batchId]?.removeAt(photoIndex);
      if (_pendingBillPhotos[batchId]?.isEmpty ?? false) {
        _pendingBillPhotos.remove(batchId);
      }
    });
  }

  // Capture installation photo with location
  Future<void> _captureInstallationPhoto(int claimId) async {
    setState(() => _uploadingInstallation[claimId] = true);

    try {
      // CAPTURE PHOTO FIRST (prevents ADB disconnect)
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        setState(() => _uploadingInstallation[claimId] = false);
        return;
      }

      // GET LOCATION AFTER CAMERA CLOSES
      final location = await _locationService.getCurrentLocation();

      if (location == null) {
        _showSnack('Could not get location. Please enable location services.');
        setState(() => _uploadingInstallation[claimId] = false);
        return;
      }

      // SAVE PHOTO + LOCATION
      setState(() {
        _pendingInstallationPhotos[claimId] = File(image.path);
        _installationLocations[claimId] = location;
        _uploadingInstallation[claimId] = false;
      });

      _showSnack('Installation photo captured with location!', isSuccess: true);
    } catch (e) {
      setState(() => _uploadingInstallation[claimId] = false);
      _showSnack('Error: $e');
    }
  }

  void _removeInstallationPhoto(int claimId) {
    setState(() {
      _pendingInstallationPhotos.remove(claimId);
      _installationLocations.remove(claimId);
    });
  }

  // Upload all photos and submit batch
  Future<void> _uploadAndSubmit(
    int batchId,
    List<Map<String, dynamic>> claims,
  ) async {
    // Validate bill photos
    final billPhotos = _pendingBillPhotos[batchId] ?? [];
    if (billPhotos.isEmpty) {
      _showSnack('Please add at least 1 bill photo');
      return;
    }

    // Validate installation photos for each claim
    for (final claim in claims) {
      final claimId = claim['claim_id'] as int;
      if (!_pendingInstallationPhotos.containsKey(claimId)) {
        _showSnack(
          'Please capture installation photo for device: ${claim['serial_number']}',
        );
        return;
      }
    }

    setState(() => _uploadingBatch[batchId] = true);

    // Upload bill photos
    final billUploadResult = await _claimService.uploadDocuments(
      batchId: batchId,
      photos: billPhotos,
    );

    if (!mounted) return;

    if (billUploadResult['success'] != true) {
      setState(() => _uploadingBatch[batchId] = false);
      _showSnack(billUploadResult['message'] ?? 'Bill upload failed');
      return;
    }

    // Upload installation photos with location
    final installationPhotosData = <Map<String, dynamic>>[];

    for (final claim in claims) {
      final claimId = claim['claim_id'] as int;
      final photo = _pendingInstallationPhotos[claimId];
      final location = _installationLocations[claimId];

      if (photo != null) {
        installationPhotosData.add({
          'claim_id': claimId,
          'photo': photo,
          'latitude': location?['latitude'],
          'longitude': location?['longitude'],
        });
      }
    }

    final installationUploadResult = await _claimService
        .uploadInstallationPhotos(photos: installationPhotosData);

    if (!mounted) return;

    if (installationUploadResult['success'] != true) {
      setState(() => _uploadingBatch[batchId] = false);
      _showSnack(
        installationUploadResult['message'] ??
            'Installation photo upload failed',
      );
      return;
    }

    // Submit batch
    setState(() {
      _uploadingBatch[batchId] = false;
      _submittingBatch[batchId] = true;
    });

    final submitResult = await _claimService.submitBatch(batchId: batchId);

    if (!mounted) return;

    setState(() => _submittingBatch[batchId] = false);

    if (submitResult['success'] == true) {
      _pendingBillPhotos.remove(batchId);
      // Remove installation photos for this batch
      for (final claim in claims) {
        final claimId = claim['claim_id'] as int;
        _pendingInstallationPhotos.remove(claimId);
        _installationLocations.remove(claimId);
      }
      _showSnack('Claim submitted for review!', isSuccess: true);
      _loadClaims();
    } else {
      _showSnack(submitResult['message'] ?? 'Submit failed');
    }
  }

  Future<ImageSource?> _showPhotoSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
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
            color: Colors.black.withOpacity(0.06),
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
    final selectedBillPhotos = _pendingBillPhotos[batchId] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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

          // Serial Numbers with Installation Photo Status
          ...claims.map((c) => _buildClaimRow(c, batchStatus)),

          // Upload sections (only for draft)
          if (batchStatus == 'draft') ...[
            const Divider(height: 1, color: AppColors.borderGrey),

            // ✅ Installation Photos Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Installation Photos (Required)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...claims.map(
                    (claim) => _buildInstallationPhotoSection(claim),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.borderGrey),

            // Bill Photos Section
            _buildBillPhotosSection(
              batchId,
              selectedBillPhotos,
              isUploading,
              isSubmitting,
            ),

            // Submit Button
            if (selectedBillPhotos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isUploading || isSubmitting
                        ? null
                        : () => _uploadAndSubmit(batchId, claims),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.medium,
                        ),
                      ),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text(
                                'Submit All for Review',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool _allInstallationPhotosCaptured(List<Map<String, dynamic>> claims) {
    for (final claim in claims) {
      final claimId = claim['claim_id'] as int;
      if (!_pendingInstallationPhotos.containsKey(claimId)) {
        return false;
      }
    }
    return true;
  }

  Widget _buildClaimRow(Map<String, dynamic> claim, String batchStatus) {
    final status = claim['status'] as String;
    final claimId = claim['claim_id'] as int;
    final hasInstallationPhoto =
        _pendingInstallationPhotos.containsKey(claimId) ||
        (claim['has_installation_photo'] == true);

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
          // Installation photo indicator
          if (batchStatus == 'draft')
            Icon(
              hasInstallationPhoto
                  ? Icons.camera_alt
                  : Icons.camera_alt_outlined,
              color: hasInstallationPhoto ? Colors.green : AppColors.greyText,
              size: 20,
            ),
          const SizedBox(width: AppSpacing.sm),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _buildInstallationPhotoSection(Map<String, dynamic> claim) {
    final claimId = claim['claim_id'] as int;
    final serialNumber = claim['serial_number'] as String;
    final photo = _pendingInstallationPhotos[claimId];
    final location = _installationLocations[claimId];
    final isUploading = _uploadingInstallation[claimId] == true;
    final hasExistingPhoto = claim['has_installation_photo'] == true;

    if (hasExistingPhoto && photo == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$serialNumber - Photo uploaded ✓',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: photo != null
              ? Colors.green.withOpacity(0.05)
              : AppColors.greyBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(
            color: photo != null ? Colors.green : AppColors.borderGrey,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    serialNumber,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (photo == null)
                  ElevatedButton.icon(
                    onPressed: isUploading
                        ? null
                        : () => _captureInstallationPhoto(claimId),
                    icon: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_a_photo, size: 16),
                    label: Text(
                      isUploading ? 'Capturing...' : 'Capture',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
              ],
            ),
            if (photo != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      photo,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Location info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (location != null) ...[
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.green,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Location captured',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Remove button
                  IconButton(
                    onPressed: () => _removeInstallationPhoto(claimId),
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillPhotosSection(
    int batchId,
    List<File> selectedPhotos,
    bool isUploading,
    bool isSubmitting,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Photos',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          if (selectedPhotos.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: selectedPhotos.length,
              itemBuilder: (_, idx) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.greyBackground,
                      child: Image.file(selectedPhotos[idx], fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removeBillPhoto(batchId, idx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
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

            const SizedBox(height: AppSpacing.md),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isUploading || isSubmitting
                    ? null
                    : () => _pickBillPhotos(batchId),
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: Text(
                  selectedPhotos.isEmpty
                      ? 'Add Bill Photos'
                      : 'Add More Photos',
                  style: const TextStyle(fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryRed,
                  side: const BorderSide(color: AppColors.primaryRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
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
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        bg = AppColors.primaryRed.withOpacity(0.12);
        fg = AppColors.primaryRed;
        label = 'Rejected';
        break;
      case 'submitted':
        bg = Colors.blue.withOpacity(0.12);
        fg = Colors.blue;
        label = 'Submitted';
        break;
      case 'draft':
        bg = Colors.amber.withOpacity(0.12);
        fg = Colors.amber.shade800;
        label = 'Draft';
        break;
      default:
        bg = Colors.orange.withOpacity(0.12);
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
