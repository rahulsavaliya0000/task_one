import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:task_one/HomeScreen.dart';
import 'package:task_one/TodoListScreen.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

void main() {
  runApp(const TodoApp());
}
