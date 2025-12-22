import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Get all tasks
  Future<List<Task>> getTasks() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/todos'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  // Get single task by ID
  Future<Task> getTask(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/todos/$id'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load task. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to load task: $e');
    }
  }

  // Create a new task
  Future<Task> createTask(Task task) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/todos'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(task.toJson()),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create task. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  // Update a task (PUT)
  Future<Task> updateTask(Task task) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/todos/${task.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(task.toJson()),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return Task.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update task. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/todos/$id'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your internet connection.');
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
