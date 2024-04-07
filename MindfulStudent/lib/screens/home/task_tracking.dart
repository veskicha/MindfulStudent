import 'package:flutter/material.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';

class TaskTrackingPage extends StatefulWidget {
  const TaskTrackingPage({Key? key}) : super(key: key);

  @override
  _TaskTrackingPageState createState() => _TaskTrackingPageState();
}

class _TaskTrackingPageState extends State<TaskTrackingPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _pendingTasks = [];
  List<Map<String, dynamic>> _completedTasks = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFC8D4D6),
                  Color(0xFFF6F6F6),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(top: 64, bottom: 32),
                child: Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF497077),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.add, color: Color(0xFF497077)),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _taskController,
                                    decoration: InputDecoration(
                                      hintText: 'Add a new task',
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _addTask(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (_pendingTasks.isNotEmpty)
                        _buildTasksSection(
                          'Pending Tasks:',
                          _pendingTasks,
                          false,
                        ),
                      SizedBox(height: 16),
                      if (_completedTasks.isNotEmpty)
                        _buildTasksSection(
                          'Completed Tasks:',
                          _completedTasks,
                          true,
                        ),
                    ],
                  ),
                ),
              ),
              BottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(
    String title,
    List<Map<String, dynamic>> tasks,
    bool completed,
  ) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF497077),
              ),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _toggleTaskCompletion(index, task['completed']),
                    child: Icon(
                      task['completed']
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          task['completed'] ? Color(0xFF497077) : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'],
                          style: TextStyle(
                            fontSize: 16,
                            color: task['completed']
                                ? Color(0xFF497077)
                                : Colors.black,
                            decoration: task['completed']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        DropdownButton<String>(
                          value: task['reminder'] ?? 'None',
                          onChanged: (value) {
                            setState(() {
                              task['reminder'] = value;
                            });
                          },
                          items: <String>[
                            'None',
                            'Daily',
                            'Weekly',
                            'Monthly',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Color(0xFF497077)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteTask(index, task['completed']),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _pendingTasks.add({
          'title': _taskController.text,
          'completed': false,
        });
        _taskController.clear();
      });
    }
  }

  void _toggleTaskCompletion(int index, bool completed) {
    setState(() {
      final task = completed ? _completedTasks[index] : _pendingTasks[index];
      task['completed'] = !completed;
      if (completed) {
        _completedTasks.removeAt(index);
        _pendingTasks.add(task);
      } else {
        _pendingTasks.removeAt(index);
        _completedTasks.add(task);
      }
    });
  }

  void _deleteTask(int index, bool completed) {
    setState(() {
      if (completed) {
        _completedTasks.removeAt(index);
      } else {
        _pendingTasks.removeAt(index);
      }
    });
  }
}
