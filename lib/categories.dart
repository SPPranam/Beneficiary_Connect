import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_signup/data/dummy_data.dart';
import 'package:login_signup/mypolicies.dart';
import 'package:login_signup/screens/claim.dart';
import 'package:login_signup/screens/claim_request.dart';
import 'package:login_signup/screens/meals.dart';
import 'package:login_signup/screens/models/meal.dart';
import 'package:login_signup/screens/purchase.dart';
import 'package:login_signup/screens/welcome_screen.dart';
import 'package:login_signup/widgets/category_grid_item.dart';
import 'package:login_signup/screens/models/category.dart';
import 'package:login_signup/screens/paypage.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    Key? key,
    required this.onToggleFavorite,
  }) : super(key: key);

  final void Function(Meal meal) onToggleFavorite;

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late User? _user;
  Map<String, dynamic>? _userData;

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
        _getUserData(user);
      }
    });
  }

  void _getUserData(User user) async {
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _userData = userData.data();
    });
  }

  void _selectCategory(BuildContext context, Category category) {
    final filteredMeals = dummyMeals.where((meal) => meal.categories.contains(category.id)).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealsScreen(
          title: category.title,
          meals: filteredMeals,
          onToggleFvorite: widget.onToggleFavorite,
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => page,
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      'User : ${_user!.email}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_userData != null)
                      Text(
                        'Name: ${_userData!['name'] as String}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.policy),
              title: Text('My Policies'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                _navigateToPage(context, MyPolicyPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Purchase'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                _navigateToPage(context, PurchasePage());
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Claim'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                _navigateToPage(context, ClaimPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Pay'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                _navigateToPage(context, PayPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle), // Icon for ClaimSubmitPage
              title: Text('Submit Claim'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                _navigateToPage(context, ClaimSubmitPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          mainAxisSpacing: 20, // Spacing between rows
          crossAxisSpacing: 20, // Spacing between columns
        ),
        children: [
          for (final category in availableCategories)
            CategoryGridItem(
              category: category,
              onSelectCategory: () {
                _selectCategory(context, category);
              },
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    routes: {
      "/": (context) => WelcomeScreen(),
      "/categories": (context) => CategoriesScreen(
            onToggleFavorite: (meal) {
              // Handle toggle favorite
            },
          ),
      "/pay": (context) => PayPage(),
      "/claim": (context) => ClaimPage(),
      "/purchase": (context) => PurchasePage(),
      "/mypolicies": (context) => MyPolicyPage(),
      "/claimsubmit": (context) => ClaimSubmitPage(), // Add ClaimSubmitPage route
    },
  ));
}
