/*
 * File: home_screen.dart
 * Feature : Individual Feature
 * Description: The main dashboard screen displaying available timer modes.
 *
 * Responsibilities:
 * - Display primary navigation options
 * - Show summary information fetched from the backend
 * - Handle mode selection and navigation to session screens
 * - Manage bottom navigation state
 *
 * Dependencies:
 * - ModeCard
 * - BottomNavBar
 * - TimerBadge
 * - NotificationBell
 * - AppColors
 * - TimerService
 * - NotificationService
 * - SessionScreen
 * - AnalysisScreen
 * - StretchLibraryScreen
 *
 * Author: <Chaiwet Ketmuangmul / Paracetamol>
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import '../widgets/mode_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/timer_badge.dart';
import '../widgets/notification_bell.dart';
import '../utils/colors.dart';
import '../services/timer_service.dart';
import '../services/notification_service.dart';
import 'session_screen.dart';
import 'analysis_screen.dart';
import 'stretch_library_screen.dart';

/// The [HomeScreen] class represents the main dashboard screen for the application.
///
/// Fields:
/// - timerService: The global timer service instance
///
/// Usage:
/// - Display primary navigation options
/// - Show summary information and mode selection
/// - Handle mode selection and navigation to session screens
/// - Manage bottom navigation state
class HomeScreen extends StatefulWidget {
  /// The global service managing the application timer.
  final TimerService timerService;

  /// Creates a [HomeScreen] with the specified timer service.
  ///
  /// The [timerService] provides access to the global timer management system
  /// for displaying timer status, handling mode selection, and coordinating
  /// navigation to session screens.
  const HomeScreen({required this.timerService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resets to the home index when returning to this screen.
    setState(() {
      _currentIndex = 0;
    });
  }

  void _onNavTap(int index) {
    if (index == 0) {
      // Skips navigation because we are already on the home screen.
      return;
    }
    setState(() => _currentIndex = index);
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AnalysisScreen(),
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
                      child: TimerBadge(timerService: widget.timerService),
                    ),
                  ),
                  NotificationBell(),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      // Title
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Choose your mode',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 30),
                      // Mode Cards
                      ModeCard(
                        icon: Icons.menu_book,
                        title: 'Study Mode',
                        subtitle: 'Focus on your studies',
                        color: Color(0xFFE1BEE7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionScreen(
                                mode: 'Study Mode',
                                emoji: '📚',
                                defaultMinutes: 90,
                                dialogColor: Color(0xFFE1BEE7), 
                                notificationMessage: 'พักสายตาหน่อย! อ่านหนังสือมา 90 นาทีแล้ว',
                                exercises: ['Eye Rest', 'Neck Stretch'],
                                hasSound: true,
                                hasVibration: true,
                                timerService: widget.timerService,
                              ),
                            ),
                          );
                        },
                      ),
                      ModeCard(
                        icon: Icons.work_outline,
                        title: 'Work Mode',
                        subtitle: 'Stay productive at work',
                        color: Color(0xFFC8E6C9),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionScreen(
                                mode: 'Work Mode',
                                emoji: '💼',
                                defaultMinutes: 60,
                                dialogColor: Color(0xFFC8E6C9), 
                                notificationMessage: 'เวลาบริหาร! ทำงานมา 60 นาทีแล้ว',
                                exercises: ['Shoulder Relief', 'Wrist Rotation'],
                                hasSound: true,
                                hasVibration: true,
                                timerService: widget.timerService,
                              ),
                            ),
                          );
                        },
                      ),
                      ModeCard(
                        icon: Icons.laptop_mac,
                        title: 'Meeting Mode',
                        subtitle: 'Silent reminders during meetings',
                        color: Color(0xFF90A4AE),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionScreen(
                                mode: 'Meeting Mode',
                                emoji: '💻',
                                defaultMinutes: 60,
                                dialogColor: Color(0xFF424242), 
                                notificationMessage: 'Quick stretch reminder (Silent)',
                                exercises: ['Shoulder Blade Squeeze', 'Hand Stretch', 'Ankle Rotations'],
                                hasSound: false,
                                hasVibration: true,
                                isSilent: true,
                                timerService: widget.timerService,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                      // Reminder Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.green,
                              AppColors.green.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.notifications_active,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Stay active, stay healthy!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
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
}