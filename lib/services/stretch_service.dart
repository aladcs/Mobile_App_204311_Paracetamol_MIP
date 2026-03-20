/*
 * File: stretch_service.dart
 * Feature : Core Feature
 * Description: Service for loading and providing static stretch data.
 *
 * Responsibilities:
 * - Load stretch data from JSON assets
 * - Provide cached access to stretch categories
 * - Map muscle names to stretch categories
 * - Handle data loading errors gracefully
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/stretch_data.dart';

/// The [StretchService] class represents a service that handles loading and querying static stretch data from assets.
///
/// Usage:
/// - Load stretch data from JSON assets
/// - Provide cached access to stretch categories
/// - Map muscle names to stretch categories
/// - Handle data loading errors gracefully
class StretchService {
  static StretchData? _cachedData;

  /// Loads stretch data asynchronously from the local asset.
  ///
  /// Loads stretch data asynchronously from the local asset.
  ///
  /// This method performs file read operations and JSON parsing which may take time to complete.
  /// Throws an exception if the asset file is not found or JSON parsing fails.
  static Future<StretchData> loadStretchData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/stretches.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cachedData = StretchData.fromJson(jsonData);
      return _cachedData!;
    } catch (e) {
      print('Error loading stretch data: $e');
      // Return empty data if loading fails
      return StretchData(categories: [], muscleMapping: {});
    }
  }

  /// Returns the list of loaded stretch categories.
  ///
  /// Provides access to all available stretch categories from the cached data.
  /// Returns empty list if no data has been loaded or if loading failed.
  /// Categories include metadata like names, durations, images, and exercise collections.
  static List<StretchCategory> getCategories() {
    return _cachedData?.categories ?? [];
  }

  /// Returns the category matching the provided visual muscle name.
  ///
  /// Uses the muscle mapping to translate visual body map selections into stretch categories.
  /// Supports interactive body map functionality by resolving muscle names to exercise
  /// collections. Returns null if the muscle name is not mapped or if no data is loaded.
  static StretchCategory? getCategoryByMuscleName(String muscleName) {
    return _cachedData?.getCategoryByMuscleName(muscleName);
  }

  /// Returns the category matching the specified category identifier.
  ///
  /// Searches through cached categories to find one with the exact ID match.
  /// Provides direct category access when the ID is known. Returns null if no
  /// matching category is found or if no data has been loaded.
  static StretchCategory? getCategoryById(String id) {
    return _cachedData?.getCategoryById(id);
  }
}
