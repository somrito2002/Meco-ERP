import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/meco_scaffold.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MyDownloadsScreen extends StatefulWidget {
  const MyDownloadsScreen({super.key});

  @override
  State<MyDownloadsScreen> createState() => _MyDownloadsScreenState();
}

class _MyDownloadsScreenState extends State<MyDownloadsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return MecoScaffold(
      title: 'My Downloads',
      currentRoute: 'My Downloads',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search Downloads',
                            prefixIcon: Icon(
                              Icons.search,
                              color: _isSearchFocused
                                  ? AppPalette.green
                                  : scheme.onSurfaceVariant,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).extension<AppColors>()?.inputFill,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: scheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: scheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppPalette.green,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color:
                            Theme.of(context).extension<AppColors>()?.divider,
                      ),
                      Expanded(
                        child: _buildContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // TODO: Replace with real downloads data when available.
    return const _EmptyState();
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
