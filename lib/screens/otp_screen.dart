import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

/// Verifies the OTP sent by Supabase Auth to the given mobile number.
///
/// Two modes:
///  - registration: [registration] holds the pending form data; on success
///    the user + student profile rows are created under the auth user id.
///  - login: [registration] is null; on success we look up the existing
///    account and route to the dashboard.
class OTPScreen extends StatefulWidget {
  final String mobile;
  final Map<String, dynamic>? registration;
  const OTPScreen({super.key, required this.mobile, this.registration});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpCtrl = TextEditingController();
  bool _verifying = false;
  int  _resendIn  = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendIn = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendIn <= 1) { t.cancel(); }
      if (mounted) setState(() => _resendIn = (_resendIn - 1).clamp(0, 30));
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: SRColors.error));
  }

  Future<void> _resend() async {
    try {
      await SRService.sendOtp(widget.mobile);
      _startResendTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('OTP re-sent to +91 ${widget.mobile}'),
        ));
      }
    } catch (e) {
      _showSnack('Could not resend OTP. Try again in a moment.');
    }
  }

  Future<void> _verify() async {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      _showSnack('Enter the 6-digit code'); return;
    }
    setState(() => _verifying = true);
    try {
      final userId = await SRService.verifyOtp(mobile: widget.mobile, token: code);

      if (widget.registration != null) {
        final r = widget.registration!;
        await SRService.completeRegistration(
          userId: userId,
          name:   r['name'] as String,
          mobile: widget.mobile,
          age:    r['age'] as int,
          city:   r['city'] as String,
          sport:  r['sport'] as String,
          guardianName:    r['guardianName'] as String?,
          guardianMobile:  r['guardianMobile'] as String?,
          parentalConsent: r['parentalConsent'] as bool? ?? false,
        );
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (_) => false, arguments: userId);
        }
      } else {
        // Login mode: account must already exist.
        final user = await SRService.getUserById(userId);
        if (!mounted) return;
        if (user != null) {
          Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (_) => false, arguments: userId);
        } else {
          _showSnack('No account found for this number — please register first.');
          Navigator.pushReplacementNamed(context, '/register/student');
        }
      }
    } catch (e) {
      final detail = e.toString();
      _showSnack(detail.contains('otp') || detail.contains('token') || detail.contains('expired')
          ? 'Invalid or expired code. Please try again.'
          : 'Verification failed: ${detail.length > 120 ? detail.substring(0, 120) : detail}');
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Mobile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            const Icon(Icons.sms_rounded, color: SRColors.orange, size: 64),
            const SizedBox(height: 24),
            Text('Enter the 6-digit code sent to',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('+91 ${widget.mobile}',
              style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white, fontSize: 28,
                fontWeight: FontWeight.w700, letterSpacing: 12),
              decoration: const InputDecoration(counterText: '', hintText: '······'),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 24),
            SRButton(label: 'Verify and Continue →', onTap: _verify, loading: _verifying),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _resendIn == 0 ? _resend : null,
              child: Text(
                _resendIn == 0 ? 'Resend OTP' : 'Resend OTP in ${_resendIn}s',
                style: GoogleFonts.inter(
                  color: _resendIn == 0 ? SRColors.orange : SRColors.muted)),
            ),
            const Spacer(flex: 2),
          ]),
        ),
      ),
    );
  }
}
