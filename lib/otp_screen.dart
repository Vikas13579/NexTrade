import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextrade/profilr_model.dart';
import 'package:nextrade/widgets.dart'; // Ensure NexButton is in here
import 'app_theme.dart';
import 'hive_service.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startTimer() async {
    while (_resendSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _resendSeconds--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexTradeColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: NexTradeColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: NexTradeColors.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verify OTP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: NexTradeColors.textPrimary)),
              const SizedBox(height: 8),
              Text('We sent a 6-digit OTP to +91 ${widget.phone}', style: const TextStyle(color: NexTradeColors.textSecondary)),
              const SizedBox(height: 40),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),

              const SizedBox(height: 32),
              Center(
                child: _resendSeconds > 0
                    ? Text('Resend OTP in $_resendSeconds s', style: const TextStyle(color: NexTradeColors.textMuted))
                    : TextButton(
                  onPressed: () { setState(() => _resendSeconds = 30); _startTimer(); },
                  child: const Text('Resend OTP', style: TextStyle(color: NexTradeColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              NexButton(
                text: 'Verify & Login',
                isLoading: _isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NexTradeColors.textPrimary),
        decoration: InputDecoration(
          counterText: '',
          fillColor: NexTradeColors.surface,
          filled: true,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexTradeColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexTradeColors.primary, width: 2)),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
          if (val.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
        },
      ),
    );
  }

  void _verify() async {
    setState(() => _isLoading = true);

    // 🔥 STEP 1: VALIDATE OTP FIRST (HERE ONLY)
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    // 🔥 STEP 2: SIMULATE / CALL API
    await Future.delayed(const Duration(seconds: 1));

    // 🔥 STEP 3: SAVE LOGIN STATE
    await HiveService.saveSetting('isLoggedIn', true);

    // 🔥 STEP 4: ENSURE PROFILE EXISTS
    final existing = HiveService.getProfile();

    if (existing == null) {
      await HiveService.saveProfile(
        ProfileModel(
          name: "Vikas P Shetty",
          email: "vikasshetty1312@email.com",
          phone: widget.phone,
        ),
      );
    }

    setState(() => _isLoading = false);

    // 🔥 STEP 5: NAVIGATE
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    }
  }
  // void _verify() async {
  //   setState(() => _isLoading = true);
  //   await Future.delayed(const Duration(seconds: 1)); // Simulate API call
  //   await HiveService.saveSetting('isLoggedIn', true);
  //   if (mounted) {
  //     // Clears login history so user can't "Go Back" to OTP
  //     Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  //   }
  // }
}