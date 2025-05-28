Flutter E-Commerce Application README

Overview
This simple e-commerce app is built with Flutter and uses the Fake Store API to fetch dynamic data. It includes a splash screen, login screen, category dashboard, product details screen, and cart screen.

Features

• Splash screen with logo animation and timed navigation
• Login screen with email/password form validation
• Dashboard displaying product categories fetched from the API
• Product listing within each category
• Product details view with image, title, description, price, and Add to Cart button
• Cart screen to view, edit quantities, remove items, and see total price
• Named-route navigation
• Basic error handling for API failures
• Responsive UI for different screen sizes

Prerequisites

• Flutter SDK installed (see flutter.dev for instructions)
• Dart SDK (bundled with Flutter)
• An IDE such as Android Studio, VS Code, or IntelliJ IDEA with Flutter plugin
• A connected device or emulator

Setup and Installation

1. Create a new Flutter project:
   flutter create ecommerce\_app
2. Navigate into the project folder:
   cd ecommerce\_app
3. Add dependencies in pubspec.yaml:
   dependencies:
   flutter:
   sdk: flutter
   http: latest
   flutter\_spinkit: latest
   shared\_preferences: latest

   # Any other UI libraries as needed
4. Run flutter pub get to install packages.

Project Structure (lib folder)

• main.dart

  • Entry point
  • Defines named routes
• screens/

  • splash\_screen.dart
  • login\_screen.dart
  • dashboard\_screen.dart
  • category\_products\_screen.dart
  • product\_details\_screen.dart
  • cart\_screen.dart
• models/

  • product.dart
  • category.dart
• services/

  • api\_service.dart  (handles HTTP requests to Fake Store API)
• widgets/

  • category\_card.dart
  • product\_card.dart
  • cart\_item\_tile.dart
• utils/

  • validators.dart  (email and password validation)
  • constants.dart   (API base URL, route names, etc.)

Screen Details
Splash Screen

• Displays app logo and name
• Fade-in animation on logo
• Timer of 3 seconds before navigating to login screen

Login Screen

• Text fields for email and password
• Validation:

  • Email must not be empty and must match email pattern
  • Password must not be empty and meet minimum length
• Login button:

  • Validates form inputs
  • On success, navigates to dashboard

Dashboard Screen

• Fetches category list from Fake Store API ([https://fakestoreapi.com/products/categories](https://fakestoreapi.com/products/categories))
• Displays categories in a grid of cards
• Tap on a category to navigate to category\_products\_screen

Category Products Screen

• Fetches products for selected category from API ([https://fakestoreapi.com/products/category/{category}](https://fakestoreapi.com/products/category/{category}))
• Displays products in a grid
• Each product card shows image, title, price
• Tap on a product to navigate to product\_details\_screen

Product Details Screen

• Fetches detailed product data by ID ([https://fakestoreapi.com/products/{id}](https://fakestoreapi.com/products/{id}))
• Shows:

  • Large product image
  • Title
  • Description
  • Price
  • “Add to Cart” button adds item to local cart

Cart Screen

• Displays list of added cart items
• Each item shows image, title, price, quantity controls ( + / – )
• Remove icon to delete item
• Calculates and displays total cart value
• “Checkout” button (placeholder)

API Service

• Uses http package for GET requests
• Methods:

  • fetchCategories()
  • fetchProductsByCategory(String category)
  • fetchProductById(int id)
• Error handling:

  • On failure, show a Snackbar with error message

Navigation

• Use named routes defined in constants.dart:

  • '/'
  • '/login'
  • '/dashboard'
  • '/category-products'
  • '/product-details'
  • '/cart'

Running the App

1. Connect a device or start an emulator
2. Run:
   flutter run

Testing

• Verify navigation between screens
• Test form validation on login screen
• Confirm categories and products load correctly
• Test adding/removing items in the cart
• Check total price calculation
• Simulate API failure (e.g. disable network) and verify error handling

Future Enhancements

• User registration and real authentication
• Persistent user sessions
• Checkout flow integration
• Order history screen
• Product search feature
• Reviews and ratings
• Improved animations and custom themes

