import 'package:flutter/material.dart';

class QrScanScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onHome;
  final VoidCallback? onLogs;
  final VoidCallback? onProfile;
  final Function(String)? onQrScanned;

  const QrScanScreen({
    super.key,
    this.onClose,
    this.onHome,
    this.onLogs,
    this.onProfile,
    this.onQrScanned,
  });

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanAnimationController;
  late AnimationController _lightingAnimationController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _lightingAnimation;
  late Animation<double> _cornerAnimation;

  bool _isContinuousScanEnabled = false;
  bool _isScanning = false;
  List<String> _scannedData = [];

  @override
  void initState() {
    super.initState();

    // Scan line animation
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Lighting effect animation
    _lightingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _lightingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _lightingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Corner animation
    _cornerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scanAnimationController.repeat();
    _lightingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _lightingAnimationController.dispose();
    super.dispose();
  }

  void _toggleContinuousScan() {
    setState(() {
      _isContinuousScanEnabled = !_isContinuousScanEnabled;
      if (_isContinuousScanEnabled) {
        _startContinuousScan();
      } else {
        _stopContinuousScan();
      }
    });
  }

  void _startContinuousScan() {
    setState(() {
      _isScanning = true;
    });
    // Simulate QR scanning every 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_isContinuousScanEnabled) {
        _simulateQrScan();
        _startContinuousScan(); // Continue scanning
      }
    });
  }

  void _stopContinuousScan() {
    setState(() {
      _isScanning = false;
    });
  }

  void _simulateQrScan() {
    // Simulate scanning a QR code
    final studentData = "Student_${DateTime.now().millisecondsSinceEpoch}";
    setState(() {
      _scannedData.add(studentData);
    });

    // Call the callback with scanned data
    widget.onQrScanned?.call(studentData);

    // Show success feedback
    _showScanSuccess();
  }

  void _showScanSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR Code scanned successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Close Button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Header Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(
                    'QR SCANNER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Scan student QR codes',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main Content Area - QR Scanner
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR Scanner Frame
                    _buildQrScannerFrame(),
                    const SizedBox(height: 40),

                    // Continuous Scan Toggle
                    _buildContinuousScanToggle(),
                    const SizedBox(height: 20),

                    // Scan Status
                    _buildScanStatus(),
                  ],
                ),
              ),
            ),

            // Scanned Data List
            if (_scannedData.isNotEmpty) ...[
              Container(
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Scanned Students:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemCount: _scannedData.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              _scannedData[index],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavItem(Icons.home, 'Home', false, widget.onHome),
                  _buildBottomNavItem(Icons.list, 'Logs', false, widget.onLogs),
                  _buildBottomNavItem(
                    Icons.person,
                    'Profile',
                    false,
                    widget.onProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrScannerFrame() {
    return AnimatedBuilder(
      animation: _lightingAnimationController,
      builder: (context, child) {
        return Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue.withOpacity(
                0.3 + _lightingAnimation.value * 0.4,
              ),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Blue lighting effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(
                        0.1 + _lightingAnimation.value * 0.2,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Corner indicators
              ..._buildCornerIndicators(),

              // Scanning line
              if (_isScanning)
                AnimatedBuilder(
                  animation: _scanAnimationController,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanLineAnimation.value * 246, // 250 - 4 for border
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.blue,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Center QR icon
              Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.blue.withOpacity(
                    0.5 + _lightingAnimation.value * 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCornerIndicators() {
    return [
      // Top-left corner
      Positioned(
        top: 10,
        left: 10,
        child: AnimatedBuilder(
          animation: _cornerAnimation,
          builder: (context, child) {
            return Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                  left: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // Top-right corner
      Positioned(
        top: 10,
        right: 10,
        child: AnimatedBuilder(
          animation: _cornerAnimation,
          builder: (context, child) {
            return Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                  right: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // Bottom-left corner
      Positioned(
        bottom: 10,
        left: 10,
        child: AnimatedBuilder(
          animation: _cornerAnimation,
          builder: (context, child) {
            return Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                  left: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // Bottom-right corner
      Positioned(
        bottom: 10,
        right: 10,
        child: AnimatedBuilder(
          animation: _cornerAnimation,
          builder: (context, child) {
            return Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                  right: BorderSide(
                    color: Colors.blue.withOpacity(
                      0.8 + _cornerAnimation.value * 0.2,
                    ),
                    width: 3,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildContinuousScanToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Continuous Scan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleContinuousScan,
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                color: _isContinuousScanEnabled ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: AnimatedAlign(
                alignment:
                    _isContinuousScanEnabled
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color:
            _isScanning
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isScanning ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isScanning ? 'Scanning...' : 'Ready to scan',
            style: TextStyle(
              color: _isScanning ? Colors.green : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.grey[400], // Light gray for dark theme
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400], // Light gray for dark theme
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
