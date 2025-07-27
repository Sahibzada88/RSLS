import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LabSearchScreen extends StatefulWidget {
  @override
  _LabSearchScreenState createState() => _LabSearchScreenState();
}

class _LabSearchScreenState extends State<LabSearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allTests = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllTests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Lab Search',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for tests...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _hasSearched = false;
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _searchTests,
                onSubmitted: _searchTests,
              ),
            ),

            SizedBox(height: 20),

            // Show all tests initially or search results
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildTestsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsList() {
    List<Map<String, dynamic>> testsToShow;
    String emptyMessage;

    if (!_hasSearched || _searchController.text.isEmpty) {
      testsToShow = _allTests;
      emptyMessage = 'No tests available. Admin needs to add tests.';
    } else {
      testsToShow = _searchResults;
      emptyMessage = 'No tests found for "${_searchController.text}". Try a different search term.';
    }

    if (testsToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_hasSearched && _allTests.isEmpty) ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAllTests,
                child: Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: testsToShow.length,
      itemBuilder: (context, index) {
        final test = testsToShow[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              test['testName'] ?? 'Unknown Test',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_hospital, size: 16, color: Colors.blue.shade600),
                    SizedBox(width: 4),
                    Text('Lab: ${test['labName'] ?? 'Unknown Lab'}'),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                    SizedBox(width: 4),
                    Text('Location: ${test['location'] ?? 'Unknown Location'}'),
                  ],
                ),
                if (test['description'] != null && test['description'].isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    test['description'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'AFN ${test['price'] ?? '0'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                  fontSize: 16,
                ),
              ),
            ),
            onTap: () {
              // Navigate back with selected test
              Navigator.pop(context, test);
            },
          ),
        );
      },
    );
  }

  Future<void> _loadAllTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tests')
          .orderBy('testName')
          .get();

      setState(() {
        _allTests = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoading = false;
      });

      print('Loaded ${_allTests.length} tests'); // Debug print
    } catch (e) {
      print('Error loading tests: $e'); // Debug print
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

  void _searchTests(String query) {
    setState(() {
      _hasSearched = true;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final searchQuery = query.toLowerCase().trim();

    setState(() {
      _searchResults = _allTests.where((test) {
        final testName = (test['testName'] ?? '').toLowerCase();
        final labName = (test['labName'] ?? '').toLowerCase();
        final location = (test['location'] ?? '').toLowerCase();
        final description = (test['description'] ?? '').toLowerCase();

        return testName.contains(searchQuery) ||
            labName.contains(searchQuery) ||
            location.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();
    });

    print('Search query: $searchQuery, Results: ${_searchResults.length}'); // Debug print
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
