import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_screen.dart';
import 'test_results_screen.dart';
import 'admin_screen.dart';
import 'signin_screen.dart';
import 'booking_history_screen.dart';
import 'payment_section_screen.dart';
import 'support_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isMobile = screenWidth < 600;
    final crossAxisCount = isTablet ? 4 : (isMobile ? 2 : 3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Lab Management',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userName ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _userRole == 'admin' ? 'Administrator' : 'Patient',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 20 : 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            // Action Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isMobile ? 12 : 16,
              mainAxisSpacing: isMobile ? 12 : 16,
              childAspectRatio: isMobile ? 1.0 : 1.2,
              children: _userRole == 'admin'
                  ? _buildAdminActions(isMobile)
                  : _buildUserActions(isMobile),
            ),

            SizedBox(height: isMobile ? 20 : 24),

            // Recent Activity (placeholder)
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: isMobile ? 40 : 48,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No recent activity',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _userRole == 'admin'
                          ? 'Recent admin activities will appear here'
                          : 'Your recent bookings and results will appear here',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: isMobile ? 12 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAdminActions(bool isMobile) {
    return [
      _buildActionCard(
        icon: Icons.admin_panel_settings,
        title: 'Admin Panel',
        subtitle: 'Manage system',
        color: Colors.red,
        isMobile: isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminScreen()),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.analytics,
        title: 'Analytics',
        subtitle: 'View reports',
        color: Colors.orange,
        isMobile: isMobile,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analytics feature coming soon!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.people,
        title: 'User Management',
        subtitle: 'Manage users',
        color: Colors.purple,
        isMobile: isMobile,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User management feature coming soon!'),
              backgroundColor: Colors.purple,
            ),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.settings,
        title: 'System Settings',
        subtitle: 'Configure system',
        color: Colors.teal,
        isMobile: isMobile,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('System settings feature coming soon!'),
              backgroundColor: Colors.teal,
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildUserActions(bool isMobile) {
    return [
      _buildActionCard(
        icon: Icons.calendar_today,
        title: 'Book Test',
        subtitle: 'Schedule a lab test',
        color: Colors.green,
        isMobile: isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingScreen()),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.assignment,
        title: 'Test Results',
        subtitle: 'View your results',
        color: Colors.purple,
        isMobile: isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TestResultsScreen()),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.history,
        title: 'Booking History',
        subtitle: 'View past bookings',
        color: Colors.blue,
        isMobile: isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingHistoryScreen()),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.payment,
        title: 'Payments',
        subtitle: 'Manage payments',
        color: Colors.orange,
        isMobile: isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentSectionScreen()),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.support_agent,
        title: 'Get Support',
        subtitle: 'Contact support',
        color: Colors.teal,
        isMobile: isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SupportScreen()),
          );
        },
      ),
      _buildActionCard(
        icon: Icons.account_circle,
        title: 'Profile',
        subtitle: 'Manage profile',
        color: Colors.indigo,
        isMobile: isMobile,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile management feature coming soon!'),
              backgroundColor: Colors.indigo,
            ),
          );
        },
      ),
    ];
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isMobile,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 24 : 32,
                  color: Colors.lightBlueAccent.shade700,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
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

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        final userData = userDoc.data()!;
        setState(() {
          _userName = userData['name'];
          _userRole = userData['role'] ?? 'user';
          _isLoading = false;
        });
        print('User data loaded: $_userName, Role: $_userRole'); // Debug print
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e'); // Debug print
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Cancel any ongoing operations here if needed
    super.dispose();
  }
}
