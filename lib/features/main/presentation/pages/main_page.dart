import 'package:flutter/material.dart';
import '../../../friends/presentation/pages/friends_page.dart';
import '../../../chat/presentation/pages/chat_list_page.dart';
import '../widgets/camera_history_page.dart';

/// Main page uses PageView like Locket:
/// Horizontal: Friends ← Camera → Messages
/// Vertical (on Camera): swipe DOWN → History
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final PageController _pageController;
  int _currentPage = 1; // Start at Camera (center)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Horizontal swipe: Friends ←→ Camera+History ←→ Messages
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: const [
              // Page 0: Friends (swipe left)
              FriendsPage(),
              // Page 1: Camera (top) + History (swipe down)
              CameraHistoryPage(),
              // Page 2: Messages (swipe right)
              ChatListPage(),
            ],
          ),

          // Page indicator dots at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
