/*
 * File: analysis_screen.dart
 * Feature : Individual Feature
 * Description: A screen for analyzing and selecting body parts to stretch.
 *
 * Responsibilities:
 * - Provide interactive body map for muscle selection
 * - Display recommended exercises from notifications
 * - Navigate to stretch guide with selected muscles
 * - Handle front/back body view switching
 *
 * Dependencies:
 * - AppColors
 * - BottomNavBar
 * - TimerBadge
 * - NotificationBell
 * - StretchModeExercise
 * - TimerService
 * - NotificationService
 * - StretchGuideScreen
 * - StretchLibraryScreen
 * - HomeScreen
 *
 * Author: <Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/timer_badge.dart';
import '../widgets/notification_bell.dart';
import '../models/stretch_mode_data.dart';
import '../services/timer_service.dart';
import '../services/notification_service.dart';
import 'stretch_guide_screen.dart';
import 'stretch_library_screen.dart';
import 'home_screen.dart';

/// The [AnalysisScreen] class represents a navigation screen that allows users to select body parts for stretching.
///
/// Fields:
/// - recommendedExercises: The exercises recommended from notifications
///
/// Usage:
/// - Provide interactive body map for muscle selection
/// - Display recommended exercises from notifications
/// - Navigate to stretch guide with selected muscles
/// - Handle front/back body view switching
class AnalysisScreen extends StatefulWidget {
  /// The recommended exercises from notifications.
  final List<StretchModeExercise>? recommendedExercises;

  /// Creates an [AnalysisScreen] with optional exercise recommendations.
  ///
  /// The [recommendedExercises] parameter optionally contains exercises
  /// recommended from notifications that should be pre-selected or highlighted
  /// in the body map interface.
  const AnalysisScreen({super.key, this.recommendedExercises});

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  /// The service managing the active stretch timer.
  final TimerService timerService = TimerService();

  // The index of the currently selected bottom navigation tab.
  int _currentIndex = 1;
  bool _showFront = true;

  // The currently selected muscles.
  static Set<String> _selectedMuscles = {}; 

  // Touch zones for front body 
  final Map<String, Map<String, double>> _frontTouchZones = {
    'Neck': {'top': 0.13, 'left': 0.50},
    'Left Shoulder': {'top': 0.18, 'left': 0.30},
    'Right Shoulder': {'top': 0.18, 'left': 0.70},
    'Left Forearm': {'top': 0.38, 'left': 0.20},
    'Right Forearm': {'top': 0.38, 'left': 0.80},
    'Left Wrist': {'top': 0.50, 'left': 0.15},
    'Right Wrist': {'top': 0.50, 'left': 0.85},
  };

  // Touch zones for back body
  final Map<String, Map<String, double>> _backTouchZones = {
    'Neck': {'top': 0.12, 'left': 0.50},
    'Left Shoulder': {'top': 0.17, 'left': 0.28},
    'Right Shoulder': {'top': 0.17, 'left': 0.72},
    'Upper Back': {'top': 0.25, 'left': 0.50},
    'Lower Back': {'top': 0.38, 'left': 0.50},
    'Left Hip': {'top': 0.48, 'left': 0.38},
    'Right Hip': {'top': 0.48, 'left': 0.62},
  };

  @override
  void dispose() {
    super.dispose();
  }

  void _clearSelection() {
    setState(() {
      _selectedMuscles.clear();
    });
  }

  void _onNavTap(int index) {
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
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => StretchLibraryScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); 
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    }
  }

  void _onTouchZoneTap(String muscle) {
    setState(() {
      if (_selectedMuscles.contains(muscle)) {
        _selectedMuscles.remove(muscle);
      } else {
        _selectedMuscles.add(muscle);
      }
    });
  }

  void _navigateToStretchGuide() {
    final hasRecommended =
        widget.recommendedExercises != null &&
        widget.recommendedExercises!.isNotEmpty;
    final hasSelection = _selectedMuscles.isNotEmpty;
    if (hasRecommended || hasSelection) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StretchGuideScreen(
            muscleNames: _selectedMuscles.toList(),
            timerService: timerService,
            recommendedExercises: widget.recommendedExercises,
          ),
        ),
      );
    }
  }

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
              'Analysis',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                height: 36, 
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _showFront = true;
                              }),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _showFront ? AppColors.green : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Front',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _showFront ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _showFront = false;
                              }),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !_showFront ? AppColors.green : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Back',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: !_showFront ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (_selectedMuscles.isNotEmpty)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: _clearSelection,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red, width: 0.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.clear, size: 10, color: Colors.white),
                                  SizedBox(width: 3),
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Body Map with Touch Zones
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final imageHeight = constraints.maxHeight * 0.85;
                        final imageWidth = imageHeight * 0.5;
                        return SizedBox(
                          height: imageHeight,
                          width: imageWidth,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Body Image
                              Image.asset(
                                _showFront 
                                  ? 'assets/images/frontbody.png'
                                  : 'assets/images/backbody.png',
                                height: imageHeight,
                                width: imageWidth,
                                fit: BoxFit.contain,
                              ),
                              // Touch Zones
                              ..._buildTouchZones(imageWidth, imageHeight),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  if (_selectedMuscles.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: AppColors.green, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Selected: ${_selectedMuscles.join(", ")}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (widget.recommendedExercises != null &&
                widget.recommendedExercises!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '${widget.recommendedExercises!.length} recommended: ${widget.recommendedExercises!.map((e) => e.title).join(", ")}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 12),
            ],
            // Action Button
            Padding(
              padding: EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedMuscles.isNotEmpty ||
                          (widget.recommendedExercises != null &&
                              widget.recommendedExercises!.isNotEmpty))
                      ? _navigateToStretchGuide
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    disabledBackgroundColor: Colors.grey[400],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Show Stretches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  List<Widget> _buildTouchZones(double imageWidth, double imageHeight) {
    final zones = _showFront ? _frontTouchZones : _backTouchZones;
    List<Widget> touchZones = [];

    zones.forEach((muscle, coords) {
      final centerY = coords['top']! * imageHeight;
      final centerX = coords['left']! * imageWidth;
      final isSelected = _selectedMuscles.contains(muscle);
      final dotSize = 20.0;
      final touchSize = 44.0; 

      // Touchable area
      touchZones.add(
        Positioned(
          top: centerY - (touchSize / 2),
          left: centerX - (touchSize / 2),
          child: GestureDetector(
            onTap: () => _onTouchZoneTap(muscle),
            child: Container(
              width: touchSize,
              height: touchSize,
              color: Colors.transparent,
            ),
          ),
        ),
      );
      // Visual dot 
      touchZones.add(
        Positioned(
          top: centerY - (dotSize / 2),
          left: centerX - (dotSize / 2),
          child: IgnorePointer(
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.red.withOpacity(0.8)
                  : Colors.grey.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                      ? Colors.red.withOpacity(0.4)
                      : Colors.black.withOpacity(0.2),
                    blurRadius: isSelected ? 6 : 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

    return touchZones;
  }
}
