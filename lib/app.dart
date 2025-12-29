import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'data/remote/services/transaction_api.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/sync_repository.dart';
import 'data/repositories/transaction_repository.dart';

import 'features/settings/presentation/pages/settings_page.dart';
import 'features/settings/state/categories_vm.dart';
import 'features/settings/state/settings_vm.dart';
import 'features/stats/presentation/pages/monthly_stats_page.dart';
import 'features/stats/state/stats_vm.dart';
import 'features/transactions/presentation/pages/transactions_home_page.dart';
import 'features/transactions/state/transactions_vm.dart';

class MoneyTrackApp extends StatelessWidget {
  const MoneyTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ===== Local repositories (Hive) =====
        Provider(create: (_) => TransactionRepository()),
        Provider(create: (_) => CategoryRepository()),
        Provider(create: (_) => SettingsRepository()),

        // ===== Network + Sync (MUST be before VMs that read them) =====
        Provider(create: (_) => ApiClient(baseUrl: 'http://localhost:3000')),
        Provider(create: (_) => NetworkInfo()),
        Provider(create: (ctx) => TransactionApi(ctx.read<ApiClient>())),
        Provider(
          create: (ctx) => SyncRepository(
            networkInfo: ctx.read<NetworkInfo>(),
            api: ctx.read<TransactionApi>(),
            localRepo: ctx.read<TransactionRepository>(),
          ),
        ),

        // ===== ViewModels =====
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
      child: const CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'MoneyTrack',
        home: _RootTabs(),
      ),
    );
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
