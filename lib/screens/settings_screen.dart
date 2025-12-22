import 'package:flutter/material.dart';
import '../services/cache_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const SettingsScreen({Key? key, required this.onThemeChanged})
      : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CacheService _cacheService = CacheService();
  
  bool _isDarkMode = false;
  String _viewMode = 'list';
  String _defaultFilter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final darkMode = await _cacheService.loadDarkMode();
    final viewMode = await _cacheService.loadViewMode();
    final defaultFilter = await _cacheService.loadDefaultFilter();

    setState(() {
      _isDarkMode = darkMode;
      _viewMode = viewMode;
      _defaultFilter = defaultFilter;
      _isLoading = false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    await _cacheService.saveDarkMode(value);
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value);
  }

  Future<void> _changeViewMode(String? value) async {
    if (value != null) {
      await _cacheService.saveViewMode(value);
      setState(() {
        _viewMode = value;
      });
    }
  }

  Future<void> _changeDefaultFilter(String? value) async {
    if (value != null) {
      await _cacheService.saveDefaultFilter(value);
      setState(() {
        _defaultFilter = value;
      });
    }
  }

  Future<void> _clearCache() async {
    try {
      await _cacheService.clearCache();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              secondary: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          const SizedBox(height: 16),

          // Display Options Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Display Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.view_module),
                  title: const Text('View Mode'),
                  subtitle: Text('Current: ${_viewMode == 'list' ? 'List' : 'Grid'}'),
                ),
                RadioListTile<String>(
                  title: const Text('List View'),
                  value: 'list',
                  groupValue: _viewMode,
                  onChanged: _changeViewMode,
                ),
                RadioListTile<String>(
                  title: const Text('Grid View'),
                  value: 'grid',
                  groupValue: _viewMode,
                  onChanged: _changeViewMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter Options Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.filter_list),
                  title: const Text('Default Filter'),
                  subtitle: Text('Current: ${_getFilterLabel(_defaultFilter)}'),
                ),
                RadioListTile<String>(
                  title: const Text('All Tasks'),
                  value: 'all',
                  groupValue: _defaultFilter,
                  onChanged: _changeDefaultFilter,
                ),
                RadioListTile<String>(
                  title: const Text('Completed Only'),
                  value: 'completed',
                  groupValue: _defaultFilter,
                  onChanged: _changeDefaultFilter,
                ),
                RadioListTile<String>(
                  title: const Text('Pending Only'),
                  value: 'pending',
                  groupValue: _defaultFilter,
                  onChanged: _changeDefaultFilter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cache Management Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Cache Management',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear Cache'),
              subtitle: const Text('Remove all cached tasks'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cache'),
                    content: const Text(
                      'Are you sure you want to clear all cached data? This will remove offline access to tasks.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearCache();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // About Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Task Manager'),
                  subtitle: Text('Version 1.0.0'),
                ),
                ListTile(
                  leading: Icon(Icons.api),
                  title: Text('API Source'),
                  subtitle: Text('JSONPlaceholder'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      default:
        return 'All Tasks';
    }
  }
}
