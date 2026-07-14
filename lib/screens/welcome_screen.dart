import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../services/sr_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 200), _ctrl.forward);

    // Already signed in (persisted Supabase session) → straight to dashboard.
    final userId = SRService.currentUserId;
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard', arguments: userId);
        }
      });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Background field lines
        CustomPaint(painter: _FieldLinesPainter(), child: const SizedBox.expand()),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(children: [
              const Spacer(flex: 2),

              // Logo + brand
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(children: [
                    // S logo mark
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: SRColors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text('S',
                          style: GoogleFonts.poppins(
                            fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('SportRise',
                      style: GoogleFonts.poppins(
                        fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Discover.  Train.  Rise.',
                      style: GoogleFonts.inter(
                        fontSize: 17, color: SRColors.gold,
                        fontStyle: FontStyle.italic, letterSpacing: 0.5)),
                  ]),
                ),
              ),

              const Spacer(flex: 2),

              // Role selection
              FadeTransition(
                opacity: _fade,
                child: Column(children: [
                  Text('I am a', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  _RoleCard(
                    icon: Icons.directions_run_rounded,
                    title: 'Student Athlete',
                    subtitle: 'Find coaches, compete, earn XP',
                    color: SRColors.orange,
                    onTap: () => Navigator.pushNamed(context, '/register/student'),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    icon: Icons.sports_rounded,
                    title: 'Certified Coach',
                    subtitle: 'List your services, grow your students',
                    color: SRColors.gold,
                    onTap: () => Navigator.pushNamed(context, '/register/coach'),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.emoji_events_rounded,
                        title: 'Organizer',
                        subtitle: 'Post tournaments',
                        color: const Color(0xFF2E86DE),
                        onTap: () => Navigator.pushNamed(context, '/register/organizer'),
                        small: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.search_rounded,
                        title: 'Scout',
                        subtitle: 'Find talent',
                        color: const Color(0xFF8E44AD),
                        onTap: () => Navigator.pushNamed(context, '/scout/dashboard'),
                        small: true,
                      ),
                    ),
                  ]),
                ]),
              ),

              const SizedBox(height: 20),

              // Already have account
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Already have an account? Sign in',
                  style: GoogleFonts.inter(color: SRColors.muted, fontSize: 14)),
              ),

              const SizedBox(height: 16),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool small;
  const _RoleCard({required this.icon, required this.title,
    required this.subtitle, required this.color,
    required this.onTap, this.small = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(small ? 14 : 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: small
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 8),
                Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 11)),
              ])
            : Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: color.withValues(alpha:0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 12)),
                ])),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
              ]),
      ),
    );
  }
}

// Subtle field lines background
class _FieldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SRColors.orange.withValues(alpha:0.07)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Diagonal lines
    for (int i = -2; i < 8; i++) {
      final startX = i * (size.width / 5);
      canvas.drawLine(Offset(startX - 50, size.height), Offset(startX + 200, 0), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
