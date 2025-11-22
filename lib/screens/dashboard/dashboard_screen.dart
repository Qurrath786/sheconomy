// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

import '../wallet/wallet_screen.dart';
import '../tools/tools_screen.dart';
import '../learn/learn_screen.dart';
import '../insights/insights_screen.dart';
import '../stocks/stocks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    WalletScreen(),
    ToolsScreen(),
    LearnScreen(),
    InsightsScreen(),
    StocksScreen(),
  ];

  final List<String> _titles = const [
    'Wallet',
    'Financial Tools',
    'Learn Hub',
    'Insights',
    'Stocks',
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            extended: isWide,
            labelType: isWide ? null : NavigationRailLabelType.all,
            backgroundColor: Colors.white,

            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/sheconomy_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isWide)
                    const Text(
                      'SHEconomy',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                ],
              ),
            ),

            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet),
                label: Text('Wallet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: Text('Tools'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: Text('Learn'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: Text('Insights'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.show_chart_outlined),
                selectedIcon: Icon(Icons.show_chart),
                label: Text('Stocks'),
              ),
            ],
          ),

          const VerticalDivider(width: 1),

          Expanded(
            child: Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              appBar: AppBar(
                title: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                centerTitle: true,
              ),
              body: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
