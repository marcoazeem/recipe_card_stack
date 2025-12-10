library recipe_card_stack;

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Directions a card can be swiped.
enum SwipeDirection { left, right, up, down }

/// Builds a card for the given [item].
///
/// [isFrontCard] is `true` when this card is on top and in focus.
typedef CardBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  bool isFrontCard,
);

/// Called whenever the top card is swiped away.
typedef OnSwipe<T> = void Function(
  int index,
  SwipeDirection direction,
  T item,
);

/// A swipeable, infinitely looping stack of cards.
///
/// Features:
/// - Top card is draggable (left/right by default)
/// - Cards behind are visible as "tabs"
/// - Swipe animates card off-screen and advances to the next item
/// - Tapping a back card brings it to the front
class InfiniteSwipeCardStack<T> extends StatefulWidget {
  const InfiniteSwipeCardStack({
    super.key,
    required this.items,
    required this.cardBuilder,
    this.onSwipe,
    this.maxVisibleCards = 4,
    this.swipeThreshold = 120.0,
    this.scaleGap = 0.05,
    this.verticalGap = 70.0,
    this.allowDirections = const {
      SwipeDirection.left,
      SwipeDirection.right,
    },
  });

  /// Items to display.
  final List<T> items;

  /// Builder for each card.
  final CardBuilder<T> cardBuilder;

  /// Callback when the top card is swiped away.
  final OnSwipe<T>? onSwipe;

  /// Maximum number of cards visible at once.
  final int maxVisibleCards;

  /// Drag distance required to count as a swipe.
  final double swipeThreshold;

  /// How much each card shrinks behind the previous.
  final double scaleGap;

  /// Vertical offset between stacked cards.
  final double verticalGap;

  /// Allowed swipe directions.
  final Set<SwipeDirection> allowDirections;

  @override
  State<InfiniteSwipeCardStack<T>> createState() =>
      _InfiniteSwipeCardStackState<T>();
}

class _InfiniteSwipeCardStackState<T> extends State<InfiniteSwipeCardStack<T>>
    with SingleTickerProviderStateMixin {
  /// Index of the front card (looped with modulo).
  int _currentIndex = 0;

  late AnimationController _controller;
  late Animation<Offset> _animation;

  Offset _dragOffset = Offset.zero;
  bool _isAnimating = false;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )
      ..addListener(() {
        setState(() {
          _dragOffset = _animation.value;
        });
      })
      ..addStatusListener(_onAnimationStatusChange);
  }

  void _onAnimationStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isAnimating) {
      final direction = _swipeDirection;
      if (direction != null && widget.items.isNotEmpty) {
        final idx = _currentIndex % widget.items.length;
        widget.onSwipe?.call(idx, direction, widget.items[idx]);
      }

      setState(() {
        _dragOffset = Offset.zero;
        _isAnimating = false;
        _swipeDirection = null;
        if (widget.items.isNotEmpty) {
          _currentIndex = (_currentIndex + 1) % widget.items.length;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Bring a card with the given [itemIndex] to the front.
  void _jumpToIndex(int itemIndex) {
    if (_isAnimating || widget.items.isEmpty) return;
    setState(() {
      _currentIndex = itemIndex % widget.items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final visibleCount = math.min(widget.maxVisibleCards, widget.items.length);

    final children = <Widget>[];

    for (int depth = 0; depth < visibleCount; depth++) {
      final itemIndex = (_currentIndex + depth) % widget.items.length;
      final item = widget.items[itemIndex];

      final scale = 1.0 - (widget.scaleGap * depth);
      final offsetY = widget.verticalGap * depth;
      final isFront = depth == 0;

      Widget cardChild;

      if (isFront) {
        cardChild = _buildDraggableCard(
          child: widget.cardBuilder(
            context,
            item,
            itemIndex,
            true,
          ),
        );
      } else {
        // Back cards: tap to bring to front.
        cardChild = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _jumpToIndex(itemIndex),
          child: widget.cardBuilder(
            context,
            item,
            itemIndex,
            false,
          ),
        );
      }

      final card = Transform.translate(
        offset: Offset(0, offsetY),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: cardChild,
        ),
      );

      children.add(card);
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: children.reversed.toList(),
    );
  }

  Widget _buildDraggableCard({required Widget child}) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (_isAnimating) return;
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        if (_isAnimating) return;
        _handlePanEnd(details.velocity.pixelsPerSecond);
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _dragOffset.dx * 0.0008,
          child: child,
        ),
      ),
    );
  }

  void _handlePanEnd(Offset velocity) {
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    final absDx = dx.abs();
    final absDy = dy.abs();

    SwipeDirection? direction;

    if (absDx > absDy && absDx > widget.swipeThreshold) {
      direction = dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else if (absDy > widget.swipeThreshold) {
      direction = dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }

    if (direction == null || !widget.allowDirections.contains(direction)) {
      _animateTo(Offset.zero);
      return;
    }

    _swipeDirection = direction;
    _isAnimating = true;

    final size = MediaQuery.of(context).size;
    late Offset targetOffset;

    switch (direction) {
      case SwipeDirection.left:
        targetOffset = Offset(-size.width * 1.2, dy);
        break;
      case SwipeDirection.right:
        targetOffset = Offset(size.width * 1.2, dy);
        break;
      case SwipeDirection.up:
        targetOffset = Offset(dx, -size.height * 1.2);
        break;
      case SwipeDirection.down:
        targetOffset = Offset(dx, size.height * 1.2);
        break;
    }

    _animateTo(targetOffset);
  }

  void _animateTo(Offset target) {
    _animation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller
      ..reset()
      ..forward();
  }
}
