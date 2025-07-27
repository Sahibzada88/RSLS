import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lab_search_screen.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  Map<String, dynamic>? _selectedTest;
  bool _isLoading = false;
  String? _currentUserName;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Book Test',
          style: TextStyle(
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : 600,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: isMobile ? 40 : 48,
                          color: Colors.green.shade700,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Book Your Test',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Fill in the details to book your lab test',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isMobile ? 12 : 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Test Selection
                  Text(
                    'Select Test',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectTest,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedTest != null ? Colors.green.shade50 : Colors.grey.shade50,
                      ),
                      child: _selectedTest != null
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedTest!['testName'] ?? 'Unknown Test',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                              Text(
                                'AFN ${_selectedTest!['price'] ?? '0'}',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.local_hospital, size: 16, color: Colors.grey.shade600),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Lab: ${_selectedTest!['labName'] ?? 'Unknown'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Location: ${_selectedTest!['location'] ?? 'Unknown'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to change test',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: isMobile ? 10 : 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade400),
                          SizedBox(width: 12),
                          Text(
                            'Tap to search and select a test',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Patient Information
                  Text(
                    'Patient Information',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Form fields with responsive layout
                  if (isMobile) ...[
                    // Mobile layout - single column
                    _buildTextField(
                      controller: _patientNameController,
                      label: 'Patient Name *',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Patient name is required';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _contactNumberController,
                      label: 'Contact Number *',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Contact number is required';
                        }
                        if (value.length < 10) {
                          return 'Enter a valid contact number';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City *',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                    ),
                  ] else ...[
                    // Desktop/Tablet layout - two columns
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _patientNameController,
                            label: 'Patient Name *',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Patient name is required';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _contactNumberController,
                            label: 'Contact Number *',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Contact number is required';
                              }
                              if (value.length < 10) {
                                return 'Enter a valid contact number';
                              }
                              return null;
                            },
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City *',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                    ),
                  ],

                  SizedBox(height: 16),

                  _buildTextField(
                    controller: _addressController,
                    label: 'Complete Address *',
                    icon: Icons.home,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address is required';
                      }
                      if (value.length < 10) {
                        return 'Please provide a complete address';
                      }
                      return null;
                    },
                    isMobile: isMobile,
                  ),

                  SizedBox(height: 32),

                  // Book Test Button
                  Container(
                    width: double.infinity,
                    height: isMobile ? 48 : 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _bookTest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Booking Test...',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Book Test',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            SizedBox(width: 8),
                            Text(
                              'Important Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• After booking, you will be redirected to payment',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                        Text(
                          '• Payment verification may take 24-48 hours',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                        Text(
                          '• Test results will be available after completion',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                        Text(
                          '• Ensure patient name matches your registered name',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Future<void> _loadCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        setState(() {
          _currentUserName = userData['name'];
          _currentUserEmail = userData['email'];
        });

        // Pre-fill patient name with current user's name
        _patientNameController.text = _currentUserName ?? '';

        print('Loaded user data: $_currentUserName, $_currentUserEmail'); // Debug print
      }
    } catch (e) {
      print('Error loading user data: $e'); // Debug print
    }
  }

  Future<void> _selectTest() async {
    final selectedTest = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => LabSearchScreen()),
    );

    if (selectedTest != null) {
      setState(() {
        _selectedTest = selectedTest;
      });
      print('Selected test: ${selectedTest['testName']}'); // Debug print
    }
  }

  Future<void> _bookTest() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if test is selected
    if (_selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a test first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in to book a test'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if email is verified
    if (!user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify your email before booking'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Resend',
            onPressed: () async {
              await user.sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification email sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create booking data
      final bookingData = {
        'userId': user.uid, // This is crucial for security rules
        'userEmail': user.email,
        'testId': _selectedTest!['id'],
        'testName': _selectedTest!['testName'],
        'labName': _selectedTest!['labName'],
        'location': _selectedTest!['location'],
        'price': _selectedTest!['price'],
        'patientName': _patientNameController.text.trim(),
        'contactNumber': _contactNumberController.text.trim(),
        'city': _cityController.text.trim(),
        'address': _addressController.text.trim(),
        'status': 'pending',
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Creating booking with data: $bookingData'); // Debug print

      // Add booking to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add(bookingData);

      print('Booking created successfully with ID: ${docRef.id}'); // Debug print

      // Store booking data for payment screen (you can pass this data through arguments or shared preferences)
      final bookingDataForPayment = {
        'bookingId': docRef.id,
        'testName': _selectedTest!['testName'],
        'amount': _selectedTest!['price'].toDouble(),
        'patientName': _patientNameController.text.trim(),
      };

      // Navigate to payment screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(),
          settings: RouteSettings(arguments: bookingDataForPayment),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test booked successfully! Proceed to payment.'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('Booking error: $e'); // Debug print

      String errorMessage = 'Failed to book test. Please try again.';

      // Handle specific Firebase errors
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please ensure you are signed in and try again.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'Service temporarily unavailable. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _bookTest,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _contactNumberController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
