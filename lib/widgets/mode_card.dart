/*
 * File: mode_card.dart
 * Feature : Individual Feature
 * Description: A reusable card widget for selecting a timer mode.
 *
 * Responsibilities:
 * - Display mode selection options with icons and descriptions
 * - Handle mode selection tap events
 * - Provide consistent card styling and layout
 * - Support customizable colors and content
 *
 * Dependencies:
 * - AppColors
 *
 * Author: <Chaiwet Ketmuangmul / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// The [ModeCard] class represents a card widget representing a selectable application mode.
///
/// Fields:
/// - icon: The icon to display for the mode
/// - title: The primary title of the mode
/// - onTap: The callback executed when the card is tapped
/// - color: The background color of the icon container
/// - subtitle: An optional secondary description of the mode
///
/// Usage:
/// - Display mode selection options with icons and descriptions
/// - Handle mode selection tap events
/// - Provide consistent card styling and layout
/// - Support customizable colors and content
class ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final String? subtitle;

  /// Creates a [ModeCard] with the specified mode configuration.
  ///
  /// The [icon] provides the visual indicator for the mode, [title] displays
  /// the primary mode name, [onTap] handles user selection events, [color]
  /// optionally customizes the background styling, and [subtitle] optionally
  /// provides additional mode description text.
  const ModeCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.green;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon, 
                size: 32,
                color: cardColor.withOpacity(0.8),
              ),
            ),
            SizedBox(width: 20),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
