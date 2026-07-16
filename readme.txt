=====================================================================
 ModfFirstPos - Flutter Point of Sale (POS) Application
=====================================================================

OVERVIEW
--------
ModfFirstPos is a multi-app Flutter Point of Sale system consisting of
two applications built from a single codebase:

  1. Cashier App          (lib/main_cashier.dart -> lib/apps/cashier_app.dart)
  2. Customer Display App (lib/main_customer.dart -> lib/apps/customer_app.dart)

The project uses GetX for state management, routing, and dependency
injection, following a modular architecture (binding / controller /
model / service / view per feature).

TECH STACK
----------
- Flutter (Dart SDK ^3.9.0)
- GetX (get)                  - state management, routing, DI
- Dio                         - HTTP networking
- web_socket_channel          - real-time communication (cashier <-> customer display)
- Firebase                    - Core, Crashlytics, Analytics, Messaging
- flutter_local_notifications - local notifications
- flutter_secure_storage      - secure token/credential storage
- flutter_dotenv              - environment configuration
- connectivity_plus / network_info_plus - network status & diagnostics
- google_fonts, iconsax, flutter_svg, flutter_animate, cached_network_image,
  loading_animation_widget    - UI/UX
- video_player, image_picker, url_launcher, intl, package_info_plus,
  persistent_device_id

PROJECT STRUCTURE
-----------------
lib/
  main.dart              - default entry point
  main_cashier.dart      - entry point for the Cashier app
  main_customer.dart     - entry point for the Customer Display app
  myApp.dart             - root app widget
  apps/                  - cashier_app.dart, customer_app.dart
  core/                  - shared infrastructure
    binding/             - initial/global bindings
    connectivity/        - network connectivity handling
    contants/            - app constants
    exceptions/          - custom exceptions
    lock/                - app lock logic
    models/              - core data models
    network/             - API client / networking layer (Dio)
    services/            - shared services
    storage/             - local & secure storage
    theme/               - app theming
    utils/               - helper utilities
  modules/               - feature modules (each with binding/controller/
                           model/service/view as applicable)
    auth/                - login & authentication
    forgotPassword/      - password recovery
    verifyOtp/           - OTP verification
    changePassword/      - change password
    pin/                 - PIN entry / verification
    storeSelection/      - store selection
    splash/              - splash screen
    home/                - home / dashboard
    catalogue/           - product catalogue
    category/            - categories (data layer)
    categoryProducts/    - products by category
    product/             - products (data layer)
    productVariant/      - product variants
    customer/            - customer management
    customerDisplay/     - customer-facing display screen
    order/               - order list, details, pagination & filtering
    notification/        - notifications
    profile/             - user profile
    setting/             - settings & connection diagnostics
                           (printer, cashier)
    about/               - about screen
    menu/                - menu views
    errorScreen/         - error screens
  routes/                - app_routes.dart, app_pages.dart (GetX routing)
  shared/widgets/        - reusable widgets (app bar, buttons, dialogs,
                           snackbars, text fields, numpad, side nav,
                           video background, etc.)

assets/
  images/                - image assets
  svgs/                  - SVG assets (menu, dialogs, update module)

Platform folders: android/, ios/, web/, windows/, macos/, linux/
test/                    - widget/unit tests

GETTING STARTED
---------------
1. Install Flutter (with Dart SDK 3.9 or newer).
2. Fetch dependencies:
     flutter pub get
3. Create/verify the .env file used by flutter_dotenv (API base URLs etc.).
4. Ensure Firebase is configured for your platforms
   (google-services.json / GoogleService-Info.plist).
5. Run the desired app:
     Cashier app:
       flutter run -t lib/main_cashier.dart
     Customer display app:
       flutter run -t lib/main_customer.dart
     Default:
       flutter run

BUILDING
--------
  flutter build apk -t lib/main_cashier.dart
  flutter build apk -t lib/main_customer.dart
(Adjust target/platform as needed: appbundle, windows, web, etc.)

OFFLINE-FIRST ARCHITECTURE
--------------------------
- SQLite (sqflite) is the primary local database (core/database/):
  cached API responses, customers, suspended orders, pending sales,
  invoice counters and website-settings cache.
- Flutter Secure Storage holds secrets only (tokens, credentials, PIN).
- SyncService (core/services/sync_service.dart) automatically pushes
  locally created customers and sales when connectivity returns, with
  periodic retry.
- All API models parse defensively via core/utils/json_utils.dart, so
  backend type drift ("1" vs 1 vs 1.0 vs null) never crashes the app.

POS FEATURES
------------
- Customer management on the home screen: search, select, add-customer
  dialog (offline-first, auto-selected after save).
- Suspend / Resume / Void order flows via the Options button.
- Payment button: Cash (custom POS keypad with quick amounts, exact
  cash and change calculation), Stripe/PayPal placeholders.
- Menu > Operations > Refresh Website Settings re-fetches branding and
  applies the theme immediately.

NOTES
-----
- The cashier and customer display apps communicate in real time
  (WebSocket based) for order/display synchronization.
- Crash reporting and analytics are handled via Firebase Crashlytics
  and Analytics.
- Linting rules come from flutter_lints via analysis_options.yaml.

VERSION
-------
1.0.0+1
=====================================================================
