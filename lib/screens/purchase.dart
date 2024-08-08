import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:login_signup/screens/paypage.dart';

class PurchasePage extends StatefulWidget {
  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  String? _selectedItem;
  final List<String> _items = [
    "LIC's Jeevan Bharathi",
    "LIC’s New Jeevan Mangal",
    'Postal Life Insurance',
    'Fixed Deposit(Bank)',
    'Fixed Deposit(Postal)',
    'TATA',
    'Post RD',
    'Bank RD',
    'Vehicle'
  ];

  String _enteredName = '';
  String _enteredContact = '';
  String _enteredAddress = '';
  String _enteredAmount = '';
  String _enteredPan = ''; // Add this line

  String? _paymentFrequency;
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _panController = TextEditingController(); // Add this line
  final _formkey = GlobalKey<FormState>();

  String _randomPolicyNumber = '';

  List<Map<String, String>> _nomineeDetailsList = []; // Ensure this is initialized

  bool loading = false;
  final databaseRef = FirebaseDatabase.instance.reference().child('Purchase');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase'),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Items to Purchase',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < (_items.length / 2).ceil(); i++)
                            if (i < _items.length)
                              Row(
                                children: [
                                  Radio<String>(
                                    value: _items[i],
                                    groupValue: _selectedItem,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedItem = value;
                                      });
                                    },
                                  ),
                                  Text(_items[i]),
                                  SizedBox(
                                      height:
                                          20), // Adjust the spacing between items
                                ],
                              ),
                        ],
                      ),
                      SizedBox(width: 50), // Adjust the spacing between columns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = (_items.length / 2).ceil();
                              i < _items.length;
                              i++)
                            if (i < _items.length)
                              Row(
                                children: [
                                  Radio<String>(
                                    value: _items[i],
                                    groupValue: _selectedItem,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedItem = value;
                                      });
                                    },
                                  ),
                                  Text(_items[i]),
                                  SizedBox(
                                      height:
                                          20), // Adjust the spacing between items
                                ],
                              ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Purchaser Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length == 1 ||
                        value.trim().length > 30) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredName = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 10) {
                      return 'Please Enter Number Correctly';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredContact = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length == 1 ||
                        value.trim().length > 30) {
                      return 'Please Enter Correct Address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredAddress = value!;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (double.tryParse(value!) == null ||
                        double.parse(value!) <= 0) {
                      return 'Please Enter Correct Amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredAmount = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _panController, // Add this TextFormField
                  decoration: const InputDecoration(
                    labelText: 'PAN Card',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 10) {
                      return 'Please Enter Valid PAN Card Number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredPan = value!;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Payment Frequency: '),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio(
                          value: 'Yearly',
                          groupValue: _paymentFrequency,
                          onChanged: (String? value) {
                            setState(() {
                              _paymentFrequency = value;
                            });
                          },
                        ),
                        Text('Yearly'),
                        Radio(
                          value: 'Monthly',
                          groupValue: _paymentFrequency,
                          onChanged: (String? value) {
                            setState(() {
                              _paymentFrequency = value;
                            });
                          },
                        ),
                        Text('Monthly'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nominee Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < _nomineeDetailsList.length; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Nominee ${i + 1} Details',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length == 1 ||
                                  value.trim().length > 30) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _nomineeDetailsList[i]['name'] = value!;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Relation',
                              prefixIcon: Icon(Icons.people),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length == 1 ||
                                  value.trim().length > 30) {
                                return 'Please Enter Relation Properly';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _nomineeDetailsList[i]['relation'] = value!;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please Enter a Valid Email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _nomineeDetailsList[i]['email'] = value!;
                            },
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _nomineeDetailsList.removeAt(i);
                              });
                            },
                            icon: Icon(Icons.remove),
                            label: Text('Delete Nominee'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _nomineeDetailsList.add({
                            'name': '',
                            'relation': '',
                            'email': '',
                          });
                        });
                      },
                      child: Text('Add Nominee'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      _generatePolicyNumber(); // Generate policy number
                      print('Form is valid, proceed with submission');
                      _saveItem(); // Call saveItem method
                    } else {
                      print('Form is invalid');
                    }
                  },
                  child: loading ? CircularProgressIndicator() : Text('Submit'),
                ),
                SizedBox(height: 20),
                if (_randomPolicyNumber.isNotEmpty)
                  Text(
                    'Policy Number: $_randomPolicyNumber',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generatePolicyNumber() {
    var random = Random();
    if (_selectedItem != null && _selectedItem!.length >= 3) {
      String prefix = _selectedItem!.substring(0, 3).toUpperCase();
      String suffix = '';
      for (var i = 0; i < 7; i++) {
        // Generate 7 random digits
        suffix += random.nextInt(10).toString();
      }
      _randomPolicyNumber = '$prefix$suffix';
     // print('Generated Policy Number: $_randomPolicyNumber');
    } else {
      _randomPolicyNumber = '';
    }
  }

  Future<void> _saveItem() async {
    setState(() {
      loading = true;
    });
    _formkey.currentState!.save();

    // Generate policy number
    _generatePolicyNumber();

    // Get the logged-in user's email
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    if (userEmail != null) {
      // Print the data before saving it to the database
      print('Policy Number: $_randomPolicyNumber');
      print('Category: $_selectedItem');
      print('Name: $_enteredName');
      print('Contact: $_enteredContact');
      print('Address: $_enteredAddress');
      print('Amount: $_enteredAmount');
      print('PAN: $_enteredPan'); 
      print('Payment Frequency: $_paymentFrequency');
      print('Nominee Details: $_nomineeDetailsList');
      print('User Email: $userEmail');

      // Save the data to the database
      databaseRef
          .child(userEmail.replaceAll('.', '_')) // Use email as the node key, replacing '.' with '_'
          .push()
          .set({
        'PolicyNumber': _randomPolicyNumber,
        'Category': _selectedItem,
        'Name': _enteredName,
        'Contact': _enteredContact,
        'Address': _enteredAddress,
        'Amount': _enteredAmount,
        'PAN': _enteredPan,
        'PaymentFrequency': _paymentFrequency,
        'NomineeDetails': _nomineeDetailsList,
      }).then((value) {
        Fluttertoast.showToast(
          msg: 'Data submitted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        setState(() {
          loading = false;
        });
        _showPaymentConfirmationDialog(context);
      }).catchError((error) {
        Fluttertoast.showToast(
          msg: 'Error: $error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        setState(() {
          loading = false;
        });
      });
    } else {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
        msg: 'Error: User not logged in',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => page,
      ),
    );
  }

  void _showPaymentConfirmationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Payment Confirmation'),
          content: Text('The amount entered must be paid.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                _navigateToPage(context, PayPage());
              },
              child: Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _panController.dispose(); 
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/": (context) => PurchasePage(),
      "/pay": (context) => PayPage(),
    },
  ));
}
