import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../login.dart';
import '../models/demo_user.dart';
import '../models/meco_notification.dart';
import '../services/notification_service.dart';
import '../session.dart';
import '../theme.dart';
import '../screens/dashboard_screen.dart' show DashboardScreen;
import '../screens/libraries_screen.dart' show LibrariesScreen;
import '../screens/manage_vendor_screen.dart';
import '../screens/my_downloads_screen.dart' show MyDownloadsScreen;
import '../screens/my_tasks_screen.dart' show MyTasksScreen;
import 'meco_support_chat.dart';

// ── UI mapping helpers ────────────────────────────────────────────────────────

IconData _iconForDepartment(String department) {
  switch (department) {
    case 'Accounts & Finance':
      return Icons.payments_outlined;
    case 'Purchase & Procurement':
      return Icons.shopping_cart_outlined;
    case 'Civil / Construction':
      return Icons.location_on_outlined;
    case 'Electrical':
      return Icons.electrical_services_outlined;
    case 'Mechanical':
      return Icons.settings_outlined;
    case 'Projects & Operations':
      return Icons.insights_outlined;
    case 'Plant / Production':
      return Icons.factory_outlined;
    case 'Design & Technical':
      return Icons.design_services_outlined;
    case 'Tender Cell & Coordination':
      return Icons.description_outlined;
    case 'Human Resources (HR)':
      return Icons.people_outline;
    case 'Administration / Back Office':
      return Icons.folder_outlined;
    case 'Management / Executive':
      return Icons.workspace_premium_outlined;
    case 'Billing & Commercial':
      return Icons.receipt_long_outlined;
    case 'Maintenance':
      return Icons.build_outlined;
    case 'Vigilance':
      return Icons.gpp_good_outlined;
    default:
      return Icons.notifications_outlined;
  }
}

String _timeAgo(DateTime timestamp) {
  final Duration diff = DateTime.now().difference(timestamp);

  if (diff.inMinutes < 1) {
    return 'just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} hr ago';
  }
  return '${diff.inDays} days ago';
}

_NotifData _toNotifData(MecoNotification n) {
  return _NotifData(
    icon: _iconForDepartment(n.department),
    title: n.title,
    subtitle: n.description,
    time: _timeAgo(n.timestamp),
  );
}

class _NotifData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  const _NotifData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

// ── Meco Scaffold ─────────────────────────────────────────────────────────────

class MecoScaffold extends StatefulWidget {
  final String title;
  final String currentRoute;
  final Widget body;

  const MecoScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
  });

  @override
  State<MecoScaffold> createState() => _MecoScaffoldState();
}

class _MecoScaffoldState extends State<MecoScaffold> {
  OverlayEntry? _notifOverlay;
  OverlayEntry? _profileOverlay;

  final GlobalKey _notifKey = GlobalKey();
  final GlobalKey _avatarKey = GlobalKey();

  DemoUser? _user;
  List<MecoNotification> _visibleNotifications = const [];

  List<_NotifData> get _unreadNotifications => _visibleNotifications
      .where((MecoNotification n) => !n.isRead)
      .map(_toNotifData)
      .toList();

  @override
  void initState() {
    super.initState();
    // Use the in-memory cache first for instant display, then confirm
    // from persistent storage in case of an app restart.
    _applyUser(Session.cachedUser);
    _loadUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-apply whenever the dependency tree changes (e.g., after navigation).
    // The cache is always up-to-date so this is instant — no async needed.
    _applyUser(Session.cachedUser);
  }

  void _applyUser(DemoUser? user) {
    if (!mounted) return;
    setState(() {
      _user = user;
      _visibleNotifications =
          NotificationService.getVisibleNotifications(user?.department);
    });
  }

  Future<void> _loadUser() async {
    final DemoUser? user = await Session.currentUser();
    // Also update the cache if it was populated from SharedPreferences
    // (e.g., after an app cold-start before login is called).
    if (user != null) Session.cachedUser = user;
    _applyUser(user);
  }

