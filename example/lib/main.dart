import 'package:flutter/material.dart';
import 'package:recipe_card_stack/recipe_card_stack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFE0E0E0),
        body: Center(
          child: SizedBox(width: 320, height: 480, child: RecipeStackDemo()),
        ),
      ),
    );
  }
}

class RecipeStackDemo extends StatelessWidget {
  const RecipeStackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = <DemoRecipe>[
      const DemoRecipe(
        title: 'Banana Cake',
        description: 'Soft, moist banana cake with vanilla.',
        serves: '8',
        prepTime: '15 min',
        cookTime: '35 min',
        color: Color(0xFFFFF7E6),
      ),
      const DemoRecipe(
        title: 'Chocolate Cake',
        description: 'Rich and fudgy chocolate layers.',
        serves: '10',
        prepTime: '20 min',
        cookTime: '30 min',
        color: Color(0xFFFFEFEF),
      ),
      const DemoRecipe(
        title: 'Vanilla Cupcakes',
        description: 'Light vanilla cupcakes with buttercream.',
        serves: '12',
        prepTime: '15 min',
        cookTime: '18 min',
        color: Color(0xFFFFF9F0),
      ),
      const DemoRecipe(
        title: 'Carrot Cake',
        description: 'Spiced carrot cake with cream cheese frosting.',
        serves: '8',
        prepTime: '25 min',
        cookTime: '40 min',
        color: Color(0xFFF7FFF2),
      ),
    ];

    return InfiniteSwipeCardStack<DemoRecipe>(
      items: recipes,
      maxVisibleCards: 4,
      scaleGap: 0.05,
      verticalGap: 70.0,
      cardBuilder: (context, recipe, index, isFrontCard) {
        return DemoRecipeCard(recipe: recipe, isFrontCard: isFrontCard);
      },
      onSwipe: (index, direction, recipe) {
        debugPrint('Swiped ${recipe.title} to $direction');
      },
    );
  }
}

class DemoRecipe {
  final String title;
  final String description;
  final String serves;
  final String prepTime;
  final String cookTime;
  final Color color;

  const DemoRecipe({
    required this.title,
    required this.description,
    required this.serves,
    required this.prepTime,
    required this.cookTime,
    required this.color,
  });
}

class DemoRecipeCard extends StatelessWidget {
  final DemoRecipe recipe;
  final bool isFrontCard;

  const DemoRecipeCard({
    super.key,
    required this.recipe,
    required this.isFrontCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        color: recipe.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: isFrontCard
            ? _buildFrontLayout(key: const ValueKey('front'))
            : _buildBackLayout(key: const ValueKey('back')),
      ),
    );
  }

  Widget _buildFrontLayout({required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              recipe.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(recipe.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Serves: ${recipe.serves}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Prep: ${recipe.prepTime}",
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "Cook: ${recipe.cookTime}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              "Read Recipe",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackLayout({required Key key}) {
    return Stack(
      key: key,
      children: [
        Positioned.fill(child: Container(color: recipe.color)),
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            width: double.infinity,
            color: Colors.black.withOpacity(0.25),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              recipe.title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
