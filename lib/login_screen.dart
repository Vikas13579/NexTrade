// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nextrade/profilr_model.dart';
import 'package:nextrade/widgets.dart';
import 'app_theme.dart';
import 'hive_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: NexTradeColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: NexTradeColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.candlestick_chart_rounded,
                          color: NexTradeColors.background,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            NexTradeColors.primaryGradient.createShader(bounds),
                        child: const Text(
                          'NexTrade',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.2),

                  const SizedBox(height: 48),

                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: NexTradeColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),

                  const Text(
                    'Login to your trading account',
                    style: TextStyle(
                      color: NexTradeColors.textSecondary,
                      fontSize: 15,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  // Phone field
                  NexTextField(
                    controller: _phoneController,
                    label: 'Mobile Number',
                    hint: 'Enter 10-digit number',
                    keyboardType: TextInputType.phone,
                    prefix: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🇮🇳  +91', style: TextStyle(color: NexTradeColors.textPrimary, fontSize: 14)),
                          SizedBox(width: 4),
                          VerticalDivider(color: NexTradeColors.border, thickness: 1),
                        ],
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Enter mobile number';
                      if (val.length != 10) return 'Enter valid 10-digit number';
                      return null;
                    },
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 32),

                  NexButton(
                    text: 'Send OTP',
                    isLoading: _isLoading,
                    onPressed: _sendOtp,
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  Row(
                    children: const [
                      Expanded(child: Divider(color: NexTradeColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or', style: TextStyle(color: NexTradeColors.textMuted)),
                      ),
                      Expanded(child: Divider(color: NexTradeColors.border)),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Biometric button
                  NexCard(
                    onTap: _biometricLogin,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.fingerprint, color: NexTradeColors.primary, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Login with Biometric',
                          style: TextStyle(
                            color: NexTradeColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 40),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: NexTradeColors.textSecondary, fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Open Demat Account',
                              style: TextStyle(
                                color: NexTradeColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) Navigator.pushNamed(context, '/otp', arguments: _phoneController.text);
  }

  void _biometricLogin() async {
    HapticFeedback.lightImpact();

    await HiveService.saveSetting('isLoggedIn', true);

    // 🔥 CREATE PROFILE IF NOT EXISTS
    final existingProfile = HiveService.getProfile();

    if (existingProfile == null) {
      await HiveService.saveProfile(
        ProfileModel(
          name: "Vikas P Shetty",
          email: "vikasshetty1312@gmail.com",
          phone: _phoneController.text.isNotEmpty
              ? _phoneController.text
              : "0000000000",
          imagePath: null,
        ),
      );
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

