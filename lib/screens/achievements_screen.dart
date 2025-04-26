import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../utils/app_theme.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }
  
  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });
    
    await _achievementService.initialize();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: _isLoading 
        ? _buildLoadingState()
        : _buildAchievementsList(),
    );
  }
  
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildAchievementsList() {
    final achievements = _achievementService.achievements;
    final unlockedCount = _achievementService.unlockedAchievements.length;
    
    // Group achievements by category
    final Map<AchievementCategory, List<Achievement>> groupedAchievements = {};
    
    for (final achievement in achievements) {
      if (!groupedAchievements.containsKey(achievement.category)) {
        groupedAchievements[achievement.category] = [];
      }
      groupedAchievements[achievement.category]!.add(achievement);
    }
    
    return Column(
      children: [
        // Achievement progress header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Text(
                'You have unlocked $unlockedCount of ${achievements.length} achievements',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: unlockedCount / achievements.length,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        
        // List of achievement categories
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final category in AchievementCategory.values)
                if (groupedAchievements.containsKey(category))
                  _buildCategorySection(
                    category, 
                    groupedAchievements[category]!,
                  ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategorySection(AchievementCategory category, List<Achievement> achievements) {
    String categoryTitle;
    
    switch (category) {
      case AchievementCategory.streak:
        categoryTitle = 'Streak Achievements';
        break;
      case AchievementCategory.completion:
        categoryTitle = 'Completion Achievements';
        break;
      case AchievementCategory.consistency:
        categoryTitle = 'Consistency Achievements';
        break;
      case AchievementCategory.special:
        categoryTitle = 'Special Achievements';
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            categoryTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
        ),
        const Divider(),
        ...achievements.map((achievement) => _buildAchievementTile(achievement)),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildAchievementTile(Achievement achievement) {
    return Card(
      elevation: achievement.isUnlocked ? 2 : 0,
      color: achievement.isUnlocked 
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          achievement.icon,
          color: achievement.isUnlocked 
              ? AppTheme.accentColor 
              : Colors.grey,
          size: 32,
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: achievement.isUnlocked 
                ? FontWeight.bold 
                : FontWeight.normal,
            color: achievement.isUnlocked
                ? null
                : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            if (achievement.isUnlocked)
              Text(
                'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: achievement.isUnlocked
            ? const Icon(Icons.emoji_events, color: Colors.amber)
            : const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 