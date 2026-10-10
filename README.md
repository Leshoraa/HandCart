# HandCart

## Overview
HandCart is an expressive Material 3 shopping planner and expense tracker mobile application built with Flutter. It allows users to organize shopping lists across multiple stores and markets, track items in a vertical single-column layout with live quantity steppers, write shopping notes and memos per store, and calculate total estimated expenses in real-time.

## Features
- **Store / Shopping Places Selection**:
  - Initial screen displaying store cards (Supermarkets, Bakeries, Organic Marts, Convenience Stores).
  - Search and filter stores by category chips.
  - Live budget badge displaying the total planned shopping expense across all stores.
  - Modal sheet to define and add new shopping places.
- **Vertical Single-Column Product List**:
  - Dedicated product list per store in a vertical 1-column layout for high density and rapid browsing.
  - Realistic product imagery with organic squircle framing and fallback icons.
  - Item name, short description, and unit price.
  - Interactive stepper `[- 1 +]` to adjust planned quantities.
  - Add custom items directly into the store list.
- **Shopping Notes & Memos**:
  - Note menu button in the top right of the store product page.
  - Dedicated layout for writing store memos, checklists, coupons, and reminders.
  - Displays total items planned and total expense for the store.
- **Real-Time Total Expense Tracker**:
  - Live calculation of total items and total expense for each store.
  - Sticky bottom summary bar displaying real-time costs as quantities are adjusted.
- **Material 3 Expressive Design**:
  - Dynamic color adaptation (Material You) on supported Android devices.
  - Eye-comfort neutral surfaces with deep emerald forest accents.
  - Soft ambient drop shadows and responsive squircle geometry.

## Architecture
HandCart follows a clean, feature-first modular architecture separating concerns across domain data, business logic state management, and presentation widgets:
- **Core Layer (`lib/core/`)**: Cross-cutting constants, theme definitions, formatting utilities, and shared widgets.
- **Feature Modules (`lib/features/`)**:
  - `stores`: Store models, dummy data, store card widgets, and store selection pages.
  - `shopping_list`: Product models, shopping planner controller, 1-column product tiles, note sheets, and expense bars.
- **State Management**: Built with Flutter's native `ChangeNotifier` (`ShoppingPlannerController`) and `InheritedNotifier` (`ShoppingPlannerScope`), providing reactive state propagation without external framework overhead.

## Project Structure
```text
lib/
├── app.dart                                # MaterialApp root with DynamicColorBuilder
├── main.dart                               # Application entry point & System UI styling
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Brand colors & fallback palette
│   │   ├── app_dimens.dart                 # Spacing, padding, and radii
│   │   └── app_strings.dart                # Centralized string constants
│   ├── theme/
│   │   └── app_theme.dart                  # Material 3 light & dark ThemeData
│   ├── utils/
│   │   ├── currency_formatter.dart         # Standard currency formatting ($X.XX)
│   │   └── date_formatter.dart             # Relative calendar date formatting
│   └── widgets/
│       └── empty_state_view.dart           # Reusable empty state placeholder
└── features/
    ├── stores/
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── store_model.dart        # Store data model
    │   │   └── store_dummy_data.dart       # Curated stores and initial catalogs
    │   └── presentation/
    │       ├── pages/
    │       │   └── store_list_page.dart    # Store selection & search screen
    │       └── widgets/
    │           ├── add_store_bottom_sheet.dart # Custom store creator sheet
    │           └── store_card.dart         # Elevated store card with budget badge
    └── shopping_list/
        ├── data/
        │   └── models/
        │       └── product_model.dart      # Product data model
        ├── state/
        │   ├── shopping_planner_controller.dart # State logic & expense computations
        │   └── shopping_planner_scope.dart # InheritedNotifier state provider
        └── presentation/
            ├── pages/
            │   └── store_product_list_page.dart # 1-column product list page
            └── widgets/
                ├── shopping_note_sheet.dart     # Shopping memo & checklist sheet
                ├── shopping_product_tile.dart   # 1-column product row with stepper
                └── store_expense_bottom_bar.dart# Live total expense bottom bar
```

## Requirements
- **Flutter SDK**: `>=3.10.0` (Dart SDK `>=3.0.0 <4.0.0`)
- **Android**: Android SDK Platform 34+, Android Studio or CLI platform-tools.
- **iOS**: macOS with Xcode 15+ and CocoaPods.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Leshoraa/HandCart.git
   cd HandCart
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

## Configuration
- Dynamic theming automatically adapts to user device wallpapers on Android 12+.
- Theme constants and brand colors are configured in [`lib/core/constants/app_colors.dart`](lib/core/constants/app_colors.dart).
- Strings and labels are maintained in [`lib/core/constants/app_strings.dart`](lib/core/constants/app_strings.dart).

## Usage
1. Launch the application:
   ```bash
   flutter run
   ```
2. On the initial screen, select a store card to open that store's shopping list.
3. In the store product list, use `[- 1 +]` steppers to add or adjust quantities. The total shopping expense updates in real-time in the bottom bar.
4. Tap the **Note** icon in the top right of the AppBar to write reminders, checklist items, or coupon codes for that store.
5. Tap **Add Store** on the main screen to create custom shopping destinations.

## Development
- Use hot reload (`r`) or hot restart (`R`) in the active terminal to preview changes.
- Ensure all business logic remains inside `ShoppingPlannerController` rather than page widgets.

## Testing
Run static analysis and the automated test suite:
```bash
# Run static analyzer
flutter analyze

# Run unit and widget tests
flutter test
```

## Build
Compile release artifacts for target mobile platforms:
- **Android APK**:
  ```bash
  flutter build apk --release
  ```
- **Android App Bundle**:
  ```bash
  flutter build appbundle
  ```
- **iOS**:
  ```bash
  flutter build ios --release
  ```

## Deployment
- Release bundles are generated in `build/app/outputs/bundle/release/app-release.aab` for Google Play distribution.

## Troubleshooting
- **Dynamic colors not changing**: Ensure device is running Android 12+ and system wallpaper theming is enabled in system settings.
- **Cache issues**: Run `flutter clean && flutter pub get`.

## Known Limitations
- Data is currently stored in-memory and re-initializes on complete application restart. Persistent database integration (e.g. SQLite / Hive) can be added as a next step.

## Architecture Decisions
- [ADR 0001: Shopping Planner State Management with InheritedNotifier](docs/adr/0001_state_management_architecture.md)
- [ADR 0002: Material 3 Expressive Design and Dynamic Color System](docs/adr/0002_material_3_theming_and_design_system.md)
