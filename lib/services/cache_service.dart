import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class CacheService {
  static const String _tasksKey = 'cached_tasks';
  static const String _cacheTimeKey = 'cache_timestamp';
  static const String _darkModeKey = 'isDarkMode';
  static const String _viewModeKey = 'viewMode';
  static const String _defaultFilterKey = 'defaultFilter';
  
  // Cache expiration time (30 minutes)
  static const Duration cacheExpiration = Duration(minutes: 30);

  // Save tasks to cache
  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      final tasksString = json.encode(tasksJson);
      
      await prefs.setString(_tasksKey, tasksString);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw Exception('Failed to save tasks to cache: $e');
    }
  }

  // Load tasks from cache
  Future<List<Task>?> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksString = prefs.getString(_tasksKey);
      
      if (tasksString == null) {
        return null;
      }

      final List<dynamic> tasksJson = json.decode(tasksString);
      return tasksJson.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks from cache: $e');
    }
  }

  // Check if cache is expired
  Future<bool> isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getInt(_cacheTimeKey);
      
      if (cacheTime == null) {
        return true;
      }

      final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final now = DateTime.now();
      
      return now.difference(cacheDate) > cacheExpiration;
    } catch (e) {
      return true;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
      await prefs.remove(_cacheTimeKey);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  // Save dark mode preference
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }

  // Load dark mode preference
  Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // Save view mode (list or grid)
  Future<void> saveViewMode(String viewMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_viewModeKey, viewMode);
  }

  // Load view mode
  Future<String> loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_viewModeKey) ?? 'list';
  }

  // Save default filter
  Future<void> saveDefaultFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultFilterKey, filter);
  }

  // Load default filter
  Future<String> loadDefaultFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultFilterKey) ?? 'all';
  }
}
