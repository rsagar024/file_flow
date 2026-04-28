import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/features/home/presentation/screens/home_screen.dart';
import 'package:fileflow/features/upload/presentation/screens/upload_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends FileFlowBackgroundState<DashboardScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ValueNotifier _currentIndex = ValueNotifier(0);
  late AnimationController _controller;
  bool isLoading = false;

  static const _activeColor = Color(0xFF0062FF);
  static const _inactiveColor = Color(0xFF9A9AB0);

  @override
  void onInit() {
    super.onInit();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void onDispose() {
    _pageController.dispose();
    super.onDispose();
  }

  void _onTapNav(int index) {
    if (index == _currentIndex.value) return;
    _currentIndex.value = index;
    _pageController.jumpToPage(index);
  }

  void startLoading() {
    setState(() => isLoading = true);
    _controller.repeat();
  }

  void stopLoading() {
    setState(() => isLoading = false);
    _controller.stop();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _pageController,
        // onPageChanged: _onTapNav,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeScreen(),
          Center(
            child: Text('Sharing', style: TextStyle(color: Colors.white)),
          ),
          UploadScreen(),
          Center(
            child: Text('Coming Soon', style: TextStyle(color: Colors.white)),
          ),
          Center(
            child: Text('Profile', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          _onTapNav(2);
          startLoading();
          await Future.delayed(const Duration(seconds: 20));
          stopLoading();
        },
        child: SizedBox(
          height: 70,
          width: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isLoading)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, _) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * 3.1416,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.red,
                              Colors.orange,
                              Colors.yellow,
                              Colors.green,
                              Colors.blue,
                              Colors.indigo,
                              Colors.purple,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              Container(
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0062FF)),
              ),
              const Icon(Icons.upload_sharp, color: Colors.white),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(top: 10),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        elevation: 10,
        color: Colors.white12,
        height: 58,
        child: Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ValueListenableBuilder(
            valueListenable: _currentIndex,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    index: 0,
                    selectedIndex: value,
                    activeColor: _activeColor,
                    inactiveColor: _inactiveColor,
                    onTap: _onTapNav,
                    label: 'Home',
                  ),
                  _NavItem(
                    icon: Icons.people_alt,
                    index: 1,
                    selectedIndex: value,
                    activeColor: _activeColor,
                    inactiveColor: _inactiveColor,
                    onTap: _onTapNav,
                    label: 'Sharing',
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    index: 2,
                    selectedIndex: value,
                    activeColor: Colors.transparent,
                    inactiveColor: Colors.transparent,
                    onTap: (value) {},
                    label: '',
                  ),
                  _NavItem(
                    icon: Icons.settings,
                    index: 3,
                    selectedIndex: value,
                    activeColor: _activeColor,
                    inactiveColor: _inactiveColor,
                    onTap: _onTapNav,
                    label: 'Coming',
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    index: 4,
                    selectedIndex: value,
                    activeColor: _activeColor,
                    inactiveColor: _inactiveColor,
                    onTap: _onTapNav,
                    label: 'Profile',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onTap;
  final String label;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    required this.label,
  });

  bool get _isSelected => index == selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _isSelected ? activeColor : inactiveColor, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: _isSelected ? FontWeight.w500 : FontWeight.w400,
                color: _isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
