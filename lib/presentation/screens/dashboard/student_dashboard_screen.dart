// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const DashboardShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use SafeArea so content doesn't clash with system UI
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 720;

            // When wide: show NavigationRail on left + content to the right
            if (isWide) {
              return Row(
                children: [
                  // Left rail
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _onTap,
                    labelType: NavigationRailLabelType.selected,
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: CircleAvatar(
                        radius: 20,
                        // TODO: replace with user's avatar
                        child: Icon(Icons.person),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.video_library_outlined),
                        selectedIcon: Icon(Icons.video_library),
                        label: Text('Video'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.picture_as_pdf_outlined),
                        selectedIcon: Icon(Icons.picture_as_pdf),
                        label: Text('Notes'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.quiz_outlined),
                        selectedIcon: Icon(Icons.quiz),
                        label: Text('Test'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profile'),
                      ),
                    ],
                  ),

                  // Content (keeps GoRouter's shell widget)
                  const VerticalDivider(width: 1),
                  Expanded(child: navigationShell),
                ],
              );
            }

            // Narrow screens: body is the navigationShell, with a bottom NavigationBar
            return Scaffold(
              body: navigationShell,
              // center FAB above bottom nav for primary action
              // floatingActionButton: FloatingActionButton(
              //   onPressed: () {
              //     // Example: go to "Create note" or open modal
              //     // Replace with appropriate branch action or route:
              //     // navigationShell.goBranch(1);
              //     // or navigate with GoRouter: GoRouter.of(context).push('/notes/create');
              //   },
              //   tooltip: 'Create',
              //   child: const Icon(Icons.add),
              // ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: _buildBottomNav(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    // Material 3 NavigationBar for a modern look
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        // Customize indicator shape & height if you want
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        height: 66,
      ),
      child: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Video',
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Test',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
