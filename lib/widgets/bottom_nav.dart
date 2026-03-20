/*
 * File: bottom_nav.dart
 * Feature : Core Feature
 * Description: Custom bottom navigation bar widget.
 *
 * Responsibilities:
 * - Provide main screen navigation interface
 * - Handle tab selection and callbacks
 * - Display navigation icons and states
 * - Maintain consistent navigation styling
 *
 * Dependencies:
 * - AppColors
 *
 * Author: <Chaiwet Ketmuangmul, Prin Panyakrue / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// The [BottomNavBar] class represents a custom bottom navigation bar for main screen routing.
///
/// Fields:
/// - currentIndex: The currently selected tab index
/// - onTap: Callback function triggered when a tab is pressed
///
/// Usage:
/// - Provide main screen navigation interface
/// - Handle tab selection and callbacks
/// - Display navigation icons and states
/// - Maintain consistent navigation styling
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  /// Creates a [BottomNavBar] with the specified navigation configuration.
  ///
  /// The [currentIndex] indicates which tab is currently selected, and [onTap]
  /// provides the callback function that will be triggered when a navigation
  /// tab is pressed by the user.
  const BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.green,
        unselectedItemColor: Colors.black54,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            activeIcon: Icon(Icons.home, size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined, size: 28),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined, size: 28),
            activeIcon: Icon(Icons.fitness_center, size: 28),
            label: '',
          ),
        ],
      ),
    );
  }
}