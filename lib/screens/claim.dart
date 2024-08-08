import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:login_signup/screens/claim_request.dart';
class ClaimPage extends StatefulWidget {
  @override
  _ClaimPageState createState() => _ClaimPageState();
}

class _ClaimPageState extends State<ClaimPage> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref().child('Purchase');
  TextEditingController _searchController = TextEditingController();
  List<Map<dynamic, dynamic>> _searchResults = [];

  // Validate PAN number
  bool _validatePAN(String pan) {
    return pan.length == 10;
  }

  void _searchData() async {
    String searchText = _searchController.text.trim();

    if (_validatePAN(searchText)) {
      if (searchText.isNotEmpty) {
        try {
          DatabaseEvent event = await _ref.once();
          DataSnapshot snapshot = event.snapshot;

          if (snapshot.value != null) {
            Map<dynamic, dynamic> userPolicies = snapshot.value as Map<dynamic, dynamic>;
            List<Map<dynamic, dynamic>> searchResults = [];

            userPolicies.forEach((userId, policies) {
              Map<dynamic, dynamic> policyMap = policies as Map<dynamic, dynamic>;
              policyMap.forEach((policyId, policyDetails) {
                String panNumber = (policyDetails as Map<dynamic, dynamic>)['PAN']!.toString().toLowerCase();

                if (panNumber == searchText.toLowerCase()) {
                  searchResults.add(policyDetails as Map<dynamic, dynamic>);
                }
              });
            });

            setState(() {
              _searchResults = searchResults;
            });
          } else {
            setState(() {
              _searchResults = [];
            });
          }
        } catch (e) {
          print("Error searching data: $e");
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Error'),
                content: Text('An error occurred while searching.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          setState(() {
            _searchResults = [];
          });
        }
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } else {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Invalid PAN Number'),
            content: Text('The PAN number should be exactly 10 characters long.'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _navigateToClaimSubmitPage(Map<dynamic, dynamic> policyDetails) async {
    String policyNumber = policyDetails['PolicyNumber']!;
    final DatabaseReference paymentsRef = FirebaseDatabase.instance.ref().child('payments').child(policyNumber);

    try {
      DatabaseEvent event = await paymentsRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> payments = snapshot.value as Map<dynamic, dynamic>;
        int completedInstallments = payments.values
          .where((payment) => (payment as Map<dynamic, dynamic>)['amount'] != null) // Adjust condition if needed
          .length;

        if (completedInstallments >= 5) { // Adjust the number if needed
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ClaimSubmitPage(), // Modify if necessary
            ),
          );
        } else {
          showCupertinoDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Insufficient Payments'),
                content: Text('The policy must have at least 2 payments completed to submit a claim.'),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Insufficient Installments'),
              content: Text('The Policy Must Have >5 Installments.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print("Error fetching payment data: $e");
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Insufficient Installments'),
            content: Text('An error occurred while fetching payment data.'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Search Policies'),
        backgroundColor: CupertinoColors.white,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                controller: _searchController,
                placeholder: 'Enter PAN Number',
                clearButtonMode: OverlayVisibilityMode.editing,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                prefix: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(CupertinoIcons.search, color: CupertinoColors.systemGrey),
                ),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: CupertinoColors.systemGrey, width: 0.5),
                ),
              ),
              SizedBox(height: 16.0),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _searchData,
                child: Text('Search', style: TextStyle(color: CupertinoColors.systemBlue)),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final result = _searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0), // Added more gap between items
                      child: CupertinoButton(
                        onPressed: () {
                          _navigateToClaimSubmitPage(result);
                        },
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Result', // Added "Result" label
                              style: TextStyle(
                                fontSize: 16.0, // Slightly larger text size for the label
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.black,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Policy Number: ${result['PolicyNumber']}',
                              style: TextStyle(
                                fontSize: 14.0, // Smaller text size
                                color: CupertinoColors.black, // Black text color
                              ),
                            ),
                            SizedBox(height: 8.0),
                            ...result.entries
                                .where((entry) => entry.key != 'PolicyNumber')
                                .map((entry) =>
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text(
                                      '${entry.key}: ${entry.value}',
                                      style: TextStyle(
                                        fontSize: 14.0, // Smaller text size
                                        color: CupertinoColors.black, // Black text color
                                      ),
                                    ),
                                  )
                                )
                                .toList(),
                            SizedBox(height: 8.0),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _navigateToClaimSubmitPage(result);
                              },
                              child: Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey),
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
        ),
      ),
    );
  }
}
