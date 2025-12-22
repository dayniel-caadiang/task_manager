import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomeScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();
  
  late Future<List<Task>> _tasksFuture;
  String _currentFilter = 'all';
  String _viewMode = 'list';
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _tasksFuture = _loadTasks();
  }

  Future<void> _loadPreferences() async {
    final viewMode = await _cacheService.loadViewMode();
    final defaultFilter = await _cacheService.loadDefaultFilter();
    setState(() {
      _viewMode = viewMode;
      _currentFilter = defaultFilter;
    });
  }

  Future<List<Task>> _loadTasks() async {
    try {
      // Try to fetch from API first
      final tasks = await _apiService.getTasks();
      // Cache the tasks
      await _cacheService.saveTasks(tasks);
      setState(() {
        _isOffline = false;
      });
      return tasks;
    } catch (e) {
      // If API fails, try to load from cache
      final cachedTasks = await _cacheService.loadTasks();
      if (cachedTasks != null) {
        setState(() {
          _isOffline = true;
        });
        return cachedTasks;
      }
      rethrow;
    }
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _tasksFuture = _loadTasks();
    });
  }

  List<Task> _filterTasks(List<Task> tasks) {
    switch (_currentFilter) {
      case 'completed':
        return tasks.where((task) => task.completed).toList();
      case 'pending':
        return tasks.where((task) => !task.completed).toList();
      default:
        return tasks;
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      _currentFilter = filter;
    });
    _cacheService.saveDefaultFilter(filter);
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == 'list' ? 'grid' : 'list';
    });
    _cacheService.saveViewMode(_viewMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Chip(
                label: Text('Offline'),
                avatar: Icon(Icons.cloud_off, size: 16),
              ),
            ),
          IconButton(
            icon: Icon(_viewMode == 'list' ? Icons.grid_view : Icons.list),
            onPressed: _toggleViewMode,
            tooltip: 'Toggle view mode',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter tasks',
            onSelected: _changeFilter,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      color: _currentFilter == 'all' ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('All Tasks'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _currentFilter == 'completed' ? Colors.green : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Completed'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(
                      Icons.pending,
                      color: _currentFilter == 'pending' ? Colors.orange : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Pending'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tasks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshTasks,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tasks available'),
            );
          }

          final filteredTasks = _filterTasks(snapshot.data!);

          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_currentFilter == 'all' ? '' : _currentFilter} tasks',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshTasks,
            child: _viewMode == 'list'
                ? _buildListView(filteredTasks)
                : _buildGridView(filteredTasks),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskFormScreen(),
            ),
          );
          if (result == true) {
            _refreshTasks();
          }
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(List<Task> tasks) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(task: task),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        task.completed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: task.completed ? Colors.green : Colors.grey,
                      ),
                      Chip(
                        label: Text(
                          'User ${task.userId}',
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${task.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
