import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingHistoryScreen extends StatefulWidget {
  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Booking History',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            children: [
              // Header - Responsive
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: isMobile ? 36 : 48,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                    Text(
                      'Your Booking History',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track all your test bookings',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: isMobile ? 12 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Filter Chips - Responsive
              Container(
                height: isMobile ? 40 : 45,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All', Colors.blue, isMobile),
                      SizedBox(width: 8),
                      _buildFilterChip('pending', 'Pending', Colors.orange, isMobile),
                      SizedBox(width: 8),
                      _buildFilterChip('confirmed', 'Confirmed', Colors.green, isMobile),
                      SizedBox(width: 8),
                      _buildFilterChip('completed', 'Completed', Colors.purple, isMobile),
                      SizedBox(width: 8),
                      _buildFilterChip('cancelled', 'Cancelled', Colors.red, isMobile),
                    ],
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              // Bookings List - Flexible and Responsive
              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: isMobile ? 2 : 3,
                  ),
                )
                    : _filteredBookings.isEmpty
                    ? _buildEmptyState(isMobile)
                    : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return _buildBookingCard(booking, isMobile, isTablet);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, Color color, bool isMobile) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue.shade700,
          fontWeight: FontWeight.w500,
          fontSize: isMobile ? 12 : 14,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.blue.shade50,
      selectedColor: Colors.blue.shade600,
      checkmarkColor: Colors.white,
      side: BorderSide(color: Colors.blue.shade200),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 6,
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_outlined,
              size: isMobile ? 48 : 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              _selectedFilter == 'all'
                  ? 'No bookings found'
                  : 'No ${_selectedFilter} bookings',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _selectedFilter == 'all'
                    ? 'Your booking history will appear here'
                    : 'Try selecting a different filter',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isMobile ? 12 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            ElevatedButton.icon(
              onPressed: _loadBookings,
              icon: Icon(Icons.refresh, size: isMobile ? 16 : 18),
              label: Text(
                'Refresh',
                style: TextStyle(fontSize: isMobile ? 12 : 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 8 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, bool isMobile, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row - Responsive
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    booking['testName'] ?? 'Unknown Test',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'] ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 8 : 12),

            // Details - Responsive Layout
            if (isMobile) ...[
              // Mobile: Single column layout
              _buildDetailItem(Icons.local_hospital, 'Lab', booking['labName']),
              _buildDetailItem(Icons.location_on, 'Location', booking['location']),
              _buildDetailItem(Icons.person, 'Patient', booking['patientName']),
              _buildDetailItem(Icons.calendar_today, 'Booked', _formatDate(booking['createdAt'])),
            ] else ...[
              // Desktop/Tablet: Two column layout
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(Icons.local_hospital, 'Lab', booking['labName']),
                  ),
                  Expanded(
                    child: _buildDetailItem(Icons.location_on, 'Location', booking['location']),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(Icons.person, 'Patient', booking['patientName']),
                  ),
                  Expanded(
                    child: _buildDetailItem(Icons.calendar_today, 'Booked', _formatDate(booking['createdAt'])),
                  ),
                ],
              ),
            ],

            SizedBox(height: isMobile ? 8 : 12),

            // Payment and Price Row - Responsive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Payment: ${booking['paymentStatus'] ?? 'Unknown'}',
                    style: TextStyle(
                      color: _getPaymentStatusColor(booking['paymentStatus']),
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
                Text(
                  'AFN ${booking['price'] ?? '0'}',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),

            // Action Button - Conditional
            if (booking['status'] == 'pending' || booking['paymentStatus'] == 'pending') ...[
              SizedBox(height: isMobile ? 8 : 12),
              SizedBox(
                width: double.infinity,
                height: isMobile ? 36 : 44,
                child: ElevatedButton.icon(
                  onPressed: () => _showBookingDetails(booking, isMobile),
                  icon: Icon(Icons.info, size: isMobile ? 16 : 18),
                  label: Text(
                    'View Details',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String? value) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 3 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: isMobile ? 14 : 16,
            color: Colors.grey.shade600,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: ${value ?? 'Unknown'}',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'all') {
      return _bookings;
    }
    return _bookings.where((booking) => booking['status'] == _selectedFilter).toList();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _bookings = querySnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          _isLoading = false;
        });
      }

      print('Loaded ${_bookings.length} bookings for user'); // Debug print
    } catch (e) {
      print('Error loading bookings: $e'); // Debug print
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading bookings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Color _getPaymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'submitted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info, color: Colors.blue.shade700, size: isMobile ? 20 : 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Booking Details',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Test', booking['testName'], isMobile),
              _buildDetailRow('Lab', booking['labName'], isMobile),
              _buildDetailRow('Location', booking['location'], isMobile),
              _buildDetailRow('Patient', booking['patientName'], isMobile),
              _buildDetailRow('Contact', booking['contactNumber'], isMobile),
              _buildDetailRow('City', booking['city'], isMobile),
              _buildDetailRow('Address', booking['address'], isMobile),
              _buildDetailRow('Price', 'AFN ${booking['price']}', isMobile),
              _buildDetailRow('Status', booking['status'], isMobile),
              _buildDetailRow('Payment Status', booking['paymentStatus'], isMobile),
              _buildDetailRow('Booking Date', _formatDate(booking['createdAt']), isMobile),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 70 : 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Unknown',
              style: TextStyle(
                color: Colors.black,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
