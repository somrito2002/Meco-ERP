import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/element_item.dart';
import '../models/library.dart';
import '../theme.dart';
import '../widgets/meco_scaffold.dart';

// ── Library data ──────────────────────────────────────────────────────────────
// Intentionally empty until a real library data source exists. When backend
// data becomes available, populate this list and the table renders
// automatically; while it is empty, the "No Libraries created" state is shown.

const List<Library> _sampleLibraries = <Library>[];

// Intentionally empty until a real element data source exists. When backend
// data becomes available, populate this list and the All Elements table
// renders automatically; while it is empty, the "No Elements created"
// state is shown below the header and filter rows.

const List<ElementItem> _sampleElements = <ElementItem>[];

// ── Screen ────────────────────────────────────────────────────────────────────

class LibrariesScreen extends StatefulWidget {
  const LibrariesScreen({super.key});

  @override
  State<LibrariesScreen> createState() => _LibrariesScreenState();
}

class _LibrariesScreenState extends State<LibrariesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      title: 'All Libraries',
      currentRoute: 'Libraries',
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
                  Tab(text: 'Element Libraries'),
                  Tab(text: 'All Elements'),
                  Tab(text: 'All Assemblies'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    const _ElementLibrariesTab(libraries: _sampleLibraries),
                    const _AllElementsTab(elements: _sampleElements),
                    const _AllAssembliesTab(),
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

// ── Element Libraries tab (library table) ─────────────────────────────────────

class _ElementLibrariesTab extends StatelessWidget {
  final List<Library> libraries;

  const _ElementLibrariesTab({required this.libraries});

  // Fixed column widths (logical pixels). The table scrolls horizontally on
  // narrow screens; on wide screens the spare width flows into the
  // "Last Updated" column so the card always fills its container.
  static const double _colSerial = 56;
  static const double _colName = 210;
  static const double _colType = 140;
  static const double _colCreatedBy = 190;
  static const double _colLastUpdated = 300;
  static const double _colSections = 90;
  static const double _colElements = 90;
  static const double _colActions = 64;
  static const double _edgePadding = 16;

  static const double _minTableWidth = _colSerial +
      _colName +
      _colType +
      _colCreatedBy +
      _colLastUpdated +
      _colSections +
      _colElements +
      _colActions +
      2 * _edgePadding;

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

                // Empty state: keep the column header (still horizontally
                // scrollable on narrow screens) and center the message in
                // the visible area below it.
                if (libraries.isEmpty) {
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
                              Divider(height: 1, thickness: 1, color: dividerColor),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'No Libraries created',
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
                        Expanded(
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: libraries.length,
                            separatorBuilder: (_, _) =>
                                Divider(height: 1, thickness: 1, color: dividerColor),
                            itemBuilder: (_, int index) =>
                                _buildLibraryRow(context, libraries[index]),
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
          _cell(_cellText('Library Name', style), width: _colName),
          _cell(_cellText('Type Of Library', style), width: _colType),
          _cell(_cellText('Created By', style), width: _colCreatedBy),
          Expanded(child: _pad(Text('Last Updated', style: style))),
          _cell(_cellText('Sections', style), width: _colSections),
          _cell(_cellText('Elements', style), width: _colElements),
          SizedBox(width: _colActions, child: _pad(const SizedBox.shrink())),
        ],
      ),
    );
  }

  Widget _buildLibraryRow(BuildContext context, Library library) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle base =
        TextStyle(fontSize: 13, color: scheme.onSurface);
    final TextStyle nameStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          _cell(_cellText('${library.serialNumber}.', base), width: _colSerial),
          _cell(_cellText(library.name, nameStyle), width: _colName),
          _cell(_cellText(library.type, base), width: _colType),
          SizedBox(
            width: _colCreatedBy,
            child: _pad(
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppPalette.profileAvatar,
                    child: Text(
                      _initial(library.createdBy),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      library.createdBy,
                      style: base,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _pad(
              Row(
                children: [
                  Expanded(
                    child: Text(
                      library.lastUpdated,
                      style: base,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.history, size: 16, color: scheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          _cell(_cellText('${library.sections}', base), width: _colSections),
          _cell(_cellText('${library.elements}', base), width: _colElements),
          SizedBox(
            width: _colActions,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              onSelected: (_) {},
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'view', child: Text('View')),
                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
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
          onPressed: () {}, // Placeholder until library creation exists.
          style: TextButton.styleFrom(foregroundColor: AppPalette.green),
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Add New Library',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _pad(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: child,
      );

  Widget _cell(Widget child, {double? width}) {
    final Widget padded = _pad(child);
    if (width == null) return padded;
    return SizedBox(
      width: width,
      child: Align(alignment: Alignment.centerLeft, child: padded),
    );
  }

  Widget _cellText(String text, TextStyle style) => Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  String _initial(String name) {
    final String trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
  }
}

// ── All Elements tab (elements table) ─────────────────────────────────────────

class _AllElementsTab extends StatefulWidget {
  final List<ElementItem> elements;

  const _AllElementsTab({required this.elements});

  @override
  State<_AllElementsTab> createState() => _AllElementsTabState();
}

class _AllElementsTabState extends State<_AllElementsTab> {
  bool _selectAll = false;

  // Column visibility state
  bool _showBrand = false;
  bool _showItemCode = false;
  bool _showCategory = false;
  bool _showItemType = false;
  bool _showServiceCharge = false;
  bool _showDiscount = false;
  bool _showHsn = false;
  bool _showGst = false;

  final LayerLink _settingsLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _closePopup();
    super.dispose();
  }

  void _toggleColumnSettings() {
    if (_overlayEntry != null) {
      _closePopup();
    } else {
      _showPopup();
    }
  }

  void _closePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showPopup() {
    final overlay = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closePopup,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _settingsLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: Material(
              color: Colors.transparent,
              child: _ColumnSettingsPopup(
                showBrand: _showBrand,
                showItemCode: _showItemCode,
                showCategory: _showCategory,
                showItemType: _showItemType,
                showServiceCharge: _showServiceCharge,
                showDiscount: _showDiscount,
                showHsn: _showHsn,
                showGst: _showGst,
                onApply: (brand, code, cat, type, svc, disc, hsn, gst) {
                  setState(() {
                    _showBrand = brand;
                    _showItemCode = code;
                    _showCategory = cat;
                    _showItemType = type;
                    _showServiceCharge = svc;
                    _showDiscount = disc;
                    _showHsn = hsn;
                    _showGst = gst;
                  });
                  _closePopup();
                },
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  // Fixed column widths (logical pixels).
  static const double _colSelect = 56;
  static const double _colItemName = 240;
  static const double _colLibrary = 180;
  static const double _colSection = 160;
  static const double _colUom = 120;
  static const double _colQty = 150;
  static const double _colSettings = 64;

  static const double _colBrand = 150;
  static const double _colItemCode = 140;
  static const double _colCategory = 140;
  static const double _colItemType = 140;
  static const double _colServiceCharge = 140;
  static const double _colDiscount = 120;
  static const double _colHsn = 120;
  static const double _colGst = 100;

  double get _currentTableWidth {
    double width = _colSelect + _colItemName + _colLibrary + _colSection + _colUom + _colQty + _colSettings;
    if (_showBrand) width += _colBrand;
    if (_showItemCode) width += _colItemCode;
    if (_showCategory) width += _colCategory;
    if (_showItemType) width += _colItemType;
    if (_showServiceCharge) width += _colServiceCharge;
    if (_showDiscount) width += _colDiscount;
    if (_showHsn) width += _colHsn;
    if (_showGst) width += _colGst;
    return width;
  }

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
                    math.max(_currentTableWidth, constraints.maxWidth);
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
                          child: widget.elements.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Elements created',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: widget.elements.length,
                                  separatorBuilder: (_, _) => Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: dividerColor),
                                  itemBuilder: (_, int index) =>
                                      _buildElementRow(
                                          context, widget.elements[index]),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
          SizedBox(width: _colSelect, child: _pad(const SizedBox.shrink())),
          _cell(_cellText('Item Name & Description', style),
              width: _colItemName),
          _cell(_cellText('Library Name', style), width: _colLibrary),
          _cell(_cellText('Section Name', style), width: _colSection),
          if (_showBrand) _cell(_cellText('Brand/Make', style), width: _colBrand),
          if (_showItemCode) _cell(_cellText('Item Code', style), width: _colItemCode),
          if (_showCategory) _cell(_cellText('Category', style), width: _colCategory),
          if (_showItemType) _cell(_cellText('Item Type', style), width: _colItemType),
          if (_showServiceCharge) _cell(_cellText('Service Charge %', style), width: _colServiceCharge),
          if (_showDiscount) _cell(_cellText('Discount %', style), width: _colDiscount),
          if (_showHsn) _cell(_cellText('HSN', style), width: _colHsn),
          if (_showGst) _cell(_cellText('GST %', style), width: _colGst),
          _cell(_cellText('UOM', style), width: _colUom),
          _cell(_cellText('Standard Quantity', style), width: _colQty),
          SizedBox(
            width: _colSettings,
            child: Center(
              child: CompositedTransformTarget(
                link: _settingsLink,
                child: IconButton(
                  icon: Icon(Icons.settings_outlined,
                      size: 20, color: scheme.onSurfaceVariant),
                  onPressed: _toggleColumnSettings,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Column Settings',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _colSelect,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: Checkbox(
                    value: _selectAll,
                    activeColor: AppPalette.green,
                    onChanged: (bool? value) =>
                        setState(() => _selectAll = value ?? false),
                  ),
                ),
                IconButton(
                  onPressed: () {}, // Placeholder until filtering exists.
                  icon: Icon(Icons.filter_alt_outlined,
                      size: 18, color: scheme.onSurfaceVariant),
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),
          _searchField(context, _colItemName),
          _searchField(context, _colLibrary),
          _searchField(context, _colSection),
          if (_showBrand) _searchField(context, _colBrand),
          if (_showItemCode) _searchField(context, _colItemCode),
          if (_showCategory) _searchField(context, _colCategory),
          if (_showItemType) _searchField(context, _colItemType),
          if (_showServiceCharge) _searchField(context, _colServiceCharge),
          if (_showDiscount) _searchField(context, _colDiscount),
          if (_showHsn) _searchField(context, _colHsn),
          if (_showGst) _searchField(context, _colGst),
          _uomDropdown(context, _colUom),
          _searchField(context, _colQty),
          SizedBox(width: _colSettings, child: _pad(const SizedBox.shrink())),
        ],
      ),
    );
  }

  Widget _buildElementRow(BuildContext context, ElementItem element) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextStyle base = TextStyle(fontSize: 13, color: scheme.onSurface);

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          SizedBox(width: _colSelect, child: _pad(const SizedBox.shrink())),
          SizedBox(
            width: _colItemName,
            child: _pad(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    element.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (element.itemDescription.isNotEmpty)
                    Text(
                      element.itemDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          _cell(_cellText(element.libraryName, base), width: _colLibrary),
          _cell(_cellText(element.sectionName, base), width: _colSection),
          if (_showBrand) _cell(_cellText(element.brand, base), width: _colBrand),
          if (_showItemCode) _cell(_cellText(element.itemCode, base), width: _colItemCode),
          if (_showCategory) _cell(_cellText(element.category, base), width: _colCategory),
          if (_showItemType) _cell(_cellText(element.itemType, base), width: _colItemType),
          if (_showServiceCharge) _cell(_cellText('${element.serviceCharge}', base), width: _colServiceCharge),
          if (_showDiscount) _cell(_cellText('${element.discount}', base), width: _colDiscount),
          if (_showHsn) _cell(_cellText(element.hsn, base), width: _colHsn),
          if (_showGst) _cell(_cellText('${element.gst}', base), width: _colGst),
          _cell(_cellText(element.uom, base), width: _colUom),
          _cell(_cellText('${element.standardQuantity}', base), width: _colQty),
          SizedBox(
            width: _colSettings,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
              padding: EdgeInsets.zero,
              onSelected: (_) {},
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'view', child: Text('View')),
                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context, double width) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fillColor =
        Theme.of(context).extension<AppColors>()?.inputFill ?? scheme.surface;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 36,
          child: TextField(
            style: TextStyle(fontSize: 13, color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle:
                  TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              prefixIcon:
                  Icon(Icons.search, size: 18, color: scheme.onSurfaceVariant),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 34, minHeight: 34),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              filled: true,
              fillColor: fillColor,
              border: border(scheme.outline),
              enabledBorder: border(scheme.outline),
              focusedBorder: border(AppPalette.green, 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _uomDropdown(BuildContext context, double width) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fillColor =
        Theme.of(context).extension<AppColors>()?.inputFill ?? scheme.surface;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 36,
          child: DropdownButtonFormField<String>(
            items: const <DropdownMenuItem<String>>[],
            onChanged: (_) {},
            icon: Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
            style: TextStyle(fontSize: 13, color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Select',
              hintStyle:
                  TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              filled: true,
              fillColor: fillColor,
              border: border(scheme.outline),
              enabledBorder: border(scheme.outline),
              focusedBorder: border(AppPalette.green, 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pad(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: child,
      );

  Widget _cell(Widget child, {double? width}) {
    final Widget padded = _pad(child);
    if (width == null) return padded;
    return SizedBox(
      width: width,
      child: Align(alignment: Alignment.centerLeft, child: padded),
    );
  }

  Widget _cellText(String text, TextStyle style) => Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}

// The _EmptyPlaceholder widget has been removed because it is no longer used

// ── All Assemblies tab (assemblies table) ─────────────────────────────────────

class _AllAssembliesTab extends StatefulWidget {
  const _AllAssembliesTab();

  @override
  State<_AllAssembliesTab> createState() => _AllAssembliesTabState();
}

class _AllAssembliesTabState extends State<_AllAssembliesTab> {
  bool _selectAll = false;

  // Column visibility state
  bool _showBrand = false;
  bool _showItemCode = false;
  bool _showCategory = false;
  bool _showItemType = false;
  bool _showServiceCharge = false;
  bool _showDiscount = false;
  bool _showHsn = false;
  bool _showGst = false;

  final LayerLink _settingsLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _closePopup();
    super.dispose();
  }

  void _toggleColumnSettings() {
    if (_overlayEntry != null) {
      _closePopup();
    } else {
      _showPopup();
    }
  }

  void _closePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showPopup() {
    final overlay = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closePopup,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _settingsLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: Material(
              color: Colors.transparent,
              child: _ColumnSettingsPopup(
                showBrand: _showBrand,
                showItemCode: _showItemCode,
                showCategory: _showCategory,
                showItemType: _showItemType,
                showServiceCharge: _showServiceCharge,
                showDiscount: _showDiscount,
                showHsn: _showHsn,
                showGst: _showGst,
                onApply: (brand, code, cat, type, svc, disc, hsn, gst) {
                  setState(() {
                    _showBrand = brand;
                    _showItemCode = code;
                    _showCategory = cat;
                    _showItemType = type;
                    _showServiceCharge = svc;
                    _showDiscount = disc;
                    _showHsn = hsn;
                    _showGst = gst;
                  });
                  _closePopup();
                },
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  // Fixed column widths (logical pixels).
  static const double _colSelect = 56;
  static const double _colItemName = 240;
  static const double _colLibrary = 180;
  static const double _colSection = 160;
  static const double _colUom = 120;
  static const double _colQty = 150;
  static const double _colSettings = 64;

  static const double _colBrand = 150;
  static const double _colItemCode = 140;
  static const double _colCategory = 140;
  static const double _colItemType = 140;
  static const double _colServiceCharge = 140;
  static const double _colDiscount = 120;
  static const double _colHsn = 120;
  static const double _colGst = 100;

  double get _currentTableWidth {
    double width = _colSelect + _colItemName + _colLibrary + _colSection + _colUom + _colQty + _colSettings;
    if (_showBrand) width += _colBrand;
    if (_showItemCode) width += _colItemCode;
    if (_showCategory) width += _colCategory;
    if (_showItemType) width += _colItemType;
    if (_showServiceCharge) width += _colServiceCharge;
    if (_showDiscount) width += _colDiscount;
    if (_showHsn) width += _colHsn;
    if (_showGst) width += _colGst;
    return width;
  }

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
                    math.max(_currentTableWidth, constraints.maxWidth);
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
                          child: Center(
                            child: Text(
                              'No Assemblies created',
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
          SizedBox(width: _colSelect, child: _pad(const SizedBox.shrink())),
          _cell(_cellText('Item Name & Description', style),
              width: _colItemName),
          _cell(_cellText('Library Name', style), width: _colLibrary),
          _cell(_cellText('Section Name', style), width: _colSection),
          if (_showBrand) _cell(_cellText('Brand/Make', style), width: _colBrand),
          if (_showItemCode) _cell(_cellText('Item Code', style), width: _colItemCode),
          if (_showCategory) _cell(_cellText('Category', style), width: _colCategory),
          if (_showItemType) _cell(_cellText('Item Type', style), width: _colItemType),
          if (_showServiceCharge) _cell(_cellText('Service Charge %', style), width: _colServiceCharge),
          if (_showDiscount) _cell(_cellText('Discount %', style), width: _colDiscount),
          if (_showHsn) _cell(_cellText('HSN', style), width: _colHsn),
          if (_showGst) _cell(_cellText('GST %', style), width: _colGst),
          _cell(_cellText('UOM', style), width: _colUom),
          _cell(_cellText('Standard Quantity', style), width: _colQty),
          SizedBox(
            width: _colSettings,
            child: Center(
              child: CompositedTransformTarget(
                link: _settingsLink,
                child: IconButton(
                  icon: Icon(Icons.settings_outlined, size: 20, color: scheme.onSurfaceVariant),
                  onPressed: _toggleColumnSettings,
                  tooltip: 'Column Settings',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _colSelect,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: Checkbox(
                    value: _selectAll,
                    activeColor: AppPalette.green,
                    onChanged: (bool? value) =>
                        setState(() => _selectAll = value ?? false),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.filter_alt_outlined,
                      size: 18, color: scheme.onSurfaceVariant),
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),
          _searchField(context, _colItemName),
          _searchField(context, _colLibrary),
          _searchField(context, _colSection),
          if (_showBrand) _searchField(context, _colBrand),
          if (_showItemCode) _searchField(context, _colItemCode),
          if (_showCategory) _searchField(context, _colCategory),
          if (_showItemType) _searchField(context, _colItemType),
          if (_showServiceCharge) _searchField(context, _colServiceCharge),
          if (_showDiscount) _searchField(context, _colDiscount),
          if (_showHsn) _searchField(context, _colHsn),
          if (_showGst) _searchField(context, _colGst),
          _uomDropdown(context, _colUom),
          _searchField(context, _colQty),
          SizedBox(width: _colSettings, child: _pad(const SizedBox.shrink())),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context, double width) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fillColor =
        Theme.of(context).extension<AppColors>()?.inputFill ?? scheme.surface;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 36,
          child: TextField(
            style: TextStyle(fontSize: 13, color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle:
                  TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              prefixIcon:
                  Icon(Icons.search, size: 18, color: scheme.onSurfaceVariant),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 34, minHeight: 34),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              filled: true,
              fillColor: fillColor,
              border: border(scheme.outline),
              enabledBorder: border(scheme.outline),
              focusedBorder: border(AppPalette.green, 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _uomDropdown(BuildContext context, double width) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color fillColor =
        Theme.of(context).extension<AppColors>()?.inputFill ?? scheme.surface;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          height: 36,
          child: DropdownButtonFormField<String>(
            items: const <DropdownMenuItem<String>>[],
            onChanged: (_) {},
            icon: Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
            style: TextStyle(fontSize: 13, color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Select',
              hintStyle:
                  TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              filled: true,
              fillColor: fillColor,
              border: border(scheme.outline),
              enabledBorder: border(scheme.outline),
              focusedBorder: border(AppPalette.green, 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pad(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: child,
      );

  Widget _cell(Widget child, {double? width}) {
    final Widget padded = _pad(child);
    if (width == null) return padded;
    return SizedBox(
      width: width,
      child: Align(alignment: Alignment.centerLeft, child: padded),
    );
  }

  Widget _cellText(String text, TextStyle style) => Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}

// ── Column Settings Popup ─────────────────────────────────────────────────────

class _ColumnSettingsPopup extends StatefulWidget {
  final bool showBrand;
  final bool showItemCode;
  final bool showCategory;
  final bool showItemType;
  final bool showServiceCharge;
  final bool showDiscount;
  final bool showHsn;
  final bool showGst;
  final void Function(bool, bool, bool, bool, bool, bool, bool, bool) onApply;

  const _ColumnSettingsPopup({
    required this.showBrand,
    required this.showItemCode,
    required this.showCategory,
    required this.showItemType,
    required this.showServiceCharge,
    required this.showDiscount,
    required this.showHsn,
    required this.showGst,
    required this.onApply,
  });

  @override
  State<_ColumnSettingsPopup> createState() => _ColumnSettingsPopupState();
}

class _ColumnSettingsPopupState extends State<_ColumnSettingsPopup> {
  late bool _brand;
  late bool _code;
  late bool _cat;
  late bool _type;
  late bool _svc;
  late bool _disc;
  late bool _hsn;
  late bool _gst;

  @override
  void initState() {
    super.initState();
    _brand = widget.showBrand;
    _code = widget.showItemCode;
    _cat = widget.showCategory;
    _type = widget.showItemType;
    _svc = widget.showServiceCharge;
    _disc = widget.showDiscount;
    _hsn = widget.showHsn;
    _gst = widget.showGst;
  }

  void _reset() {
    setState(() {
      _brand = false;
      _code = false;
      _cat = false;
      _type = false;
      _svc = false;
      _disc = false;
      _hsn = false;
      _gst = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color dividerColor = Theme.of(context).extension<AppColors>()?.divider ?? scheme.outlineVariant;
    
    return Container(
      width: 240,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 120, // Leave room for padding/keyboard
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Column Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggle('Brand/Make', _brand, (v) => setState(() => _brand = v)),
                    _buildToggle('Item Code', _code, (v) => setState(() => _code = v)),
                    _buildToggle('Category', _cat, (v) => setState(() => _cat = v)),
                    _buildToggle('Item Type', _type, (v) => setState(() => _type = v)),
                    _buildToggle('Service Charge %', _svc, (v) => setState(() => _svc = v)),
                    _buildToggle('Discount %', _disc, (v) => setState(() => _disc = v)),
                    _buildToggle('HSN', _hsn, (v) => setState(() => _hsn = v)),
                    _buildToggle('GST %', _gst, (v) => setState(() => _gst = v)),
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => widget.onApply(_brand, _code, _cat, _type, _svc, _disc, _hsn, _gst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 36),
                    elevation: 0,
                  ),
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    side: BorderSide(color: scheme.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool value, ValueChanged<bool> onChanged) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              height: 28,
              width: 44,
              child: Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppPalette.green,
                  inactiveThumbColor: scheme.onSurfaceVariant,
                  inactiveTrackColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
