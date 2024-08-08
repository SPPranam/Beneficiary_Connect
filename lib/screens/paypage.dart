import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PayPage extends StatefulWidget {
  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardTypeController = TextEditingController(text: 'Debit');
  final _cardholderNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();
  final _amountController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _paymentFrequencyController = TextEditingController(text: 'Monthly'); 

  List<Map<String, dynamic>> _userPolicies = [];

  @override
  void initState() {
    super.initState();
    _fetchUserPolicies();
  }

  @override
  void dispose() {
    _cardTypeController.dispose();
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    _amountController.dispose();
    _policyNumberController.dispose();
    _paymentFrequencyController.dispose(); 
    super.dispose();
  }

  Future<void> _fetchUserPolicies() async {
    DatabaseReference purchaseRef = FirebaseDatabase.instance.reference().child('Purchase');
    DatabaseEvent event = await purchaseRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      List<Map<String, dynamic>> policies = [];
      for (DataSnapshot userPolicies in snapshot.children) {
        for (DataSnapshot policy in userPolicies.children) {
          Map<String, dynamic> policyData = {
            'policyNumber': policy.child('PolicyNumber').value,
            'amount': policy.child('Amount').value,
          };
          policies.add(policyData);
        }
      }
      setState(() {
        _userPolicies = policies;
      });
    }
  }

  Future<bool> _isPolicyValid(String policyNumber) async {
    for (var policy in _userPolicies) {
      if (policy['policyNumber'] == policyNumber) {
        return true;
      }
    }
    return false;
  }

  Future<bool> _isDuplicatePayment(String policyNumber, DateTime paymentDate) async {
    DatabaseReference paymentsRef = FirebaseDatabase.instance.reference().child('payments').child(policyNumber);

    DatabaseEvent event = await paymentsRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      for (DataSnapshot payment in snapshot.children) {
        String paymentDateTimeStr = payment.child('dateTime').value.toString();
        DateTime paymentDateTime = DateTime.parse(paymentDateTimeStr);

        if (_paymentFrequencyController.text == 'Monthly') {
          if (paymentDateTime.year == paymentDate.year && paymentDateTime.month == paymentDate.month) {
            return true;
          }
        } else if (_paymentFrequencyController.text == 'Yearly') {
          if (paymentDateTime.year == paymentDate.year) {
            return true;
          }
        }
      }
    }
    return false;
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card Number cannot be empty';
    }

    String cardType = _cardTypeController.text;
    if (cardType == 'Debit') {
      if (!value.startsWith('4') && !value.startsWith('5')) {
        return 'Invalid Debit Card Number';
      }
    } else if (cardType == 'Credit') {
      if (!value.startsWith('4') && !value.startsWith('5')) {
        return 'Invalid Credit Card Number';
      }
    } else {
      return 'Card Type must be either Debit or Credit';
    }

    if (!_luhnAlgorithm(value)) {
      return 'Invalid Card Number';
    }

    return null;
  }

  bool _luhnAlgorithm(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int n = int.parse(cardNumber[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }

      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  void _initiatePayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await Future.delayed(Duration(seconds: 2));

      String policyNumber = _policyNumberController.text.trim();
      bool isPolicyValid = await _isPolicyValid(policyNumber);
      if (!isPolicyValid) {
        Navigator.of(context).pop(); 
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Invalid Policy Number'),
              content: Text('The entered policy number is not valid.'),
              actions: <Widget>[
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
        return;
      }

      DateTime now = DateTime.now();
      DateTime nextPaymentDate;
      if (_paymentFrequencyController.text == 'Monthly') {
        nextPaymentDate = now.add(Duration(days: 30));
      } else {
        nextPaymentDate = DateTime(now.year + 1, now.month, now.day);
      }
      String nextPaymentDateString = nextPaymentDate.toLocal().toString().split(' ')[0]; 

      Map<String, dynamic> paymentData = {
        'cardType': _cardTypeController.text,
        'cardholderName': _cardholderNameController.text,
        'cardNumber': _cardNumberController.text,
        'expiryMonth': _expiryMonthController.text,
        'expiryYear': _expiryYearController.text,
        'cvc': _cvcController.text,
        'amount': _amountController.text,
        'timestamp': now.millisecondsSinceEpoch,
        'dateTime': now.toIso8601String(),
        'paymentFrequency': _paymentFrequencyController.text,
        'nextPaymentDate': nextPaymentDateString,
      };

      bool isDuplicate = await _isDuplicatePayment(policyNumber, now);
      if (isDuplicate) {
        Navigator.of(context).pop(); 
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Duplicate Payment'),
              content: Text('A payment has already been made for this period.'),
              actions: <Widget>[
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
        return;
      }

      DatabaseReference dbRef = FirebaseDatabase.instance.reference().child('payments').child(policyNumber);
      await dbRef.push().set(paymentData);

      Navigator.of(context).pop();

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Payment Successful'),
            content: Text(
                'Your payment of \$${_amountController.text} was successfully processed.\n'
                'Your next payment is due on $nextPaymentDateString.'),
            actions: <Widget>[
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
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      return _userPolicies.where((policy) {
                        return policy['policyNumber']
                            .toString()
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (Map<String, dynamic> policy) =>
                        policy['policyNumber'],
                    onSelected: (Map<String, dynamic> selectedPolicy) {
                      _policyNumberController.text = selectedPolicy['policyNumber'];
                      _amountController.text = selectedPolicy['amount'];
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Policy Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) => _validateNotEmpty(value, 'Policy Number'),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _amountController,
                        label: 'Amount',
                        keyboardType: TextInputType.number,
                        validator: (value) => _validateNotEmpty(value, 'Amount'),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _cardholderNameController,
                        label: 'Cardholder Name',
                        validator: (value) => _validateNotEmpty(value, 'Cardholder Name'),
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _cardNumberController,
                        label: 'Card Number',
                        keyboardType: TextInputType.number,
                        validator: _validateCardNumber,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _expiryMonthController,
                              label: 'Expiry Month',
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNotEmpty(value, 'Expiry Month'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _expiryYearController,
                              label: 'Expiry Year',
                              keyboardType: TextInputType.number,
                              validator: (value) => _validateNotEmpty(value, 'Expiry Year'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _cvcController,
                        label: 'CVC',
                        keyboardType: TextInputType.number,
                        validator: (value) => _validateNotEmpty(value, 'CVC'),
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        value: _cardTypeController.text,
                        items: ['Debit', 'Credit'],
                        onChanged: (newValue) {
                          setState(() {
                            _cardTypeController.text = newValue!;
                          });
                        },
                        label: 'Card Type',
                      ),
                      SizedBox(height: 16),
                      _buildDropdown(
                        value: _paymentFrequencyController.text,
                        items: ['Monthly', 'Yearly'],
                        onChanged: (newValue) {
                          setState(() {
                            _paymentFrequencyController.text = newValue!;
                          });
                        },
                        label: 'Payment Frequency',
                      ),
                      SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: Color.fromARGB(255, 25, 177, 232), // Background color
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  onPressed: _initiatePayment, // Vertical padding
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      color: CupertinoColors.white, // Text color
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
