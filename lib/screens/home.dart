import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';
import 'activity.dart';
import 'customers.dart';
import 'dashboard.dart';
import 'settings.dart';

// Shown while the local database opens/seeds.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ýazdyr',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Text(l.t('splashTagline'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
            const SizedBox(height: 22),
            const _PulsingDots(),
            const SizedBox(height: 14),
            Text(l.t('loadingDb'),
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (_c.value + i * 0.2) % 1.0;
          final opacity = 0.25 + 0.75 * (1 - (phase * 2 - 1).abs());
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentOf(context).withValues(alpha: opacity),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  // Visited-tab stack so the system back gesture returns to the previous tab
  // instead of quitting; empty stack means back exits the app.
  final List<int> _history = [];

  @override
  Widget build(BuildContext context) {
    final l = LedgerScope.of(context);
    final tabs = const [
      DashboardScreen(),
      CustomersScreen(),
      ActivityScreen(),
      SettingsScreen(),
    ];
    return PopScope(
      canPop: _history.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _history.isEmpty) return;
        setState(() => _index = _history.removeLast());
      },
      child: Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: tabs)),
      // Keep nav labels on one line regardless of language/system font scale;
      // NavigationBar's label Text inherits softWrap/maxLines from DefaultTextStyle.
      bottomNavigationBar: DefaultTextStyle.merge(
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: goToTab,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: l.t('navDashboard')),
          NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l.t('navCustomers')),
          NavigationDestination(
              icon: const Icon(Icons.show_chart),
              label: l.t('navActivity')),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: l.t('navSettings')),
        ],
        ),
      ),
      ),
    );
  }

  // Lets child screens jump to a tab (e.g. dashboard quick actions), recording
  // the current tab so back returns here.
  void goToTab(int i) {
    if (i == _index) return;
    setState(() {
      _history.remove(i); // keep one entry per tab; avoid unbounded growth
      _history.add(_index);
      _index = i;
    });
  }
}

// Helper so any descendant can switch the primary tab (0..3).
void switchToTab(BuildContext context, int index) {
  context.findAncestorStateOfType<_HomeShellState>()?.goToTab(index);
}
