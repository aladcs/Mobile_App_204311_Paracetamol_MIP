/*
 * File: stretch_mode_service.dart
 * Feature : Core Feature
 * Description: Service for loading and providing stretch exercises specific to timer modes.
 *
 * Responsibilities:
 * - Load mode-specific exercise data from JSON assets
 * - Generate random exercise recommendations
 * - Map muscle groups to body map areas
 * - Provide exercise filtering by mode
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/stretch_mode_data.dart';

/// The [StretchModeService] class represents a service that loads and manages exercises specific to focus modes.
///
/// Usage:
/// - Load mode-specific exercise data from JSON assets
/// - Generate random exercise recommendations
/// - Map muscle groups to body map areas
/// - Provide exercise filtering by mode
class StretchModeService {
  static final StretchModeService _instance = StretchModeService._internal();

  /// Creates a singleton [StretchModeService] instance.
  ///
  /// This factory constructor implements the singleton pattern to ensure only one
  /// instance of the service exists throughout the application lifecycle, providing
  /// consistent access to stretch mode data and functionality across different
  /// parts of the app.
  factory StretchModeService() => _instance;
  StretchModeService._internal();
  StretchModeData? _stretchModeData;
  final Random _random = Random();

  /// Loads stretch mode details from the designated JSON file asynchronously.
  /// Loads stretch mode details from the designated JSON file asynchronously.
  ///
  /// This method performs file read operations and JSON parsing which may take time to complete.
  /// Throws an exception if the asset file is not found or JSON parsing fails.
  Future<void> loadStretchModes() async {
    if (_stretchModeData != null) return;
    try {
      final String jsonString = await rootBundle.loadString('assets/data/stretch_mode.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _stretchModeData = StretchModeData.fromJson(jsonData);
    } catch (e) {
      print('Error loading stretch modes: $e');
      _stretchModeData = StretchModeData(exercises: []);
    }
  }
  /// Retrieves randomly selected exercise titles for the given mode.
  ///
  /// Filters exercises by mode and returns a randomized selection of exercise titles.
  /// Returns all available exercises if count exceeds available options. Uses internal
  /// random number generator for consistent randomization. Returns empty list if no
  /// exercises match the specified mode or if data is not loaded.
  List<String> getRandomExercises(String mode, {int count = 2}) {
    if (_stretchModeData == null) {
      return [];
    }
    // Gets exercises for the specific mode.
    List<StretchModeExercise> modeExercises = _stretchModeData!.getExercisesByMode(mode);
    if (modeExercises.isEmpty) {
      return [];
    }
    if (modeExercises.length <= count) {
      return modeExercises.map((e) => e.title).toList();
    }
    List<StretchModeExercise> shuffled = List.from(modeExercises)..shuffle(_random);
    return shuffled.take(count).map((e) => e.title).toList();
  }

  /// Retrieves randomly selected StretchModeExercise objects for the given mode.
  ///
  /// Filters exercises by mode and returns a randomized selection of complete exercise objects.
  /// Provides full exercise data including descriptions, durations, and video paths for
  /// detailed display purposes. Returns all available exercises if count exceeds options.
  /// Returns empty list if no exercises match the mode or data is not loaded.
  List<StretchModeExercise> getRandomExerciseObjects(String mode, {int count = 2}) {
    if (_stretchModeData == null) {
      return [];
    }
    List<StretchModeExercise> modeExercises = _stretchModeData!.getExercisesByMode(mode);
    if (modeExercises.isEmpty) {
      return [];
    }
    if (modeExercises.length <= count) {
      return modeExercises;
    }
    List<StretchModeExercise> shuffled = List.from(modeExercises)..shuffle(_random);
    return shuffled.take(count).toList();
  }
  /// Retrieves all StretchModeExercise recommendations for a specific mode.
  ///
  /// Returns the complete collection of exercises available for the specified mode
  /// without any filtering or randomization. Useful for displaying comprehensive
  /// exercise lists or performing bulk operations. Returns empty list if mode
  /// has no exercises or if data is not loaded.
  List<StretchModeExercise> getAllExercisesByMode(String mode) {
    if (_stretchModeData == null) {
      return [];
    }
    return _stretchModeData!.getExercisesByMode(mode);
  }

  /// Maps generalized [muscleGroup] names from `stretch_mode.json` to specific body map targets.
  static const Map<String, List<String>> muscleGroupToBodyMap = {
    'Neck': ['Neck'],
    'Upper Back': ['Upper Back'],
    'Shoulders': ['Left Shoulder', 'Right Shoulder'],
    'Lower Back': ['Lower Back'],
    'Wrists': ['Left Wrist', 'Right Wrist'],
    'Hips': ['Left Hip', 'Right Hip'],
    'Forearms': ['Left Forearm', 'Right Forearm'],
  };

  /// Compiles body map area names for pre-selection based on exercises.
  ///
  /// Maps exercise muscle groups to specific body map target areas for the Analysis screen.
  /// Uses predefined muscle group mappings to translate exercise data into interactive
  /// body map selections. Returns unique list of body area names that should be
  /// highlighted or pre-selected when displaying recommended exercises.
  static List<String> getBodyMapMusclesForRecommended(
    List<StretchModeExercise> exercises,
  ) {
    final Set<String> result = {};
    for (final e in exercises) {
      final list = muscleGroupToBodyMap[e.muscleGroup];
      if (list != null) result.addAll(list);
    }
    return result.toList();
  }
}
