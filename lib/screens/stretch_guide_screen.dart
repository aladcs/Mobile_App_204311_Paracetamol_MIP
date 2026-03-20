/*
 * File: stretch_guide_screen.dart
 * Feature : Individual Feature
 * Description: Displays a guide for a selected stretch or a list of stretches based on muscle selection or notification recommendation.
 *
 * Responsibilities:
 * - Display detailed stretch instructions and videos
 * - Show recommended exercises from notifications
 * - Organize stretches by category and source
 * - Provide interactive stretch cards with timers
 *
 * Dependencies:
 * - AppColors
 * - TimerBadge
 * - NotificationBell
 * - VideoPlayerWidget
 * - TimerService
 * - StretchService
 * - StretchData
 * - StretchModeExercise
 * - InteractiveStretchCard
 *
 * Author: <Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/timer_badge.dart';
import '../widgets/notification_bell.dart';
import '../widgets/video_player_widget.dart';
import '../services/timer_service.dart';
import '../services/stretch_service.dart';
import '../models/stretch_data.dart';
import '../models/stretch_mode_data.dart';
import '../widgets/interactive_stretch_card.dart';

/// The [StretchGuideScreen] class represents a screen displaying stretch guides based on user selection or recommendations.
///
/// Fields:
/// - muscleNames: Selected muscle areas for targeted stretching
/// - timerService: The global timer service instance
/// - recommendedExercises: Recommended exercises passed from notifications
/// - singleStretch: A single specific stretch to display
///
/// Usage:
/// - Display detailed stretch instructions and videos
/// - Show recommended exercises from notifications
/// - Organize stretches by category and source
/// - Provide interactive stretch cards with timers
class StretchGuideScreen extends StatefulWidget {
  final List<String> muscleNames;
  final TimerService timerService;
  
  /// Recommended exercises from notification.
  final List<StretchModeExercise>? recommendedExercises;
  
  /// A single stretch to display.
  final Map<String, String>? singleStretch;

  /// Creates a [StretchGuideScreen] with the specified configuration.
  ///
  /// The [muscleNames] contains selected muscle areas for targeted stretching,
  /// [timerService] provides access to the global timer system, [recommendedExercises]
  /// optionally contains exercises from notifications, and [singleStretch] optionally
  /// specifies a single stretch to display from library selection.
  const StretchGuideScreen({
    Key? key,
    required this.muscleNames,
    required this.timerService,
    this.recommendedExercises,
    this.singleStretch,
  }) : super(key: key);

  // Creates the mutable state for this widget.
  @override
  _StretchGuideScreenState createState() => _StretchGuideScreenState();
}

class _StretchGuideScreenState extends State<StretchGuideScreen> {
  /// List of raw map data for recommended stretches.
  List<Map<String, dynamic>> recommendedStretches = [];
  
  /// List of raw map data for stretches combined with their category names.
  List<Map<String, dynamic>> selectedStretchesWithCategory = [];
  
  /// Whether the stretches are currently being loaded.
  bool isLoading = true;

  /// Initializes the state and triggers data loading.
  ///
  /// Called once when the state object is created. Sets up the initial state
  /// and immediately begins loading stretch data based on the widget configuration.
  /// Ensures the screen displays appropriate content upon first render.
  @override
  void initState() {
    super.initState();
    _loadStretches();
  }

  // Loads the stretch data based on the provided configuration.
  Future<void> _loadStretches() async {
    if (widget.singleStretch != null) {
      final s = widget.singleStretch!;
      selectedStretchesWithCategory = [
        {
          'categoryName': '',
          'stretch': Stretch(
            title: s['title'] ?? '',
            description: s['description'] ?? '',
            duration: s['duration'] ?? '15 sec',
            videoPath: s['videoPath'],
            videoUrl: s['videoUrl'],
          ),
        }
      ];
      setState(() { isLoading = false; });
      return;
    }
    if (widget.recommendedExercises != null &&
        widget.recommendedExercises!.isNotEmpty) {
      recommendedStretches = widget.recommendedExercises!.map((e) {
        return {
          'sectionLabel': 'From notification',
          'title': e.title,
          'description': e.description,
          'duration': '${e.durationInSeconds} sec',
          'videoPath': e.videoPath ?? '',
        };
      }).toList();
    }

    await StretchService.loadStretchData();
    Set<String> addedCategories = {};
    List<Map<String, dynamic>> selected = [];

    for (String muscleName in widget.muscleNames) {
      var category = StretchService.getCategoryByMuscleName(muscleName);
      category ??= StretchService.getCategoryById(muscleName);
      if (category != null && !addedCategories.contains(category.id)) {
        for (var stretch in category.stretches) {
          selected.add({
            'categoryName': category.name,
            'stretch': stretch,
          });
        }
        addedCategories.add(category.id);
      }
    }
    selectedStretchesWithCategory = selected;
    setState(() {
      isLoading = false;
    });
  }

  /// Builds the widget tree for the stretch guide screen.
  ///
  /// Creates a scaffold with header navigation, title section, and scrollable content area.
  /// Displays loading indicator during data fetch, empty state when no stretches available,
  /// or organized stretch lists with sections for user selections and recommendations.
  /// Returns a complete screen layout with proper styling and interactive elements.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: TimerBadge(timerService: widget.timerService),
                    ),
                  ),
                  NotificationBell(),
                ],
              ),
            ),
            
            // Title
            Text(
              'Stretch Guide',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (widget.muscleNames.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Selected: ${widget.muscleNames.join(", ")}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.green))
                  : (recommendedStretches.isEmpty &&
                          selectedStretchesWithCategory.isEmpty)
                      ? Center(
                          child: Text(
                            'No stretches available',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.all(16),
                          children: [
                            if (selectedStretchesWithCategory.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.only(left: 8, bottom: 12),
                                child: Text(
                                  'From your selection',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                  ),
                                ),
                              ),
                              ...selectedStretchesWithCategory.asMap().entries.map((entry) {
                                final item = entry.value;
                                final categoryName = item['categoryName'] as String;
                                final stretch = item['stretch'] as Stretch;
                                final idx = entry.key;
                                bool showCategoryHeader = idx == 0 ||
                                    (selectedStretchesWithCategory[idx - 1]['categoryName'] != categoryName);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showCategoryHeader)
                                      Padding(
                                        padding: EdgeInsets.only(left: 8, bottom: 8),
                                        child: Text(
                                          categoryName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    InteractiveStretchCard(stretch: stretch.toMap()),
                                  ],
                                );
                              }),
                              SizedBox(height: 24),
                            ],
                            // From notification
                            if (recommendedStretches.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.only(left: 8, bottom: 12),
                                child: Text(
                                  'Recommended',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.green,
                                  ),
                                ),
                              ),
                              ...recommendedStretches.map((item) => InteractiveStretchCard(stretch: {
                                    'title': item['title'] as String,
                                    'description': item['description'] as String,
                                    'duration': item['duration'] as String,
                                    'videoPath': item['videoPath'] as String? ?? '',
                                  })),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
