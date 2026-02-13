import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../services/claim_service.dart';
import '../services/location_service.dart';

class BatchDetailScreen extends StatefulWidget {
  final int batchId;
  final List<Map<String, dynamic>> claims;
  final String batchStatus;

  const BatchDetailScreen({
    Key? key,
    required this.batchId,
    required this.claims,
    required this.batchStatus,
  }) : super(key: key);

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  final ClaimService _claimService = ClaimService();
  final LocationService _locationService = LocationService();
  final ImagePicker _picker = ImagePicker();

  List<File> _billPhotos = [];
  Map<int, File?> _installationPhotos = {};
  Map<int, Map<String, dynamic>?> _locations = {};
  Map<int, bool> _uploadingInstallation = {};

  bool _uploading = false;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBatchInfo(),
                    const SizedBox(height: AppSpacing.md),
                    _buildDevicesList(),
                    if (widget.batchStatus == 'draft') ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildInstallationPhotosSection(),
                      const SizedBox(height: AppSpacing.md),
                      _buildBillPhotosSection(),
                      const SizedBox(height: AppSpacing.md),
                      _buildSubmitButton(),
                    ],
                  ],
                ),
              ),
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
                  'Batch #${widget.batchId}',
                  style: AppTextStyles.header3.copyWith(fontSize: 20),
                ),
                Text(
                  '${widget.claims.length} device${widget.claims.length != 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(widget.batchStatus),
        ],
      ),
    );
  }

  Widget _buildBatchInfo() {
    final firstClaim = widget.claims.first;
    return Container(
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
          Text(
            'Batch Information',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _infoRow('Batch ID', '#${widget.batchId}'),
          _infoRow('Total Devices', '${widget.claims.length}'),
          _infoRow('Status', widget.batchStatus.toUpperCase()),
          _infoRow(
            'Product',
            firstClaim['product_name'] ?? 'Multiple Products',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.greyText),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return Container(
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
          Text(
            'Claimed Devices',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...widget.claims.map((claim) => _buildDeviceItem(claim)),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(Map<String, dynamic> claim) {
    final claimId = claim['claim_id'] as int;
    final hasInstallationPhoto =
        _installationPhotos.containsKey(claimId) ||
        (claim['has_installation_photo'] == true);

    // Check if batch has bill photos
    final hasBillPhotos =
        _billPhotos.isNotEmpty || (widget.batchStatus == 'submitted');

    // Both conditions must be true for green checkmark
    final isComplete = hasInstallationPhoto && hasBillPhotos;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.greyBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.memory,
              size: 20,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claim['serial_number'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  claim['product_name'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          // Show completion status
          if (widget.batchStatus == 'draft')
            Column(
              children: [
                Icon(
                  isComplete
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isComplete ? Colors.green : AppColors.greyText,
                  size: 20,
                ),
                if (!isComplete && hasInstallationPhoto && !hasBillPhotos)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Add bills',
                      style: TextStyle(fontSize: 9, color: AppColors.greyText),
                    ),
                  ),
                if (!isComplete && !hasInstallationPhoto && hasBillPhotos)
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Add photo',
                      style: TextStyle(fontSize: 9, color: AppColors.greyText),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInstallationPhotosSection() {
    return Container(
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
            children: [
              const Icon(Icons.camera_alt, color: AppColors.primaryRed),
              const SizedBox(width: 8),
              Text(
                'Installation Photos',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Capture installation photo for each device',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.greyText),
          ),
          const SizedBox(height: AppSpacing.md),
          ...widget.claims.map((claim) => _buildInstallationPhotoItem(claim)),
        ],
      ),
    );
  }

  Widget _buildInstallationPhotoItem(Map<String, dynamic> claim) {
    final claimId = claim['claim_id'] as int;
    final serialNumber = claim['serial_number'] as String;
    final photo = _installationPhotos[claimId];
    final isUploading = _uploadingInstallation[claimId] == true;
    final hasExisting = claim['has_installation_photo'] == true;

    if (hasExisting && photo == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                serialNumber,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              'Uploaded ✓',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: photo != null
            ? Colors.green.withValues(alpha: 0.05)
            : AppColors.greyBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
        border: Border.all(
          color: photo != null ? Colors.green : AppColors.borderGrey,
          width: photo != null ? 2 : 1,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (photo == null)
                ElevatedButton.icon(
                  onPressed: isUploading ? null : () => _capturePhoto(claimId),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    photo,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  onPressed: () => _removePhoto(claimId),
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _capturePhoto(int claimId) async {
    setState(() => _uploadingInstallation[claimId] = true);

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) {
        setState(() => _uploadingInstallation[claimId] = false);
        return;
      }

      final location = await _locationService.getCurrentLocation();

      if (location == null) {
        _showSnack('Could not get location');
        setState(() => _uploadingInstallation[claimId] = false);
        return;
      }

      setState(() {
        _installationPhotos[claimId] = File(image.path);
        _locations[claimId] = location;
        _uploadingInstallation[claimId] = false;
      });

      _showSnack('Photo captured!', isSuccess: true);
    } catch (e) {
      setState(() => _uploadingInstallation[claimId] = false);
      _showSnack('Error: $e');
    }
  }

  void _removePhoto(int claimId) {
    setState(() {
      _installationPhotos.remove(claimId);
      _locations.remove(claimId);
    });
  }

  Widget _buildBillPhotosSection() {
    return Container(
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
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primaryRed),
              const SizedBox(width: 8),
              Text(
                'Bill Photos',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Upload purchase bills for verification',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.greyText),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_billPhotos.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _billPhotos.length,
              itemBuilder: (_, idx) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _billPhotos[idx],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removeBillPhoto(idx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickBillPhotos,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_billPhotos.isEmpty ? 'Add Bill Photos' : 'Add More'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                side: const BorderSide(color: AppColors.primaryRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBillPhotos() async {
    final source = await _showSourceDialog();
    if (source == null) return;

    List<File> files = [];

    if (source == ImageSource.camera) {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) files.add(File(image.path));
    } else {
      final images = await _picker.pickMultiImage();
      files = images.map((img) => File(img.path)).toList();
    }

    if (files.isEmpty) return;

    setState(() {
      _billPhotos.addAll(files);
    });
  }

  void _removeBillPhoto(int index) {
    setState(() {
      _billPhotos.removeAt(index);
    });
  }

  Future<ImageSource?> _showSourceDialog() async {
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
              'Add Photos',
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
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    // ✅ Check all claims have installation photos
    final allInstallationPhotosCaptured = widget.claims.every((claim) {
      final claimId = claim['claim_id'] as int;
      return _installationPhotos.containsKey(claimId) ||
          (claim['has_installation_photo'] == true);
    });

    // ✅ Check bill photos are uploaded
    final hasBillPhotos = _billPhotos.isNotEmpty;

    // ✅ Both conditions must be met
    final canSubmit = _billPhotos.isNotEmpty && allInstallationPhotosCaptured;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_uploading || _submitting || !canSubmit)
            ? null
            : _submitBatch,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSubmit ? Colors.green : AppColors.borderGrey,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
        ),
        child: _uploading || _submitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canSubmit
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canSubmit
                        ? 'Submit for Review'
                        : !hasBillPhotos
                        ? 'Add Bill Photos'
                        : 'Add Installation Photos',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitBatch() async {
    setState(() => _uploading = true);

    // Upload bills
    final billResult = await _claimService.uploadDocuments(
      batchId: widget.batchId,
      photos: _billPhotos,
    );

    if (!mounted) return;

    if (billResult['success'] != true) {
      setState(() => _uploading = false);
      _showSnack(billResult['message'] ?? 'Bill upload failed');
      return;
    }

    // Upload installation photos
    final installationData = <Map<String, dynamic>>[];
    for (final claim in widget.claims) {
      final claimId = claim['claim_id'] as int;
      final photo = _installationPhotos[claimId];
      final location = _locations[claimId];

      if (photo != null) {
        installationData.add({
          'claim_id': claimId,
          'photo': photo,
          'latitude': location?['latitude'],
          'longitude': location?['longitude'],
          'address': location?['address'],
        });
      }
    }

    if (installationData.isNotEmpty) {
      final installResult = await _claimService.uploadInstallationPhotos(
        photos: installationData,
      );

      if (!mounted) return;

      if (installResult['success'] != true) {
        setState(() => _uploading = false);
        _showSnack(installResult['message'] ?? 'Installation upload failed');
        return;
      }
    }

    // Submit batch
    setState(() {
      _uploading = false;
      _submitting = true;
    });

    final submitResult = await _claimService.submitBatch(
      batchId: widget.batchId,
    );

    if (!mounted) return;

    setState(() => _submitting = false);

    if (submitResult['success'] == true) {
      _showSnack('Claim submitted successfully!', isSuccess: true);
      Navigator.pop(context, true); // Return true to trigger refresh
    } else {
      _showSnack(submitResult['message'] ?? 'Submit failed');
    }
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
}
