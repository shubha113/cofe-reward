import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/claim_service.dart';
import 'barcode_scanner_screen.dart';

class ClaimDevicesScreen extends StatefulWidget {
  final int productId;
  final int initialCount;

  const ClaimDevicesScreen({
    Key? key,
    required this.productId,
    this.initialCount = 1,
  }) : super(key: key);

  @override
  State<ClaimDevicesScreen> createState() => _ClaimDevicesScreenState();
}

class _ClaimDevicesScreenState extends State<ClaimDevicesScreen> {
  final ClaimService _claimService = ClaimService();

  late int _deviceCount;
  bool _isValidating = false;
  bool _validated = false;
  int? _batchId;

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  Map<String, String> _serialStatuses = {};

  @override
  void initState() {
    super.initState();
    _deviceCount = widget.initialCount;
    _syncControllers();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _syncControllers() {
    while (_controllers.length < _deviceCount) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    while (_controllers.length > _deviceCount) {
      _controllers.removeLast().dispose();
      _focusNodes.removeLast().dispose();
    }
  }

  // SCAN SINGLE BARCODE FOR SPECIFIC INPUT
  Future<void> _scanSingleBarcode(int index) async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BarcodeScannerScreen(totalDevices: 1, alreadyScanned: []),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _controllers[index].text = result.first;
        _validated = false;
        _serialStatuses.clear();
        _batchId = null;
      });
    }
  }

  // SCAN ALL BARCODES AT ONCE
  Future<void> _scanAllBarcodes() async {
    // Get already filled serials
    final alreadyScanned = _controllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => BarcodeScannerScreen(
          totalDevices: _deviceCount,
          alreadyScanned: alreadyScanned,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        for (int i = 0; i < result.length && i < _deviceCount; i++) {
          _controllers[i].text = result[i];
        }
        _validated = false;
        _serialStatuses.clear();
        _batchId = null;
      });
    }
  }

  Future<void> _validateSerials() async {
    final serials = _controllers.map((c) => c.text.trim()).toList();
    final emptyIndex = serials.indexWhere((s) => s.isEmpty);
    if (emptyIndex >= 0) {
      _focusNodes[emptyIndex].requestFocus();
      _showSnack('Please fill Serial Number ${emptyIndex + 1}');
      return;
    }

    setState(() {
      _isValidating = true;
      _validated = false;
      _serialStatuses.clear();
      _batchId = null;
    });

    final result = await _claimService.validateSerials(
      productId: widget.productId,
      serialNumbers: serials,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final Map<String, String> statuses = {};
      for (final r in result['results']) {
        statuses[r['serial_number']] = r['status'];
      }

      setState(() {
        _serialStatuses = statuses;
        _batchId = result['batch_id'];
        _validated = true;
        _isValidating = false;
      });

      final allValid = statuses.values.every((s) => s == 'valid');
      if (allValid) {
        _showSnack(
          '✓ All ${serials.length} device(s) successfully claimed!',
          isSuccess: true,
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/my-claims',
            ).then((_) {
              Navigator.pop(context);
            });
          }
        });
      } else {
        // Show error summary
        final invalidCount = statuses.values.where((s) => s != 'valid').length;
        _showSnack('$invalidCount serial number(s) have errors');
      }
    } else {
      setState(() {
        _isValidating = false;
      });
      _showSnack(result['message'] ?? 'Validation failed');
    }
  }

  String? _getStatusForIndex(int index) {
    final serial = _controllers[index].text.trim();
    if (serial.isEmpty || !_validated) return null;
    return _serialStatuses[serial];
  }

  void _goToMyClaims() {
    Navigator.pushReplacementNamed(context, '/my-claims');
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSerialInputs(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildActionButton(),
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
                  'Claim Devices',
                  style: AppTextStyles.header3.copyWith(fontSize: 20),
                ),
                Text(
                  'Enter serial numbers for $_deviceCount device${_deviceCount > 1 ? 's' : ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CARD WITH SCAN ALL BUTTON
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_deviceCount Device${_deviceCount > 1 ? 's' : ''} Selected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scan or enter serial numbers below',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // SCAN ALL BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _scanAllBarcodes,
              icon: const Icon(Icons.qr_code_scanner, size: 22),
              label: Text(
                'Scan All $_deviceCount Barcodes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSerialInputs() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Serial Numbers',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_validated)
                Text(
                  '${_serialStatuses.values.where((s) => s == "valid").length}/$_deviceCount valid',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(_deviceCount, (i) => _buildSerialInput(i)),
        ],
      ),
    );
  }

  Widget _buildSerialInput(int index) {
    final status = _getStatusForIndex(index);
    final bool hasError = status != null && status != 'valid';
    final bool isValid = status == 'valid';

    Color borderColor = AppColors.borderGrey;
    Color fillColor = AppColors.white;
    if (hasError) {
      borderColor = AppColors.primaryRed;
      fillColor = AppColors.primaryRed.withValues(alpha: 0.04);
    } else if (isValid) {
      borderColor = Colors.green;
      fillColor = Colors.green.withValues(alpha: 0.04);
    }

    String? errorText;
    if (status == 'invalid') errorText = 'Invalid serial number';
    if (status == 'already_claimed') errorText = 'Already claimed';
    if (status == 'wrong_product') errorText = 'Wrong product serial';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isValid
                    ? Colors.green
                    : hasError
                    ? AppColors.primaryRed
                    : AppColors.greyBackground,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: (isValid || hasError)
                        ? AppColors.white
                        : AppColors.greyText,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  border: Border.all(
                    color: borderColor,
                    width: hasError || isValid ? 2 : 1,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () => _scanSingleBarcode(index),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppBorderRadius.medium),
                          bottomLeft: Radius.circular(AppBorderRadius.medium),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.selectedBackground,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                AppBorderRadius.medium - 1,
                              ),
                              bottomLeft: Radius.circular(
                                AppBorderRadius.medium - 1,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primaryRed,
                            size: 24,
                          ),
                        ),
                      ),

                      // Vertical divider
                      Container(
                        width: 1,
                        height: 48,
                        color: AppColors.borderGrey,
                      ),

                      // Text field
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          style: AppTextStyles.inputText,
                          onChanged: (_) {
                            if (_validated) {
                              setState(() {
                                _validated = false;
                                _serialStatuses.clear();
                                _batchId = null;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Serial number ${index + 1}',
                            hintStyle: AppTextStyles.inputHint,
                            suffixIcon: isValid
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : hasError
                                ? const Icon(
                                    Icons.error,
                                    color: AppColors.primaryRed,
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 4),
            child: Text(
              errorText,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildActionButton() {
    final allValid =
        _validated && _serialStatuses.values.every((s) => s == 'valid');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isValidating
            ? null
            : allValid
            ? _goToMyClaims
            : _validateSerials,
        style: ElevatedButton.styleFrom(
          backgroundColor: allValid ? Colors.green : AppColors.primaryRed,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.borderGrey,
        ),
        child: _isValidating
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allValid ? Icons.shopping_cart : Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allValid ? 'Go to My Claims →' : 'Validate Serial Numbers',
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
}
