import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextrade/portfolio_screen.dart';
import 'package:nextrade/profile_screen.dart';
import 'package:nextrade/watchlist_screen.dart';
import 'app_theme.dart';
import 'home.dart';
import 'market_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Market'),
    _NavItem(icon: Icons.pie_chart_outline, activeIcon: Icons.pie_chart_rounded, label: 'Portfolio'),
    _NavItem(icon: Icons.star_border_rounded, activeIcon: Icons.star_rounded, label: 'Watchlist'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  // FIXED: List matches _navItems length and order
  final List<Widget> _screens = const [
    HomeScreen(),
    MarketScreen(),
    PortfolioScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: NexTradeColors.surface,
        border: Border(top: BorderSide(color: NexTradeColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final isActive = _currentIndex == i;

              // Center Portfolio/Trade Button Styling
              if (i == 2) {
                return GestureDetector(
                  onTap: () => _onNavTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: isActive ? NexTradeColors.primaryGradient : null,
                          color: isActive ? null : NexTradeColors.surfaceHighlight,
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                            BoxShadow(
                              color: NexTradeColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                              : null,
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? NexTradeColors.background : NexTradeColors.textMuted,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isActive ? NexTradeColors.primary : NexTradeColors.textMuted,
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GestureDetector(
                onTap: () => _onNavTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? NexTradeColors.primaryGlow : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? NexTradeColors.primary : NexTradeColors.textMuted,
                        size: 22,
                      ),
                    ),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? NexTradeColors.primary : NexTradeColors.textMuted,
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}