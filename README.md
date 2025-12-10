# recipe_card_stack

<p align="center">
  <img src="https://raw.githubusercontent.com/marcoazeem/recipe_card_stack/main/assets/logo.png" width="120" alt="Logo"/>
</p>

A smooth, swipeable stacked-card widget for Flutter. Cards appear behind each other with visible “tabs”, giving a vintage index-card feel. Users can:

- Swipe cards left and right
- Tap any back card to bring it to the front
- Preview upcoming cards in the stack
- Loop infinitely through the deck
- Fade in full card content when the card becomes active
- Customize every part of the UI

Perfect for **recipe boxes**, **flash cards**, **quizzes**, **selectors**, **photo stacks**, or any classic card-based interface.

---

## ✨ Features

- 🎞 Smooth swipe animations  
- 👆 Tap-to-focus stacked cards  
- ♾ Infinite looping  
- 🌫 Fade-in content for focused cards  
- 🧩 Customizable layout + builder  
- ⚙ Configurable spacing, scale & depth  
- 🪶 Very lightweight (no dependencies)  

---

## 🎥 Demo

<p align="center">
  <img src="https://raw.githubusercontent.com/marcoazeem/recipe_card_stack/main/assets/demo.gif" width="400" />
</p>

---

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  recipe_card_stack: ^0.0.3
```

Then run:

```
flutter pub get
```

---

## 🎯 Basic Usage

```dart
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
```

---

## ⚙ Configuration Parameters

| Parameter         | Type                  | Description                                  |
|------------------|-----------------------|----------------------------------------------|
| `items`          | `List<T>`             | Your card data                               |
| `cardBuilder`    | builder               | Build UI for each card                       |
| `onSwipe`        | callback              | Triggered when top card is swiped away       |
| `maxVisibleCards`| `int`                 | Number of visible stacked cards              |
| `scaleGap`       | `double`              | Scale difference between stacked cards       |
| `verticalGap`    | `double`              | Vertical offset for stacked cards            |
| `allowDirections`| `Set<SwipeDirection>` | Allowed swipe directions                      |

---

## 📦 Example Project

A fully working example is included in the `example/` folder:

```bash
flutter run -t example/lib/main.dart
```

---

## 📄 License

This package is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for details.

---

## ❤️ Contributing

Issues and pull requests are welcome! Feel free to open discussions or submit improvements on GitHub.
