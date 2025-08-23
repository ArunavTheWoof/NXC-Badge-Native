import 'package:flutter/material.dart';

class LogsGatekeeperScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final VoidCallback? onLogs;
  final VoidCallback? onProfile;

  const LogsGatekeeperScreen({
    super.key,
    this.onBack,
    this.onHome,
    this.onLogs,
    this.onProfile,
  });

  @override
  State<LogsGatekeeperScreen> createState() => _LogsGatekeeperScreenState();
}

class _LogsGatekeeperScreenState extends State<LogsGatekeeperScreen> {
  DateTime selectedDate = DateTime(2024, 10, 5); // October 5, 2024
  DateTime currentMonth = DateTime(2024, 10); // October 2024
  bool isPresentFilterActive = true; // Present filter is active by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Back arrow
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
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
                  // Empty space for balance
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar Section
                    _buildCalendarSection(),
                    const SizedBox(height: 24),

                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 20),

                    // Attendance Filter Buttons
                    _buildFilterButtons(),
                    const SizedBox(height: 24),

                    // Student List
                    _buildStudentList(),
                  ],
                ),
              ),
            ),

            
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Month and Year Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
                icon: const Icon(
                  Icons.chevron_left,
                  color: Colors.black,
                  size: 24,
                ),
              ),
              Text(
                '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                },
                icon: const Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days of the Week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('S', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('M', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('T', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('W', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('T', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('F', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('S', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    List<Widget> calendarDays = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday - 1; i++) {
      calendarDays.add(const SizedBox(height: 40, width: 40));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final isSelected = date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;

      calendarDays.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
          },
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Create rows of 7 days each
    List<Widget> rows = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      final rowDays = calendarDays.skip(i).take(7).toList();
      // Pad the last row if needed
      while (rowDays.length < 7) {
        rowDays.add(const SizedBox(height: 40, width: 40));
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rowDays,
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Search students',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isPresentFilterActive = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: isPresentFilterActive ? Colors.white : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                border: isPresentFilterActive
                    ? Border.all(color: Colors.grey[600]!)
                    : null,
              ),
              child: Center(
                child: Text(
                  'Present',
                  style: TextStyle(
                    color: isPresentFilterActive ? Colors.black : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isPresentFilterActive = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: !isPresentFilterActive ? Colors.white : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                border: !isPresentFilterActive
                    ? Border.all(color: Colors.grey[600]!)
                    : null,
              ),
              child: Center(
                child: Text(
                  'Absent',
                  style: TextStyle(
                    color: !isPresentFilterActive ? Colors.black : Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    final students = [
      {'name': 'Ethan Harper', 'grade': 'Grade 10', 'avatarColor': Colors.teal},
      {'name': 'Olivia Bennett', 'grade': 'Grade 10', 'avatarColor': Colors.pink},
      {'name': 'Noah Carter', 'grade': 'Grade 10', 'avatarColor': Colors.green},
      {'name': 'Ava Mitchell', 'grade': 'Grade 10', 'avatarColor': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: students.map((student) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              // Circular Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: student['avatarColor'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (student['name'] as String).split(' ').map((n) => n[0]).join(''),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] as String,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student['grade'] as String,
                      style: const TextStyle(
                        color: Color(0xFF87CEEB), // Light blue
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
