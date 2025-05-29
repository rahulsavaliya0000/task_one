Flutter To-Do List Application

A simple To-Do List application built with Flutter. It allows users to add, view, complete, edit, and delete tasks. Tasks are persisted locally using shared_preferences.

Features

Add Tasks: Easily add new tasks to your list. View Tasks: See all your tasks in a clean, scrollable list. Mark as Completed: Check off tasks as you complete them. Edit Tasks: Modify the title of existing tasks. Delete Tasks: Remove tasks you no longer need. Persistence: Your tasks are saved locally and will be available even after closing and reopening the app. Filter Tasks: View all tasks, only active tasks, or only completed tasks. Sort Tasks: Tasks are automatically sorted with incomplete tasks appearing first, then by newest created within each status.

Prerequisites

Flutter SDK: Make sure you have Flutter installed. For installation instructions, see the Flutter official documentation. An editor like VS Code or Android Studio with the Flutter plugin. A connected device (Android/iOS) or an emulator/simulator.

How to Run the App

Ensure Dependencies: This project uses the following Flutter packages: shared_preferences: For local data persistence. uuid: For generating unique IDs for tasks. Add these to your pubspec.yaml file if they are not already present:

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.0.0  Use the latest version
  uuid: ^4.0.0  Use the latest version
Then, run flutter pub get in your project's root directory.

Save the Code: Copy the entire Dart code provided above. Save it into a file named main.dart inside the lib folder of your new Flutter project. (e.g., your_flutter_project/lib/main.dart). If you don't have a project, create one using flutter create your_todo_app_name.

Run the App: Open your terminal or command prompt. Navigate to the root directory of your Flutter project. Run the command: flutter run Select the device or emulator you want to run the app on when prompted.

Code Structure (lib/main.dart)

Task Class: A model class to define the structure of a task (id, title, completion status, creation date). It includes toJson and fromJson methods for persistence. TodoApp StatelessWidget: The root widget of the application, sets up MaterialApp. TodoListScreen StatefulWidget: The main screen of the app. Manages the list of tasks (_tasks). Handles loading tasks from and saving tasks to shared_preferences. Contains methods for adding, toggling completion, editing, and deleting tasks. Builds the UI, including the input field, add button, and the list of tasks. Includes filtering logic.

State Management

The app uses Flutter's built-in setState mechanism for managing the state of the task list and UI updates.

Persistence

Task data is persisted locally using the shared_preferences package. Tasks are stored as a JSON string.

Testing

The app should be tested on both iOS and Android physical devices and emulators/simulators. Verify that all functionalities (add, complete, edit, delete, persistence, filtering) work as expected. Check UI responsiveness on different screen sizes and orientations.

Potential Future Enhancements (Not Implemented in this version)

More sophisticated sorting options (e.g., by due date, manual reordering). Task priorities. Due dates and reminders. Cloud synchronization. Advanced UI animations and custom themes. Categorization of tasks.
