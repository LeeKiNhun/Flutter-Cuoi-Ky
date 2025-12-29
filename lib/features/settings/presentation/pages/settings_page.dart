import 'package:cuoi_ky/core/utils/app_theme_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/hive/default_categories.dart';
import '../../../auth/state/auth_vm.dart';
import '../../../stats/state/stats_vm.dart';
import '../../../transactions/state/transactions_vm.dart';
import '../../state/settings_vm.dart';
import 'categories_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsVm>();
    final authVm = context.watch<AuthVm>();

    final txVm = context.read<TransactionsVm>();
    final statsVm = context.read<StatsVm>();

    final userEmail = authVm.session?.user.email;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cài đặt'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // ======================
            // ACCOUNT
            // ======================
            CupertinoListSection.insetGrouped(
              header: const Text('Tài khoản'),
              children: [
                CupertinoListTile(
                  title: const Text('Trạng thái'),
                  subtitle: Text(
                    userEmail != null
                        ? 'Đã đăng nhập: $userEmail'
                        : 'Chưa đăng nhập',
                  ),
                ),
                CupertinoListTile(
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                  onTap: () async {
                    final ok = await showCupertinoDialog<bool>(
                      context: context,
                      builder: (dialogContext) => CupertinoAlertDialog(
                        title: const Text('Đăng xuất?'),
                        content: const Text(
                          'Bạn sẽ quay về màn hình đăng nhập.',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Hủy'),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );

                    if (ok == true) {
                      await authVm.logout();
                      // ❗ Không cần Navigator.pop
                      // _AuthGate sẽ tự chuyển về LoginPage
                    }
                  },
                ),
              ],
            ),

            // ======================
            // DATA
            // ======================
            CupertinoListSection.insetGrouped(
              header: const Text('Data'),
              children: [
                // Seed demo
                CupertinoListTile(
                  title: const Text('Seed demo data (>= 20)'),
                  trailing:
                      settingsVm.busy ? const CupertinoActivityIndicator() : null,
                  onTap: settingsVm.busy
                      ? null
                      : () async {
                          await settingsVm.seedDemo(
                            month: DateTime.now(),
                            txVm: txVm,
                            statsVm: statsVm,
                            count: 25,
                          );
                        },
                ),

                // Reset
                CupertinoListTile(
                  title: const Text('Reset data'),
                  trailing:
                      settingsVm.busy ? const CupertinoActivityIndicator() : null,
                  onTap: settingsVm.busy
                      ? null
                      : () async {
                          final ok = await showCupertinoDialog<bool>(
                            context: context,
                            builder: (dialogContext) => CupertinoAlertDialog(
                              title: const Text('Reset tất cả data?'),
                              content: const Text(
                                'Thao tác này sẽ xóa các giao dịch và khôi phục các danh mục mặc định.',
                              ),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Hủy'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text('Reset'),
                                ),
                              ],
                            ),
                          );

                          if (ok == true) {
                            await settingsVm.reset(
                              txVm: txVm,
                              statsVm: statsVm,
                              defaults: defaultCategories,
                            );
                          }
                        },
                ),
              ],
            ),

            // ======================
            // CATEGORIES
            // ======================
            CupertinoListSection.insetGrouped(
              header: const Text('Danh mục'),
              children: [
                CupertinoListTile(
                  title: const Text('Quản lý danh mục'),
                  trailing: const Icon(CupertinoIcons.chevron_forward),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const CategoriesPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
            header: const Text('Giao diện'),
            children: [
              CupertinoListTile(
                title: const Text('Theme'),
                subtitle: Text(settingsVm.themeMode.label),
                trailing: CupertinoSlidingSegmentedControl<AppThemeMode>(
                  groupValue: settingsVm.themeMode,
                  children: const {
                    AppThemeMode.system: Text('System'),
                    AppThemeMode.light: Text('Light'),
                    AppThemeMode.dark: Text('Dark'),
                  },
                  onValueChanged: (v) {
                    if (v != null) settingsVm.setThemeMode(v);
                  },
                ),
              ),
            ],
          ),

            // ======================
            // ABOUT
            // ======================
            CupertinoListSection.insetGrouped(
              header: const Text('About'),
              children: const [
                CupertinoListTile(
                  title: Text('MoneyTrack MVP'),
                  subtitle: Text('Offline • Hive • Cupertino • ReqRes Auth'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
