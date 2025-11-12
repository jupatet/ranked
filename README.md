# Ranked# Ranked# Ranked - ELO Rating System App



A Flutter app for ranking items using an ELO-based rating system.



## FeaturesA Flutter application for ranking items using an intelligent ELO-based rating system with hybrid comparison selection.A Flutter application for ranking people or objects using an ELO rating system with categories and customizable questions.



- Manage items with groups and categories

- Compare items with a tracking system that avoids duplicate questions

- View live rankings with detailed statistics## Features## Features

- Cloud sync with Firebase

- Charts and analytics

- Search and filter items

- 🎯 **Smart Item Management**: Create and organize rankable items with groups and custom attributes### 🎯 Core Functionality

## How It Works

- 📊 **Hybrid Comparison Algorithm**: Intelligent pairing system that prioritizes least-compared items while selecting the closest ratings for accurate ranking- **Item Management**: Create and manage a list of people or objects to rank

The app uses an ELO rating system similar to chess rankings. Items start at 1000 points and adjust based on comparison outcomes.

- 🔥 **Real-time Rankings**: Live leaderboard with dynamic ratings and performance statistics- **Categories & Questions**: Define custom categories with specific questions for comparison

### Comparison Algorithm

- 🌐 **Cloud Sync**: Firebase integration for data backup and synchronization- **Swipeable Comparisons**: Intuitive swipe left/right interface to choose between items

The algorithm tracks every item pair to ensure no comparison is repeated until all possible combinations have been asked:

- 📈 **Visual Analytics**: Charts and statistics powered by fl_chart- **ELO Rating System**: Chess-inspired rating algorithm that adjusts based on:

- Maintains a history of all comparisons (item A vs item B for each question)

- Only presents item pairs that haven't been compared yet- 🎨 **Modern UI**: Clean interface built with Forui design system  - Number of comparisons (new items have more volatile ratings)

- When all possible combinations are exhausted, the history resets automatically

- Prioritizes items with fewer comparisons to ensure balanced coverage- 🔍 **Search & Filter**: Quick search functionality for managing large item collections  - Expected vs actual outcomes



### Rating System- 🏆 **Animated Elements**: Engaging UI with smooth animations including trophy glow effects  - Relative skill differences



- Items start at 1000 points

- K-Factor changes based on comparison count (newer items have more volatile ratings)

- Ratings adjust after each comparison using expected outcome calculations## How It Works### 📊 Features

- The more comparisons an item has, the more stable its rating becomes

- **Real-time Rankings**: View live leaderboard with ratings and tiers

## Setup

### ELO Rating System- **Persistent Storage**: All data saved locally using SharedPreferences

### Prerequisites

The app uses a modified ELO rating system with intelligent comparison selection:- **Statistics Tracking**: Monitor total items, categories, questions, and comparisons

- Flutter SDK 3.9.2+

