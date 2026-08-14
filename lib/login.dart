import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _selectedDepartment;
  final ValueNotifier<String?> _selectedDepartmentNotifier =
      ValueNotifier<String?>(null);

  final List<String> _departments = <String>[
    'IT',
    'HR',
    'Admin',
    'Accounts',
    'Management',
    'Procurement',
    'Super Admin',
  ]..sort();

  String _appVersionText = 'Version --';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersionText = 'Version ${packageInfo.version}';
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
    _selectedDepartmentNotifier.dispose();
    super.dispose();
  }

  void _handleLogin() {
    debugPrint('LoginID: ${_loginIdController.text}');
    debugPrint('Password: ${_passwordController.text}');
    debugPrint('Department: $_selectedDepartment');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final AppColors appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Logo (Image Asset) ---
                      Image.asset(
                        'assets/logo/MECO TECHNOLOGIES PR-Photoroom.png',
                        height: 120,
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
                        'Meco',
                        style: TextStyle(
                          fontSize: 38,
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
                      _InputField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        trailing: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: scheme.onSurfaceVariant,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
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
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 15,
                          ),
                          items: [
                            for (final dept in _departments)
                              DropdownItem<String>(
                                value: dept,
                                child: Text(
                                  dept,
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
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                          onChanged: (value) {
                            _selectedDepartmentNotifier.value = value;
                            setState(() => _selectedDepartment = value);
                          },
                          buttonStyleData: ButtonStyleData(
                            width: double.infinity,
                            height: 52,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              border: Border.all(color: scheme.outline),
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
                        onTap: () {
                          // TODO: launch mail client, e.g. using url_launcher
                        },
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

            // --- Theme toggle ---
            Positioned(
              top: 4,
              right: 8,
              child: IconButton(
                onPressed: widget.onToggleTheme,
                tooltip: theme.brightness == Brightness.dark
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                icon: Icon(
                  theme.brightness == Brightness.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
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