import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/meco_scaffold.dart';

// ── Task data model ───────────────────────────────────────────────────────────

/// Represents a task category in the left sidebar.
class TaskCategory {
  final String id;
  final String label;
  final IconData icon;
  final int count;

  const TaskCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.count = 0,
  });

  TaskCategory copyWith({int? count}) => TaskCategory(
        id: id,
        label: label,
        icon: icon,
        count: count ?? this.count,
      );
}

/// Represents a single child item inside an expandable task section.
///
/// These will later become task filters fed by backend data.
class TaskSubItem {
  final String title;
  final int count;

  const TaskSubItem({
    required this.title,
    required this.count,
  });
}

/// All task categories with their initial data.
final List<TaskCategory> _kCategories = [
  const TaskCategory(id: 'important', label: 'Important', icon: Icons.star_border, count: 0),
  const TaskCategory(id: 'reminders', label: 'Reminders', icon: Icons.schedule_outlined, count: 0),
  const TaskCategory(id: 'mentions', label: 'Mentions', icon: Icons.alternate_email, count: 0),
  const TaskCategory(id: 'tasks_for_me', label: 'Tasks for me', icon: Icons.assignment_ind_outlined, count: 0),
  const TaskCategory(id: 'tasks_by_me', label: 'Tasks by me', icon: Icons.assignment_outlined, count: 0),
  const TaskCategory(id: 'my_requests', label: 'My Requests', icon: Icons.check_circle_outline, count: 0),
  const TaskCategory(id: 'my_approvals', label: 'My Approvals', icon: Icons.verified_outlined, count: 0),
  const TaskCategory(id: 'my_comments', label: 'My Comments', icon: Icons.comment_outlined, count: 0),
];

/// Expandable child items for the sections that have them.
///
/// Single source of truth for the submenu values; only sections listed here
/// can expand. Values will be replaced by real backend data later.
const Map<String, List<TaskSubItem>> _kSubItems = {
  'tasks_for_me': [
    TaskSubItem(title: 'Active', count: 0),
    TaskSubItem(title: 'Archived', count: 0),
  ],
  'tasks_by_me': [
    TaskSubItem(title: 'Active', count: 0),
    TaskSubItem(title: 'Archived', count: 0),
  ],
  'my_requests': [
    TaskSubItem(title: 'Pending Requests', count: 1),
    TaskSubItem(title: 'Draft Requests', count: 0),
    TaskSubItem(title: 'Archived Requests', count: 22),
  ],
};

// Index boundaries for divider placement (after index 2, after index 4)
const int _kDivider1After = 2;
const int _kDivider2After = 4;

