import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../categories_repository.dart';

const _categoryColors = [
  0xFF5C6BC0,
  0xFF42A5F5,
  0xFF66BB6A,
  0xFFFF7043,
  0xFF26A69A,
  0xFFEC407A,
  0xFFAB47BC,
  0xFFFFA726,
  0xFF78909C,
];

const _categoryIcons = {
  'category': Icons.category_outlined,
  'home': Icons.home_outlined,
  'water': Icons.water_drop_outlined,
  'groceries': Icons.shopping_basket_outlined,
  'restaurant': Icons.restaurant_outlined,
  'transport': Icons.directions_transit_outlined,
  'car': Icons.directions_car_outlined,
  'health': Icons.health_and_safety_outlined,
  'subscriptions': Icons.subscriptions_outlined,
  'entertainment': Icons.movie_outlined,
  'shopping': Icons.shopping_bag_outlined,
  'wine': Icons.wine_bar_outlined,
  'taxes': Icons.receipt_long_outlined,
  'education': Icons.school_outlined,
  'salary': Icons.payments_outlined,
  'bonus': Icons.card_giftcard_outlined,
  'work': Icons.work_outline,
  'investments': Icons.trending_up,
  'income': Icons.add_card_outlined,
};

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editCategory(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: categories.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось загрузить категории: $error'),
          ),
        ),
        data: (items) {
          final expenses = items
              .where((category) => category.type == 'EXPENSE')
              .toList();
          final incomes = items
              .where((category) => category.type == 'INCOME')
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _CategoryGroup(title: 'Расходы', categories: expenses),
              const SizedBox(height: 20),
              _CategoryGroup(title: 'Доходы', categories: incomes),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _editCategory(
  BuildContext context,
  WidgetRef ref, [
  Category? category,
]) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => _CategoryDialog(category: category),
  );
  if (saved == true) ref.invalidate(categoriesProvider);
}

class _CategoryGroup extends ConsumerWidget {
  const _CategoryGroup({required this.title, required this.categories});

  final String title;
  final List<Category> categories;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (categories.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Категорий пока нет.'),
          ),
        )
      else
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < categories.length; index++) ...[
                if (index > 0) const Divider(height: 1, indent: 72),
                _CategoryTile(
                  category: categories[index],
                  onEdit: () => _editCategory(context, ref, categories[index]),
                  onToggleArchive: () async {
                    await ref
                        .read(categoriesRepositoryProvider)
                        .setArchived(
                          categories[index].id,
                          !categories[index].isArchived,
                        );
                    ref.invalidate(categoriesProvider);
                  },
                ),
              ],
            ],
          ),
        ),
    ],
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onToggleArchive,
  });

  final Category category;
  final VoidCallback onEdit;
  final Future<void> Function() onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.14),
        foregroundColor: color,
        child: Icon(_categoryIcons[category.icon] ?? Icons.category_outlined),
      ),
      title: Text(category.name),
      subtitle: category.isArchived ? const Text('В архиве') : null,
      trailing: PopupMenuButton<String>(
        tooltip: 'Действия с категорией',
        onSelected: (action) async {
          try {
            if (action == 'edit') {
              onEdit();
            } else {
              await onToggleArchive();
            }
          } catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Не удалось изменить категорию: $error'),
                ),
              );
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Изменить')),
          PopupMenuItem(
            value: 'archive',
            child: Text(category.isArchived ? 'Восстановить' : 'В архив'),
          ),
        ],
      ),
    );
  }
}

class _CategoryDialog extends ConsumerStatefulWidget {
  const _CategoryDialog({this.category});

  final Category? category;

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  late final TextEditingController _name;
  late String _type;
  late String _icon;
  late int _color;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _name = TextEditingController(text: category?.name ?? '');
    _type = category?.type ?? 'EXPENSE';
    _icon = _categoryIcons.containsKey(category?.icon)
        ? category!.icon
        : 'category';
    _color = category?.color ?? _categoryColors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.category == null ? 'Новая категория' : 'Категория'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Тип'),
            items: const [
              DropdownMenuItem(value: 'EXPENSE', child: Text('Расход')),
              DropdownMenuItem(value: 'INCOME', child: Text('Доход')),
            ],
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) setState(() => _type = value);
                  },
          ),
          const SizedBox(height: 16),
          Text('Значок', style: Theme.of(context).textTheme.labelLarge),
          Wrap(
            spacing: 4,
            children: [
              for (final entry in _categoryIcons.entries)
                IconButton(
                  tooltip: entry.key,
                  onPressed: _saving
                      ? null
                      : () => setState(() => _icon = entry.key),
                  isSelected: _icon == entry.key,
                  icon: Icon(entry.value),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Цвет', style: Theme.of(context).textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: [
              for (final color in _categoryColors)
                IconButton(
                  tooltip: 'Выбрать цвет',
                  onPressed: _saving
                      ? null
                      : () => setState(() => _color = color),
                  icon: CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(color),
                    child: _color == color
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context, false),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Сохранить'),
      ),
    ],
  );

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Укажите название категории');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = ref.read(categoriesRepositoryProvider);
      final category = widget.category;
      if (category == null) {
        await repository.create(
          name: _name.text,
          type: _type,
          icon: _icon,
          color: _color,
        );
      } else {
        await repository.update(
          id: category.id,
          name: _name.text,
          type: _type,
          icon: _icon,
          color: _color,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Не удалось сохранить категорию: $error';
        });
      }
    }
  }
}
