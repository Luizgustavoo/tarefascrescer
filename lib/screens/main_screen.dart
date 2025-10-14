import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'finished_orders_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/add_project_modal.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(key: _homeScreenKey),
      const Center(child: Text('Página de Agendados')),
      const FinishedOrdersScreen(),
      const Center(child: Text('Página de Pessoas')),
    ];
  }

  void _onItemTapped(int visualIndex) {
    if (visualIndex == 2) return;

    int pageIndex = visualIndex > 2 ? visualIndex - 1 : visualIndex;
    setState(() {
      _pageIndex = pageIndex;
    });
  }

  void _showAddProjectModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: const Color(0xFFF8F8FA),
          child: AddProjectModal(
            onProjectSaved: (newProject) {
              _homeScreenKey.currentState?.addProject(newProject);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int visualIndex = _pageIndex >= 2 ? _pageIndex + 1 : _pageIndex;

    return Scaffold(
      body: IndexedStack(index: _pageIndex, children: _pages),

      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddProjectModal(context);
              },
              backgroundColor: const Color(0XFFD932CE),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,

      floatingActionButtonLocation: _pageIndex == 0
          ? FloatingActionButtonLocation.centerDocked
          : null,
      bottomNavigationBar: BottomNavBar(
        visualCurrentIndex: visualIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
