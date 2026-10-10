# HandCart

## Overview
HandCart is a modern retail assistant and shopping cart mobile application built with Flutter. It delivers an expressive Material 3 experience with dynamic color adaptation (Material You), responsive product catalog exploration, real-time category filtering, and reactive in-memory cart state management.

## Features
- **Material 3 Expressive Design**: Seamless Light and Dark mode theming with dynamic wallpaper color adaptation on supported Android devices.
- **Product Catalog Exploration**:
  - Real-time search query filtering across product titles and categories.
  - Horizontal category selection via choice chips (`All`, `Beverages`, `Food`, `Snacks`, `Pantry`, `Accessories`).
  - Responsive 2-column product grid with soft elevated cards, ratings, and favorite toggles.
- **Product Management**:
  - Material 3 squircle Floating Action Button for modal product creation.
  - Form validation with managed text editing controllers.
- **Reactive Shopping Cart**:
  - Live quantity adjustment directly from the product cards and cart item tiles.
  - Cart item counter badges in the top AppBar and bottom summary bar.
  - Automated calculation of subtotal, tax (11%), and final total.
  - Swipe-to-dismiss deletion for individual cart items.
  - Clear cart confirmation and checkout completion dialogs.
- **Relative Date Header**: Dynamic section header formatting for current calendar dates (`Today`, `Yesterday`, or localized date strings).

## Architecture
HandCart follows a clean, feature-first modular architecture separating concerns across domain data, business logic state management, and presentation widgets:
- **Core Layer (`lib/core/`)**: Cross-cutting constants, theme definitions, formatting utilities, and shared presentation primitives.
- **Feature Modules (`lib/features/`)**: High cohesion feature modules (`home`, `cart`) isolating presentation pages, domain models, and state controllers.
- **State Management**: Built with Flutter's native `ChangeNotifier` and `InheritedNotifier` (`CartScope`), providing reactive state propagation without external framework overhead.

## Project Structure
```text
lib/
├── app.dart                                # MaterialApp root with DynamicColorBuilder
├── main.dart                               # Application entry point & System UI styling
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Brand colors & fallback palette
│   │   ├── app_dimens.dart                 # Paddings, radii, and elevations
│   │   └── app_strings.dart                # Centralized string constants
│   ├── theme/
│   │   └── app_theme.dart                  # Material 3 light & dark ThemeData
│   ├── utils/
│   │   ├── currency_formatter.dart         # Standard currency formatting ($X.XX)
│   │   └── date_formatter.dart             # Relative calendar date formatting
│   └── widgets/
│       └── empty_state_view.dart           # Reusable empty catalog & cart view
└── features/
    ├── home/
    │   ├── data/
    │   │   ├── dummy_data.dart             # Mock product catalog & categories
    │   │   └── models/
    │   │       └── product_model.dart      # Immutable Product data model
    │   └── presentation/
    │       ├── pages/
    │       │   └── home_page.dart          # Catalog view & search/filter controller
    │       └── widgets/
    │           ├── add_product_bottom_sheet.dart # Product creation modal form
    │           ├── home_cart_bottom_bar.dart     # Floating bottom cart summary bar
    │           └── product_card.dart             # 2-column elevated product card
    └── cart/
        ├── presentation/
        │   ├── pages/
        │   │   └── cart_page.dart          # Cart items list, summary, & checkout
        │   └── widgets/
        │       └── cart_item_tile.dart     # Dismissible cart item row with stepper
        └── state/
            ├── cart_controller.dart        # Cart business logic & calculations
            └── cart_scope.dart             # InheritedNotifier state provider
```

## Requirements
- **Flutter SDK**: `>=3.10.0` (Dart SDK `>=3.0.0 <4.0.0`)
- **Android**: Android SDK Platform 34+, Android Studio or CLI platform-tools.
- **iOS**: macOS with Xcode 15+ and CocoaPods (for iOS deployment).

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
The project is pre-configured with default settings:
- Dynamic theming requires no additional setup on Android 12+ devices.
- Fallback colors are configured in [`lib/core/constants/app_colors.dart`](lib/core/constants/app_colors.dart).
- Strings and labels are maintained in [`lib/core/constants/app_strings.dart`](lib/core/constants/app_strings.dart).

## Usage
1. Launch the application on an emulator or physical device:
   ```bash
   flutter run
   ```
2. Filter products using search keywords or horizontal category chips.
3. Tap **Add** on any product card to place it into the cart.
4. Tap the floating cart pill or the AppBar cart icon to view the order breakdown and proceed to checkout.
5. Tap the squircle `+` Floating Action Button to define and add new products into the catalog.

## Development
- Use hot reload (`r`) or hot restart (`R`) in the active terminal to preview modifications.
- Keep components cohesive and avoid placing business logic or long sheets inside page widgets.

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
- **Android App Bundle (Google Play)**:
  ```bash
  flutter build appbundle
  ```
- **iOS**:
  ```bash
  flutter build ios --release
  ```

## Deployment
- Release bundles are generated in `build/app/outputs/bundle/release/app-release.aab` for Google Play Console distribution.
- Sign the APK/Bundle using a release keystore configured in `android/app/build.gradle`.

## Troubleshooting
- **Dynamic colors not changing**: Ensure device is running Android 12+ and system wallpaper theming is enabled in system settings.
- **Corrupted test or build cache**: Run `flutter clean && flutter pub get`.

## Known Limitations
- Cart items and dynamically added catalog products are currently stored in-memory and reset upon application restart.
- Payment gateway integration is mocked with a completion dialog.

## Architecture Decisions
Significant design and technical decisions are documented in the Architecture Decision Records:
- [ADR 0001: State Management Architecture with InheritedNotifier](docs/adr/0001_state_management_architecture.md)
- [ADR 0002: Material 3 Expressive Design and Dynamic Color System](docs/adr/0002_material_3_theming_and_design_system.md)
