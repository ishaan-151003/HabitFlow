import 'package:intl/intl.dart';

class HabitDateUtils {
  // Format date as 'yyyy-MM-dd' (standard ISO format)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format date as 'EEE, MMM d' (e.g., "Mon, Jan 1")
  static String formatDateShort(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }
  
  // Format date as 'EEEE, MMMM d, yyyy' (e.g., "Monday, January 1, 2023")
  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
  
  // Get the date for today at midnight (for consistent comparisons)
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  // Get the date for yesterday at midnight
  static DateTime yesterday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - 1);
  }
  
  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  // Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
  
  // Get a list of the past n days (including today)
  static List<DateTime> getPastDays(int days) {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      dates.add(DateTime(now.year, now.month, now.day - i));
    }
    
    return dates;
  }
  
  // Get the week number of the year (1-53)
  static int getWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
  
  // Get the first day of the week containing the given date
  static DateTime getFirstDayOfWeek(DateTime date) {
    // Adjust based on whether weeks start on Sunday or Monday
    // This uses Monday as the first day of the week
    final daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }
  
  // Get friendly relative date name
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      // Check if in current week
      final today = DateTime.now();
      final startOfWeek = getFirstDayOfWeek(today);
      
      if (date.isAfter(startOfWeek) || date.isAtSameMomentAs(startOfWeek)) {
        return DateFormat('EEEE').format(date); // Day of week
      } else {
        return formatDateShort(date);
      }
    }
  }
  
  // Get a date range in ISO format strings
  static List<String> getDateRangeStrings(DateTime start, DateTime end) {
    final List<String> dates = [];
    DateTime current = start;
    
    while (!current.isAfter(end)) {
      dates.add(formatDate(current));
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }
  
  // Parse ISO date string to DateTime
  static DateTime parseDate(String dateStr) {
    return DateFormat('yyyy-MM-dd').parse(dateStr);
  }
} 