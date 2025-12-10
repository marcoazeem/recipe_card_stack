# recipe_card_stack

A smooth, swipeable stacked-card widget for Flutter.  
Cards appear behind each other with visible "tabs", and users can:

- Swipe cards left and right
- Tap any back card to bring it to the front
- View faded “tab” previews of upcoming cards
- Use infinite looping (deck never ends)
- Fully customize each card layout
- Add content that fades in when a card becomes active

Perfect for recipe boxes, flash cards, quizzes, selectors, photo stacks, or classic index-card UIs.

---

## ✨ Features

✔ Smooth swipe animations  
✔ Tap a card to focus it  
✔ Infinite looping  
✔ Fade-in content for active cards  
✔ Configurable card spacing & scale  
✔ Very lightweight — no extra dependencies  
✔ Fully customizable card UI  

---

## 🎥 Demo

in assets folder

---

## 🚀 Installation

```yaml
dependencies:
  recipe_card_stack: ^0.0.1

---

## 🚀 Installation

InfiniteSwipeCardStack<String>(
  items: ["One", "Two", "Three", "Four"],
  maxVisibleCards: 4,
  scaleGap: 0.05,
  verticalGap: 70,
  cardBuilder: (context, item, index, isFront) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFront ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        item,
        style: TextStyle(
          fontSize: isFront ? 28 : 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  },
  onSwipe: (index, direction, item) {
    print("Swiped: $item");
  },
);

---

## Configuration Parametrs

| Parameter         | Type                  | Description                           |
| ----------------- | --------------------- | ------------------------------------- |
| `items`           | `List<T>`             | Your data                             |
| `cardBuilder`     | builder               | Your custom card UI                   |
| `onSwipe`         | callback              | Called when top card is swiped away   |
| `maxVisibleCards` | `int`                 | How many cards are visible            |
| `scaleGap`        | `double`              | Size difference between stacked cards |
| `verticalGap`     | `double`              | Vertical spacing                      |
| `allowDirections` | `Set<SwipeDirection>` | Allowed swipe directions              |
