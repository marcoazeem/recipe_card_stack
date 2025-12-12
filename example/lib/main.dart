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
        return DemoRecipeCard(
          key: ValueKey(recipe.title), // use a real id if you have one
          recipe: recipe,
          isFrontCard: isFrontCard,
        );
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
      child: Stack(
        children: [
          // Back "tab" title strip (always present, stable)
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

          // Front details: REAL fade-in on focus change
          FocusFade(
            isFocused: isFrontCard,
            fadeIn: const Duration(milliseconds: 260),
            fadeOut: const Duration(milliseconds: 120),
            curveIn: Curves.easeOutCubic,
            curveOut: Curves.easeOut,
            // Optional: tiny delay so it starts after the swipe settles a bit
            // (feels more premium, less "UI fighting")
            delayOnFocus: const Duration(milliseconds: 60),
            child: _FrontDetails(recipe: recipe),
          ),
        ],
      ),
    );
  }
}

class _FrontDetails extends StatelessWidget {
  final DemoRecipe recipe;

  const _FrontDetails({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Only interactable when focused (FocusFade already handles)
      ignoring: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
      ),
    );
  }
}

/// A fade wrapper that *actually animates* when focus changes.
/// This avoids the common "it popped in" issue when widgets rebuild
/// already in the focused state.
class FocusFade extends StatefulWidget {
  const FocusFade({
    super.key,
    required this.isFocused,
    required this.child,
    this.fadeIn = const Duration(milliseconds: 240),
    this.fadeOut = const Duration(milliseconds: 140),
    this.curveIn = Curves.easeOut,
    this.curveOut = Curves.easeOut,
    this.delayOnFocus = Duration.zero,
  });

  final bool isFocused;
  final Widget child;

  final Duration fadeIn;
  final Duration fadeOut;
  final Curve curveIn;
  final Curve curveOut;

  /// Optional delay before starting fade in (helps after swipe)
  final Duration delayOnFocus;

  @override
  State<FocusFade> createState() => _FocusFadeState();
}

class _FocusFadeState extends State<FocusFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeIn,
      reverseDuration: widget.fadeOut,
      value: widget.isFocused ? 1.0 : 0.0,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.curveIn,
      reverseCurve: widget.curveOut,
    );
  }

  @override
  void didUpdateWidget(covariant FocusFade oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If timing/curves change, refresh controller settings
    if (oldWidget.fadeIn != widget.fadeIn) _controller.duration = widget.fadeIn;
    if (oldWidget.fadeOut != widget.fadeOut) {
      _controller.reverseDuration = widget.fadeOut;
    }

    final becameFocused = !oldWidget.isFocused && widget.isFocused;
    final becameUnfocused = oldWidget.isFocused && !widget.isFocused;

    if (becameFocused) {
      if (widget.delayOnFocus == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(widget.delayOnFocus, () {
          if (!mounted) return;
          // only fade in if still focused
          if (widget.isFocused) _controller.forward();
        });
      }
    } else if (becameUnfocused) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.isFocused,
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
  }
}
