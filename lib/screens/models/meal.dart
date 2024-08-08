enum Complexity {
  simple,
  challenging,
  hard,
  Whole_Life,
}

enum Affordability {
  Basic,
  Standard,
  Premium,
  Economical,
  Moderate,
  Value,
  Exclusive,
  Elite,
  Budgetfriendly,
  Highend,
}

class Meal {
  const Meal({
    required this.id,
    required this.categories,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.complexity,
    required this.affordability,
    required this.percentage,
  });

  final String id;
  final List<String> categories;
  final String title;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  final double percentage;
}
