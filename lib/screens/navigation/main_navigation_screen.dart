import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../attendance/my_attendance_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../leaves/leaves_screen.dart';
import '../profile/profile_screen.dart';

/// Shared authenticated shell with bottom navigation.
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 3).toInt();
    _pages = [
      DashboardScreen(onTabChangeRequested: _switchTab),
      const LeavesScreen(),
      const MyAttendanceScreen(),
      const ProfileScreen(),
    ];
  }

  void _switchTab(int index) {
    if (index < 0 || index > 3) return;
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openScanQr() {
    Navigator.of(context).pushNamed('/scan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        height: 90,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A0F172A),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'Home',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.event_busy_outlined,
                      activeIcon: Icons.event_busy,
                      label: 'Leave',
                      index: 1,
                    ),
                    const SizedBox(width: 64),
                    _buildNavItem(
                      icon: Icons.history_edu_outlined,
                      activeIcon: Icons.history_edu,
                      label: 'Attendance',
                      index: 2,
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -2,
              child: Center(
                child: GestureDetector(
                  onTap: _openScanQr,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x44F04129),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Scan QR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;
    final color = isActive ? AppTheme.primary : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _switchTab(index),
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isActive ? activeIcon : icon, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
