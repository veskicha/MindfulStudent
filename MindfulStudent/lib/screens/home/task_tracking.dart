import 'package:flutter/material.dart';
import 'package:mindfulstudent/backend/tasks.dart';
import 'package:mindfulstudent/provider/task_provider.dart';
import 'package:mindfulstudent/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class TaskTrackingPage extends StatefulWidget {
  const TaskTrackingPage({Key? key}) : super(key: key);

  @override
  _TaskTrackingPageState createState() => _TaskTrackingPageState();
}

class _TaskTrackingPageState extends State<TaskTrackingPage> {
  int _selectedIndex = 0;
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
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
                padding: const EdgeInsets.only(top: 64, bottom: 32),
                child: const Text(
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
                                const Icon(Icons.add, color: Color(0xFF497077)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _taskController,
                                    decoration: const InputDecoration(
                                      hintText: 'Add a new task',
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _addTask(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<TaskProvider>(
                        builder: (context, taskProvider, _) {
                          return _buildTasksSection(
                            'Pending Tasks:',
                            taskProvider.pendingTasks,
                            false,
                            taskProvider,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Consumer<TaskProvider>(
                        builder: (context, taskProvider, _) {
                          return _buildTasksSection(
                            'Completed Tasks:',
                            taskProvider.completedTasks,
                            true,
                            taskProvider,
                          );
                        },
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
    List<Task> tasks,
    bool completed,
    TaskProvider taskProvider,
  ) {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF497077),
              ),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                    onTap: () => taskProvider.toggleTaskCompletion(task),
                    child: Icon(
                      task.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.completed
                          ? const Color(0xFF497077)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: task.completed
                                ? const Color(0xFF497077)
                                : Colors.black,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        DropdownButton<String>(
                          value: task.reminder ?? 'None',
                          onChanged: (value) {
                            taskProvider.updateTaskReminder(
                                task, value ?? 'None');
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
                                style:
                                    const TextStyle(color: Color(0xFF497077)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => taskProvider.deleteTask(task),
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

  void _addTask(BuildContext context) {
    if (_taskController.text.isNotEmpty) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.addTask(_taskController.text);
      _taskController.clear();
    }
  }
}
