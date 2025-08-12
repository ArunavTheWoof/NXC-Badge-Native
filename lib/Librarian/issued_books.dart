import 'package:flutter/material.dart';

class IssuedBooks extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onHome;
  final VoidCallback? onLogs;
  final VoidCallback? onProfile;
  final Function(String borrowerName, String bookTitle)? onReturnBook;

  const IssuedBooks({
    super.key,
    this.onBack,
    this.onHome,
    this.onLogs,
    this.onProfile,
    this.onReturnBook,
  });

  @override
  State<IssuedBooks> createState() => _IssuedBooksState();
}

class _IssuedBooksState extends State<IssuedBooks> {
  final List<Map<String, String>> _issuedBooks = [
    {
      'borrower': 'Ethan Carter',
      'issueDate': '2023-08-15',
      'bookTitle': 'The Great Gatsby',
    },
    {
      'borrower': 'Olivia Bennett',
      'issueDate': '2023-07-22',
      'bookTitle': 'To Kill a Mockingbird',
    },
    {
      'borrower': 'Noah Thompson',
      'issueDate': '2023-06-10',
      'bookTitle': '1984',
    },
    {
      'borrower': 'Ava Martinez',
      'issueDate': '2023-05-05',
      'bookTitle': 'Pride and Prejudice',
    },
    {
      'borrower': 'Liam Harris',
      'issueDate': '2023-04-18',
      'bookTitle': 'The Catcher in the Rye',
    },
    {
      'borrower': 'Sophia Clark',
      'issueDate': '2023-03-25',
      'bookTitle': 'The Hobbit',
    },
    {
      'borrower': 'Jackson Lewis',
      'issueDate': '2023-02-12',
      'bookTitle': 'The Lord of the Rings',
    },
    {
      'borrower': 'Isabella Walker',
      'issueDate': '2023-01-08',
      'bookTitle': 'The Da Vinci Code',
    },
    {
      'borrower': 'Lucas Hall',
      'issueDate': '2022-12-15',
      'bookTitle': 'The Alchemist',
    },
    {
      'borrower': 'Mia Young',
      'issueDate': '2022-11-20',
      'bookTitle': 'The Hunger Games',
    },
  ];

  void _returnBook(String borrowerName, String bookTitle) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return Book'),
          content: Text(
            'Are you sure you want to return "$bookTitle" from $borrowerName?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmReturn(borrowerName, bookTitle);
              },
              child: const Text('Return'),
            ),
          ],
        );
      },
    );
  }

  void _confirmReturn(String borrowerName, String bookTitle) {
    setState(() {
      _issuedBooks.removeWhere(
        (book) =>
            book['borrower'] == borrowerName && book['bookTitle'] == bookTitle,
      );
    });

    // Call the callback
    widget.onReturnBook?.call(borrowerName, bookTitle);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Book "$bookTitle" returned successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
                    onPressed: widget.onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Issued Books',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the header
                ],
              ),
            ),

            // Content Area - List of Issued Books
            Expanded(
              child:
                  _issuedBooks.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books,
                              size: 64,
                              color: Color(0xFF9E9E9E),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No books currently issued',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: _issuedBooks.length,
                        itemBuilder: (context, index) {
                          final book = _issuedBooks[index];
                          return _buildBookItem(
                            book['borrower']!,
                            book['issueDate']!,
                            book['bookTitle']!,
                          );
                        },
                      ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
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

  Widget _buildBookItem(
    String borrowerName,
    String issueDate,
    String bookTitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          // Book Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Borrower Name
                Text(
                  borrowerName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Issue Date
                Text(
                  'Issued: $issueDate',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),

                // Book Title
                Text(
                  bookTitle,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Return Button
          ElevatedButton(
            onPressed: () => _returnBook(borrowerName, bookTitle),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5F5DC), // Light beige/off-white
              foregroundColor: const Color(0xFF424242), // Dark gray text
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Return',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
            color: const Color(0xFF9E9E9E), // Light gray
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9E9E9E), // Light gray
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
