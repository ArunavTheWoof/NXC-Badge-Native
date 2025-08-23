import 'package:flutter/material.dart';

// You can replace this with your actual data model
class IssuedBook {
  final String name;
  final String date;
  final String bookTitle;

  const IssuedBook({required this.name, required this.date, required this.bookTitle});
}

// Screen Widget for "Issued Books"
class IssuedBooksScreen extends StatelessWidget {
  // Mock data for the list of issued books.
  // In a real app, you would pass this data into the widget.
  final List<IssuedBook> issuedBooksData = const [
    const IssuedBook(name: 'Ethan Carter', date: '2023-08-15', bookTitle: 'The Great Gatsby'),
    const IssuedBook(name: 'Olivia Bennett', date: '2023-07-22', bookTitle: 'To Kill a Mockingbird'),
    const IssuedBook(name: 'Noah Thompson', date: '2023-06-10', bookTitle: '1984'),
    const IssuedBook(name: 'Ava Martinez', date: '2023-05-05', bookTitle: 'Pride and Prejudice'),
    const IssuedBook(name: 'Liam Harris', date: '2023-04-18', bookTitle: 'The Catcher in the Rye'),
    const IssuedBook(name: 'Sophia Clark', date: '2023-03-25', bookTitle: 'The Hobbit'),
    const IssuedBook(name: 'Jackson Lewis', date: '2023-02-12', bookTitle: 'The Lord of the Rings'),
    const IssuedBook(name: 'Isabella Walker', date: '2023-01-08', bookTitle: 'The Da Vinci Code'),
  ];

  const IssuedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        // The back button that redirects to the previous screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // This is the line that makes the back button work
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Issued Books',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: issuedBooksData.isEmpty
          ? const Center(
              child: Text(
                'No books currently issued.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: issuedBooksData.length,
              itemBuilder: (context, index) {
                final item = issuedBooksData[index];
                return _buildBookListItem(
                  name: item.name,
                  date: item.date,
                  bookTitle: item.bookTitle,
                );
              },
            ),
    );
  }

  // A widget to build each item in the list
  Widget _buildBookListItem({
    required String name,
    required String date,
    required String bookTitle,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Issued: $date',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bookTitle,
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                ],
              ),
            ),
            // The "Return" button
            ElevatedButton(
              onPressed: () {
                // TODO: Implement return functionality
                print('Return button for $name tapped');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5F5DC), // Light beige/brown
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Return',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