  void _removeOverlays() {
    _notifOverlay?.remove();
    _notifOverlay = null;
    _profileOverlay?.remove();
    _profileOverlay = null;
  }

  void _markAllRead() {
    setState(() {
      _visibleNotifications = [
        for (final MecoNotification n in _visibleNotifications)
          n.copyWith(isRead: true),
      ];
    });
    _notifOverlay?.markNeedsBuild();
  }

  void _showNotifications(BuildContext context) {
    if (_notifOverlay != null) { _removeOverlays(); return; }
    _removeOverlays();

    final RenderBox box =
        _notifKey.currentContext!.findRenderObject() as RenderBox;
    final Offset pos = box.localToGlobal(Offset.zero);

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    const double hMargin = 12;
    final double popupWidth = math.min(360.0, screenWidth - 2 * hMargin);

    final double bellRight = pos.dx + box.size.width;
    final double rightDistance = (screenWidth - bellRight).clamp(
      hMargin,
      math.max(hMargin, screenWidth - hMargin - popupWidth),
    );

    final double top = pos.dy + box.size.height + 4;
    final double maxHeight = math.max(0.0, screenHeight - top - hMargin);

    _notifOverlay = OverlayEntry(builder: (_) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlays,
        child: Stack(children: [
          Positioned(
            top: top,
            right: rightDistance,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: Colors.transparent,
                child: _NotificationPanel(
                  notifications: _unreadNotifications,
                  onDismiss: _removeOverlays,
                  onMarkAllRead: _markAllRead,
                  width: popupWidth,
                  maxHeight: maxHeight,
                ),
              ),
            ),
          ),
        ]),
      );
    });
    Overlay.of(context).insert(_notifOverlay!);
  }

  void _showProfileDropdown(BuildContext context) {
    if (_profileOverlay != null) { _removeOverlays(); return; }
    _removeOverlays();

    final RenderBox box =
        _avatarKey.currentContext!.findRenderObject() as RenderBox;
    final Offset pos = box.localToGlobal(Offset.zero);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double right = screenWidth - pos.dx - box.size.width;
    
    final double top = pos.dy + box.size.height + 4;
    final double maxHeight = math.max(0.0, screenHeight - top - 12);

    _profileOverlay = OverlayEntry(builder: (_) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlays,
        child: Stack(children: [
          Positioned(
            top: pos.dy + box.size.height + 4,
            right: right - 8,
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: Colors.transparent,
                child: _ProfileDropdown(
                  onDismiss: _removeOverlays,
                  onLogout: _handleLogout,
                  user: _user,
                  maxHeight: maxHeight,
                ),
              ),
            ),
          ),
        ]),
      );
    });
    Overlay.of(context).insert(_profileOverlay!);
  }

  Future<void> _handleLogout() async {
    _removeOverlays();
    await Session.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigate(String routeName, Widget Function() builder) {
    if (widget.currentRoute == routeName) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => builder(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlays();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Ensure surface background everywhere
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check_circle_outline, color: scheme.onSurface),
            onPressed: () {
              _navigate('My Tasks', () => const MyTasksScreen());
            },
          ),
          IconButton(
            key: _notifKey,
            icon: _unreadNotifications.isEmpty
                ? Icon(Icons.notifications_outlined, color: scheme.onSurface)
                : Badge(
                    label: Text('${_unreadNotifications.length}'),
                    backgroundColor: AppPalette.green,
                    child: Icon(Icons.notifications_outlined,
                        color: scheme.onSurface),
                  ),
            onPressed: () => _showNotifications(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: GestureDetector(
              key: _avatarKey,
              onTap: () => _showProfileDropdown(context),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppPalette.profileAvatar,
                child: Text(
                  _user != null ? getLoginIdInitial(_user!.loginId) : 'M',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: scheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/logo/MECO TECHNOLOGIES PR-Photoroom.png',
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "MECO",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                  _DrawerItem(
                    icon: Icons.show_chart,
                    title: 'Insights',
                    isSelected: widget.currentRoute == 'Insights',
                    onTap: () {
                      _navigate('Insights', () => const DashboardScreen());
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline,
                    title: 'My Projects',
                    isSelected: widget.currentRoute == 'My Projects',
                    onTap: () {},
                  ),
                  _DrawerItem(
                    icon: Icons.check_circle_outline,
                    title: 'My Tasks',
                    isSelected: widget.currentRoute == 'My Tasks',
                    onTap: () {
                      _navigate('My Tasks', () => const MyTasksScreen());
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart,
                    title: 'My Downloads',
                    isSelected: widget.currentRoute == 'My Downloads',
                    onTap: () {
                      _navigate('My Downloads', () => const MyDownloadsScreen());
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.layers_outlined,
                    title: 'Libraries',
                    isSelected: widget.currentRoute == 'Libraries',
                    onTap: () {
                      _navigate('Libraries', () => const LibrariesScreen());
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.store_mall_directory_outlined,
                    title: 'Manage Vendor',
                    isSelected: widget.currentRoute == 'Manage Vendor',
                    onTap: () {
                      _navigate('Manage Vendor', () => const ManageVendorScreen());
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Manage Clients',
                    isSelected: widget.currentRoute == 'Manage Clients',
                    onTap: () {},
                  ),
                      ],
                    ),
                  ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(height: 1),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        children: [
                          _DrawerItem(
                            icon: Icons.help_outline,
                            title: 'Help Center',
                            onTap: () {},
                          ),
                          _DrawerItem(
                            icon: Icons.support_agent,
                            iconColor: AppPalette.green,
                            title: 'Customer Support',
                            onTap: () {
                              Navigator.of(context).pop();
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const MecoSupportChat(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: widget.body,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final Color? iconColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? AppPalette.green : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : (iconColor ?? scheme.onSurfaceVariant),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : scheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  final List<_NotifData> notifications;
  final VoidCallback onDismiss;
  final VoidCallback onMarkAllRead;
  final double width;
  final double maxHeight;

  const _NotificationPanel({
    required this.notifications,
    required this.onDismiss,
    required this.onMarkAllRead,
    required this.width,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      constraints: BoxConstraints(maxHeight: maxHeight),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Notifications',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (notifications.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppPalette.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${notifications.length} new',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: scheme.outlineVariant),

          if (notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
              child: Center(
                child: Text(
                  'NO recent Notification',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else ...[
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: notifications.length,
                itemBuilder: (_, i) => _NotifTile(data: notifications[i]),
              ),
            ),
            Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
            InkWell(
              onTap: onMarkAllRead,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Mark read',
                    style: TextStyle(
                      color: AppPalette.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _NotifData data;
  const _NotifTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.brightness == Brightness.light ? const Color(0xFFE8F5E9) : AppPalette.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: AppPalette.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            data.time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onLogout;
  final DemoUser? user;
  final double maxHeight;

  const _ProfileDropdown({
    required this.onDismiss,
    required this.onLogout,
    required this.user,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String name = user?.name ?? 'Test User';
    final String loginId = user?.loginId ?? 'test@meco.com';
    final String department = user?.department ?? 'Test Department';
    final String userId = user?.userId ?? 'xx';
    final String location = 'Test/Test';

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppPalette.profileAvatar,
                      child: Text(
                        getLoginIdInitial(loginId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logged-in as',
                            style: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileInfoRow(label: 'Department', value: department),
                    const SizedBox(height: 8),
                    _ProfileInfoRow(label: 'User ID', value: userId),
                    const SizedBox(height: 8),
                    _ProfileInfoRow(label: 'Location', value: location),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
              InkWell(
                onTap: onLogout,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.red.shade400),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
