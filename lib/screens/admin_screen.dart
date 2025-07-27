import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import 'dart:io';
import '../widgets/image_viewer_dialog.dart';
import '../widgets/document_viewer_dialog.dart';

// Global key to access ResultManagementTab state
final GlobalKey<_ResultManagementTabState> resultTabKey = GlobalKey<_ResultManagementTabState>();

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.red.shade800,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red.shade700,
          isScrollable: isMobile,
          labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
          tabs: [
            Tab(text: 'Tests'),
            Tab(text: 'Bookings'),
            Tab(text: 'Payments'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TestManagementTab(),
          BookingManagementTab(),
          PaymentManagementTab(tabController: _tabController),
          ResultManagementTab(key: resultTabKey),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Rest of the TestManagementTab and BookingManagementTab remain unchanged...
class TestManagementTab extends StatefulWidget {
  @override
  _TestManagementTabState createState() => _TestManagementTabState();
}

class _TestManagementTabState extends State<TestManagementTab> {
  final _formKey = GlobalKey<FormState>();
  final _testNameController = TextEditingController();
  final _labNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _tests = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Add Test Form
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_circle, color: Colors.red.shade700),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Add New Test',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Responsive form layout
                    if (isMobile) ...[
                      // Mobile layout - single column
                      _buildTextField(
                        controller: _testNameController,
                        label: 'Test Name *',
                        icon: Icons.medical_services,
                        validator: (value) => value?.isEmpty ?? true ? 'Test name is required' : null,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: _labNameController,
                        label: 'Lab Name *',
                        icon: Icons.local_hospital,
                        validator: (value) => value?.isEmpty ?? true ? 'Lab name is required' : null,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: _locationController,
                        label: 'Location *',
                        icon: Icons.location_on,
                        validator: (value) => value?.isEmpty ?? true ? 'Location is required' : null,
                        isMobile: isMobile,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price (AFN) *',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Price is required';
                          if (double.tryParse(value!) == null) return 'Enter valid price';
                          return null;
                        },
                        isMobile: isMobile,
                      ),
                    ] else ...[
                      // Desktop layout - two columns
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _testNameController,
                              label: 'Test Name *',
                              icon: Icons.medical_services,
                              validator: (value) => value?.isEmpty ?? true ? 'Test name is required' : null,
                              isMobile: isMobile,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _labNameController,
                              label: 'Lab Name *',
                              icon: Icons.local_hospital,
                              validator: (value) => value?.isEmpty ?? true ? 'Lab name is required' : null,
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _locationController,
                              label: 'Location *',
                              icon: Icons.location_on,
                              validator: (value) => value?.isEmpty ?? true ? 'Location is required' : null,
                              isMobile: isMobile,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _priceController,
                              label: 'Price (AFN) *',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Price is required';
                                if (double.tryParse(value!) == null) return 'Enter valid price';
                                return null;
                              },
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      icon: Icons.description,
                      maxLines: 2,
                      isMobile: isMobile,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 44 : 48,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _addTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Adding Test...',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: isMobile ? 18 : 20),
                            SizedBox(width: 8),
                            Text(
                              'Add Test',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Tests List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Existing Tests (${_tests.length})',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadTests,
                icon: Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),

          SizedBox(height: 8),

          // Tests List - Fixed height container with internal scrolling
          Container(
            height: isMobile ? 300 : 400,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _tests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: isMobile ? 48 : 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tests added yet',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first test using the form above',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: isMobile ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _tests.length,
              itemBuilder: (context, index) {
                final test = _tests[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(isMobile ? 8 : 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      radius: isMobile ? 20 : 24,
                      child: Icon(
                        Icons.medical_services,
                        color: Colors.blue.shade700,
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                    title: Text(
                      test['testName'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${test['labName']} - ${test['location']}',
                          style: TextStyle(fontSize: isMobile ? 12 : 14),
                        ),
                        Text(
                          'AFN ${test['price']}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: isMobile ? 18 : 20,
                          ),
                          onPressed: () => _editTest(test),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: isMobile ? 18 : 20,
                          ),
                          onPressed: () => _deleteTest(test['id']),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isMobile,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isMobile ? 8 : 12,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Future<void> _loadTests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tests')
          .orderBy('testName')
          .get();

      if (mounted) {
        setState(() {
          _tests = querySnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          _isLoading = false;
        });
      }

      print('Admin loaded ${_tests.length} tests'); // Debug print
    } catch (e) {
      print('Error loading tests: $e'); // Debug print
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addTest() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final testData = {
        'testName': _testNameController.text.trim(),
        'labName': _labNameController.text.trim(),
        'location': _locationController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('tests').add(testData);

      _clearForm();
      await _loadTests(); // Reload the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test "${testData['testName']}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      print('Test added successfully: ${testData['testName']}'); // Debug print
    } catch (e) {
      print('Error adding test: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _testNameController.clear();
    _labNameController.clear();
    _locationController.clear();
    _priceController.clear();
    _descriptionController.clear();
  }

  void _editTest(Map<String, dynamic> test) {
    // Pre-fill the form with existing data
    _testNameController.text = test['testName'] ?? '';
    _labNameController.text = test['labName'] ?? '';
    _locationController.text = test['location'] ?? '';
    _priceController.text = test['price']?.toString() ?? '';
    _descriptionController.text = test['description'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Test'),
        content: Text('Form has been pre-filled with current data. Modify the fields above and click "Add Test" to update.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete the old test and add the new one
              _deleteTest(test['id'], showConfirmation: false);
            },
            child: Text('Update'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTest(String testId, {bool showConfirmation = true}) async {
    bool confirmed = true;

    if (showConfirmation) {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Test'),
          content: Text('Are you sure you want to delete this test? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        ),
      ) ?? false;
    }

    if (confirmed) {
      try {
        await FirebaseFirestore.instance
            .collection('tests')
            .doc(testId)
            .delete();

        await _loadTests(); // Reload the list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Test deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting test: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _testNameController.dispose();
    _labNameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// BookingManagementTab implementation remains unchanged...

class BookingManagementTab extends StatefulWidget {
  @override
  _BookingManagementTabState createState() => _BookingManagementTabState();
}

class _BookingManagementTabState extends State<BookingManagementTab> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          if (_isLoading)
            Container(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_bookings.isEmpty)
            Container(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: isMobile ? 48 : 64,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No bookings found',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      booking['testName'] ?? 'Unknown Test',
                      style: TextStyle(fontSize: isMobile ? 14 : 16),
                    ),
                    subtitle: Text(
                      'Patient: ${booking['patientName']} - Status: ${booking['status']}',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact: ${booking['contactNumber']}'),
                            Text('City: ${booking['city']}'),
                            Text('Address: ${booking['address']}'),
                            Text('Payment Status: ${booking['paymentStatus']}'),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _updateBookingStatus(booking['id'], 'confirmed'),
                                  child: Text('Confirm'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 8 : 12,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _updateBookingStatus(booking['id'], 'cancelled'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 8 : 12,
                                    ),
                                  ),
                                  child: Text('Cancel'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
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
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking status updated to $status!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }
}

class PaymentManagementTab extends StatefulWidget {
  final TabController tabController;

  const PaymentManagementTab({Key? key, required this.tabController}) : super(key: key);

  @override
  _PaymentManagementTabState createState() => _PaymentManagementTabState();
}

class _PaymentManagementTabState extends State<PaymentManagementTab> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          if (_isLoading)
            Container(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_payments.isEmpty)
            Container(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: isMobile ? 48 : 64,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No payments found',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      payment['testName'] ?? 'Unknown Test',
                      style: TextStyle(fontSize: isMobile ? 14 : 16),
                    ),
                    subtitle: Text(
                      'Amount: AFN ${payment['amount']} - Status: ${payment['status']}',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Patient: ${payment['patientName']}'),
                            Text('Easypaisa: ${payment['easypaiseNumber']}'),
                            if (payment['receiptUrl'] != null) ...[
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _viewReceipt(payment['receiptUrl']),
                                child: Text('View Receipt'),
                              ),
                            ],
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _updatePaymentStatus(payment['id'], payment['bookingId'], 'verified'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 8 : 12,
                                    ),
                                  ),
                                  child: Text('Verify'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _updatePaymentStatus(payment['id'], payment['bookingId'], 'rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 8 : 12,
                                    ),
                                  ),
                                  child: Text('Reject'),
                                ),
                                // Show "Proceed to Upload Results" button only for verified payments
                                if (payment['status'] == 'verified') ...[
                                  ElevatedButton.icon(
                                    onPressed: () => _proceedToUploadResults(payment),
                                    icon: Icon(Icons.upload_file, size: 16),
                                    label: Text('Proceed to Upload Results'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade600,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 8 : 12,
                                        vertical: isMobile ? 6 : 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _loadPayments() async {
    if (!mounted) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _payments = querySnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading payments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePaymentStatus(String paymentId, String? bookingId, String status) async {
    try {
      // Update payment status
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(paymentId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If payment is verified, also update the booking payment status
      if (status == 'verified' && bookingId != null) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .update({
          'paymentStatus': 'verified',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment status updated to $status!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  void _viewReceipt(String receiptUrl) {
    showDialog(
      context: context,
      builder: (context) => ImageViewerDialog(
        imageUrl: receiptUrl,
        title: 'Payment Receipt',
      ),
    );
  }

  Future<void> _proceedToUploadResults(Map<String, dynamic> payment) async {
    try {
      // Get booking details to auto-fill the result form
      final bookingDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(payment['bookingId'])
          .get();

      if (!bookingDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking details not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final bookingData = bookingDoc.data()!;

      // Switch to Results tab
      widget.tabController.animateTo(3); // Results tab is index 3

      // Wait a bit for the tab to switch
      await Future.delayed(Duration(milliseconds: 300));

      // Use the global key to access the ResultManagementTab state
      if (resultTabKey.currentState != null) {
        resultTabKey.currentState!.autoFillFromPayment(payment, bookingData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to Results tab. Form has been auto-filled.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not access Results tab. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error proceeding to upload results: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading booking details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ResultManagementTab extends StatefulWidget {
  // Add key parameter to constructor
  const ResultManagementTab({Key? key}) : super(key: key);

  @override
  _ResultManagementTabState createState() => _ResultManagementTabState();
}

class _ResultManagementTabState extends State<ResultManagementTab> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _testNameController = TextEditingController();
  final _labNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  File? _selectedFile;
  String? _selectedFileName;

  // Auto-fill data
  String? _autoFillUserId;
  String? _autoFillBookingId;
  String? _autoFillPaymentId;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  // Method to auto-fill form from payment data
  void autoFillFromPayment(Map<String, dynamic> payment, Map<String, dynamic> booking) {
    setState(() {
      _patientNameController.text = payment['patientName'] ?? '';
      _testNameController.text = payment['testName'] ?? '';
      _labNameController.text = booking['labName'] ?? '';
      _contactNumberController.text = booking['contactNumber'] ?? '';
      _notesController.text = 'Result for booking ID: ${payment['bookingId']}';

      // Store IDs for proper linking
      _autoFillUserId = payment['userId'];
      _autoFillBookingId = payment['bookingId'];
      _autoFillPaymentId = payment['id'];
    });

    // Show a highlighted form to indicate auto-fill
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form auto-filled! Please upload the result file and submit.'),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Upload Result Form
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // Highlight the card if auto-filled
            color: _autoFillUserId != null ? Colors.purple.shade50 : null,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upload_file, color: Colors.purple.shade700),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _autoFillUserId != null
                                ? 'Upload Test Result (Auto-filled)'
                                : 'Upload Test Result',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Show auto-fill notice
                    if (_autoFillUserId != null) ...[
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.purple.shade700, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Form auto-filled from verified payment. Just upload the result file!',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _clearAutoFill,
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 16),

                    // Responsive form layout
                    if (isMobile) ...[
                      // Mobile layout - single column
                      _buildTextField(
                        controller: _patientNameController,
                        label: 'Patient Name *',
                        icon: Icons.person,
                        validator: (value) => value?.isEmpty ?? true ? 'Patient name is required' : null,
                        isMobile: isMobile,
                        isAutoFilled: _autoFillUserId != null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: _testNameController,
                        label: 'Test Name *',
                        icon: Icons.medical_services,
                        validator: (value) => value?.isEmpty ?? true ? 'Test name is required' : null,
                        isMobile: isMobile,
                        isAutoFilled: _autoFillUserId != null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: _labNameController,
                        label: 'Lab Name *',
                        icon: Icons.local_hospital,
                        validator: (value) => value?.isEmpty ?? true ? 'Lab name is required' : null,
                        isMobile: isMobile,
                        isAutoFilled: _autoFillUserId != null,
                      ),
                      SizedBox(height: 12),
                      _buildTextField(
                        controller: _contactNumberController,
                        label: 'Contact Number *',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true ? 'Contact number is required' : null,
                        isMobile: isMobile,
                        isAutoFilled: _autoFillUserId != null,
                      ),
                    ] else ...[
                      // Desktop layout - two columns
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _patientNameController,
                              label: 'Patient Name *',
                              icon: Icons.person,
                              validator: (value) => value?.isEmpty ?? true ? 'Patient name is required' : null,
                              isMobile: isMobile,
                              isAutoFilled: _autoFillUserId != null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _testNameController,
                              label: 'Test Name *',
                              icon: Icons.medical_services,
                              validator: (value) => value?.isEmpty ?? true ? 'Test name is required' : null,
                              isMobile: isMobile,
                              isAutoFilled: _autoFillUserId != null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _labNameController,
                              label: 'Lab Name *',
                              icon: Icons.local_hospital,
                              validator: (value) => value?.isEmpty ?? true ? 'Lab name is required' : null,
                              isMobile: isMobile,
                              isAutoFilled: _autoFillUserId != null,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _contactNumberController,
                              label: 'Contact Number *',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) => value?.isEmpty ?? true ? 'Contact number is required' : null,
                              isMobile: isMobile,
                              isAutoFilled: _autoFillUserId != null,
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Additional Notes (Optional)',
                      icon: Icons.note,
                      maxLines: 2,
                      isMobile: isMobile,
                      isAutoFilled: _autoFillUserId != null,
                    ),
                    SizedBox(height: 16),

                    // File Upload Section - Responsive
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: _autoFillUserId != null
                                ? Colors.purple.shade300
                                : Colors.grey.shade300
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _autoFillUserId != null
                            ? Colors.purple.shade50
                            : Colors.grey.shade50,
                      ),
                      child: isMobile
                          ? Column(
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                            size: 32,
                            color: _selectedFile != null ? Colors.green : Colors.grey.shade400,
                          ),
                          SizedBox(height: 8),
                          Text(
                            _selectedFile != null
                                ? 'File Selected'
                                : 'Select Result File',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedFile != null ? Colors.green.shade700 : Colors.grey.shade600,
                            ),
                          ),
                          if (_selectedFile != null) ...[
                            SizedBox(height: 4),
                            Text(
                              _selectedFileName ?? 'Unknown file',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickFile,
                            child: Text(_selectedFile != null ? 'Change' : 'Choose'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                            size: 32,
                            color: _selectedFile != null ? Colors.green : Colors.grey.shade400,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile != null
                                      ? 'File Selected'
                                      : 'Select Result File',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _selectedFile != null ? Colors.green.shade700 : Colors.grey.shade600,
                                  ),
                                ),
                                if (_selectedFile != null)
                                  Text(
                                    _selectedFileName ?? 'Unknown file',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _pickFile,
                            child: Text(_selectedFile != null ? 'Change' : 'Choose'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: isMobile ? 44 : 48,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || _selectedFile == null) ? null : _uploadResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _autoFillUserId != null
                              ? Colors.purple.shade700
                              : Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Uploading Result...',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload, size: isMobile ? 18 : 20),
                            SizedBox(width: 8),
                            Text(
                              _autoFillUserId != null
                                  ? 'Upload Result for Patient'
                                  : 'Upload Result',
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Results List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Uploaded Results (${_results.length})',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadResults,
                icon: Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),

          SizedBox(height: 8),

          // Results List - Fixed height container
          Container(
            height: isMobile ? 300 : 400,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: isMobile ? 48 : 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No results uploaded yet',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload your first test result using the form above',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: isMobile ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      radius: isMobile ? 18 : 20,
                      child: Icon(
                        Icons.assignment,
                        color: Colors.purple.shade700,
                        size: isMobile ? 16 : 18,
                      ),
                    ),
                    title: Text(
                      '${result['testName']} - ${result['patientName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    subtitle: Text(
                      '${result['labName']} • ${_formatDate(result['createdAt'])}',
                      style: TextStyle(fontSize: isMobile ? 12 : 14),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Patient: ${result['patientName']}'),
                            Text('Contact: ${result['contactNumber']}'),
                            if (result['notes']?.isNotEmpty ?? false)
                              Text('Notes: ${result['notes']}'),
                            if (result['bookingId'] != null)
                              Text('Booking ID: ${result['bookingId']}'),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _viewResult(result),
                                  icon: Icon(Icons.visibility, size: 16),
                                  label: Text('View Result'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 12,
                                      vertical: isMobile ? 4 : 8,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _deleteResult(result['id']),
                                  icon: Icon(Icons.delete, size: 16),
                                  label: Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 12,
                                      vertical: isMobile ? 4 : 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isMobile,
    bool isAutoFilled = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isAutoFilled ? Colors.purple.shade300 : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isAutoFilled ? Colors.purple.shade300 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isAutoFilled ? Colors.purple.shade500 : Colors.blue.shade500,
          ),
        ),
        prefixIcon: Icon(
          icon,
          color: isAutoFilled ? Colors.purple.shade600 : null,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isMobile ? 8 : 12,
        ),
        fillColor: isAutoFilled ? Colors.purple.shade50 : null,
        filled: isAutoFilled,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  void _clearAutoFill() {
    setState(() {
      _autoFillUserId = null;
      _autoFillBookingId = null;
      _autoFillPaymentId = null;
    });
    _clearForm();
  }

  Future<void> _pickFile() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show options for image or document
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select File Type'),
          content: Text('Choose the type of result file to upload:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'image'),
              child: Text('Image (JPG/PNG)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'document'),
              child: Text('Document (PDF)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );

      if (result == 'image') {
        final XFile? file = await picker.pickImage(source: ImageSource.gallery);
        if (file != null) {
          setState(() {
            _selectedFile = File(file.path);
            _selectedFileName = file.name;
          });
        }
      } else if (result == 'document') {
        // For PDF files, we'll use a simple file picker approach
        // Note: In a real app, you might want to use file_picker package for better PDF support
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF file selection will be implemented with file_picker package'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadResult() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload file to Cloudinary
      String resultUrl;
      if (_selectedFileName?.toLowerCase().endsWith('.pdf') ?? false) {
        resultUrl = await CloudinaryService.uploadResult(_selectedFile!);
      } else {
        resultUrl = await CloudinaryService.uploadResult(_selectedFile!);
      }

      // Use auto-filled userId if available, otherwise find by name
      String? userId = _autoFillUserId;
      if (userId == null) {
        userId = await _findUserIdByName(_patientNameController.text.trim());
      }

      // Save result data to Firestore with proper linking
      final resultData = {
        'patientName': _patientNameController.text.trim(),
        'testName': _testNameController.text.trim(),
        'labName': _labNameController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'notes': _notesController.text.trim(),
        'resultUrl': resultUrl,
        'status': 'completed',
        'userId': userId, // Properly linked to user
        'bookingId': _autoFillBookingId, // Link to booking if auto-filled
        'paymentId': _autoFillPaymentId, // Link to payment if auto-filled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('results').add(resultData);

      // If this was auto-filled from a payment, update the booking status
      if (_autoFillBookingId != null) {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(_autoFillBookingId)
            .update({
          'status': 'completed',
          'resultUploaded': true,
          'resultUploadedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _clearForm();
      _clearAutoFill();
      await _loadResults();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test result uploaded successfully! User will now see it in their results.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('Error uploading result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading result: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<String?> _findUserIdByName(String patientName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: patientName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print('Error finding user by name: $e');
    }
    return null;
  }

  Future<void> _loadResults() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('results')
          .orderBy('createdAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _results = querySnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading results: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _patientNameController.clear();
    _testNameController.clear();
    _labNameController.clear();
    _contactNumberController.clear();
    _notesController.clear();
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
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

  void _viewResult(Map<String, dynamic> result) {
    if (result['resultUrl'] != null) {
      final String url = result['resultUrl'];
      if (url.toLowerCase().contains('.pdf')) {
        // Show PDF document
        showDialog(
          context: context,
          builder: (context) => DocumentViewerDialog(
            documentUrl: url,
            title: 'Test Result - ${result['testName']}',
            fileName: '${result['testName']}_result',
          ),
        );
      } else {
        // Show image
        showDialog(
          context: context,
          builder: (context) => ImageViewerDialog(
            imageUrl: url,
            title: 'Test Result - ${result['testName']}',
          ),
        );
      }
    }
  }

  Future<void> _deleteResult(String resultId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Result'),
        content: Text('Are you sure you want to delete this test result? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      try {
        await FirebaseFirestore.instance
            .collection('results')
            .doc(resultId)
            .delete();

        await _loadResults();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Result deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting result: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _testNameController.dispose();
    _labNameController.dispose();
    _contactNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