- Dart SDK 3.9.2+- **Beautiful UI**: Built with [forui](https://pub.dev/packages/forui) design system

- Firebase account (for cloud features)

1. **Starting Rating**: All items begin at 1000 points

### Installation

2. **Hybrid Selection Strategy**:## How It Works

```bash

git clone https://github.com/yourusername/ranked.git   - Filters items to the bottom 50% by comparison count (using median)

cd ranked

flutter pub get   - Among filtered items, selects the pair with closest ratings### 1. Setup Phase

```

   - Ensures balanced coverage while maintaining fair matchups1. **Add Items**: Create a list of people or objects you want to rank (minimum 2)

### Firebase Configuration

3. **Dynamic K-Factor**: Rating volatility adjusts based on comparison count2. **Create Categories**: Define categories like "Skills", "Personality", "Performance"

1. Add `google-services.json` to `android/app/`

2. Add `GoogleService-Info.plist` to `ios/Runner/`   - New items: Higher volatility for faster convergence3. **Add Questions**: Write questions for each category (e.g., "Who is more creative?")



### Run   - Established items: Lower volatility for stability



```bash### 2. Comparison Phase

flutter run

```### Comparison Flow- The app randomly selects a question and two items



## Building1. Add items to rank (minimum 2 required)- Swipe left to choose the left item, right to choose the right item



```bash2. Create categories and questions for structured comparisons- Or tap directly on your choice

# Windows

flutter build windows --release3. The app intelligently selects pairs using the hybrid algorithm- Ratings are automatically updated using the ELO algorithm



# Android4. Swipe or tap to choose between items

flutter build apk --release

5. Ratings update automatically using ELO calculations### 3. Results Phase

# iOS

flutter build ios --release6. View comprehensive rankings with detailed statistics- View complete rankings with:



# Web  - Current rating scores

flutter build web --release

```## Getting Started  - Number of comparisons



## Project Structure  - Tier levels (Beginner → Master)



```### Prerequisites  - Visual podium for top 3

lib/

├── main.dart- Flutter SDK 3.9.2 or higher

├── models/

│   ├── item_group.dart- Dart SDK 3.9.2 or higher## ELO Rating System

│   ├── rankable_item.dart

│   └── ranking.dart- Firebase account (for cloud features)

├── screens/

│   ├── home_screen.dartThe app uses a modified ELO rating system similar to chess:

│   ├── items_setup_screen.dart

│   ├── categories_setup_screen.dart### Installation- **Starting Rating**: 1000 points

│   ├── comparison_screen.dart

│   └── rankings_screen.dart- **K-Factor (Volatility)**:

└── services/

    └── firebase_service.dart1. Clone the repository:  - New items (< 10 comparisons): K = 32 (high volatility)

```

```bash  - Moderate items (10-30 comparisons): K = 24

## Dependencies

git clone https://github.com/yourusername/ranked.git  - Experienced items (> 30 comparisons): K = 16 (stable)

- forui: UI components

- firebase_core, cloud_firestore, firebase_auth: Cloud featurescd ranked- **Rating Tiers**:

- shared_preferences: Local storage

- fl_chart: Charts```  - Master: 2000+

- uuid: ID generation

  - Expert: 1800+

## License

2. Install dependencies:  - Advanced: 1600+

MIT License

```bash  - Intermediate: 1400+

flutter pub get  - Novice: 1200+

```  - Beginner: < 1200



3. Configure Firebase:## Getting Started

   - Add your `google-services.json` (Android) to `android/app/`

   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`### Prerequisites

   - Update Firebase configuration as needed- Flutter SDK (3.9.2 or higher)

- Dart SDK

4. Run the app:- An IDE (VS Code, Android Studio, etc.)

```bash

flutter run### Installation

```

1. Clone the repository:

## Building for Production```bash

git clone <repository-url>

### Windowscd ranked

```bash```

flutter build windows --release

```2. Install dependencies:

Distributable files will be in `build/windows/x64/runner/Release/````bash

flutter pub get

### Android```

```bash

flutter build apk --release3. Run the app:

``````bash

flutter run

### iOS```

```bash

flutter build ios --release### Building for Release

```

```bash

### Web# Android

```bashflutter build apk

flutter build web --release

```# iOS

flutter build ios

## Project Structure

# Web

```flutter build web

lib/

├── main.dart                    # Application entry point# Windows

├── models/                      # Data modelsflutter build windows

│   ├── item_group.dart         # Group definitions

│   ├── rankable_item.dart      # Item structure# macOS

│   └── ranking.dart            # Ranking modelflutter build macos

├── screens/                     # UI screens

│   ├── home_screen.dart        # Main dashboard with animated trophy# Linux

│   ├── items_setup_screen.dart # Item management with searchflutter build linux

│   ├── categories_setup_screen.dart # Category configuration```

│   ├── comparison_screen.dart  # Hybrid comparison algorithm

│   └── rankings_screen.dart    # Results display## Project Structure

└── services/                    # Business logic

    └── firebase_service.dart   # Cloud data management```

```lib/

├── models/              # Data models

## Key Dependencies│   ├── rankable_item.dart

│   ├── category.dart

- **flutter**: Framework│   ├── question.dart

- **forui** (^0.16.0): UI components│   └── comparison.dart

- **firebase_core** (^4.2.1): Firebase initialization├── services/            # Business logic

- **cloud_firestore** (^6.1.0): Cloud database│   ├── elo_service.dart

- **firebase_auth** (^6.1.2): Authentication│   └── storage_service.dart

- **shared_preferences** (^2.5.3): Local storage├── screens/             # UI screens

- **fl_chart** (^0.70.1): Data visualization│   ├── home_screen.dart

- **uuid** (^4.5.1): Unique identifiers│   ├── items_setup_screen.dart

│   ├── categories_setup_screen.dart

## Recent Improvements│   ├── comparison_screen.dart

│   └── rankings_screen.dart

- ✅ Hybrid comparison selection (median-based filtering + closest ratings)└── main.dart            # App entry point

- ✅ Search functionality for items with name and group filtering```

- ✅ Animated trophy glow on home screen

- ✅ Unified page scrolling in items management## Dependencies

- ✅ Consistent header styling across setup screens

- ✅ Fixed button sizing inconsistencies- **flutter**: SDK

- **forui** (^0.16.0): UI design system

## Development- **shared_preferences** (^2.5.3): Local data persistence

- **cupertino_icons** (^1.0.8): iOS-style icons

### Running Tests

```bash## Usage Tips

flutter test

```1. **Start Small**: Begin with 3-5 items to get a feel for the system

2. **Multiple Categories**: Create different categories for different aspects

### Code Analysis3. **Specific Questions**: More specific questions lead to better comparisons

```bash4. **Keep Comparing**: More comparisons = more accurate ratings

flutter analyze5. **Reset Anytime**: Use the reset button in the app bar to start fresh

```

## Development

### Formatting

```bash### Running Tests

dart format lib```bash

```flutter test

```

## Contributing

### Code Formatting

Contributions are welcome! Please feel free to submit a Pull Request.```bash

dart format lib test

1. Fork the repository```

2. Create your feature branch (`git checkout -b feature/AmazingFeature`)

3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)### Analysis

4. Push to the branch (`git push origin feature/AmazingFeature`)```bash

5. Open a Pull Requestflutter analyze

```

## License

## Contributing

This project is available under the MIT License.

1. Fork the repository

## Acknowledgments2. Create a feature branch

3. Commit your changes

- ELO rating system concept by Arpad Elo4. Push to the branch

- UI framework: [Forui](https://pub.dev/packages/forui)5. Create a Pull Request

- Built with [Flutter](https://flutter.dev)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- ELO rating system invented by Arpad Elo
- UI design powered by [forui](https://pub.dev/packages/forui)
- Built with Flutter
