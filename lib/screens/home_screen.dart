import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: const [
          SearchScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: themeProvider.textColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '搜索',
              backgroundColor: themeProvider.backgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '设置',
              backgroundColor: themeProvider.backgroundColor,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: themeProvider.accentColor,
          unselectedItemColor: themeProvider.textColor.withOpacity(0.5),
          backgroundColor: themeProvider.backgroundColor,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
} 