/*
 * File: stretch_library_screen.dart
 * Feature : Individual Feature
 * Description: A library screen providing a searchable list of all available stretches.
 *
 * Responsibilities:
 * - Display comprehensive stretch library with search functionality
 * - Filter stretches by target area and mode
 * - Load and combine data from multiple sources
 * - Navigate to individual stretch guides
 *
 * Dependencies:
 * - BottomNavBar
 * - TimerBadge
 * - NotificationBell
 * - AppColors
 * - TimerService
 * - StretchService
 * - StretchModeService
 * - StretchData
 * - AnalysisScreen
 * - HomeScreen
 * - StretchGuideScreen
 *
 * Author: <Chaiwet Ketmuangmul / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/timer_badge.dart';
import '../widgets/notification_bell.dart';
import '../utils/colors.dart';
import '../services/timer_service.dart';
import '../services/stretch_service.dart';
import '../services/stretch_mode_service.dart';
import '../models/stretch_data.dart';
import 'analysis_screen.dart';
import 'home_screen.dart';
import 'stretch_guide_screen.dart';

/// The [StretchLibraryScreen] class represents a screen providing a searchable library of all available stretches.
///
/// Usage:
/// - Display comprehensive stretch library with search functionality
/// - Filter stretches by target area and mode
/// - Load and combine data from multiple sources
/// - Navigate to individual stretch guides
class StretchLibraryScreen extends StatefulWidget {
  @override
  _StretchLibraryScreenState createState() => _StretchLibraryScreenState();
}

class _StretchLibraryScreenState extends State<StretchLibraryScreen> {
  final TimerService timerService = TimerService();
  final TextEditingController _searchController = TextEditingController();

  /// The local list of all loaded stretch data maps.
  List<Map<String, dynamic>> allStretches = [];
  
  /// Whether the library data is currently loading.
  bool isLoading = true;

  // Filter state
  String _searchQuery = '';
  String _selectedArea = 'All';
  String _selectedMode = 'All Modes';

  // The available filter options.
  final List<String> _targetAreas = [
    'All', 'Neck', 'Shoulders', 'Upper Back', 'Lower Back', 'Forearms', 'Wrists', 'Hips',
  ];
  final List<String> _modes = [
    'All Modes', 'Study', 'Work', 'Meeting',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Loads stretch and exercise mode data from multiple sources.
  Future<void> _loadData() async {
    List<Map<String, dynamic>> stretchesList = [];

    // Loads body-part from stretches.json.
    final data = await StretchService.loadStretchData();
    for (var category in data.categories) {
      for (var stretch in category.stretches) {
        stretchesList.add({
          'categoryId': category.id,
          'categoryName': category.name,
          'title': stretch.title,
          'description': stretch.description,
          'duration': stretch.duration,
          'videoPath': stretch.videoPath ?? '',
          'videoUrl': stretch.videoUrl ?? '',
          'mode': '', 
        });
      }
    }
    // Loads from stretch_mode.json.
    final modeService = StretchModeService();
    await modeService.loadStretchModes();
    for (var mode in ['Study', 'Work', 'Meeting']) {
      final exercises = modeService.getAllExercisesByMode(mode);
      for (var exercise in exercises) {
        stretchesList.add({
          'categoryId': exercise.muscleGroup.toLowerCase().replaceAll(' ', '_'),
          'categoryName': exercise.muscleGroup,
          'title': exercise.title,
          'description': exercise.description,
          'duration': '${exercise.durationInSeconds} sec',
          'videoPath': exercise.videoPath ?? '',
          'videoUrl': '',
          'mode': exercise.mode,
        });
      }
    }
    setState(() {
      allStretches = stretchesList;
      isLoading = false;
    });
  }
  // The filtered list of stretches using current search and filter criteria.
  List<Map<String, dynamic>> get _filteredStretches {
    return allStretches.where((stretch) {
      // Search text
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (stretch['title'] as String).toLowerCase();
        final category = (stretch['categoryName'] as String).toLowerCase();
        if (!title.contains(query) && !category.contains(query)) {
          return false;
        }
      }
      // Target Area
      if (_selectedArea != 'All') {
        final category = (stretch['categoryName'] as String).toLowerCase();
        if (category != _selectedArea.toLowerCase()) {
          return false;
        }
      }
      // Mode
      if (_selectedMode != 'All Modes') {
        final mode = (stretch['mode'] as String).toLowerCase();
        if (mode != _selectedMode.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredStretches;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Timer Badge and Notification
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(width: 48),
                  Expanded(
                    child: Center(
                      child: TimerBadge(timerService: timerService),
                    ),
                  ),
                  NotificationBell(),
                ],
              ),
            ),
            // Title
            Text(
              'Stretch Library',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            //Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search stretches...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade400, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            // Filter Target Area
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _targetAreas.length,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final area = _targetAreas[index];
                  final isSelected = _selectedArea == area;
                  return ChoiceChip(
                    label: Text(area),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedArea = area),
                    selectedColor: AppColors.green,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            // Filter Mode 
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _modes.length,
                separatorBuilder: (_, __) => SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final mode = _modes[index];
                  final isSelected = _selectedMode == mode;
                  return ChoiceChip(
                    label: Text(mode),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedMode = mode),
                    selectedColor: Color(0xFF60A5FA), // soft blue
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    showCheckmark: false,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            // Result count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filtered.length} stretches',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4),
            //Grid
            Expanded(
              child: isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.green))
                : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade300),
                          SizedBox(height: 12),
                          Text(
                            'No stretches found',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      padding: EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final stretch = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StretchGuideScreen(
                                  muscleNames: [],
                                  timerService: timerService,
                                  singleStretch: {
                                    'title': stretch['title'] as String,
                                    'description': stretch['description'] as String,
                                    'duration': stretch['duration'] as String,
                                    'videoPath': stretch['videoPath'] as String? ?? '',
                                    'videoUrl': stretch['videoUrl'] as String? ?? '',
                                  },
                                ),
                              ),
                            );
                          },
                          child: _buildExerciseCard(
                            stretch['title'],
                            stretch['duration'],
                            stretch['categoryName'],
                            stretch['mode'] as String,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(timerService: timerService),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => AnalysisScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildExerciseCard(String title, String duration, String categoryName, String mode) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Static Thumbnail 
          Container(
            width: double.infinity,
            height: 100,
            margin: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Color(0xFF6EE7B7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.play_circle_fill, size: 40, color: Colors.white.withOpacity(0.8)),
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (mode.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getModeColor(mode),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(fontSize: 10, color: _getModeTextColor(mode), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Title
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Category
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'study':
        return Color(0xFFE1BEE7); 
      case 'work':
        return Color(0xFFC8E6C9); 
      case 'meeting':
        return Color(0xFF90A4AE); 
      default:
        return Colors.grey;
    }
  }

  Color _getModeTextColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'study':
        return Color(0xFF7B1FA2); 
      case 'work':
        return Color(0xFF2E7D32); 
      case 'meeting':
        return Colors.white;
      default:
        return Colors.white;
    }
  }
}