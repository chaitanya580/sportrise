import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

/// Sign-in with mobile number + OTP for existing accounts.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final mobile = _mobileCtrl.text.trim();
      await SRService.sendOtp(mobile);
      if (mounted) {
        Navigator.pushNamed(context, '/otp', arguments: {'mobile': mobile});
      }
    } catch (e) {
      if (mounted) {
        final detail = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not send OTP: ${detail.length > 120 ? detail.substring(0, 120) : detail}'),
          backgroundColor: SRColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Spacer(),
              const Icon(Icons.login_rounded, color: SRColors.orange, size: 64),
              const SizedBox(height: 24),
              Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Enter your registered mobile number and we\'ll send you a verification code.',
                style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SRTextField(
                label: 'Mobile Number',
                hint: '10-digit registered number',
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: Text('+91', style: GoogleFonts.inter(color: SRColors.muted, fontSize: 14)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your mobile number';
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SRButton(label: 'Send OTP →', onTap: _sendOtp, loading: _sending),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/register/student'),
                child: Text('New to SportRise? Create an account',
                  style: GoogleFonts.inter(color: SRColors.muted, fontSize: 14)),
              ),
              const Spacer(flex: 2),
            ]),
          ),
        ),
      ),
    );
  }
}
