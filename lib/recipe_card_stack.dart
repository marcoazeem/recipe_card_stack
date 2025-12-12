library recipe_card_stack;

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SwipeDirection { left, right, up, down }

typedef CardBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  bool isFrontCard,
);

typedef OnSwipe<T> = void Function(
  int index,
  SwipeDirection direction,
  T item,
);

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
    this.stackAnimationDuration = const Duration(milliseconds: 220),
    this.swipeAnimationDuration = const Duration(milliseconds: 280),
  });

  final List<T> items;
  final CardBuilder<T> cardBuilder;
  final OnSwipe<T>? onSwipe;

  final int maxVisibleCards;
  final double swipeThreshold;
  final double scaleGap;
  final double verticalGap;
  final Set<SwipeDirection> allowDirections;

  final Duration stackAnimationDuration;
  final Duration swipeAnimationDuration;

  @override
  State<InfiniteSwipeCardStack<T>> createState() =>
      _InfiniteSwipeCardStackState<T>();
}

class _InfiniteSwipeCardStackState<T> extends State<InfiniteSwipeCardStack<T>>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _controller;
  late Animation<Offset> _offsetAnim;

  final ValueNotifier<Offset> _dragOffset = ValueNotifier<Offset>(Offset.zero);

  bool _isAnimating = false;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.swipeAnimationDuration,
    );

    _offsetAnim = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )
      ..addListener(() {
        _dragOffset.value = _offsetAnim.value;
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _isAnimating) {
          final direction = _swipeDirection;

          if (direction != null && widget.items.isNotEmpty) {
            final idx = _currentIndex % widget.items.length;
            widget.onSwipe?.call(idx, direction, widget.items[idx]);
          }

          if (!mounted) return;
          setState(() {
            _dragOffset.value = Offset.zero;
            _isAnimating = false;
            _swipeDirection = null;

            if (widget.items.isNotEmpty) {
              _currentIndex = (_currentIndex + 1) % widget.items.length;
            }
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant InfiniteSwipeCardStack<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.swipeAnimationDuration != widget.swipeAnimationDuration) {
      _controller.duration = widget.swipeAnimationDuration;
    }
    // Handle item list changes safely
    if (widget.items.isEmpty) {
      _currentIndex = 0;
    } else {
      _currentIndex = _currentIndex % widget.items.length;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _dragOffset.dispose();
    super.dispose();
  }

  void _jumpToIndex(int itemIndex) {
    if (_isAnimating || widget.items.isEmpty) return;
    setState(() {
      _dragOffset.value = Offset.zero;
      _currentIndex = itemIndex % widget.items.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final visibleCount = math.min(widget.maxVisibleCards, widget.items.length);
    final children = <Widget>[];

    // Build from front (0) to back (visibleCount-1)
    for (int depth = 0; depth < visibleCount; depth++) {
      final itemIndex = (_currentIndex + depth) % widget.items.length;
      final item = widget.items[itemIndex];

      final scale = 1.0 - (widget.scaleGap * depth);
      final offsetY = widget.verticalGap * depth;
      final isFront = depth == 0;

      // FIX: The last card in the stack (the one wrapping around)
      // must snap instantly to position, otherwise it animates from Scale 1.0 (Front)
      // down to Scale 0.8 (Back) *behind* the new front card, causing ghosting.
      final isBottomCard = depth == visibleCount - 1;
      final duration =
          isBottomCard ? Duration.zero : widget.stackAnimationDuration;

      final cardChild = _CardInteractor(
        isFront: isFront,
        dragOffset: _dragOffset,
        canInteract: () => !_isAnimating,
        onTap: () => _jumpToIndex(itemIndex),
        onDragUpdate: (delta) {
          if (!isFront || _isAnimating) return;
          final current = _dragOffset.value;
          final next = current + delta;
          _dragOffset.value = Offset.lerp(current, next, 0.55)!;
        },
        onDragEnd: (velocity) {
          if (!isFront || _isAnimating) return;
          _handlePanEnd(velocity);
        },
        child: RepaintBoundary(
          child: widget.cardBuilder(context, item, itemIndex, isFront),
        ),
      );

      final card = AnimatedContainer(
        key: ValueKey<int>(itemIndex),
        duration: duration, // <--- Use the conditional duration
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, offsetY)
          ..scale(scale, scale),
        transformAlignment: Alignment.topCenter,
        child: cardChild,
      );

      children.add(card);
    }

    return Stack(
      alignment: Alignment.topCenter,
      // Render back cards first, front card last
      children: children.reversed.toList(),
    );
  }

  void _handlePanEnd(Offset velocity) {
    final dx = _dragOffset.value.dx;
    final dy = _dragOffset.value.dy;
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
        targetOffset = Offset(-size.width * 1.5, dy);
        break;
      case SwipeDirection.right:
        targetOffset = Offset(size.width * 1.5, dy);
        break;
      case SwipeDirection.up:
        targetOffset = Offset(dx, -size.height * 1.5);
        break;
      case SwipeDirection.down:
        targetOffset = Offset(dx, size.height * 1.5);
        break;
    }

    _animateTo(targetOffset);
  }

  void _animateTo(Offset target) {
    _offsetAnim = Tween<Offset>(
      begin: _dragOffset.value,
      end: target,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller
      ..reset()
      ..forward();
  }
}

class _CardInteractor extends StatelessWidget {
  const _CardInteractor({
    required this.isFront,
    required this.dragOffset,
    required this.onTap,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
    required this.canInteract,
  });

  final bool isFront;
  final ValueNotifier<Offset> dragOffset;
  final VoidCallback onTap;
  final void Function(Offset delta) onDragUpdate;
  final void Function(Offset velocity) onDragEnd;
  final Widget child;
  final bool Function() canInteract;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isFront ? null : onTap,
      onPanUpdate:
          isFront && canInteract() ? (d) => onDragUpdate(d.delta) : null,
      onPanEnd: isFront && canInteract()
          ? (d) => onDragEnd(d.velocity.pixelsPerSecond)
          : null,
      child: AnimatedBuilder(
        animation: dragOffset,
        builder: (context, _) {
          final offset = isFront ? dragOffset.value : Offset.zero;
          // Reduced rotation slightly for a cleaner look
          final angle = isFront ? (offset.dx / 500.0).clamp(-0.15, 0.15) : 0.0;

          return Transform.translate(
            offset: offset,
            child: Transform.rotate(
              angle: angle,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
