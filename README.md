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




## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- ELO rating system invented by Arpad Elo
- UI design powered by [forui](https://pub.dev/packages/forui)
- Built with Flutter
