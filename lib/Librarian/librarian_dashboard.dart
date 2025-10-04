import 'package:flutter/material.dart';
import 'package:test_app1/Librarian/bottom_nav_bar_librarian.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app1/services/library_service.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/log_service.dart';
import 'dart:math' as math;
import 'package:test_app1/nfc_scan.dart';

class LibrarianDashboard extends StatefulWidget {
  const LibrarianDashboard({
    super.key,
  });

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard>
    with TickerProviderStateMixin {
  late AnimationController _nfcAnimationController;
  late Animation<double> _nfcWaveAnimation;
  late Animation<double> _nfcPulseAnimation;

  final bool _isNfcScanning = false;
  String _selectedTab = 'Issue Book';
  String? _currentUserId;

  @override
  void initState() {
    super.initState();

    _nfcAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _nfcWaveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _nfcAnimationController, curve: Curves.easeInOut),
    );

    _nfcPulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _nfcAnimationController, curve: Curves.easeInOut),
    );
    _currentUserId = FirebaseService.currentUserId;
  }

  @override
  void dispose() {
    _nfcAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Librarian',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the header
                ],
              ),
            ),

            // Tab Navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  _buildTab('Issue Book', _selectedTab == 'Issue Book'),
                  const SizedBox(width: 32),
                  _buildTab('Return Book', _selectedTab == 'Return Book'),
                  const SizedBox(width: 32),
                  _buildTab('Active Issues', _selectedTab == 'Active Issues'),
                ],
              ),
            ),

            const Divider(color: Color(0xFFE0E0E0), height: 1),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: () {
                  switch (_selectedTab) {
                    case 'Issue Book':
                      return _buildIssueBookContent(context);
                    case 'Return Book':
                      return _buildReturnBookContent();
                    case 'Active Issues':
                      return _buildActiveIssues();
                    default:
                      return const SizedBox.shrink();
                  }
                }(),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BottomNavBarLibrarian(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF20B2AA), // Teal color
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'View Issued Books',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF20B2AA), // Teal color
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Export Ledger',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildIssueBookContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scan Zone Section
        const Text(
          'Scan Zone',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Scan QR Option
        _buildScanOption(
          icon: Icons.qr_code_scanner,
          title: 'Scan QR',
          onTap: () {},
        ),
        const SizedBox(height: 12),

        // Scan NFC Option
        _buildScanOption(
          icon: Icons.nfc,
          title: 'Scan NFC',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NfcScanScreen()),
            );
          },
          isNfc: true,
        ),

        const SizedBox(height: 32),

        // Today's Issued Books Section
        const Text(
          "Today's Issued Books",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Book List
        _buildBookItem(
          'The Great Gatsby',
          'Issued: 1',
          _buildBookCover1(),
        ),
        const SizedBox(height: 12),
        _buildBookItem(
          'To Kill a Mockingbird',
          'Issued: 1',
          _buildBookCover2(),
        ),
      ],
    );
  }

  Widget _buildReturnBookContent() {
    return const Center(
      child: Text(
        'Return Book Content',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildActiveIssues() {
    final uid = _currentUserId;
    if (uid == null) {
      return const Center(child: Text('Not signed in'));
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: LibraryService.activeIssuesStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final issues = snapshot.data ?? [];
        if (issues.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text('No active issues.')),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Issues',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            for (final issue in issues) _buildIssueRow(issue),
          ],
        );
      },
    );
  }

  Widget _buildIssueRow(Map<String, dynamic> issue) {
    final issueId = (issue['issueId'] ?? '') as String;
    final bookTitle = (issue['bookTitle'] ?? 'Unknown') as String;
    final dueTs = issue['dueDate'];
    DateTime? due;
    if (dueTs is Timestamp) {
      due = dueTs.toDate().toLocal();
    } else if (dueTs is String && dueTs.isNotEmpty) {
      try {
        due = DateTime.parse(dueTs).toLocal();
      } catch (_) {}
    }
    final overdue = due != null && due.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                if (due != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${due.toString().split(' ').first}${overdue ? ' (Overdue)' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: overdue ? Colors.red : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: issueId.isEmpty ? null : () async {
                try {
                  await LibraryService.markReturned(issueId);
                } catch (e) {
                  LogService.warning('Failed to mark returned: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Return',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              height: 2,
              color: Colors.black,
            ),
        ],
      ),
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isNfc = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child:
                  isNfc && _isNfcScanning
                      ? _buildNfcAnimation()
                      : Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcAnimation() {
    return AnimatedBuilder(
      animation: _nfcAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _nfcPulseAnimation.value,
          child: CustomPaint(
            size: const Size(40, 40),
            painter: NfcCurvesPainter(animationValue: _nfcWaveAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildBookItem(String title, String issued, Widget cover) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: cover,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  issued,
                  style: const TextStyle(
                    color: Color(0xFF20B2AA), // Teal color
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover1() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6D3), // Light beige
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 2,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover2() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8), // Light green
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: CustomPaint(size: const Size(24, 24), painter: PlantPainter()),
      ),
    );
  }
}

class NfcCurvesPainter extends CustomPainter {
  final double animationValue;

  NfcCurvesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF20B2AA) // Teal color
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw NFC signal curves
    _drawCurvedLine(canvas, center, 16, 0.6, paint);
    _drawCurvedLine(canvas, center, 12, 0.5, paint);
    _drawCurvedLine(canvas, center, 8, 0.4, paint);

    // Draw center dot
    canvas.drawCircle(center, 2, paint);
  }

  void _drawCurvedLine(
    Canvas canvas,
    Offset center,
    double radius,
    double arcHeight,
    Paint paint,
  ) {
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: radius * 2 * arcHeight,
    );

    canvas.drawArc(rect, 0, math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PlantPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF4CAF50) // Green color
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..color = const Color(0xFF4CAF50)
          ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem
    canvas.drawLine(
      Offset(center.dx, center.dy + 8),
      Offset(center.dx, center.dy - 4),
      paint,
    );

    // Draw leaves
    _drawLeaf(canvas, Offset(center.dx - 3, center.dy - 2), fillPaint);
    _drawLeaf(canvas, Offset(center.dx + 3, center.dy - 1), fillPaint);
    _drawLeaf(canvas, Offset(center.dx - 2, center.dy + 1), fillPaint);
    _drawLeaf(canvas, Offset(center.dx + 2, center.dy + 2), fillPaint);
  }

  void _drawLeaf(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    path.moveTo(position.dx, position.dy);
    path.quadraticBezierTo(
      position.dx + 2,
      position.dy - 2,
      position.dx + 4,
      position.dy,
    );
    path.quadraticBezierTo(
      position.dx + 2,
      position.dy + 2,
      position.dx,
      position.dy,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
