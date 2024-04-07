import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks = taskStrings.map((taskString) {
        final split = taskString.split('|');
        return Task(title: split[0], completed: split[1] == 'true');
      }).toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> taskStrings = _tasks.map((task) {
      return '${task.title}|${task.completed}';
    }).toList();
    prefs.setStringList('tasks', taskStrings);
  }

  void _addTask(String title) {
    setState(() {
      _tasks.add(Task(title: title));
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index] = Task(
        title: _tasks[index].title,
        completed: !_tasks[index].completed,
      );
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text('Task Tracker'),
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.title),
            leading: Checkbox(
              value: task.completed,
              onChanged: (_) => _toggleTaskCompletion(index),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTask(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () async {
          final newTask = await showDialog<String>(
            context: context,
            builder: (context) => _buildAddTaskDialog(context),
          );
          if (newTask != null && newTask.isNotEmpty) {
            _addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddTaskDialog(BuildContext context) {
    String newTask = '';
    return AlertDialog(
      title: const Text('Add Task',style: TextStyle(color: Colors.black87),),
      content: TextField(
        onChanged: (value) => newTask = value,
        decoration: const InputDecoration(hintText: 'Task title'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(

          onPressed: () {
            Navigator.of(context).pop(newTask);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
