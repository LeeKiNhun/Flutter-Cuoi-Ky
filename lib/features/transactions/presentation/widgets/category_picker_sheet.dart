import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/category_entity.dart';
import '../../../settings/state/categories_vm.dart';

class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet({
    super.key,
    required this.type,
    required this.onSelected,
  });

  final int type; // 0 expense, 1 income
  final ValueChanged<CategoryEntity> onSelected;

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesVm>().loadByType(widget.type);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriesVm>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Select Category')),
      child: SafeArea(
        child: vm.items.isEmpty
            ? const Center(
                child: Text(
                  'No categories found.',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              )
            : ListView.builder(
                itemCount: vm.items.length,
                itemBuilder: (context, index) {
                  final c = vm.items[index];
                  return CupertinoListTile(
                    title: Text(c.name),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c.colorValue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        IconData(c.iconCode, fontFamily: 'CupertinoIcons'),
                        size: 18,
                        color: CupertinoColors.white,
                      ),
                    ),
                    onTap: () {
                      widget.onSelected(c);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
      ),
    );
  }
}
