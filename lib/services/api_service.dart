import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  // Use ngrok for both web and mobile (works through firewall)
  static const String baseUrl =
      'https://irresolute-paginal-suzy.ngrok-free.dev';

  // ---------------- FETCH TASKS ----------------
  static Future<List<Task>> fetchTasks() async {
    try {
      print('🔍 Fetching tasks from: $baseUrl/tasks');
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {'ngrok-skip-browser-warning': '69420'},
      ).timeout(const Duration(seconds: 10));

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => Task.fromJson(e)).toList();
      } else {
        throw Exception(
            'Failed to load tasks (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // ---------------- ADD TASK ----------------
  static Future<void> addTask(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': '69420'
      },
      body: json.encode({'title': title}),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception('Failed to add task');
    }
  }

  // ---------------- DELETE TASK ----------------
  static Future<void> deleteTask(int id) async {
    final response =
        await http.delete(
          Uri.parse('$baseUrl/tasks/$id'),
          headers: {'ngrok-skip-browser-warning': '69420'},
        );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }

  // ---------------- TOGGLE COMPLETED ----------------
// ---------------- TOGGLE COMPLETED ----------------
static Future<void> toggleTask(int id, bool completed) async {
  final response = await http.put(
    Uri.parse('$baseUrl/tasks/$id'),
    headers: {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': '69420'
    },
    body: json.encode({'completed': completed}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update task');
  }
}


  // ---------------- EDIT TASK (OPTIONAL) ----------------
  static Future<void> updateTaskTitle(int id, String title) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': '69420'
      },
      body: json.encode({'title': title}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }
}
