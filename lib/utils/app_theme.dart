import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Theme mode
  static bool isDarkMode = false;
  
  // Primary color palette - modern and soothing
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryColorLight = Color(0xFF818CF8); // Light indigo
  static const Color primaryColorDark = Color(0xFF4F46E5); // Dark indigo
  
  // More energetic secondary color palette
  static const Color accentColor = Color(0xFFFF5722); // Vibrant orange
  static const Color accentColorLight = Color(0xFFFF8A65); // Light orange
  static const Color accentColorDark = Color(0xFFE64A19); // Dark orange
  
  // Background colors - neutral and soft
  static const Color backgroundColor = Color(0xFFF9FAFB); // Light gray
  static const Color cardColor = Colors.white;
  static const Color scaffoldBackgroundColor = Color(0xFFF9FAFB);
  
  // Text colors - high contrast but not harsh
  static const Color textPrimaryColor = Color(0xFF111827); // Very dark gray
  static const Color textSecondaryColor = Color(0xFF6B7280); // Medium gray
  static const Color textHintColor = Color(0xFF9CA3AF); // Light gray
  
  // Status colors - vibrant but harmonious
  static const Color successColor = Color(0xFF22C55E); // Green
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  
  // Border colors
  static const Color borderColor = Color(0xFFE5E7EB); // Light gray for borders
  
  // Gamification colors - cohesive progression
  static const Color levelColor1 = Color(0xFFE0E7FF); // Very light indigo
  static const Color levelColor2 = Color(0xFFC7D2FE); // Light indigo
  static const Color levelColor3 = Color(0xFFA5B4FC); // Medium indigo
  static const Color levelColor4 = Color(0xFF818CF8); // Strong indigo
  static const Color levelColor5 = Color(0xFF6366F1); // Full indigo
  
  // Achievement colors - traditional but softer
  static const Color bronzeColor = Color(0xFFD97706); // Softer bronze
  static const Color silverColor = Color(0xFF9CA3AF); // Softer silver
  static const Color goldColor = Color(0xFFFCD34D); // Softer gold
  
  // Streak colors (for visualizing streak heatmaps) - cohesive gradient
  static const List<Color> streakColorScale = [
    Color(0xFFF9FAFB), // No completion (lightest)
    Color(0xFFDCFCE7), // Light green
    Color(0xFFA7F3D0), // Mint green
    Color(0xFF6EE7B7), // Medium green
    Color(0xFF10B981), // Full green
  ];
  
  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkScaffoldBackgroundColor = Color(0xFF121212);
  static const Color darkTextPrimaryColor = Color(0xFFEEF2FF); // Lighter with slight blue tint
  static const Color darkTextSecondaryColor = Color(0xFFBBC5F8); // Light indigo shade
  static const Color darkTextHintColor = Color(0xFFA5B4FC); // Medium indigo
  
  static const List<Color> darkStreakColorScale = [
    Color(0xFF1E1E1E), // No completion (lightest)
    Color(0xFF0F3321), // Dark green
    Color(0xFF064E3B), // Medium green
    Color(0xFF047857), // Light green
    Color(0xFF10B981), // Full green
  ];
  
  // Get a color from the streak scale based on a value (0.0 to 1.0)
  static Color getStreakColor(double value) {
    if (value <= 0) return isDarkMode ? darkStreakColorScale[0] : streakColorScale[0];
    if (value >= 1) return isDarkMode ? darkStreakColorScale[darkStreakColorScale.length - 1] : streakColorScale[streakColorScale.length - 1];
    
    final index = (value * (streakColorScale.length - 1)).floor();
    return isDarkMode ? darkStreakColorScale[index] : streakColorScale[index];
  }
  
  // Get a consistent color for a habit based on its ID
  static Color getPrimaryColorForHabit(int? habitId) {
    // Define a palette of colors to use for habits
    const List<Color> habitColors = [
      Color(0xFF6366F1), // Indigo (primary)
      Color(0xFF14B8A6), // Teal
      Color(0xFFEF4444), // Red
      Color(0xFFF59E0B), // Amber
      Color(0xFF8B5CF6), // Purple
      Color(0xFF3B82F6), // Blue
      Color(0xFF10B981), // Emerald
      Color(0xFFF97316), // Orange
      Color(0xFFEC4899), // Pink
      Color(0xFF64748B), // Slate
    ];
    
    // If no ID provided, return the default color
    if (habitId == null) return habitColors[0];
    
    // Use the ID to get a consistent color from the palette
    final colorIndex = habitId % habitColors.length;
    return habitColors[colorIndex];
  }
  
  // Toggle dark mode
  static void toggleDarkMode() {
    isDarkMode = !isDarkMode;
  }
  
  // Get the main theme data based on mode
  static ThemeData getTheme() {
    return isDarkMode ? getDarkTheme() : getLightTheme();
  }
  
  // Get light theme data
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        background: backgroundColor,
        error: errorColor,
        
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryColor,
        onError: Colors.white,
        
        // Additional color scheme properties
        primaryContainer: primaryColorLight,
        secondaryContainer: accentColorLight,
        surface: cardColor,
        onSurface: textPrimaryColor,
      ),
      
      // Text theme with more modern fonts
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
          letterSpacing: -0.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimaryColor,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimaryColor,
          letterSpacing: 0.25,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
      
      // Card theme with softer shadows and rounded corners
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardColor,
      ),
      
      // AppBar theme - clean with subtle gradient
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      
      // Button themes - consistent with overall theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      
      // FloatingActionButton theme - matching accent color
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.all(16),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      
      // Other
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Color(0xFFE5E7EB), // Light gray
      ),
      
      // Input decoration with clean styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: textHintColor),
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      
      // Bottom navigation bar theme - consistent with app theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
  
  // Get dark theme data
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        background: darkBackgroundColor,
        error: errorColor,
        
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: darkTextPrimaryColor,
        onError: Colors.white,
        
        // Additional color scheme properties
        primaryContainer: primaryColorLight,
        secondaryContainer: accentColorLight,
        surface: darkCardColor,
        onSurface: darkTextPrimaryColor,
      ),
      
      // Text theme with more modern fonts - consistent colors for dark mode
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkTextPrimaryColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkTextPrimaryColor,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkTextPrimaryColor,
          letterSpacing: -0.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkTextPrimaryColor,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkTextPrimaryColor,
          letterSpacing: 0.25,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkTextPrimaryColor,
          letterSpacing: 0.1,
        ),
      ),
      
      // Card theme with softer shadows and rounded corners
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: darkCardColor,
      ),
      
      // AppBar theme - clean with subtle gradient
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      
      // Button themes - consistent with overall theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      
      // FloatingActionButton theme - matching accent color
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedPadding: const EdgeInsets.all(16),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      
      // Other
      scaffoldBackgroundColor: darkScaffoldBackgroundColor,
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Color(0xFFE5E7EB), // Light gray
      ),
      
      // Input decoration with clean styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: darkTextHintColor),
        isDense: true,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      
      // Bottom navigation bar theme - consistent with app theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkTextSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
  
  // Common text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
    letterSpacing: 0.15,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
    letterSpacing: 0.25,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: textSecondaryColor,
    letterSpacing: 0.4,
  );
  
  // Common UI values
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultRadius = 12.0;
  static const double largeRadius = 20.0;
  static const double smallRadius = 6.0;
  
  // Animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Curve defaultAnimationCurve = Curves.easeInOut;
  
  // Get level color based on habit strength (1-5)
  static Color getLevelColor(int level) {
    switch (level) {
      case 1: return levelColor1;
      case 2: return levelColor2;
      case 3: return levelColor3;
      case 4: return levelColor4;
      case 5: return levelColor5;
      default: return levelColor1;
    }
  }
} 