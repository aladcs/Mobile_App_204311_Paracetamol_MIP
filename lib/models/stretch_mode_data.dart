/*
 * File: stretch_mode_data.dart
 * Feature : Core Feature
 * Description: Data models for exercises specific to work, study, or meeting modes.
 *
 * Responsibilities:
 * - Define mode-specific exercise data structures
 * - Handle JSON serialization for exercise data
 * - Filter exercises by mode type
 * - Support exercise recommendation systems
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

/// The [StretchModeExercise] class represents an exercise associated with a specific timer mode.
///
/// Fields:
/// - id: A unique identifier for the exercise
/// - mode: The timer mode it is suitable for
/// - title: The display name of the exercise
/// - description: Instructions on how to perform the exercise
/// - durationInSeconds: The active time required
/// - muscleGroup: The targeted body part
/// - videoPath: An optional video reference
///
/// Usage:
/// - Define mode-specific exercise data structures
/// - Handle JSON serialization for exercise data
/// - Support exercise recommendation systems
class StretchModeExercise {
  final String id;
  final String mode;
  final String title;
  final String description;
  final int durationInSeconds;
  final String muscleGroup;
  final String? videoPath;

  /// Creates a [StretchModeExercise] with the specified exercise information.
  ///
  /// The [id] provides unique identification, [mode] specifies the timer mode
  /// it's suitable for, [title] is the display name, [description] contains
  /// performance instructions, [durationInSeconds] indicates the active time
  /// required, [muscleGroup] identifies the targeted body part, and [videoPath]
  /// optionally references an instruction video.
  StretchModeExercise({
    required this.id,
    required this.mode,
    required this.title,
    required this.description,
    required this.durationInSeconds,
    required this.muscleGroup,
    this.videoPath,
  });

  /// Creates a [StretchModeExercise] from a JSON map representation.
  ///
  /// The [json] parameter contains the serialized exercise data with id, mode,
  /// title, description, durationInSeconds, muscleGroup, and optional videoPath
  /// fields that will be parsed into a structured StretchModeExercise object.
  factory StretchModeExercise.fromJson(Map<String, dynamic> json) {
    return StretchModeExercise(
      id: json['id'] as String,
      mode: json['mode'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      durationInSeconds: json['durationInSeconds'] as int,
      muscleGroup: json['muscleGroup'] as String,
      videoPath: json['videoPath'] as String?,
    );
  }

  /// Converts this exercise instance back to a JSON map.
  ///
  /// Creates a map representation of the exercise with all field values preserved.
  /// Maintains original data types for proper JSON serialization. Returns a map
  /// suitable for storage, transmission, or debugging purposes.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode,
      'title': title,
      'description': description,
      'durationInSeconds': durationInSeconds,
      'muscleGroup': muscleGroup,
      'videoPath': videoPath,
    };
  }
}

/// The [StretchModeData] class represents a collection of mode-specific exercises.
///
/// Fields:
/// - exercises: The list of all loaded dynamic exercises
///
/// Usage:
/// - Store and manage mode-specific exercise collections
/// - Filter exercises by mode type
/// - Support exercise recommendation systems
class StretchModeData {
  final List<StretchModeExercise> exercises;

  /// Creates a [StretchModeData] with the specified exercise collection.
  ///
  /// The [exercises] parameter contains the list of all loaded mode-specific
  /// exercises that can be filtered and recommended based on timer modes.
  StretchModeData({required this.exercises});

  /// Creates a [StretchModeData] from a JSON map representation.
  ///
  /// The [json] parameter contains the serialized data with an exercises array
  /// that will be parsed into StretchModeExercise objects and collected into
  /// a structured StretchModeData container.
  factory StretchModeData.fromJson(Map<String, dynamic> json) {
    var exercisesList = json['exercises'] as List;
    List<StretchModeExercise> exercises = exercisesList
        .map((exercise) => StretchModeExercise.fromJson(exercise))
        .toList();

    return StretchModeData(exercises: exercises);
  }

  /// Filters and returns exercises suitable for the specified mode.
  ///
  /// Searches through all available exercises to find those matching the given mode string.
  /// Uses exact string matching for mode identification. Returns an empty list if no
  /// exercises match the specified mode or if the exercises collection is empty.
  List<StretchModeExercise> getExercisesByMode(String mode) {
    return exercises.where((exercise) => exercise.mode == mode).toList();
  }
}
