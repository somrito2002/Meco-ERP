import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

  static const Color navy = Color(0xFF0E2438);
  static const Color fieldBorder = Color(0xFFE0E3E8);
  static const Color hintGray = Color(0xFF9AA1AC);

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
        _appVersionText =
            'Version ${packageInfo.version} (Build ${packageInfo.buildNumber})';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
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
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if asset is missing or fails to load
                      return Container(
                        height: 90,
                        width: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: navy,
                        ),
                        child: const Icon(
                          Icons.apartment_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Meco',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: navy,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Gradient Divider ---
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFFD1D5DB),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Title ---
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: navy,
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
                        color: hintGray,
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
                      hint: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.apartment_outlined,
                            color: hintGray,
                            size: 24,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Department',
                            style: TextStyle(color: hintGray, fontSize: 15),
                          ),
                        ],
                      ),
                      style: const TextStyle(color: navy, fontSize: 15),
                      items: [
                        for (final dept in _departments)
                          DropdownItem<String>(
                            value: dept,
                            child: Text(
                              dept,
                              style: const TextStyle(color: navy, fontSize: 15),
                            ),
                          ),
                      ],
                      selectedItemBuilder: (context) => [
                        for (final dept in _departments)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.apartment_outlined,
                                color: hintGray,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                dept,
                                style: const TextStyle(
                                  color: navy,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: fieldBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: navy,
                          size: 24,
                        ),
                        openMenuIcon: Icon(
                          Icons.keyboard_arrow_up,
                          color: navy,
                          size: 24,
                        ),
                      ),
                      barrierDismissible: true,
                      dropdownStyleData: DropdownStyleData(
                        // Exactly 3 items (3 x 48px item height) visible at a time.
                        maxHeight: 144,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: fieldBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        offset: const Offset(0, 4),
                        scrollbarTheme: ScrollbarThemeData(
                          thumbVisibility: WidgetStateProperty.all(true),
                          thickness: WidgetStateProperty.all(6),
                          radius: const Radius.circular(40),
                          thumbColor: WidgetStateProperty.all(
                            const Color(0xFFCBD2DC),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Footer ---
                  const Text(
                    'Facing issues in login, please write to us at:',
                    style: TextStyle(color: navy, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      // TODO: launch mail client, e.g. using url_launcher
                    },
                    child: const Text(
                      'support@meco.io',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- App version ---
                  Text(
                    _appVersionText,
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
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

  static const Color fieldBorder = Color(0xFFE0E3E8);
  static const Color hintGray = Color(0xFF9AA1AC);
  static const Color navy = Color(0xFF0E2438);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: navy, fontSize: 15),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, color: hintGray),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 56,
          minHeight: 24,
        ),
        suffixIcon: trailing,
        hintText: hint,
        hintStyle: const TextStyle(color: hintGray),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navy, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: fieldBorder),
        ),
      ),
    );
  }
}
