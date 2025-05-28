

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_one/Model/taskmodel.dart';
import 'package:task_one/main.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Master list of all tasks
  final List<Task> _masterTasks = [];
  // Controller for the text input field
  final TextEditingController _taskController = TextEditingController();
  // Key for the AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  String _currentFilter = 'All'; // 'All', 'Active', 'Completed'

  // Derived list for display based on filter and sort
  List<Task> get _displayedTasks {
    List<Task> filtered;
    if (_currentFilter == 'Active') {
      filtered = _masterTasks.where((task) => !task.isCompleted).toList();
    } else if (_currentFilter == 'Completed') {
      filtered = _masterTasks.where((task) => task.isCompleted).toList();
    } else {
      filtered = List.from(_masterTasks); // Create a copy for sorting
    }
    // Sort: incomplete tasks first, then by newest created
    filtered.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.isCompleted ? 1 : -1;
    });
    return filtered;
  }


  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> taskJson = jsonDecode(tasksString) as List<dynamic>;
      setState(() {
        _masterTasks.clear();
        _masterTasks.addAll(taskJson.map((jsonItem) => Task.fromJson(jsonItem as Map<String, dynamic>)));
        // Initial sort happens via _displayedTasks getter
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> taskJson =
        _masterTasks.map((task) => task.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(taskJson));
  }

  void _addTask() {
    final String taskTitle = _taskController.text.trim();
    if (taskTitle.isNotEmpty) {
      final newTask = Task(id: uuid.v4(), title: taskTitle);
      
      // Determine insertion index based on current sort/filter for animation
      // This is complex if animation should respect global sort order across filters.
      // For simplicity, we add to _masterTasks and then let _displayedTasks rebuild AnimatedList.
      // The animation will appear correctly within the current filtered/sorted view.
      
      setState(() {
        _masterTasks.add(newTask);
        // The _displayedTasks getter will resort and include the new task.
        // To animate, we need the index in the *currently displayed* list.
        // If filter is 'Completed', new task won't be in displayed list, so no animation.
        // If filter is 'Active' or 'All', it will be.
        
        List<Task> currentlyDisplayed = _displayedTasks; // Get the list *before* potential re-render from this setState
        int insertionIndex = 0; // Default to top if active/all
        if (_currentFilter == 'Active' || _currentFilter == 'All') {
           // Find where it *would* be inserted in the displayed list
           // After adding to master, re-evaluate displayed list
           List<Task> newDisplayedList = _getPostActionDisplayedTasks(newTask, isAdding: true);
           insertionIndex = newDisplayedList.indexWhere((t) => t.id == newTask.id);
           if (insertionIndex != -1 && _listKey.currentState != null) {
             _listKey.currentState!.insertItem(insertionIndex, duration: const Duration(milliseconds: 400));
           }
        }
      });
      HapticFeedback.lightImpact();
      _taskController.clear();
      _saveTasks();
    }
  }
  
  // Helper to get what the displayed list would look like after an action, for animation indexing
  List<Task> _getPostActionDisplayedTasks(Task actionTask, {bool isAdding = false, bool isDeleting = false, bool isCompleting = false}) {
      List<Task> tempMasterTasks = List.from(_masterTasks);
      if (isAdding) { // This function is called *after* master list is updated for add
          // no change needed to tempMasterTasks for add as it's already added
      }
      if (isDeleting) { // Simulate deletion
          tempMasterTasks.removeWhere((t) => t.id == actionTask.id);
      }
      if (isCompleting) { // Simulate completion
          int idx = tempMasterTasks.indexWhere((t) => t.id == actionTask.id);
          if(idx != -1) tempMasterTasks[idx].isCompleted = !tempMasterTasks[idx].isCompleted;
      }

      List<Task> filtered;
      if (_currentFilter == 'Active') {
          filtered = tempMasterTasks.where((task) => !task.isCompleted).toList();
      } else if (_currentFilter == 'Completed') {
          filtered = tempMasterTasks.where((task) => task.isCompleted).toList();
      } else {
          filtered = List.from(tempMasterTasks);
      }
      filtered.sort((a, b) {
          if (a.isCompleted == b.isCompleted) {
              return b.createdAt.compareTo(a.createdAt);
          }
          return a.isCompleted ? 1 : -1;
      });
      return filtered;
  }


  void _toggleTaskCompletion(String id, int displayedIndex) {
    Task? taskToToggle;
    int masterIndex = _masterTasks.indexWhere((task) => task.id == id);
    if(masterIndex == -1) return;
    taskToToggle = _masterTasks[masterIndex];

    bool wasCompleted = taskToToggle.isCompleted;
    taskToToggle.isCompleted = !taskToToggle.isCompleted;

    HapticFeedback.lightImpact();

    // If the filter causes the item to disappear/appear, animate removal/insertion
    bool willDisappear = (_currentFilter == 'Active' && taskToToggle.isCompleted) ||
                         (_currentFilter == 'Completed' && !taskToToggle.isCompleted);
    
    setState(() {
      // Master list is already updated
      if (willDisappear && _listKey.currentState != null) {
        _listKey.currentState!.removeItem(
          displayedIndex,
          (context, animation) => _buildAnimatedTaskItem(taskToToggle!, animation, displayedIndex), // Pass a copy
          duration: const Duration(milliseconds: 300)
        );
      } else {
        // Item might re-sort, or if filter is 'All', it just updates.
        // A full setState will refresh the list and its order.
        // For smoother re-sorting animation, a more complex setup is needed.
      }
    });
    _saveTasks();
  }


  void _deleteTask(String id, int displayedIndex, {bool viaDismiss = false}) {
    Task? taskToDelete;
    int masterIndex = _masterTasks.indexWhere((task) => task.id == id);
    if (masterIndex == -1) return;

    taskToDelete = _masterTasks.removeAt(masterIndex); // Remove from master list first

    if (taskToDelete != null && _listKey.currentState != null) {
      _listKey.currentState!.removeItem(
        displayedIndex,
        (context, animation) => _buildAnimatedTaskItem(taskToDelete!, animation, displayedIndex),
        duration: const Duration(milliseconds: 300),
      );
    }
    
    HapticFeedback.mediumImpact();
    _saveTasks();

    if (mounted && !viaDismiss) { // Show snackbar only if not dismissed (dismissible has its own feedback)
      ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove any existing snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              _undoDelete(taskToDelete!, masterIndex, displayedIndex);
            },
          ),
        ),
      );
    }
  }

  void _undoDelete(Task deletedTask, int originalMasterIndex, int originalDisplayedIndex) {
    setState(() {
      // Re-insert into master list at original position if possible, otherwise add
      if (originalMasterIndex < _masterTasks.length) {
         _masterTasks.insert(originalMasterIndex, deletedTask);
      } else {
         _masterTasks.add(deletedTask);
      }

      // Check if item should be re-inserted into AnimatedList based on current filter
      List<Task> newDisplayedList = _displayedTasks;
      int insertionIndex = newDisplayedList.indexWhere((t) => t.id == deletedTask.id);

      if (insertionIndex != -1 && _listKey.currentState != null) {
        _listKey.currentState!.insertItem(insertionIndex, duration: const Duration(milliseconds: 300));
      }
    });
    _saveTasks();
  }

  void _showEditTaskDialog(Task task) {
    final TextEditingController editController =
        TextEditingController(text: task.title);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter new task title'),
            onSubmitted: (_) { // Allow submitting with keyboard action
                 final String newTitle = editController.text.trim();
                if (newTitle.isNotEmpty) {
                  _editTask(task.id, newTitle);
                }
                Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final String newTitle = editController.text.trim();
                if (newTitle.isNotEmpty) {
                  _editTask(task.id, newTitle);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTask(String id, String newTitle) {
    setState(() {
      final taskIndex = _masterTasks.indexWhere((task) => task.id == id);
      if (taskIndex != -1) {
        _masterTasks[taskIndex].title = newTitle;
      }
    });
    _saveTasks();
  }

  // Build a single task item widget for AnimatedList (includes animation)
  Widget _buildAnimatedTaskItem(Task task, Animation<double> animation, int index) {
    // You can use various animations like SizeTransition, FadeTransition, SlideTransition
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: SizeTransition(
        sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: _buildTaskListItem(task, index), // Use the common list item builder
      ),
    );
  }

  // Common list item builder (used by AnimatedList and Dismissible)
  Widget _buildTaskListItem(Task task, int displayedIndex) {
    return Card(
      key: ValueKey(task.id), // Important for list updates
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0), // Adjusted padding
        leading: InkWell( // Larger tap area for checkbox
          onTap: () => _toggleTaskCompletion(task.id, displayedIndex),
          customBorder: const CircleBorder(), // Make ripple circular
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Padding around checkbox
            child: Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                _toggleTaskCompletion(task.id, displayedIndex);
              },
              visualDensity: VisualDensity.compact, // Make checkbox slightly smaller
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted ? Colors.grey[500] : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16.5, // Slightly adjusted font size
            fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit_note_outlined, color: Colors.blueGrey[700], size: 24),
              onPressed: () {
                _showEditTaskDialog(task);
              },
              tooltip: 'Edit Task',
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: Colors.red[600], size: 24),
              onPressed: () {
                _deleteTask(task.id, displayedIndex);
              },
              tooltip: 'Delete Task',
            ),
          ],
        ),
        onTap: () { // Allow editing by tapping the main body of the task
          _showEditTaskDialog(task);
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // This list is now derived, filtered, and sorted.
    // It's the source of truth for what AnimatedList should display.
    final List<Task> currentDisplayedTasks = _displayedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List 📝'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: "Filter tasks",
            onSelected: (String value) {
              setState(() {
                _currentFilter = value;
                // When filter changes, AnimatedList needs to reflect the new list.
                // A common way is to rebuild it. For item-specific animations on filter change,
                // a more complex state management and list diffing is needed.
                // Here, changing filter will cause a non-animated rebuild of the list items.
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'All',
                child: Text('All', style: TextStyle(fontWeight: _currentFilter == 'All' ? FontWeight.bold : FontWeight.normal)),
              ),
              PopupMenuItem<String>(
                value: 'Active',
                child: Text('Active', style: TextStyle(fontWeight: _currentFilter == 'Active' ? FontWeight.bold : FontWeight.normal)),
              ),
              PopupMenuItem<String>(
                value: 'Completed',
                child: Text('Completed', style: TextStyle(fontWeight: _currentFilter == 'Completed' ? FontWeight.bold : FontWeight.normal)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      // prefixIcon: const Icon(Icons.post_add_outlined, color: Colors.teal),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      suffixIcon: _taskController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _taskController.clear();
                                setState(() {}); 
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _addTask(),
                    onChanged: (text) {
                       setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add'),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Filter: $_currentFilter Tasks", style: TextStyle(color: Colors.grey[700], fontSize: 13, fontStyle: FontStyle.italic)),
            ),
          ),
          Expanded(
            child: currentDisplayedTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist_rtl_outlined, size: 90, color: Colors.teal.withOpacity(0.6)),
                          const SizedBox(height: 20),
                          Text(
                            _currentFilter == 'All'
                                ? 'No tasks yet. Add something productive!'
                                : _currentFilter == 'Active'
                                  ? 'All tasks completed. Great job!'
                                  : 'No tasks marked as completed yet.',
                            style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          if (_currentFilter != 'All' && _masterTasks.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.list_alt),
                                label: const Text('Show All Tasks'),
                                onPressed: () {
                                  setState(() {
                                    _currentFilter = 'All';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.teal,
                                  side: const BorderSide(color: Colors.teal),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  )
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: currentDisplayedTasks.length,
                    padding: const EdgeInsets.only(top: 8.0, bottom: 80.0), // Padding for FAB if used, or general bottom space
                    itemBuilder: (context, index, animation) {
                      // Important: Ensure index is valid for currentDisplayedTasks
                      if (index >= currentDisplayedTasks.length) {
                          return const SizedBox.shrink(); // Should not happen if itemCount is correct
                      }
                      final task = currentDisplayedTasks[index];
                      return Dismissible(
                        key: ValueKey(task.id), // Unique key for Dismissible
                        background: Container(
                          color: Colors.green[400],
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerLeft,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Complete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red[400],
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.delete_sweep_outlined, color: Colors.white),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          // Store current displayed index before master list modification
                          int displayedIndexForDismiss = currentDisplayedTasks.indexWhere((t) => t.id == task.id);

                          if (direction == DismissDirection.endToStart) { // Swiped Left (Delete)
                            _deleteTask(task.id, displayedIndexForDismiss, viaDismiss: true);
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Task deleted'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(10),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () {
                                     int masterIdx = _masterTasks.indexWhere((t) => t.id == task.id); // May have changed or -1
                                    _undoDelete(task, masterIdx == -1 ? _masterTasks.length : masterIdx, displayedIndexForDismiss); // Pass original task
                                  },
                                ),
                              ),
                            );
                          } else { // Swiped Right (Complete/Uncomplete)
                             // We need the original task object to toggle, not a copy.
                             Task originalTask = _masterTasks.firstWhere((t) => t.id == task.id);
                             _toggleTaskCompletion(originalTask.id, displayedIndexForDismiss);
                             // Important: Dismissible removes the item visually.
                             // If toggling completion changes its filter status, the item might
                             // disappear/reappear. We need to ensure the list visually remains consistent.
                             // Rebuilding the state after toggle handles this for now.
                             setState(() {});
                          }
                        },
                        child: _buildAnimatedTaskItem(task, animation, index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}