import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_signup/categories.dart';
import 'package:login_signup/screens/meals.dart';
import 'package:login_signup/screens/models/meal.dart';

class TabsScreen extends StatefulWidget{
  const TabsScreen({super.key});
@override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}


class _TabsScreenState extends State<TabsScreen>{
  int _selectedPageIndex=0;
  final List<Meal> _favouriteMeals = [];
  void _showInfoMessagae(String message){
    ScaffoldMessenger
    .of(context)
    .clearSnackBars();
    ScaffoldMessenger
    .of(context)
    .showSnackBar(
      SnackBar
      (
        content: Text(message),
      ),
      );
  } 

  void _toggleMealFavoritestatus(Meal meal) {
    final isExisting = _favouriteMeals.contains(meal);
    if(isExisting){
      setState(() {
        _favouriteMeals.remove(meal);
      });
      _showInfoMessagae('No Longer A Favorite!');
    }else{
      setState(() {
        _favouriteMeals.add(meal);
        _showInfoMessagae('Marked As Favorite!');
      });
    }

  } 

  void _selectpage(int index){
    setState(() {
      _selectedPageIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {

    Widget activePage = CategoriesScreen(onToggleFavorite: _toggleMealFavoritestatus,);
    var activePageTitle = 'Categories';

    if(_selectedPageIndex == 1){
      activePage =MealsScreen(
        meals:_favouriteMeals,
        onToggleFvorite:_toggleMealFavoritestatus ,
        );
      activePageTitle = 'Favourites';
    }
   return Scaffold(
    appBar: AppBar(
      title: Text(activePageTitle),
    ),
    body: activePage,
    bottomNavigationBar: BottomNavigationBar(
      onTap: _selectpage,
      currentIndex: _selectedPageIndex,
      items: const [
        BottomNavigationBarItem(icon:Icon(Icons.set_meal) ,label: 'Categories' ),
        BottomNavigationBarItem(icon:Icon(Icons.star) ,label:'Favorites' ),

      ],
    ),
   );

  }
}