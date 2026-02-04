import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../constants/app_constants.dart';

enum ScanState { idle, detecting, success, error }

class BarcodeScannerScreen extends StatefulWidget {
  final int totalDevices;
  final List<String> alreadyScanned;

  const BarcodeScannerScreen({
    Key? key,
    required this.totalDevices,
    this.alreadyScanned = const [],
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.code128],
    facing: CameraFacing.back,
  );

  List<String> _scannedSerials = [];
  String? _lastScanned;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannedSerials.addAll(widget.alreadyScanned);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? code = barcode.rawValue;

    if (code == null || code.isEmpty) return;

    // Prevent duplicate processing
    if (_lastScanned == code) return;

    setState(() {
      _isProcessing = true;
      _lastScanned = code;
    });

    // Check if already scanned
    if (_scannedSerials.contains(code)) {
      HapticFeedback.heavyImpact();
      _showSnack('Already scanned: $code', isError: true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      });
      return;
    }

    // Add to list
    setState(() {
      _scannedSerials.add(code);
    });

    HapticFeedback.mediumImpact();

    _showSnack(
      'Scanned ${_scannedSerials.length}/${widget.totalDevices}',
      isSuccess: true,
    );

    // Check if all devices scanned
    if (_scannedSerials.length >= widget.totalDevices) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pop(context, _scannedSerials);
        }
      });
    } else {
      // Reset after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      });
    }
  }

  void _showSnack(String msg, {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
            ? Colors.green
            : AppColors.primaryRed,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          MobileScanner(controller: _controller, onDetect: _onBarcodeDetect),

          // Top bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withValues(alpha: 0.5),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, _scannedSerials),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scan Barcodes',
                          style: AppTextStyles.header3.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${_scannedSerials.length}/${widget.totalDevices} scanned',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Flashlight toggle
                  IconButton(
                    onPressed: () => _controller.toggleTorch(),
                    icon: const Icon(Icons.flashlight_on, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Scan area overlay
          Center(
            child: Container(
              width: 280,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryRed, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_scannedSerials.isNotEmpty) ...[
                    const Text(
                      'Scanned Devices:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _scannedSerials
                          .map(
                            (serial) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                serial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Position the barcode within the frame',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (_scannedSerials.length < widget.totalDevices)
                    Text(
                      'Scan ${widget.totalDevices - _scannedSerials.length} more',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
}
