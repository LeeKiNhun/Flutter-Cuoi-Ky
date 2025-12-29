import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/hive/default_categories.dart';
import '../../../stats/state/stats_vm.dart';
import '../../../transactions/state/transactions_vm.dart';
import '../../state/settings_vm.dart';
import 'categories_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsVm>();
    final txVm = context.read<TransactionsVm>();
    final statsVm = context.read<StatsVm>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Cài đặt'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Data'),
              children: [
                // ✅ Seed demo
                CupertinoListTile(
                  title: const Text('Seed demo data (>= 20)'),
                  trailing: vm.busy ? const CupertinoActivityIndicator() : null,
                  onTap: vm.busy
                      ? null
                      : () async {
                          await vm.seedDemo(
                            month: DateTime.now(),
                            txVm: txVm,
                            statsVm: statsVm,
                            count: 25,
                          );
                        },
                ),

                // ✅ Reset
                CupertinoListTile(
                  title: const Text('Reset data'),
                  trailing: vm.busy ? const CupertinoActivityIndicator() : null,
                  onTap: vm.busy
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
                            await vm.reset(
                              txVm: txVm,
                              statsVm: statsVm,
                              defaults: defaultCategories, // ✅ defaults chuẩn
                            );
                          }
                        },
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Danh mục'),
              children: [
                CupertinoListTile(
                  title: const Text('Quản lý danh mục'),
                  trailing: const Icon(CupertinoIcons.chevron_forward),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (_) => const CategoriesPage()),
                    );
                  },
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('About'),
              children: const [
                CupertinoListTile(
                  title: Text('MoneyTrack MVP'),
                  subtitle: Text('Offline • Hive • Cupertino'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
