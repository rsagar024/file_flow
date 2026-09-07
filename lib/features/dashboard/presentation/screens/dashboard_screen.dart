import 'package:fileflow/core/common/base/presentation/file_flow_background_stateful_widget.dart';
import 'package:fileflow/core/enums/app_state/app_status.dart';
import 'package:fileflow/core/extensions/build_context_theme_extension.dart';
import 'package:fileflow/core/resources/common/string_constants.dart';
import 'package:fileflow/core/themes/app_colors.dart';
import 'package:fileflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fileflow/features/auth/presentation/screens/login_screen.dart';
import 'package:fileflow/features/home/presentation/screens/home_screen.dart';
import 'package:fileflow/features/profile/presentation/screens/profile_screen.dart';
import 'package:fileflow/features/upload/presentation/screens/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends FileFlowBackgroundStatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends FileFlowBackgroundState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ValueNotifier _currentIndex = ValueNotifier(0);
  late AnimationController _controller;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
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
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthAppStatus.unAuthenticated) {
          context.go(LoginScreen.routeName);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: PageView(
          controller: _pageController,
          // onPageChanged: _onTapNav,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const HomeScreen(),
            Center(
              child: Text('Sharing', style: TextStyle(color: context.colors.textPrimary)),
            ),
            const UploadScreen(),
            Center(
              child: Text(
                'Coming Soon',
                style: TextStyle(color: context.colors.textPrimary),
              ),
            ),
            const ProfileScreen(),
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
                                AppColors.red,
                                AppColors.orange,
                                AppColors.yellow,
                                AppColors.green,
                                AppColors.blue,
                                AppColors.indigo,
                                AppColors.purple,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
                Icon(Icons.upload_sharp, color: context.colors.textPrimary),
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
          color: context.colors.surfaceVariant,
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
                      activeColor: AppColors.primary,
                      inactiveColor: context.colors.inactive,
                      onTap: _onTapNav,
                      label: StringConstants.kHome,
                    ),
                    _NavItem(
                      icon: Icons.people_alt,
                      index: 1,
                      selectedIndex: value,
                      activeColor: AppColors.primary,
                      inactiveColor: context.colors.inactive,
                      onTap: _onTapNav,
                      label: StringConstants.kSharing,
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      index: 2,
                      selectedIndex: value,
                      activeColor: AppColors.transparent,
                      inactiveColor: AppColors.transparent,
                      onTap: (value) {},
                      label: '',
                    ),
                    _NavItem(
                      icon: Icons.settings,
                      index: 3,
                      selectedIndex: value,
                      activeColor: AppColors.primary,
                      inactiveColor: context.colors.inactive,
                      onTap: _onTapNav,
                      label: StringConstants.kComing,
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      index: 4,
                      selectedIndex: value,
                      activeColor: AppColors.primary,
                      inactiveColor: context.colors.inactive,
                      onTap: _onTapNav,
                      label: StringConstants.kProfile,
                    ),
                  ],
                );
              },
            ),
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
            Icon(
              icon,
              color: _isSelected ? activeColor : inactiveColor,
              size: 26,
            ),
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
