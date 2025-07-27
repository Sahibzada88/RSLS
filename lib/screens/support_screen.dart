import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String _selectedCategory = 'general';

  final List<Map<String, dynamic>> _supportCategories = [
    {'value': 'general', 'label': 'General Inquiry', 'icon': Icons.help_outline},
    {'value': 'booking', 'label': 'Booking Issues', 'icon': Icons.calendar_today},
    {'value': 'payment', 'label': 'Payment Problems', 'icon': Icons.payment},
    {'value': 'results', 'label': 'Test Results', 'icon': Icons.assignment},
    {'value': 'technical', 'label': 'Technical Support', 'icon': Icons.bug_report},
    {'value': 'complaint', 'label': 'Complaint', 'icon': Icons.report_problem},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Get Support',
          style: TextStyle(
            color: Colors.teal.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Colors.teal.shade700,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  Text(
                    'We\'re here to assist you with any questions or issues',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Quick Help Section
            Text(
              'Quick Help',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildQuickHelpCard(
                  icon: Icons.phone,
                  title: 'Call Us',
                  subtitle: '+1 (555) 123-4567',
                  color: Colors.green,
                  onTap: () => _showContactInfo('phone'),
                ),
                _buildQuickHelpCard(
                  icon: Icons.email,
                  title: 'Email Us',
                  subtitle: 'support@labsystem.com',
                  color: Colors.blue,
                  onTap: () => _showContactInfo('email'),
                ),
                _buildQuickHelpCard(
                  icon: Icons.chat,
                  title: 'Live Chat',
                  subtitle: 'Available 24/7',
                  color: Colors.purple,
                  onTap: () => _showContactInfo('chat'),
                ),
                _buildQuickHelpCard(
                  icon: Icons.help,
                  title: 'FAQ',
                  subtitle: 'Common questions',
                  color: Colors.orange,
                  onTap: () => _showFAQ(),
                ),
              ],
            ),

            SizedBox(height: 32),



            SizedBox(height: 24),

            // Additional Info
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
                        'Support Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Response time: 24-48 hours for email support',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
                  ),
                  Text(
                    '• Phone support: Monday-Friday, 9 AM - 6 PM',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
                  ),
                  Text(
                    '• Emergency support: Available 24/7 for urgent issues',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
                  ),
                  Text(
                    '• Live chat: Available during business hours',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.blue.shade700,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final categoryData = _supportCategories.firstWhere(
          (cat) => cat['value'] == category,
      orElse: () => _supportCategories.first,
    );
    return categoryData['icon'];
  }

  Future<void> _submitSupportRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in to submit a support request'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();

      // Submit support request
      await FirebaseFirestore.instance.collection('support_requests').add({
        'userId': user.uid,
        'userEmail': user.email,
        'userName': userData?['name'] ?? 'Unknown',
        'category': _selectedCategory,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = 'general';
      });

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Request Submitted'),
            ],
          ),
          content: Text(
            'Your support request has been submitted successfully. We\'ll get back to you within 24-48 hours.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text('OK'),
            ),
          ],
        ),
      );

      print('Support request submitted successfully'); // Debug print
    } catch (e) {
      print('Error submitting support request: $e'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showContactInfo(String type) {
    String title = '';
    String content = '';
    IconData icon = Icons.info;

    switch (type) {
      case 'phone':
        title = 'Call Us';
        content = 'Phone: +1 (555) 123-4567\nAvailable: Monday-Friday, 9 AM - 6 PM\nEmergency: 24/7 for urgent issues';
        icon = Icons.phone;
        break;
      case 'email':
        title = 'Email Us';
        content = 'Email: support@labsystem.com\nResponse time: 24-48 hours\nFor urgent matters, please call us directly';
        icon = Icons.email;
        break;
      case 'chat':
        title = 'Live Chat';
        content = 'Live chat is available during business hours\nMonday-Friday: 9 AM - 6 PM\nFor immediate assistance outside these hours, please call us';
        icon = Icons.chat;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(icon, color: Colors.teal.shade700),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    final faqs = [
      {
        'question': 'How do I book a test?',
        'answer': 'Go to the "Book Test" section from the home screen, select your test, fill in the details, and proceed to payment.',
      },
      {
        'question': 'How long does it take to get results?',
        'answer': 'Test results are typically available within 24-48 hours after sample collection. You\'ll be notified when they\'re ready.',
      },
      {
        'question': 'Can I cancel my booking?',
        'answer': 'Yes, you can cancel your booking before the test is conducted. Contact support for assistance with cancellations.',
      },
      {
        'question': 'What payment methods do you accept?',
        'answer': 'We currently accept payments through Easypaisa. More payment options will be available soon.',
      },
      {
        'question': 'How do I view my test results?',
        'answer': 'Go to the "Test Results" section from the home screen. Your results will be available once the lab completes your test.',
      },
      {
        'question': 'What if my payment fails?',
        'answer': 'If your payment fails, you can retry from the "Payments" section. Contact support if you continue to experience issues.',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help, color: Colors.orange.shade700),
            SizedBox(width: 8),
            Text('Frequently Asked Questions'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      faq['answer']!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
