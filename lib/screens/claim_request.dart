import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class ClaimSubmitPage extends StatefulWidget {
  @override
  _ClaimSubmitPageState createState() => _ClaimSubmitPageState();
}

class _ClaimSubmitPageState extends State<ClaimSubmitPage> {
  final _policyNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final databaseRef =
      FirebaseDatabase.instance.reference().child('ClaimRequests');

  @override
  void dispose() {
    _policyNumberController.dispose();
    _nameController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _submitClaimRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final policyNumber = _policyNumberController.text.trim();
      final enteredName = _nameController.text.trim();
      final enteredRelation = _relationController.text.trim();

      // Check if claim request already exists for the policy number
      final claimSnapshot = await databaseRef
          .orderByChild('PolicyNumber')
          .equalTo(policyNumber)
          .once();
      if (claimSnapshot.snapshot.value != null) {
        _showCupertinoDialog(
          title: 'Error',
          content: 'Claim request already submitted for this policy number',
        );
        return;
      }

      // Check if there are at least 5 payments for the policy number
      final paymentsRef = FirebaseDatabase.instance.reference().child('payments/$policyNumber');
      final paymentsSnapshot = await paymentsRef.once();
      if (paymentsSnapshot.snapshot.value == null || (paymentsSnapshot.snapshot.value as Map).length < 5) {
        _showCupertinoDialog(
          title: 'Error',
          content: 'Not enough payments for claim request to be processed',
        );
        return;
      }

      // Submit claim request
      databaseRef.push().set({
        'PolicyNumber': policyNumber,
        'Name': enteredName,
        'Relation': enteredRelation,
        'IsNominee': true, // Since the checkbox is removed, assume always true
      }).then((_) {
        // Show confirmation dialog
        _showCupertinoDialog(
          title: 'Claim Request Initiated',
          content: 'Your claim request for policy number $policyNumber has been initiated. An agent will contact you soon!',
        );

        // Send push notification to the original nominee and the person who sent the claim
        _sendClaimRequestNotification(enteredName, policyNumber);
      }).catchError((error) {
        _showCupertinoDialog(
          title: 'Error',
          content: 'Error: $error',
        );
      });
    }
  }

  Future<void> _sendClaimRequestNotification(
      String name, String policyNumber) async {
    final String serverKey =
        'YOUR_FIREBASE_SERVER_KEY'; // Replace with your Firebase Cloud Messaging server key
    final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

    // Notification content
    final Map<String, dynamic> notification = {
      'notification': {
        'title': 'Claim Request Initiated',
        'body':
            'Your claim request for policy number $policyNumber has been initiated.',
      },
      'data': {
        'click_action':
            'FLUTTER_NOTIFICATION_CLICK', // Optional: Handle notification click in Flutter
        'policyNumber': policyNumber,
      },
      'to':
          '/topics/claimRequests', // Send notification to a specific topic or device token
    };

    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=$serverKey', // Server key for Firebase Cloud Messaging
        },
        body: jsonEncode(notification),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Notification sent successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to send notification: ${response.reasonPhrase}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error sending notification: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showCupertinoDialog({required String title, required String content}) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Claim Submission'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _policyNumberController,
                  decoration: InputDecoration(labelText: 'Policy Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter policy number';
                    } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value)) {
                      return 'Policy number can only contain letters and numbers';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Your Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) {
                      return 'Name can only contain letters and spaces';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _relationController,
                  decoration:
                      InputDecoration(labelText: 'Relation with Policyholder'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your relation';
                    } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) {
                      return 'Relation can only contain letters and spaces';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitClaimRequest,
                  child: Text('Submit Claim Request'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ClaimSubmitPage(),
  ));
}
