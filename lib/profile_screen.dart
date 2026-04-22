// lib/presentation/screens/profile/profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nextrade/profilr_model.dart';
import 'package:nextrade/widgets.dart';

import 'app_theme.dart';
import 'edit_profile_screen.dart';
import 'hive_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = HiveService.isBiometricEnabled();
  bool _notificationsEnabled = HiveService.isNotificationsEnabled();
  String _currentTheme = HiveService.getTheme();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            NexCard(
              showGlow: true,
              borderColor: NexTradeColors.primaryDim.withOpacity(0.3),
              child: ValueListenableBuilder(
                valueListenable: HiveService.profileBox.listenable(),
                builder: (context, Box<ProfileModel> box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text("No Profile Found"));
                  }

                  final profile = box.getAt(0)!;

                  return Row(
                    children: [
                      // 🔥 PROFILE IMAGE / INITIAL
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          gradient: NexTradeColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: profile.imagePath != null
                              ? Image.file(
                            File(profile.imagePath!),
                            fit: BoxFit.cover,
                          )
                              : Center(
                            child: Text(
                              profile.name.isNotEmpty
                                  ? profile.name.substring(0, 2).toUpperCase()
                                  : "NA",
                              style: const TextStyle(
                                color: NexTradeColors.background,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 🔥 NAME + EMAIL
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                color: NexTradeColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              profile.email,
                              style: const TextStyle(
                                color: NexTradeColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: NexTradeColors.profitBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      size: 12, color: NexTradeColors.profit),
                                  SizedBox(width: 4),
                                  Text(
                                    'KYC Verified',
                                    style: TextStyle(
                                      color: NexTradeColors.profit,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔥 EDIT BUTTON
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: NexTradeColors.textMuted),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            // ── Account Info ──────────────────────────────────────────
            NexCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildInfoRow('PAN Number', 'ABCPK1234D'),
                  _buildInfoRow('Demat Account', 'IN12345678901234'),
                  _buildInfoRow('Member Since', 'Jan 2023'),
                  _buildInfoRow('Account Type', 'Individual'),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            // ── Settings Toggles ──────────────────────────────────────
            NexCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildThemeToggle(),
                  const Divider(color: NexTradeColors.border, height: 1),
                  _buildToggleRow(
                    'Biometric Login',
                    Icons.fingerprint,
                    _biometricEnabled,
                        (val) async {
                      setState(() => _biometricEnabled = val);
                      await HiveService.saveSetting('biometricEnabled', val);
                    },
                  ),
                  const Divider(color: NexTradeColors.border, height: 1),
                  _buildToggleRow(
                    'Push Notifications',
                    Icons.notifications_outlined,
                    _notificationsEnabled,
                        (val) async {
                      setState(() => _notificationsEnabled = val);
                      await HiveService.saveSetting('notifications', val);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            // ── Menu Items (all with navigation) ─────────────────────
            NexCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.account_balance_wallet_outlined,
                    'Bank Accounts',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BankAccountsScreen())),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.shield_outlined,
                    'Security',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SecurityScreen())),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.headset_mic_outlined,
                    'Help & Support',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.description_outlined,
                    'Reports & Statements',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ReportsScreen())),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    Icons.info_outline,
                    'About NexTrade',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            NexButton(
              text: 'Logout',
              isOutlined: true,
              color: NexTradeColors.loss,
              onPressed: () => _showLogoutDialog(context),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            const Text(
              'NexTrade v1.0.0\nSEBI Registered · NSE & BSE Member',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: NexTradeColors.textMuted, fontSize: 11, height: 1.6),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────────

  Widget _buildThemeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.dark_mode_outlined,
              color: NexTradeColors.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Dark Mode',
                  style: TextStyle(
                      color: NexTradeColors.textPrimary, fontSize: 14))),
          Switch.adaptive(
            value: _currentTheme == 'dark',
            onChanged: (val) async {
              setState(() => _currentTheme = val ? 'dark' : 'light');
              await HiveService.saveSetting('theme', val ? 'dark' : 'light');
            },
            activeColor: NexTradeColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: NexTradeColors.textMuted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: NexTradeColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
      String label, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: NexTradeColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: NexTradeColors.textPrimary, fontSize: 14))),
          Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: NexTradeColors.primary),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label,
      {required VoidCallback onTap, Color? labelColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: labelColor ?? NexTradeColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: labelColor ?? NexTradeColors.textPrimary,
                        fontSize: 14))),
            const Icon(Icons.chevron_right,
                color: NexTradeColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      const Divider(color: NexTradeColors.border, height: 1, indent: 16, endIndent: 16);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexTradeColors.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout',
            style: TextStyle(color: NexTradeColors.textPrimary)),
        content: const Text(
            'Are you sure you want to logout? All local cache will be cleared.',
            style: TextStyle(color: NexTradeColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: NexTradeColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await HiveService.clearAll();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NexTradeColors.loss,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}



// ════════════════════════════════════════════════════════════════
// BANK ACCOUNTS SCREEN
// ════════════════════════════════════════════════════════════════
class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {

  List<Map<String, dynamic>> banks = [
    {'name': 'HDFC Bank', 'account': 'XXXX XXXX 4521', 'ifsc': 'HDFC0001234', 'primary': true},
    {'name': 'SBI', 'account': 'XXXX XXXX 8890', 'ifsc': 'SBIN0003456', 'primary': false},
  ];

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final newBank = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBankScreen()),
              );

              if (newBank != null) {
                setState(() {
                  banks.add(newBank);
                });
              }
            },
            icon: const Icon(Icons.add, color: NexTradeColors.primary, size: 18),
            label: const Text('Add Bank',
                style: TextStyle(color: NexTradeColors.primary, fontSize: 13)),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: banks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final b = banks[i];
          return NexCard(
            borderColor:
            b['primary'] == true ? NexTradeColors.primaryDim : null,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: NexTradeColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance,
                      color: NexTradeColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(b['name'] as String,
                              style: const TextStyle(
                                  color: NexTradeColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          if (b['primary'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: NexTradeColors.primaryGlow,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text('Primary',
                                  style: TextStyle(
                                      color: NexTradeColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      Text(b['account'] as String,
                          style: const TextStyle(
                              color: NexTradeColors.textSecondary,
                              fontSize: 13)),
                      Text('IFSC: ${b['ifsc']}',
                          style: const TextStyle(
                              color: NexTradeColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: NexTradeColors.surfaceElevated,
                  icon: const Icon(Icons.more_vert,
                      color: NexTradeColors.textMuted),
                  onSelected: (val) {},
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'primary',
                        child: Text('Set as Primary',
                            style:
                            TextStyle(color: NexTradeColors.textPrimary))),
                    const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove',
                            style: TextStyle(color: NexTradeColors.loss))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// SECURITY SCREEN
// ════════════════════════════════════════════════════════════════
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactor = true;
  bool _loginAlerts = true;
  bool _transactionPin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NexCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildSecurityToggle(
                    '2-Factor Authentication',
                    'Extra OTP on every login',
                    Icons.security,
                    _twoFactor,
                        (v) => setState(() => _twoFactor = v)),
                const Divider(color: NexTradeColors.border, height: 1),
                _buildSecurityToggle(
                    'Login Alerts',
                    'Get notified on new device login',
                    Icons.notifications_active_outlined,
                    _loginAlerts,
                        (v) => setState(() => _loginAlerts = v)),
                const Divider(color: NexTradeColors.border, height: 1),
                _buildSecurityToggle(
                    'Transaction PIN',
                    'Require PIN for every order',
                    Icons.pin_outlined,
                    _transactionPin,
                        (v) => setState(() => _transactionPin = v)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NexCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildActionTile(
                    Icons.lock_outline, 'Change MPIN', () => _changeMpin(context)),
                const Divider(color: NexTradeColors.border, height: 1, indent: 16),
                _buildActionTile(
                    Icons.devices_outlined, 'Manage Devices', () {}),
                const Divider(color: NexTradeColors.border, height: 1, indent: 16),
                _buildActionTile(
                    Icons.history, 'Login History', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityToggle(String title, String subtitle, IconData icon,
      bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: NexTradeColors.primaryGlow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: NexTradeColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: NexTradeColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: NexTradeColors.primary),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: NexTradeColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: NexTradeColors.textPrimary, fontSize: 14))),
            const Icon(Icons.chevron_right,
                color: NexTradeColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _changeMpin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: NexTradeColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Change MPIN',
                style: TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            _buildPinField('Current MPIN'),
            const SizedBox(height: 14),
            _buildPinField('New MPIN'),
            const SizedBox(height: 14),
            _buildPinField('Confirm New MPIN'),
            const SizedBox(height: 24),
            NexButton(
                text: 'Update MPIN',
                onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField(String hint) {
    return TextField(
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: const TextStyle(color: NexTradeColors.textPrimary),
      decoration: InputDecoration(hintText: hint, counterText: ''),
    );
  }
}



class AddBankScreen extends StatefulWidget {
  const AddBankScreen({super.key});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text("Add Bank Account"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔥 TOP HIGHLIGHT CARD
            NexCard(
              showGlow: true,
              borderColor: NexTradeColors.primaryDim.withOpacity(0.3),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      gradient: NexTradeColors.primaryGradient,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: const Icon(Icons.account_balance,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Link Your Bank",
                          style: TextStyle(
                              color: NexTradeColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Used for deposits & withdrawals",
                          style: TextStyle(
                              color: NexTradeColors.textMuted,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 INPUT SECTION
            NexCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  _buildInputField(
                    controller: _bankNameController,
                    hint: "Bank Name",
                    icon: Icons.account_balance_outlined,
                  ),
                  const Divider(color: NexTradeColors.border),

                  _buildInputField(
                    controller: _accountController,
                    hint: "Account Number",
                    icon: Icons.credit_card_outlined,
                    keyboard: TextInputType.number,
                  ),
                  const Divider(color: NexTradeColors.border),

                  _buildInputField(
                    controller: _ifscController,
                    hint: "IFSC Code",
                    icon: Icons.qr_code_2_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔥 CTA BUTTON (STRONG)
            SizedBox(
              width: double.infinity,
              child: NexButton(
                text: "Add Bank Account",
                onPressed: _saveBank,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Your bank details are encrypted & secure 🔒",
              style: TextStyle(
                  color: NexTradeColors.textMuted,
                  fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CLEAN INPUT FIELD
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: NexTradeColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: const TextStyle(color: NexTradeColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                const TextStyle(color: NexTradeColors.textMuted),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 SAVE
  void _saveBank() {
    if (_bankNameController.text.isEmpty ||
        _accountController.text.isEmpty ||
        _ifscController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final bank = {
      'name': _bankNameController.text,
      'account': _accountController.text,
      'ifsc': _ifscController.text,
      'primary': false,
    };

    Navigator.pop(context, bank);
  }
}



// ════════════════════════════════════════════════════════════════
// HELP & SUPPORT SCREEN
// ════════════════════════════════════════════════════════════════
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I add funds to my account?',
        'a': 'Go to Home → Add Funds. You can add via UPI, Net Banking or NEFT/RTGS.'
      },
      {
        'q': 'How long does order execution take?',
        'a': 'Market orders execute instantly during market hours. Limit orders execute when price is met.'
      },
      {
        'q': 'What are the brokerage charges?',
        'a': 'NexTrade charges ₹20 per order or 0.03% (whichever is lower) for intraday. Delivery is free.'
      },
      {
        'q': 'How to withdraw funds?',
        'a': 'Go to Portfolio → Funds → Withdraw. Amount reflects in your bank within 1 working day.'
      },
      {
        'q': 'What is CNC vs MIS?',
        'a': 'CNC is for delivery trades (holdings). MIS is for intraday trades that auto-square off by 3:15 PM.'
      },
    ];

    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Contact options
          Row(
            children: [
              Expanded(
                  child: _buildContactCard(
                      Icons.chat_bubble_outline, 'Live Chat', 'Online now',
                      NexTradeColors.profit, () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildContactCard(
                      Icons.email_outlined, 'Email Us', 'support@nextrade.in',
                      NexTradeColors.primary, () {})),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildContactCard(
                      Icons.phone_outlined, 'Call Us', '1800-123-4567',
                      NexTradeColors.secondary, () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildContactCard(
                      Icons.article_outlined, 'Raise Ticket', 'Track issues',
                      const Color(0xFF6366F1), () {})),
            ],
          ),
          const SizedBox(height: 24),
          const Text('FAQs',
              style: TextStyle(
                  color: NexTradeColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const SizedBox(height: 12),
          ...faqs.map((faq) => _buildFaqItem(faq['q']!, faq['a']!)),
        ],
      ),
    );
  }

  Widget _buildContactCard(
      IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NexTradeColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NexTradeColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: NexTradeColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            Text(subtitle,
                style: const TextStyle(
                    color: NexTradeColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: NexTradeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexTradeColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: NexTradeColors.primary,
        collapsedIconColor: NexTradeColors.textMuted,
        title: Text(question,
            style: const TextStyle(
                color: NexTradeColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer,
                style: const TextStyle(
                    color: NexTradeColors.textSecondary,
                    fontSize: 13,
                    height: 1.6)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// REPORTS & STATEMENTS SCREEN
// ════════════════════════════════════════════════════════════════
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {'icon': Icons.receipt_long_outlined, 'title': 'Contract Notes', 'subtitle': 'Daily trade confirmations', 'color': NexTradeColors.primary},
      {'icon': Icons.account_balance_outlined, 'title': 'P&L Statement', 'subtitle': 'Profit & Loss summary', 'color': NexTradeColors.profit},
      {'icon': Icons.savings_outlined, 'title': 'Capital Gains', 'subtitle': 'Tax computation report', 'color': NexTradeColors.secondary},
      {'icon': Icons.swap_horiz, 'title': 'Ledger', 'subtitle': 'Fund inflows & outflows', 'color': const Color(0xFF6366F1)},
      {'icon': Icons.inventory_2_outlined, 'title': 'Holdings Report', 'subtitle': 'Current portfolio snapshot', 'color': const Color(0xFFEC4899)},
      {'icon': Icons.file_download_outlined, 'title': 'Annual Statement', 'subtitle': 'Full year summary', 'color': NexTradeColors.loss},
    ];

    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('Reports & Statements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Financial year selector
          NexCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: NexTradeColors.primary, size: 18),
                const SizedBox(width: 10),
                const Text('Financial Year: ',
                    style: TextStyle(
                        color: NexTradeColors.textMuted, fontSize: 13)),
                const Text('2024–25',
                    style: TextStyle(
                        color: NexTradeColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down,
                    color: NexTradeColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: reports.map((r) {
              final color = r['color'] as Color;
              return GestureDetector(
                onTap: () {},
                child: NexCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(r['icon'] as IconData, color: color, size: 20),
                      ),
                      const Spacer(),
                      Text(r['title'] as String,
                          style: const TextStyle(
                              color: NexTradeColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(r['subtitle'] as String,
                          style: const TextStyle(
                              color: NexTradeColors.textMuted, fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ABOUT SCREEN
// ════════════════════════════════════════════════════════════════
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        title: const Text('About NexTrade'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: NexTradeColors.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: NexTradeColors.primary.withOpacity(0.3),
                          blurRadius: 24,
                          spreadRadius: 4)
                    ],
                  ),
                  child: const Icon(Icons.candlestick_chart_rounded,
                      color: NexTradeColors.background, size: 40),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (b) =>
                      NexTradeColors.primaryGradient.createShader(b),
                  child: const Text('NexTrade',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                const Text('Version 1.0.0',
                    style: TextStyle(
                        color: NexTradeColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'NexTrade is a next-generation stock trading platform built for speed, simplicity, and reliability. '
                'Trade equities, F&O, and mutual funds across NSE & BSE with real-time data and advanced analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: NexTradeColors.textSecondary, fontSize: 14, height: 1.7),
          ),
          const SizedBox(height: 28),
          NexCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildAboutRow('SEBI Registration', 'INZ000123456'),
                _buildAboutRow('NSE Member', 'NSE/MEM/12345'),
                _buildAboutRow('BSE Member', 'BSE/MEM/67890'),
                _buildAboutRow('Depository (CDSL)', 'IN-DP-000000-2023'),
                _buildAboutRow('Registered Office', 'Mumbai, Maharashtra'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          NexCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildLinkTile(Icons.description_outlined, 'Terms & Conditions'),
                const Divider(color: NexTradeColors.border, height: 1, indent: 16),
                _buildLinkTile(Icons.privacy_tip_outlined, 'Privacy Policy'),
                const Divider(color: NexTradeColors.border, height: 1, indent: 16),
                _buildLinkTile(Icons.gavel_outlined, 'Disclaimer'),
                const Divider(color: NexTradeColors.border, height: 1, indent: 16),
                _buildLinkTile(Icons.open_in_new, 'Visit Website'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: NexTradeColors.textMuted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: NexTradeColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: NexTradeColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: NexTradeColors.textPrimary, fontSize: 14))),
            const Icon(Icons.chevron_right,
                color: NexTradeColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}