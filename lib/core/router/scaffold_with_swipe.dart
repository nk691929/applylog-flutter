import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithSwipe extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const ScaffoldWithSwipe({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  State<ScaffoldWithSwipe> createState() => _ScaffoldWithSwipeState();
}

class _ScaffoldWithSwipeState extends State<ScaffoldWithSwipe> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != oldWidget.navigationShell.currentIndex) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != widget.navigationShell.currentIndex) {
        _pageController.animateToPage(
          widget.navigationShell.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        children: widget.children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => widget.navigationShell.goBranch(index),
        items: const [
          BottomNavigationBarItem(
            label: "Dashboard",
            icon: Icon(Icons.dashboard),
          ),
          BottomNavigationBarItem(
            label: "Applications",
            icon: Icon(Icons.list),
          ),
          BottomNavigationBarItem(
            label: "Settings",
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}