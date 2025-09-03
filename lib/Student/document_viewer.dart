import 'package:flutter/material.dart';
import '../services/log_service.dart';

class DocumentViewerScreen extends StatefulWidget {
  const DocumentViewerScreen({
    super.key,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isZoomed = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
    LogService.info('Document search toggled: ${_isSearching ? 'enabled' : 'disabled'}');
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    LogService.info('Searching document for: $query');
    
    // Show search result feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for "$query" in document...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleView() {
    setState(() {
      _isZoomed = !_isZoomed;
    });
    
    LogService.info('Document view toggled: ${_isZoomed ? 'zoomed' : 'normal'}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isZoomed ? 'Zoomed view enabled' : 'Normal view restored'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  const BackButton(),
                  const Expanded(
                    child: Text(
                      'Document Viewer',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Search button with professional implementation
                  IconButton(
                    onPressed: _toggleSearch,
                    icon: Icon(
                      _isSearching ? Icons.search_off : Icons.search,
                      color: _isSearching ? Colors.blue : Colors.black,
                      size: 24,
                    ),
                    tooltip: _isSearching ? 'Close search' : 'Search document',
                  ),
                  // View button with professional zoom functionality
                  IconButton(
                    onPressed: _toggleView,
                    icon: Icon(
                      _isZoomed ? Icons.zoom_out : Icons.zoom_in,
                      color: _isZoomed ? Colors.green : Colors.black,
                      size: 24,
                    ),
                    tooltip: _isZoomed ? 'Zoom out' : 'Zoom in',
                  ),
                ],
              ),
            ),

            // Search bar (conditionally shown)
            if (_isSearching)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search in document...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _performSearch(value);
                    }
                  },
                ),
              ),

            // Document display area with zoom functionality
            Expanded(
              child: Container(
                color: const Color(0xFFD2691E), // Orange-brown/terracotta background
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: EdgeInsets.all(_isZoomed ? 10.0 : 20.0),
                    width: double.infinity,
                    height: double.infinity,
                    transform: Matrix4.identity()..scale(_isZoomed ? 1.1 : 1.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: _isZoomed ? 0.2 : 0.1),
                          spreadRadius: _isZoomed ? 4 : 2,
                          blurRadius: _isZoomed ? 12 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(_isZoomed ? 24.0 : 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PDF label with enhanced styling
                          Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red[600],
                                size: _isZoomed ? 24 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PDF Document',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: _isZoomed ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Professional document content
                          _buildDocumentContent(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDocumentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section with enhanced styling
        Container(
          width: double.infinity,
          height: _isZoomed ? 3 : 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        const SizedBox(height: 15),

        // Document Title
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'ACADEMIC DOCUMENT - STUDENT INFORMATION',
            style: TextStyle(
              fontSize: _isZoomed ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Enhanced form fields with professional styling
        _buildFormField('Student Name:', 'John Doe'),
        _buildFormField('Student ID:', 'STU2024001'),
        _buildFormField('Course:', 'Computer Science'),
        _buildFormField('Semester:', '1st Semester'),
        _buildFormField('Academic Year:', '2024-2025'),
        _buildFormField('Exam Date:', 'December 15, 2024'),
        _buildFormField('Venue:', 'Hall A, Block 2'),
        _buildFormField('Status:', 'Active'),

        const SizedBox(height: 20),

        // Document body content
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Document Details',
                style: TextStyle(
                  fontSize: _isZoomed ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              _buildContentLine(context, 0.8),
              _buildContentLine(context, 0.9),
              _buildContentLine(context, 0.6),
              _buildContentLine(context, 0.7),
              _buildContentLine(context, 0.5),
              _buildContentLine(context, 0.8),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Footer section with signatures
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Signature',
                  style: TextStyle(
                    fontSize: _isZoomed ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: _isZoomed ? 8 : 6,
                  color: Colors.grey[400],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authorized Signature',
                  style: TextStyle(
                    fontSize: _isZoomed ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: _isZoomed ? 8 : 6,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Document metadata
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Generated: ${DateTime.now().toString().substring(0, 16)}',
                style: TextStyle(
                  fontSize: _isZoomed ? 12 : 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Version: 1.0',
                style: TextStyle(
                  fontSize: _isZoomed ? 12 : 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _isZoomed ? 100 : 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: _isZoomed ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: _isZoomed ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentLine(BuildContext context, double widthFactor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * widthFactor * 0.6,
        height: _isZoomed ? 8 : 6,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
