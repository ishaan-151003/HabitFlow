import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../services/habit_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/habit_card.dart';
import 'habit_detail_screen.dart';

class HabitsTab extends StatefulWidget {
  const HabitsTab({Key? key}) : super(key: key);

  @override
  State<HabitsTab> createState() => _HabitsTabState();
}

class _HabitsTabState extends State<HabitsTab> {
  bool _showArchived = false;
  String _sortBy = 'name'; // 'name', 'streak', 'completion'
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Use Future.microtask to defer the loadHabits call until after the build phase
    Future.microtask(() => _loadHabits());
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }
  
  Future<void> _loadHabits() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    await habitProvider.loadHabits();
  }
  
  Future<void> _refreshHabits() async {
    await _loadHabits();
  }
  
  List<Habit> _sortHabits(List<Habit> habits) {
    switch (_sortBy) {
      case 'name':
        habits.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'streak':
        habits.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
        break;
      case 'completion':
        habits.sort((a, b) => b.completionRate.compareTo(a.completionRate));
        break;
    }
    return habits;
  }
  
  List<Habit> _filterHabits(List<Habit> habits) {
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      habits = habits.where((h) => 
        h.title.toLowerCase().contains(query) || 
        h.description.toLowerCase().contains(query)
      ).toList();
    }
    
    // Filter by archived status
    habits = habits.where((h) => h.isActive == !_showArchived).toList();
    
    return habits;
  }
  
  void _navigateToHabitDetail(Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habitId: habit.id!),
      ),
    ).then((_) => _refreshHabits());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final allHabits = habitProvider.habits;
        final filteredHabits = _filterHabits(List.from(allHabits));
        final sortedHabits = _sortHabits(filteredHabits);
        final isLoading = habitProvider.isLoading;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(_showArchived ? 'Archived Habits' : 'Active Habits'),
            actions: [
              // Sort button
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort habits',
                onPressed: () => _showSortDialog(),
              ),
              // Filter button
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Show archived habits',
                onPressed: () => setState(() {
                  _showArchived = !_showArchived;
                }),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search habits...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshHabits,
            child: sortedHabits.isEmpty && !isLoading
                ? _buildEmptyState()
                : _buildHabitList(sortedHabits, isLoading),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    final emptyStateText = _showArchived
        ? 'No archived habits yet'
        : _searchQuery.isNotEmpty
            ? 'No habits matching "${_searchQuery}"'
            : 'No habits yet. Add one to get started!';
            
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _showArchived ? Icons.archive : Icons.add_task,
                size: 72,
                color: AppTheme.primaryColorLight,
              ),
              const SizedBox(height: 16),
              Text(
                emptyStateText,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHabitList(List<Habit> habits, bool isLoading) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: habits.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == habits.length) {
          return const Padding(
            padding: EdgeInsets.all(AppTheme.defaultPadding),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        final habit = habits[index];
        return HabitCard(
          habit: habit,
          onTap: () => _navigateToHabitDetail(habit),
          onLongPress: _showArchived ? null : () => _showHabitActions(habit),
          onToggleCompletion: _showArchived ? null : (_) => _toggleHabitCompletion(habit),
        );
      },
    );
  }
  
  Future<void> _toggleHabitCompletion(Habit habit) async {
    try {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      await habitProvider.toggleHabitCompletion(habit.id!, DateTime.now());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Habits By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('name', 'Name (A-Z)'),
            _buildSortOption('streak', 'Current Streak'),
            _buildSortOption('completion', 'Completion Rate'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _sortBy,
      onChanged: (newValue) {
        Navigator.pop(context);
        setState(() {
          _sortBy = newValue!;
        });
      },
    );
  }
  
  void _showHabitActions(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Habit'),
              onTap: () {
                Navigator.pop(context);
                _navigateToHabitDetail(habit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive Habit'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                  await habitProvider.archiveHabit(habit.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Habit archived')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Habit', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(habit);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDelete(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                await habitProvider.deleteHabit(habit.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Habit deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 