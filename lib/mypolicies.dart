import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyPolicyPage extends StatefulWidget {
  const MyPolicyPage({Key? key}) : super(key: key);

  @override
  _MyPolicyPageState createState() => _MyPolicyPageState();
}

class _MyPolicyPageState extends State<MyPolicyPage> {
  User? _user;
  List<Map<String, dynamic>> _policies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  void _getUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
      if (user != null) {
        _fetchPolicies();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchPolicies() async {
    if (_user == null) return; // Ensure user is not null

    String userEmail = _user!.email!.replaceAll('.', '_'); // Replace '.' with '_' for Firebase key compatibility

    DatabaseReference policiesRef = FirebaseDatabase.instance
        .ref()
        .child('Purchase')
        .child(userEmail); // Navigate to the user-specific policies node

    try {
      final policiesSnapshot = await policiesRef.once();
      final policiesData = policiesSnapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (policiesData != null) {
        final List<Map<String, dynamic>> policiesList = [];

        for (final entry in policiesData.entries) {
          final policyId = entry.key;
          final policyData = entry.value as Map<dynamic, dynamic>;
          final policyNumber = policyData['PolicyNumber'] as String;

          // Fetch next payment date from payments table using the policy number
          final paymentsRef = FirebaseDatabase.instance
              .ref()
              .child('payments')
              .child(policyNumber); // Navigate to the specific payments node using policy number

          final paymentsSnapshot = await paymentsRef.once();
          final paymentsData = paymentsSnapshot.snapshot.value as Map<dynamic, dynamic>?;

          String nextPaymentDate = 'N/A';
          if (paymentsData != null && paymentsData.containsKey('nextPaymentDate')) {
            nextPaymentDate = paymentsData['nextPaymentDate'] as String;
          }

          // Add formatted policy data to the list
          policiesList.add({
            'id': policyId,
            ...Map<String, dynamic>.from(policyData),
            'nextPaymentDate': nextPaymentDate,
          });
        }

        setState(() {
          _policies = policiesList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print("Error fetching policies: $error");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _customFormatDate(String dateStr) {
    try {
      // Parse the date assuming it is in 'yyyy-MM-dd' format
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = parts[1];
        final day = parts[2];
        return '$day-$month-$year'; // Convert to 'dd-MM-yyyy'
      } else {
        return 'Invalid Date Format';
      }
    } catch (e) {
      print('Error parsing date: $e');
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Policies'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _policies.isEmpty
              ? Center(child: Text('No policies available'))
              : ListView.builder(
                  itemCount: _policies.length,
                  itemBuilder: (context, index) {
                    final policy = _policies[index];
                    return Card(
                      child: ListTile(
                        title: Text(policy['PolicyNumber'] ?? 'No Policy Number'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${policy['Name'] ?? 'N/A'}'),
                            Text('Category: ${policy['Category'] ?? 'N/A'}'),
                            Text('Amount: ${policy['Amount'] ?? 'N/A'}'),
                            Text('Payment Frequency: ${policy['PaymentFrequency'] ?? 'N/A'}'),
                            Text('Next Payment Date: ${_customFormatDate(policy['nextPaymentDate'] ?? 'N/A')}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyPolicyPage(),
  ));
}
