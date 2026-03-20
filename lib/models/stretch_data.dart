/*
 * File: stretch_data.dart
 * Feature : Core Feature
 * Description: Data models representing static stretch categories and exercises.
 *
 * Responsibilities:
 * - Define stretch category and exercise data structures
 * - Handle JSON serialization and deserialization
 * - Provide muscle name to category mapping
 * - Support stretch data querying and lookup
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

/// The [StretchCategory] class represents a category of stretches targeting a specific area.
///
/// Fields:
/// - id: A unique identifier for the category
/// - name: The display name of the category
/// - duration: The total duration required for all stretches in the category
/// - image: The path to the category's cover image
/// - stretches: A list of individual [Stretch] exercises in this category
///
/// Usage:
/// - Organize stretches by body area or muscle group
/// - Provide category-level metadata and images
/// - Support stretch library navigation and filtering
class StretchCategory {
  final String id;
  final String name;
  final String duration;
  final String image;
  final List<Stretch> stretches;

  /// Creates a [StretchCategory] with the specified category information.
  ///
  /// The [id] provides unique identification for the category, [name] is the display
  /// title, [duration] indicates the total time required, [image] specifies the
  /// cover image path, and [stretches] contains the list of individual exercises
  /// within this category.
  StretchCategory({
    required this.id,
    required this.name,
    required this.duration,
    required this.image,
    required this.stretches,
  });

  /// Creates a [StretchCategory] from a JSON map representation.
  ///
  /// The [json] parameter contains the serialized category data with id, name,
  /// duration, image, and stretches fields that will be parsed into a structured
  /// StretchCategory object with nested Stretch instances.
  factory StretchCategory.fromJson(Map<String, dynamic> json) {
    return StretchCategory(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
      image: json['image'],
      stretches: (json['stretches'] as List)
          .map((s) => Stretch.fromJson(s))
          .toList(),
    );
  }
}

/// The [Stretch] class represents a single stretch exercise definition.
///
/// Fields:
/// - title: The display name of the stretch
/// - description: Instructions on how to perform the stretch
/// - duration: The display text for the stretch duration
/// - videoPath: The optional local asset path for the instruction video
/// - videoUrl: The optional remote URL for the instruction video
///
/// Usage:
/// - Define individual stretch exercises with instructions
/// - Support video content for exercise guidance
/// - Handle JSON serialization and deserialization
class Stretch {
  final String title;
  final String description;
  final String duration;
  final String? videoPath;
  final String? videoUrl;

  /// Creates a [Stretch] with the specified exercise details.
  ///
  /// The [title] is the display name of the stretch, [description] provides
  /// instructions on how to perform it, [duration] shows the time requirement,
  /// [videoPath] optionally references a local video file, and [videoUrl]
  /// optionally references a remote video source.
  Stretch({
    required this.title,
    required this.description,
    required this.duration,
    this.videoPath,
    this.videoUrl,
  });

  /// Creates a [Stretch] from a JSON map representation.
  ///
  /// The [json] parameter contains the serialized stretch data with title,
  /// description, duration, and optional video reference fields that will
  /// be parsed into a structured Stretch object.
  factory Stretch.fromJson(Map<String, dynamic> json) {
    return Stretch(
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      videoPath: json['videoPath'],
      videoUrl: json['videoUrl'],
    );
  }

  /// Converts this stretch into a string map for serialization.
  ///
  /// Creates a map representation of the stretch with string values for all fields.
  /// Converts null video paths to empty strings for consistent data handling.
  /// Returns a map suitable for JSON serialization or widget parameter passing.
  Map<String, String> toMap() {
    return {
      'title': title,
      'description': description,
      'videoPath': videoPath ?? '',
      'videoUrl': videoUrl ?? '',
    };
  }
}

/// The [StretchData] class represents a container holding all categories and muscle mapping.
///
/// Fields:
/// - categories: All available stretch categories in the app
/// - muscleMapping: A map linking muscle names to category IDs
///
/// Usage:
/// - Provide centralized access to all stretch data
/// - Support muscle name to category mapping for interactive body maps
/// - Handle stretch data querying and lookup operations
class StretchData {
  final List<StretchCategory> categories;
  final Map<String, String> muscleMapping;

  /// Creates a [StretchData] with the specified categories and muscle mapping.
  ///
  /// The [categories] contains all available stretch categories in the app,
  /// and [muscleMapping] provides the mapping between muscle names and
  /// category IDs for interactive body map functionality.
  StretchData({
    required this.categories,
    required this.muscleMapping,
  });

  /// Creates a [StretchData] from a JSON map representation.
  ///
  /// The [json] parameter contains the serialized data with categories array
  /// and muscle_mapping object that will be parsed into a structured StretchData
  /// object with category collections and muscle name mappings.
  factory StretchData.fromJson(Map<String, dynamic> json) {
    return StretchData(
      categories: (json['categories'] as List)
          .map((c) => StretchCategory.fromJson(c))
          .toList(),
      muscleMapping: Map<String, String>.from(json['muscle_mapping']),
    );
  }

  /// Searches for a category matching the given identifier.
  ///
  /// Iterates through all available categories to find one with the specified ID.
  /// Uses exact string matching for category identification. Returns null if no
  /// matching category is found or if the categories list is empty.
  StretchCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Resolves the category associated with a visual muscle name.
  ///
  /// Uses the muscle mapping to find the category ID for the given muscle name,
  /// then retrieves the corresponding category. Supports interactive body map
  /// functionality by translating visual selections to stretch categories.
  /// Returns null if the muscle name is not mapped or category is not found.
  StretchCategory? getCategoryByMuscleName(String muscleName) {
    final categoryId = muscleMapping[muscleName];
    if (categoryId != null) {
      return getCategoryById(categoryId);
    }
    return null;
  }
}
