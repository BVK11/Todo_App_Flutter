import 'package:flutter/material.dart';
import 'models/task.dart';
import 'services/api_service.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const TodoHome(),
    );
  }
}

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  late Future<List<Task>> futureTasks;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshTasks();
  }

  void refreshTasks() {
    setState(() {
      futureTasks = ApiService.fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart To-Do Manager'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => refreshTasks(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInputCard(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<List<Task>>(
                      future: futureTasks,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        else if (snapshot.hasError) {
  return Center(
    child: Text(snapshot.error.toString()),
  );
}


                        final tasks = snapshot.data ?? [];

                        if (tasks.isEmpty) {
                          return const Center(
                            child: Text(
                              '🎉 No tasks yet!\nAdd one to get started.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        final completed =
                            tasks.where((t) => t.completed).length;

                        return Column(
                          children: [
                            _buildStats(tasks.length, completed),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  return _buildTaskCard(tasks[index]);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: 'Enter new task'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                if (controller.text.isEmpty) return;
                await ApiService.addTask(controller.text);
                controller.clear();
                refreshTasks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task added')),
                );
              },
              child: const Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStats(int total, int completed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Chip(label: Text('Total: $total')),
        Chip(label: Text('Completed: $completed')),
        Chip(label: Text('Pending: ${total - completed}')),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: task.completed,
          onChanged: (val) async {
            await ApiService.toggleTask(task.id, val!);
            refreshTasks();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete Task?'),
                content: const Text('This action cannot be undone'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete')),
                ],
              ),
            );

            if (confirm == true) {
              await ApiService.deleteTask(task.id);
              refreshTasks();
            }
          },
        ),
      ),
    );
  }
}
