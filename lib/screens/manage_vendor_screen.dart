import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/vendor.dart';
import '../theme.dart';
import '../widgets/meco_scaffold.dart';

const List<Vendor> _sampleVendors = <Vendor>[];

class ManageVendorScreen extends StatefulWidget {
  const ManageVendorScreen({super.key});

  @override
  State<ManageVendorScreen> createState() => _ManageVendorScreenState();
}

class _ManageVendorScreenState extends State<ManageVendorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return MecoScaffold(
      title: 'All Vendors',
      currentRoute: 'Manage Vendor',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppPalette.green,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppPalette.green,
                unselectedLabelColor: scheme.onSurfaceVariant,
                labelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                tabs: const <Widget>[
                  Tab(text: 'My Vendors'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const <Widget>[
                    _MyVendorsTab(vendors: _sampleVendors),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyVendorsTab extends StatelessWidget {
  final List<Vendor> vendors;

  const _MyVendorsTab({required this.vendors});

  static const double _colSerial = 56;
  static const double _colName = 240;
  static const double _colUser = 200;
  static const double _colTags = 150;
  static const double _colUid = 150;
  static const double _colInvite = 150;
  static const double _colStatus = 150;

  static const double _minTableWidth = _colSerial +
      _colName +
      _colUser +
      _colTags +
      _colUid +
      _colInvite +
      _colStatus;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color dividerColor =
        Theme.of(context).extension<AppColors>()?.divider ?? scheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width =
                    math.max(_minTableWidth, constraints.maxWidth);

                if (vendors.isEmpty) {
                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeaderRow(context),
                              Divider(
                                  height: 1, thickness: 1, color: dividerColor),
                              _buildFilterRow(context),
                              Divider(
                                  height: 1, thickness: 1, color: dividerColor),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'No Vendors found',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderRow(context),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        _buildFilterRow(context),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: vendors.length,
                            separatorBuilder: (_, _) =>
                                Divider(height: 1, thickness: 1, color: dividerColor),
                            itemBuilder: (_, int index) =>
                                _buildVendorRow(context, vendors[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Add New Vendor',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle style = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          _cell(_cellText('S.No', style), width: _colSerial),
          _cell(_cellText('Vendor Name & Code', style), width: _colName),
          _cell(_cellText('Primary User', style), width: _colUser),
          _cell(_cellText('Vendor Tags', style), width: _colTags),
          _cell(_cellText('UID', style), width: _colUid),
          _cell(_cellText('Invite Status', style), width: _colInvite),
          Expanded(child: _pad(Text('Status', style: style))),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      color: scheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: _colSerial,
            child: Center(
              child: Icon(Icons.filter_alt_outlined,
                  size: 20, color: scheme.onSurfaceVariant),
            ),
          ),
          _searchField(context, _colName),
          _searchField(context, _colUser),
          _selectDropdown(context, _colTags, 'Select'),
          _searchField(context, _colUid),
          _selectDropdown(context, _colInvite, 'Select status'),
          Expanded(
            child: _pad(
              SizedBox(
                height: 32,
                child: _Dropdown(hint: 'Select status', width: double.infinity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorRow(BuildContext context, Vendor vendor) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle base = TextStyle(fontSize: 13, color: scheme.onSurface);

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          _cell(_cellText('${vendor.serialNumber}.', base), width: _colSerial),
          _cell(_cellText(vendor.nameAndCode, base), width: _colName),
          _cell(_cellText(vendor.primaryUser, base), width: _colUser),
          _cell(_cellText(vendor.tags, base), width: _colTags),
          _cell(_cellText(vendor.uid, base), width: _colUid),
          _cell(_cellText(vendor.inviteStatus, base), width: _colInvite),
          Expanded(child: _pad(Text(vendor.status, style: base))),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context, double width) {
    return SizedBox(
      width: width,
      child: _pad(
        SizedBox(
          height: 32,
          child: _SearchInput(),
        ),
      ),
    );
  }

  Widget _selectDropdown(BuildContext context, double width, String hint) {
    return SizedBox(
      width: width,
      child: _pad(
        SizedBox(
          height: 32,
          child: _Dropdown(hint: hint, width: width - 32),
        ),
      ),
    );
  }

  Widget _cell(Widget child, {required double width}) {
    return SizedBox(width: width, child: _pad(child));
  }

  Widget _pad(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }

  Widget _cellText(String text, TextStyle style) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _SearchInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return TextField(
      style: TextStyle(fontSize: 13, color: scheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          size: 16,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: AppPalette.green),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String hint;
  final double width;

  const _Dropdown({required this.hint, required this.width});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              hint,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
