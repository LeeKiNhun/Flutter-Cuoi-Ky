import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/category_entity.dart';
import '../../state/categories_vm.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _type = 0; // 0 expense, 1 income

  // Palette màu preset (dễ nhìn, hợp iOS)
  static const List<int> _palette = [
    0xFF007AFF, // iOS blue
    0xFF34C759, // iOS green
    0xFFFF3B30, // iOS red
    0xFFFF9500, // iOS orange
    0xFFFFCC00, // iOS yellow
    0xFFAF52DE, // iOS purple
    0xFF5AC8FA, // iOS teal
    0xFF8E8E93, // iOS gray
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesVm>().loadByType(_type);
    });
  }

  Future<void> _addCategory(BuildContext context) async {
    final nameCtrl = TextEditingController();
    int selectedColor = _palette.first;
    final uuid = const Uuid();

    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        // Dùng StatefulBuilder để cập nhật UI trong dialog (preview/tick)
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            final name = nameCtrl.text.trim();
            final canAdd = name.isNotEmpty;

            return CupertinoAlertDialog(
              title: const Text('Thêm danh mục'),
              content: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    // Preview row
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Color(selectedColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.tag,
                            size: 18,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name.isEmpty ? 'Preview' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    CupertinoTextField(
                      controller: nameCtrl,
                      placeholder: 'Tên danh mục',
                      onChanged: (_) => setLocalState(() {}),
                    ),
                    const SizedBox(height: 12),

                    // Color palette (grid)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Màu sắc',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey.resolveFrom(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ColorGrid(
                      colors: _palette,
                      selected: selectedColor,
                      onSelect: (c) => setLocalState(() => selectedColor = c),
                    ),
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Hủy'),
                ),
                CupertinoDialogAction(
                  onPressed: canAdd ? () => Navigator.of(dialogContext).pop(true) : null,
                  child: Text(
                    'Thêm',
                    style: TextStyle(
                      color: canAdd
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    final c = CategoryEntity(
      id: uuid.v4(),
      type: _type,
      name: name,
      iconCode: CupertinoIcons.tag.codePoint, // MVP preset icon
      colorValue: selectedColor,
    );

    await context.read<CategoriesVm>().add(c);
  }

  Future<void> _deleteCategory(BuildContext context, CategoryEntity c) async {
    final vm = context.read<CategoriesVm>();

    // 1) Block delete if used
    if (!vm.canDelete(c.id)) {
      await showCupertinoDialog(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Không thể xóa'),
          content: const Text('Danh mục đang được sử dụng.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 2) Confirm
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text('Xóa "${c.name}"?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await vm.delete(c.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoriesVm>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Danh mục'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _addCategory(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _type,
                children: const {
                  0: Text('Chi'),
                  1: Text('Thu'),
                },
                onValueChanged: (v) {
                  if (v == null) return;
                  setState(() => _type = v);
                  context.read<CategoriesVm>().loadByType(v);
                },
              ),
            ),
            Expanded(
              child: vm.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Không tìm thấy danh mục nào.',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: vm.items.length,
                      separatorBuilder: (_, __) => Container(
                        height: 0.5,
                        color: CupertinoColors.systemGrey4.withOpacity(0.6),
                      ),
                      itemBuilder: (context, index) {
                        final c = vm.items[index];
                        return CupertinoListTile(
                          leading: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(c.colorValue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              IconData(c.iconCode, fontFamily: 'CupertinoIcons'),
                              size: 18,
                              color: CupertinoColors.white,
                            ),
                          ),
                          title: Text(c.name),
                          trailing: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _deleteCategory(context, c),
                            child: const Icon(
                              CupertinoIcons.delete,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  final List<int> colors;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    // 4 cột nhìn đẹp trong dialog
    const cols = 4;
    final rows = (colors.length / cols).ceil();

    return Column(
      children: List.generate(rows, (r) {
        final start = r * cols;
        final end = (start + cols).clamp(0, colors.length);
        final rowColors = colors.sublist(start, end);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowColors.map((c) {
              final isSelected = c == selected;

              return GestureDetector(
                onTap: () => onSelect(c),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Color(c),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? CupertinoColors.black.withOpacity(0.35)
                          : CupertinoColors.white.withOpacity(0.0),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          size: 16,
                          color: CupertinoColors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
