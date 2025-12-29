import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/category_entity.dart';
import '../../../../data/repositories/category_repository.dart';

class TxFilterResult {
  final int type; // -1 all, 0 expense, 1 income
  final String? categoryId; // null = all
  const TxFilterResult({required this.type, required this.categoryId});
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.initialType,
    required this.initialCategoryId,
  });

  final int initialType;
  final String? initialCategoryId;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late int _type;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _categoryId = widget.initialCategoryId;
  }

  List<CategoryEntity> _categoriesForCurrentType(CategoryRepository repo) {
    // Nếu All type => không cho chọn category (đơn giản)
    if (_type == -1) return const [];
    return repo.getByType(_type);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CategoryRepository>();
    final cats = _categoriesForCurrentType(repo);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Bộ lọc'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pop(
              TxFilterResult(type: _type, categoryId: _categoryId),
            );
          },
          child: const Text('Áp dụng'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Loại'),
              children: [
                CupertinoListTile(
                  title: const Text('Tất cả'),
                  trailing: _type == -1
                      ? const Icon(CupertinoIcons.check_mark)
                      : null,
                  onTap: () => setState(() {
                    _type = -1;
                    _categoryId = null; // reset category when All
                  }),
                ),
                CupertinoListTile(
                  title: const Text('Chi'),
                  trailing: _type == 0
                      ? const Icon(CupertinoIcons.check_mark)
                      : null,
                  onTap: () => setState(() {
                    _type = 0;
                    // giữ category nếu vẫn hợp lệ, không thì reset
                    if (_categoryId != null &&
                        !repo.getByType(0).any((c) => c.id == _categoryId)) {
                      _categoryId = null;
                    }
                  }),
                ),
                CupertinoListTile(
                  title: const Text('Thu'),
                  trailing: _type == 1
                      ? const Icon(CupertinoIcons.check_mark)
                      : null,
                  onTap: () => setState(() {
                    _type = 1;
                    if (_categoryId != null &&
                        !repo.getByType(1).any((c) => c.id == _categoryId)) {
                      _categoryId = null;
                    }
                  }),
                ),
              ],
            ),

            CupertinoListSection.insetGrouped(
              header: const Text('Danh mục'),
              children: [
                CupertinoListTile(
                  title: Text(_type == -1 ? 'Tất cả (Chọn loại trước)' : 'Tất cả danh mục'),
                  trailing: (_type != -1 && _categoryId == null)
                      ? const Icon(CupertinoIcons.check_mark)
                      : null,
                  onTap: _type == -1
                      ? null
                      : () => setState(() => _categoryId = null),
                ),
                if (_type != -1)
                  ...cats.map((c) {
                    final selected = _categoryId == c.id;
                    return CupertinoListTile(
                      leading: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(c.colorValue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          IconData(c.iconCode, fontFamily: 'CupertinoIcons'),
                          size: 16,
                          color: CupertinoColors.white,
                        ),
                      ),
                      title: Text(c.name),
                      trailing:
                          selected ? const Icon(CupertinoIcons.check_mark) : null,
                      onTap: () => setState(() => _categoryId = c.id),
                    );
                  }),
              ],
            ),

            const SizedBox(height: 6),

            CupertinoButton(
              color: CupertinoColors.systemGrey5,
              onPressed: () {
                setState(() {
                  _type = -1;
                  _categoryId = null;
                });
              },
              child: const Text('Xoá bộ lọc'),
            ),
          ],
        ),
      ),
    );
  }
}