// ── Screen ────────────────────────────────────────────────────────────────────

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  // Mutable categories (counts can be updated later from backend)
  final List<TaskCategory> _categories = List.of(_kCategories);

  // Currently selected category id
  String _selectedId = 'important';

  // Sections whose submenu is currently expanded (independent per section)
  // Pre-expand all sections that have sub-items so they show on first load.
  final Set<String> _expandedSections = {'tasks_for_me', 'tasks_by_me', 'my_requests'};

  // Currently selected sub-item (e.g. 'Active', 'Archived') — null means show list
  String? _selectedSubItem;

  TaskCategory get _selectedCategory =>
      _categories.firstWhere((c) => c.id == _selectedId);

  void _onSelectCategory(String id) {
    setState(() {
      _selectedId = id;
      _selectedSubItem = null; // reset sub-item when switching category
    });
  }

  void _onToggleSection(String id) {
    setState(() {
      if (!_expandedSections.remove(id)) {
        _expandedSections.add(id);
      }
    });
  }

  void _onSubItemTap(String title) {
    setState(() => _selectedSubItem = title);
  }

  @override
  Widget build(BuildContext context) {
    return MecoScaffold(
      title: 'My Tasks',
      currentRoute: 'My Tasks',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Task Manager header ─────────────────────────────────────────
          _TaskManagerHeader(),
          // ── Divider ──────────────────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          // ── Main body ────────────────────────────────────────────────────
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double sidebarBreakpoint = 600;
                if (constraints.maxWidth >= sidebarBreakpoint) {
                  // ── Desktop / wide layout: sidebar + content side-by-side ──
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 220,
                        child: _TaskSidebar(
                          categories: _categories,
                          selectedId: _selectedId,
                          onSelect: _onSelectCategory,
                          expandedSections: _expandedSections,
                          onToggleSection: _onToggleSection,
                        ),
                      ),
                      const VerticalDivider(
                          width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                      Expanded(
                        child: _selectedSubItem != null
                            ? _TaskSubItemDetail(
                                title: _selectedSubItem!,
                                onBack: () => setState(() => _selectedSubItem = null),
                              )
                            : _TaskContent(
                                category: _selectedCategory,
                                onSubItemTap: _onSubItemTap,
                              ),
                      ),
                    ],
                  );
                } else {
                  // ── Mobile layout: horizontal scrollable tab strip + content ──
                  return Column(
                    children: [
                      _MobileCategoryStrip(
                        categories: _categories,
                        selectedId: _selectedId,
                        onSelect: _onSelectCategory,
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                      Expanded(
                        child: _selectedSubItem != null
                            ? _TaskSubItemDetail(
                                title: _selectedSubItem!,
                                onBack: () => setState(() => _selectedSubItem = null),
                              )
                            : _TaskContent(
                                category: _selectedCategory,
                                onSubItemTap: _onSubItemTap,
                              ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task Manager header ───────────────────────────────────────────────────────

class _TaskManagerHeader extends StatelessWidget {
  const _TaskManagerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Manager',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          // Meco green underline
          Container(
            width: 100,
            height: 2.5,
            decoration: BoxDecoration(
              color: AppPalette.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}

// ── Desktop sidebar ───────────────────────────────────────────────────────────

class TaskSidebar extends StatelessWidget {
  final List<TaskCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final Set<String> expandedSections;
  final ValueChanged<String>? onToggleSection;

  const TaskSidebar({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    this.expandedSections = const <String>{},
    this.onToggleSection,
  });

  @override
  Widget build(BuildContext context) => _TaskSidebar(
        categories: categories,
        selectedId: selectedId,
        onSelect: onSelect,
        expandedSections: expandedSections,
        onToggleSection: onToggleSection,
      );
}

class _TaskSidebar extends StatelessWidget {
  final List<TaskCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final Set<String> expandedSections;
  final ValueChanged<String>? onToggleSection;

  const _TaskSidebar({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.expandedSections,
    required this.onToggleSection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Create New Task button ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: CreateTaskButton(),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
          // ── Category items with dividers ──────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                final isSelected = cat.id == selectedId;
                final subItems = _kSubItems[cat.id];
                final isExpanded = expandedSections.contains(cat.id);

                if (subItems != null) {
                  return _ExpandableSection(
                    cat: cat,
                    subItems: subItems,
                    isExpanded: isExpanded,
                    onToggle: () {
                      onSelect(cat.id);
                      onToggleSection?.call(cat.id);
                    },
                  );
                } else {
                  return Column(
                    children: [
                      TaskMenuItem(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () => onSelect(cat.id),
                      ),
                      if (i == _kDivider1After || i == _kDivider2After)
                        Divider(
                            height: 1,
                            thickness: 1,
                            color: Theme.of(context).colorScheme.outlineVariant,
                            indent: 12,
                            endIndent: 12),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task menu item ────────────────────────────────────────────────────────────

class TaskMenuItem extends StatelessWidget {
  final TaskCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const TaskMenuItem({
    super.key,
    required this.category,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = AppPalette.green; // Meco green for active state
    final itemBg = isSelected ? AppPalette.green.withValues(alpha: 0.1) : Colors.transparent;
    final iconColor =
        isSelected ? selectedColor : Theme.of(context).colorScheme.onSurfaceVariant;
    final textColor =
        isSelected ? selectedColor : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: itemBg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(category.icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${category.count}',
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? selectedColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expandable section (Tasks for me / Tasks by me / My Requests) ────────────

/// A sidebar section that has a header row (icon + label) and collapsible
/// bullet child items below it — matching the reference image exactly.
class _ExpandableSection extends StatelessWidget {
  final TaskCategory cat;
  final List<TaskSubItem> subItems;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableSection({
    required this.cat,
    required this.subItems,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Divider above the section ────────────────────────────────
        Divider(height: 1, thickness: 1, color: scheme.outlineVariant),

        // ── Section header row ────────────────────────────────────────
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(cat.icon, size: 17, color: scheme.onSurface),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),

        // ── Animated sub-item list ────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final item in subItems)
                      _SectionSubItem(item: item),
                    const SizedBox(height: 4),
                  ],
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

/// One bullet sub-item row: `•  Label          count`
class _SectionSubItem extends StatelessWidget {
  final TaskSubItem item;
  const _SectionSubItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(left: 38, right: 14, top: 6, bottom: 6),
        child: Row(
          children: [
            Text(
              '• ',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${item.count}',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Task button ────────────────────────────────────────────────────────

class CreateTaskButton extends StatelessWidget {
  const CreateTaskButton({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = AppPalette.green;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: null, // Placeholder — functionality TBD
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: brand),
              foregroundColor: brand,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            icon: const Icon(Icons.edit_outlined, size: 15, color: brand),
            label: const Text(
              'Create New Task',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: brand,
              ),
            ),
          ),
        ),
        // Dropdown arrow section
        Container(
          height: 42,
          width: 32,
          decoration: BoxDecoration(
            border: Border.all(color: brand),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: brand),
        ),
      ],
    );
  }
}

// ── Mobile horizontal category strip ─────────────────────────────────────────

class _MobileCategoryStrip extends StatelessWidget {
  final List<TaskCategory> categories;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _MobileCategoryStrip({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  // Very subtle active-tab background, derived from the brand green so the
  // active state never introduces a red/pink tint.
  static final Color _activeBackground =
      AppPalette.green.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final isSelected = cat.id == selectedId;
          const brand = AppPalette.green;
          return GestureDetector(
            onTap: () => onSelect(cat.id),
            child: SizedBox(
              height: 44,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? _activeBackground : Colors.transparent,
                  border: isSelected
                      ? const Border(
                          bottom: BorderSide(color: brand, width: 2))
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon,
                        size: 14,
                        color: isSelected ? brand : Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? brand : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Task content area ─────────────────────────────────────────────────────────

class TaskContent extends StatelessWidget {
  final TaskCategory category;
  const TaskContent({super.key, required this.category});

  @override
  Widget build(BuildContext context) => _TaskContent(category: category);
}

class _TaskContent extends StatelessWidget {
  final TaskCategory category;
  final ValueChanged<String>? onSubItemTap;
  const _TaskContent({required this.category, this.onSubItemTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subItems = _kSubItems[category.id];

    return Container(
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Content header ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subItems != null ? '' : 'All Done',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: scheme.outlineVariant),

          // ── Sub-item list OR empty state ─────────────────────────────
          Expanded(
            child: subItems != null
                ? _SubItemListView(items: subItems, scheme: scheme, onTap: onSubItemTap)
                : Center(
                    child: _TaskEmptyState(categoryLabel: category.label),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-item list view (shown in content area on mobile) ─────────────────────

class _SubItemListView extends StatelessWidget {
  final List<TaskSubItem> items;
  final ColorScheme scheme;
  final ValueChanged<String>? onTap;

  const _SubItemListView({required this.items, required this.scheme, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: scheme.outlineVariant, indent: 20, endIndent: 20),
      itemBuilder: (context, i) {
        final item = items[i];
        return InkWell(
          onTap: () => onTap?.call(item.title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 15,
                    color: scheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  '${item.count}',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Empty state widget ────────────────────────────────────────────────────────

class _TaskEmptyState extends StatelessWidget {
  final String categoryLabel;
  const _TaskEmptyState({required this.categoryLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustrated empty state icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
            ),
            child: Icon(
              Icons.task_alt,
              size: 36,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${categoryLabel.toLowerCase()} tasks',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When tasks are assigned, they will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Sub-item detail view (Active / Archived / Pending Requests â€¦) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TaskSubItemDetail extends StatefulWidget {
  final String title;
  final VoidCallback onBack;

  const _TaskSubItemDetail({required this.title, required this.onBack});

  @override
  State<_TaskSubItemDetail> createState() => _TaskSubItemDetailState();
}

class _TaskSubItemDetailState extends State<_TaskSubItemDetail> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back arrow + title row
                Row(
                  children: [
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 14, color: scheme.onSurface),
                      ),
                    ),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // "0 Task,  0 Unread" with colored counts
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    children: const [
                      TextSpan(
                        text: '0',
                        style: TextStyle(
                            color: Color(0xFFE67E22), fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' Task,  '),
                      TextSpan(
                        text: '0',
                        style: TextStyle(
                            color: Color(0xFF2980B9), fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' Unread'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // â”€â”€ Search bar + filter button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(fontSize: 13, color: scheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                            fontSize: 13, color: scheme.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search,
                            size: 18, color: scheme.onSurfaceVariant),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: scheme.outlineVariant, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: scheme.outlineVariant, width: 1.2),
                        ),
                        filled: true,
                        fillColor: scheme.surface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                    color: scheme.surface,
                  ),
                  child: Icon(Icons.filter_list_outlined,
                      size: 18, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // â”€â”€ No tasks found â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              'No Tasks Found',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
