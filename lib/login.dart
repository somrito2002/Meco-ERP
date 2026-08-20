import 'package:account_picker/account_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_version.dart';
import 'auth/demo_users.dart';
import 'models/demo_user.dart';
import 'screens/dashboard_screen.dart';
import 'session.dart';
import 'theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(
    true,
  );
  final ValueNotifier<String?> _selectedDepartmentNotifier =
      ValueNotifier<String?>(null);

  bool _isDepartmentDropdownOpen = false;

  static const List<String> _departments = <String>[
    'Accounts & Finance',
    'Administration / Back Office',
    'Billing & Commercial',
    'Civil / Construction',
    'Design & Technical',
    'Electrical',
    'Human Resources (HR)',
    'IT/Developer',
    'Maintenance',
    'Management / Executive',
    'Mechanical',
    'Plant / Production',
    'Projects & Operations',
    'Purchase & Procurement',
    'Tender Cell & Coordination',
    'Vigilance',
  ];

  String _appVersionText = 'Version --';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final String? version = await AppVersion.installedSemanticVersion();
      if (!mounted) return;
      setState(() {
        // Only MAJOR.MINOR.PATCH is shown; the build number is never displayed.
        _appVersionText = version != null ? 'Version $version' : 'Version --';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _appVersionText = 'Version --');
    }
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
    _selectedDepartmentNotifier.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text;
    final department = _selectedDepartmentNotifier.value;

    // Authenticate against the temporary demo users. All three values must
    // match; the auth service decides, the UI does not.
    final DemoUser? user = authenticate(
      loginId: loginId,
      password: password,
      department: department,
    );

    if (user != null) {
      // Persist the session AND update the in-memory cache before navigating
      // so the new screen reads the correct user instantly with no async delay.
      await Session.save(user);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Login ID, Password, or Department."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Android shows the system account chooser, listing every email ID
  /// configured on the device. The chosen account is used as the sender,
  /// then the device mail app opens with the support address pre-filled in
  /// the "To" field and a "Issue Regarding Login" subject.
  Future<void> _handleSupportEmailTap() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await AccountPicker.emailHint();
      } on PlatformException {
        // Account picker unavailable; still open the mail app below.
      }
    }

    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: 'support@meco.io',
      query: 'subject=${Uri.encodeComponent('Issue Regarding Login')}',
    );

    try {
      await launchUrl(mailUri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      // No mail client installed; nothing else to do.
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppColors appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Logo (Image Asset) ---
                  Image.asset(
                    'assets/logo/MECO TECHNOLOGIES PR-Photoroom.png',
                    height: 120,
                    // Shown at ~120 logical px; decode at a capped width
                    // instead of the full 862px source.
                    cacheWidth: 512,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if asset is missing or fails to load
                      return Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                        child: Icon(
                          Icons.apartment_outlined,
                          color: scheme.onPrimary,
                          size: 48,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MECO',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Gradient Divider ---
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          appColors.divider,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Title ---
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Login ID field ---
                  _InputField(
                    controller: _loginIdController,
                    hint: 'Send your LoginID',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // --- Password field ---
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscurePasswordNotifier,
                    builder: (context, obscurePassword, _) {
                      return _InputField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: obscurePassword,
                        trailing: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: scheme.onSurfaceVariant,
                            size: 22,
                          ),
                          onPressed: () {
                            _obscurePasswordNotifier.value = !obscurePassword;
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Department dropdown ---
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      valueListenable: _selectedDepartmentNotifier,
                      hint: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.apartment_outlined,
                            color: scheme.onSurfaceVariant,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Department',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(color: scheme.onSurface, fontSize: 15),
                      items: [
                        for (final dept in _departments)
                          DropdownItem<String>(
                            value: dept,
                            child: Text(
                              dept,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 15,
                              ),
                            ),
                          ),
                      ],
                      selectedItemBuilder: (context) => [
                        for (final dept in _departments)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.apartment_outlined,
                                color: scheme.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                dept,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                      ],
                      onChanged: (value) {
                        // The dropdown drives its own UI via
                        // `valueListenable`; no screen-wide setState.
                        _selectedDepartmentNotifier.value = value;
                      },
                      onMenuStateChange: (isOpen) {
                        setState(() {
                          _isDepartmentDropdownOpen = isOpen;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        width: double.infinity,
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          border: _isDepartmentDropdownOpen
                              ? Border.all(color: scheme.primary, width: 1.5)
                              : Border.all(color: scheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      iconStyleData: IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: scheme.onSurface,
                          size: 24,
                        ),
                        openMenuIcon: Icon(
                          Icons.keyboard_arrow_up,
                          color: scheme.onSurface,
                          size: 24,
                        ),
                      ),
                      barrierDismissible: true,
                      dropdownStyleData: DropdownStyleData(
                        // Exactly 3 items (3 x 48px item height) visible at a time.
                        maxHeight: 144,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          border: Border.all(color: scheme.outline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        offset: const Offset(0, 4),
                        scrollbarTheme: ScrollbarThemeData(
                          thumbVisibility: WidgetStateProperty.all(true),
                          thickness: WidgetStateProperty.all(6),
                          radius: const Radius.circular(40),
                          thumbColor: WidgetStateProperty.all(
                            scheme.outlineVariant,
                          ),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Login button ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Footer ---
                  Text(
                    'Facing issues in login, please write to us at:',
                    style: TextStyle(color: scheme.onSurface, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _handleSupportEmailTap,
                    child: Text(
                      'support@meco.io',
                      style: TextStyle(
                        color: appColors.link,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- App version ---
                  Text(
                    _appVersionText,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable outlined text field matching the design (icon + hint + optional trailing).
/// Colors are inherited from the active theme's `InputDecorationTheme`.
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: scheme.onSurface, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, color: scheme.onSurfaceVariant),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 56,
          minHeight: 24,
        ),
        suffixIcon: trailing,
        hintText: hint,
      ),
    );
  }
}
