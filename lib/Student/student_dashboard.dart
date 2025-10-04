import 'package:flutter/material.dart';
import 'package:test_app1/services/firebase_service.dart';
import 'package:test_app1/services/attendance_service.dart';
import 'package:test_app1/services/classes_service.dart';

class _AttendanceData {
  final Map<String, dynamic> attendanceClasses; // classId -> {presentCount,totalCount}
  final List<Map<String, dynamic>> userClasses; // list of class docs
  const _AttendanceData({required this.attendanceClasses, required this.userClasses});
  bool get hasUserClasses => userClasses.isNotEmpty;
}

class _SubjectDef {
  final String label;
  final String classId;
  final String asset;
  const _SubjectDef(this.label, this.classId, this.asset);
}

class StudentDashboard extends StatefulWidget {
  final VoidCallback? onSettings;
  final VoidCallback? onViewSubject;
  final VoidCallback? onViewMissedClasses;
  final VoidCallback? onViewAttendancePredictor;
  final VoidCallback? onViewDocuments;

  const StudentDashboard({
    super.key,
    this.onSettings,
    this.onViewSubject,
    this.onViewMissedClasses,
    this.onViewAttendancePredictor,
    this.onViewDocuments,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late Future<_AttendanceData> _attendanceFuture;
  static const _seedEmail = 'legendary.squad.0216@gmail.com';

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _loadAttendance();
  }

  Future<_AttendanceData> _loadAttendance() async {
    final userId = FirebaseService.currentUserId;
  if (userId == null) return const _AttendanceData(attendanceClasses: {}, userClasses: []);

    // Ensure aggregate doc exists
    await AttendanceService.ensureUserAggregate(userId);
    var attendanceMap = await AttendanceService.fetchUserAggregate(userId);

    // Fallback: if aggregate empty, attempt mirror collection
    if (attendanceMap.isEmpty) {
      try {
          final mirror = await FirebaseService.firestore
              .collection(AttendanceService.mirrorCollection)
              .doc(userId)
              .get();
        if (mirror.exists) {
          final data = mirror.data() ?? {};
          attendanceMap = (data['classes'] as Map<String, dynamic>? ?? {});
        }
      } catch (_) {}
    }

    // Always mirror (will create collection if first time)
    try {
      await AttendanceService.mirrorUserAggregate(userId, attendanceMap);
    } catch (_) {}

    // If still empty after mirror, perform a quick demo seed (generic) then refetch.
    if (attendanceMap.isEmpty) {
      await AttendanceService.quickDemoSeed(userId: userId);
      attendanceMap = await AttendanceService.fetchUserAggregate(userId);
      try { await AttendanceService.mirrorUserAggregate(userId, attendanceMap); } catch (_) {}
    }

    // Fetch user classes (enrolled) via ClassesService
    List<Map<String, dynamic>> userClasses = [];
    try {
      userClasses = await ClassesService.fetchClassesForUser(userId);
    } catch (_) {}

    // Dev seeding for specific email only (idempotent)
    final email = FirebaseService.currentUser?.email;
    if (email == _seedEmail) {
      final needsSeed = _needsSeeding(attendanceMap);
      if (needsSeed) {
        await AttendanceService.seedAttendanceForUser(
          userId: userId,
          email: email!,
          existingClasses: attendanceMap,
        );
        // Refetch after seeding
        attendanceMap = await AttendanceService.fetchUserAggregate(userId);
      }
    }
    return _AttendanceData(attendanceClasses: attendanceMap, userClasses: userClasses);
  }

  bool _needsSeeding(Map<String, dynamic> classes) {
    // If any of the target class IDs have totalCount < 10, we seed.
    const targets = ['MATH101', 'SCI101', 'HIS101', 'ENG101', 'ART101'];
    for (final id in targets) {
      final stats = classes[id] as Map<String, dynamic>?;
      final total = (stats?['totalCount'] as num?)?.toInt() ?? 0;
      if (total < 10) return true;
    }
    return false;
  }

  Future<String> _fetchUserName() async {
    final uid = FirebaseService.currentUserId;
    if (uid == null) return 'User';
    try {
      final doc = await FirebaseService.firestore.collection('users').doc(uid).get();
      if (!doc.exists) return 'User';
      final data = doc.data() ?? {};
      return (data['name'] ?? data['displayName'] ?? 'User').toString();
    } catch (_) {
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Attendance',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onSettings,
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Welcome name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FutureBuilder<String>(
                  future: _fetchUserName(),
                  builder: (context, snapshot) {
                    final name = snapshot.data ?? 'User';
                    return Text(
                      'Welcome, $name',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic attendance subjects
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FutureBuilder<_AttendanceData>(
                  future: _attendanceFuture,
                  builder: (context, snapshot) {
                    final loading = snapshot.connectionState == ConnectionState.waiting;
                    final data = snapshot.data;
                    final attendanceMap = data?.attendanceClasses ?? {};
                    final userClasses = data?.userClasses ?? [];

                    if (loading) {
                      return const Center(
                        child: SizedBox(
                          height: 32,
                          width: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    // If no enrolled classes, fallback to legacy static subjects list.
                    if (userClasses.isEmpty) {
                      final fallback = const [
                        _SubjectDef('Math', 'MATH101', 'lib/assets/math_student.png'),
                        _SubjectDef('Science', 'SCI101', 'lib/assets/science_student.png'),
                        _SubjectDef('History', 'HIS101', 'lib/assets/history_student.png'),
                        _SubjectDef('English', 'ENG101', 'lib/assets/english_student.png'),
                        _SubjectDef('Art', 'ART101', 'lib/assets/art_student.png'),
                      ];
                      return Column(
                        children: [
                          for (final subj in fallback) _buildAttendanceCardFromMap(
                            label: subj.label,
                            classId: subj.classId,
                            asset: subj.asset,
                            attendanceMap: attendanceMap,
                          ),
                        ],
                      );
                    }

                    // Show one card per class
                    return Column(
                      children: [
                        for (final classDoc in userClasses) ...[
                          Builder(builder: (_) {
                            final classId = (classDoc['classId'] ?? classDoc['id'] ?? '') as String;
                            if (classId.isEmpty) return const SizedBox.shrink();
                            final name = (classDoc['name'] ?? 'Class').toString();
                            final asset = _pickAssetForClassName(name);
                            return _buildAttendanceCardFromMap(
                              label: name,
                              classId: classId,
                              asset: asset,
                              attendanceMap: attendanceMap,
                            );
                          }),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Other cards (maintain original order/spacing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildMissedClassesCard(),
                    const SizedBox(height: 16),
                    _buildAttendancePredictorCard(),
                    const SizedBox(height: 16),
                    _buildDocumentsCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String subject, String percentage, String assetPath, VoidCallback? onView) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side - Illustration
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a card from aggregate map for either fallback subject or real class
  Widget _buildAttendanceCardFromMap({
    required String label,
    required String classId,
    required String asset,
    required Map<String, dynamic> attendanceMap,
  }) {
    final stats = attendanceMap[classId] as Map<String, dynamic>?;
    final present = (stats?['presentCount'] as num?)?.toInt() ?? 0;
    final total = (stats?['totalCount'] as num?)?.toInt() ?? 0;
    final pct = total == 0 ? 0 : ((present / total) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildSubjectCard(
        label,
        pct.toString(),
        asset,
        widget.onViewSubject,
      ),
    );
  }

  // Simple deterministic asset picker based on name keywords
  String _pickAssetForClassName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('math')) return 'lib/assets/math_student.png';
    if (lower.contains('sci')) return 'lib/assets/science_student.png';
    if (lower.contains('hist')) return 'lib/assets/history_student.png';
    if (lower.contains('eng')) return 'lib/assets/english_student.png';
    if (lower.contains('art')) return 'lib/assets/art_student.png';
    // default
    return 'lib/assets/classes.png';
  }

  Widget _buildMissedClassesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Missed Classes',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '5',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: widget.onViewMissedClasses,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side - Calendar illustration
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'lib/assets/missedclass_student.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendancePredictorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Predictor',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Warning: Your attendance in History is at risk. Consider attending all upcoming classes to improve your standing.',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: widget.onViewAttendancePredictor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side - Chart illustration
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'lib/assets/attendance_predictor.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Documents',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access your attendance records and related documents.',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: widget.onViewDocuments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side - Folder illustration
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset(
              'lib/assets/documents.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
