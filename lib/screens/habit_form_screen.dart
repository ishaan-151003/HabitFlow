import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../services/habit_provider.dart';
import '../utils/app_theme.dart';

class HabitFormScreen extends StatefulWidget {
  final Habit? habitToEdit;

  const HabitFormScreen({
    Key? key,
    this.habitToEdit,
  }) : super(key: key);

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _frequency = 'daily';
  int _targetDays = 21;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    // Pre-populate the form if we're editing an existing habit
    if (widget.habitToEdit != null) {
      _titleController.text = widget.habitToEdit!.title;
      _descriptionController.text = widget.habitToEdit!.description;
      _frequency = widget.habitToEdit!.frequency;
      _targetDays = widget.habitToEdit!.targetDays;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      
      if (widget.habitToEdit == null) {
        // Create new habit
        final newHabit = Habit(
          title: title,
          description: description,
          frequency: _frequency,
          targetDays: _targetDays,
        );
        
        await habitProvider.addHabit(newHabit);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit created successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Update existing habit
        final updatedHabit = widget.habitToEdit!.copyWith(
          title: title,
          description: description,
          frequency: _frequency,
          targetDays: _targetDays,
        );
        
        await habitProvider.updateHabit(updatedHabit);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Habit updated successfully!')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.cyan[300] : null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'Create New Habit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Habit Title',
                    hintText: 'e.g., Morning Meditation',
                    border: const OutlineInputBorder(),
                    // Ensure label is visible in dark mode
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.cyan[300] : null,
                      fontSize: isDarkMode ? 16 : null,
                    ),
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.cyan[100] : null,
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : null,
                    fontSize: 16,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title for your habit';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'e.g., Meditate for 10 minutes after waking up',
                    border: const OutlineInputBorder(),
                    // Ensure label is visible in dark mode
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.cyan[300] : null,
                      fontSize: isDarkMode ? 16 : null,
                    ),
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.cyan[100] : null,
                    ),
                  ),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : null,
                    fontSize: 16,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                // Frequency selector
                Text(
                  'Frequency',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontSize: isDarkMode ? 18 : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFrequencySelector(isDarkMode),
                const SizedBox(height: 24),

                // Target days selector
                Text(
                  'Target Days',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontSize: isDarkMode ? 18 : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'It takes about 21 days to build a new habit. Set your target:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.cyan[100] : null,
                    fontSize: isDarkMode ? 15 : null,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTargetDaysSelector(isDarkMode),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _saveHabit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDarkMode ? Colors.cyan : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Habit' : 'Create Habit',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? Colors.cyan[700]! : AppTheme.textHintColor,
          width: isDarkMode ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
        color: isDarkMode ? Colors.black.withOpacity(0.3) : null,
      ),
      child: Column(
        children: [
          _buildFrequencyOption('daily', 'Daily', isDarkMode),
          Divider(
            height: 1,
            color: isDarkMode ? Colors.cyan[700] : null,
          ),
          _buildFrequencyOption('weekly', 'Weekly', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String value, String label, bool isDarkMode) {
    final isSelected = _frequency == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _frequency = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected 
                ? (isDarkMode ? Colors.cyan : AppTheme.primaryColor)
                : (isDarkMode ? Colors.cyan[100] : AppTheme.textSecondaryColor),
              size: isDarkMode ? 24 : 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? (isDarkMode ? Colors.cyan : AppTheme.primaryColor)
                  : (isDarkMode ? Colors.white : AppTheme.textPrimaryColor),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isDarkMode ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetDaysSelector(bool isDarkMode) {
    return Column(
      children: [
        Slider(
          value: _targetDays.toDouble(),
          min: 7.0,
          max: 66.0,
          divisions: 9,  // (66-7)/7 = 9 steps
          label: _targetDays.toString(),
          activeColor: isDarkMode ? Colors.cyan : AppTheme.primaryColor,
          thumbColor: isDarkMode ? Colors.cyanAccent : null,
          onChanged: (value) {
            setState(() {
              _targetDays = value.round();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_targetDays.toString()} days', 
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDarkMode ? Colors.cyan : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: isDarkMode ? 16 : null,
              ),
            ),
            Text(
              (_targetDays >= 21) 
                ? 'Great choice!' 
                : 'Consider longer for better habits',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.cyan[100] : null,
                fontSize: isDarkMode ? 14 : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 