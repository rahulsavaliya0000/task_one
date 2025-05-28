import 'package:flutter/material.dart';
import 'package:task_one/TodoListScreen.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter To-Do List',
      theme: ThemeData(
        // Use our custom hex colors below:
        primaryColor: const Color(0xFF512DA8), // Deep Purple
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF512DA8), // Primary seed color
          brightness: Brightness.light,
          primary: const Color(0xFF512DA8), // Deep Purple
          secondary: const Color(0xFFFFC107), // Amber
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF512DA8), // Deep Purple
          foregroundColor: Colors.white,
          elevation: 4.0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFC107), // Amber
          foregroundColor: Color(0xFF212121), // Dark Grey for contrast
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Color(0xFFBDBDBD)), // Light Grey
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            borderSide: BorderSide(color: Color(0xFF512DA8), width: 2.0),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFAFA), // Almost-white background
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF512DA8); // Deep Purple when selected
            }
            return const Color(0xFF757575); // Medium Grey when unchecked
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(color: const Color(0xFF616161), width: 1.5),
        ),
        cardTheme: CardTheme(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: const Color(0xFFE0E0E0), width: 0.5),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF512DA8), // Deep Purple
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF512DA8), // Deep Purple
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF424242), // Dark Grey
          ),
        ),
      ),
      home: const TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
