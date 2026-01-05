import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/utils/app_theme_mode.dart';

import 'data/repositories/transaction_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/sync_repository.dart';

import 'data/remote/services/transaction_api.dart';

// ===== AI =====
import 'data/remote/services/ai_api.dart';
import 'data/repositories/ai_repository.dart';
import 'features/ai/ai_vm.dart';

// ===== Auth =====
import 'data/remote/services/auth_api.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/state/auth_vm.dart';

// ===== Features =====
import 'features/transactions/presentation/pages/transactions_home_page.dart';
import 'features/transactions/state/transactions_vm.dart';

import 'features/stats/presentation/pages/monthly_stats_page.dart';
import 'features/stats/state/stats_vm.dart';

import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/state/categories_vm.dart';
import 'features/settings/state/settings_vm.dart';

class MoneyTrackApp extends StatelessWidget {
  const MoneyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ baseUrl chạy được cả Web + Android emulator
    // - Web: localhost
    // - Android emulator: 10.0.2.2
    // - iOS simulator: localhost (OK)
    final baseUrl = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

    return MultiProvider(
      providers: [
        // ===== Local repositories (Hive) =====
        Provider(create: (_) => TransactionRepository()),
        Provider(create: (_) => CategoryRepository()),
        Provider(create: (_) => SettingsRepository()),

        // ===== Auth local (Hive session) =====
        Provider(create: (_) => AuthRepository()),

        // ===== Network =====
        Provider(create: (_) => ApiClient(baseUrl: baseUrl)),
        Provider(create: (_) => NetworkInfo(Connectivity())),

        // ===== Remote services =====
        Provider(create: (_) => AuthApi()),
        Provider(create: (ctx) => TransactionApi(ctx.read<ApiClient>())),
        Provider(create: (ctx) => AiApi(ctx.read<ApiClient>())),

        // ===== Sync =====
        Provider(
          create: (ctx) => SyncRepository(
            networkInfo: ctx.read<NetworkInfo>(),
            api: ctx.read<TransactionApi>(),
            localRepo: ctx.read<TransactionRepository>(),
          ),
        ),

        // ===== AI =====
        Provider(create: (ctx) => AiRepository(ctx.read<AiApi>())),
        ChangeNotifierProvider(create: (ctx) => AiVm(ctx.read<AiRepository>())),

        // ===== ViewModels =====
        ChangeNotifierProvider(
          create: (ctx) => AuthVm(
            authRepo: ctx.read<AuthRepository>(),
            authApi: ctx.read<AuthApi>(),
          )..init(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TransactionsVm(
            ctx.read<TransactionRepository>(),
            ctx.read<SyncRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => StatsVm(ctx.read<TransactionRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CategoriesVm(ctx.read<CategoryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => SettingsVm(
            ctx.read<SettingsRepository>(),
            ctx.read<CategoryRepository>(),
          ),
        ),
      ],
      child: Consumer<SettingsVm>(
        builder: (context, settingsVm, _) {
          final brightness = settingsVm.themeMode.toBrightness(); // null => system

          return CupertinoApp(
            debugShowCheckedModeBanner: false,
            title: 'MoneyTrack',
            theme: CupertinoThemeData(brightness: brightness),
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

/// Nếu đã login -> vào tabs
/// Chưa login -> LoginPage
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthVm>();

    if (authVm.status == AuthStatus.loading ||
        authVm.status == AuthStatus.unknown) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (authVm.status == AuthStatus.authenticated) {
      return const _RootTabs();
    }

    return const LoginPage();
  }
}

class _RootTabs extends StatelessWidget {
  const _RootTabs();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: 'Cài đặt',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (_) {
            switch (index) {
              case 0:
                return const TransactionsHomePage();
              case 1:
                return const MonthlyStatsPage();
              case 2:
                return const SettingsPage();
              default:
                return const TransactionsHomePage();
            }
          },
        );
      },
    );
  }
}
