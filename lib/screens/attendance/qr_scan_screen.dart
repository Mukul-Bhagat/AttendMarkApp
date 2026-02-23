import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/attendance_provider.dart';
import '../../config/theme.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/device_id.dart';
import 'dart:io';

/// QR Scan Screen
/// Scans QR code and marks attendance
/// Handles camera permissions, GPS location, and device ID
class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});
  
  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;
  bool _hasCameraPermission = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  /// Check camera permission
  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isDenied) {
        // Request permission
        final result = await Permission.camera.request();
        setState(() {
          _hasCameraPermission = result.isGranted;
          if (!_hasCameraPermission) {
            _errorMessage = 'Camera permission is required to scan QR codes. Please grant camera permission in app settings.';
          }
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _hasCameraPermission = false;
          _errorMessage = 'Camera permission is permanently denied. Please enable camera access in app settings.';
        });
      } else {
        setState(() {
          _hasCameraPermission = status.isGranted;
        });
      }
    } catch (e) {
      Logger.e('QRScanScreen', 'Failed to check camera permission', e);
      setState(() {
        _hasCameraPermission = false;
        _errorMessage = 'Failed to check camera permission. Please try again.';
      });
    }
  }
  
  /// Handle QR code scan
  Future<void> _handleScan(String? code) async {
    if (code == null || code.isEmpty || _isProcessing) {
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    
    try {
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

      Logger.i('QRScanScreen', 'QR Code scanned: $code');
      
      // Extract session ID from QR code
      // QR code format: sessionId or full URL with sessionId
      String sessionId = code.trim();
      if (sessionId.contains('/')) {
        // Extract session ID from URL
        final parts = sessionId.split('/');
        sessionId = parts.last;
      }
      
      Logger.d('QRScanScreen', 'Extracted session ID: $sessionId');
      
      // Get device ID and user agent
      final deviceId = await DeviceId.getOrCreateDeviceId();
      final userAgent = 'AttendMark-Flutter/${Platform.operatingSystem}';
      
      Logger.d('QRScanScreen', 'Device ID: $deviceId');
      Logger.d('QRScanScreen', 'User Agent: $userAgent');
      
      // Mark attendance (this will get GPS location automatically)
      await attendanceProvider.markAttendance(
        sessionId: sessionId,
        deviceId: deviceId,
        userAgent: userAgent,
      );
      
      // Stop camera
      await _controller.stop();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Attendance marked successfully!'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate back after short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      Logger.e('QRScanScreen', 'Failed to mark attendance', e);
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      
      // Resume scanning after error
      if (mounted) {
        await _controller.start();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
      ),
      body: _hasCameraPermission
          ? Stack(
              children: [
                // Camera view
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _handleScan(barcode.rawValue);
                        break;
                      }
                    }
                  },
                ),
                
                // Overlay with scanning area
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isProcessing ? AppTheme.warning : AppTheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                // Processing overlay
                if (_isProcessing || attendanceProvider.isLoading || attendanceProvider.isGettingLocation)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            attendanceProvider.isGettingLocation
                                ? 'Getting your location...'
                                : attendanceProvider.isLoading
                                    ? 'Marking attendance...'
                                    : 'Processing...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Error message
                if (_errorMessage != null)
                  Positioned(
                    bottom: 100,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Instructions
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Position the QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Camera Permission Required',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Camera permission is required to scan QR codes.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _checkCameraPermission,
                      child: const Text('Grant Permission'),
                    ),
                    if (_errorMessage != null && _errorMessage!.contains('permanently'))
                      const SizedBox(height: 16),
                    if (_errorMessage != null && _errorMessage!.contains('permanently'))
                      OutlinedButton(
                        onPressed: () => openAppSettings(),
                        child: const Text('Open Settings'),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

