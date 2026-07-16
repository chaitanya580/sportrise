import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

/// Full coach profile with a session-booking flow.
/// Receives the coach_profiles row (with embedded `users`) from discovery.
class CoachDetailScreen extends StatefulWidget {
  final Map<String, dynamic> coach;
  const CoachDetailScreen({super.key, required this.coach});

  @override
  State<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends State<CoachDetailScreen> {
  bool _booking = false;

  String get _name => (widget.coach['users']?['name'] as String?) ?? 'Coach';
  String? get _coachUserId => widget.coach['user_id'] as String?;

  Future<void> _book() async {
    final studentId = SRService.currentUserId;
    if (studentId == null) {
      _snack('Please sign in as a student to book a session.', error: true);
      return;
    }
    if (_coachUserId == null) {
      _snack('This coach cannot be booked right now.', error: true);
      return;
    }

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now.add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: SRColors.orange, surface: SRColors.navyLight,
            onSurface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    setState(() => _booking = true);
    try {
      await SRService.bookSession(
        coachId: _coachUserId!,
        studentId: studentId,
        sessionDate: date,
      );
      if (mounted) {
        _snack('Session booked with $_name on ${DateFormat('d MMM yyyy').format(date)}');
      }
    } catch (e) {
      final d = e.toString();
      _snack('Booking failed: ${d.length > 120 ? d.substring(0, 120) : d}', error: true);
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? SRColors.error : SRColors.navyLight,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c        = widget.coach;
    final city     = (c['city'] as String?) ?? '';
    final sport    = (c['sport'] as String?) ?? '';
    final fee      = c['fee_per_session'] as int? ?? 0;
    final rating   = (c['avg_rating'] as num?)?.toDouble() ?? 0;
    final sessions = c['total_sessions'] as int? ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(_name, style: Theme.of(context).textTheme.titleLarge)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: SRColors.orange.withValues(alpha: 0.15),
              child: Text(_name[0].toUpperCase(),
                style: GoogleFonts.poppins(color: SRColors.orange, fontSize: 32, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: SRColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SRColors.success.withValues(alpha: 0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.verified_rounded, color: SRColors.success, size: 12),
                    const SizedBox(width: 4),
                    Text('Verified', style: GoogleFonts.inter(
                      color: SRColors.success, fontSize: 10, fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(width: 8),
                Text('$city · $sport', style: GoogleFonts.inter(color: SRColors.muted, fontSize: 13)),
              ]),
            ])),
          ]),

          const SizedBox(height: 24),

          // Stat cards
          Row(children: [
            StatCard(value: rating.toStringAsFixed(1), label: 'Rating', color: SRColors.gold),
            const SizedBox(width: 12),
            StatCard(value: '$sessions', label: 'Sessions', color: SRColors.orange),
            const SizedBox(width: 12),
            StatCard(value: '₹$fee', label: 'Per Session', color: const Color(0xFF2E86DE)),
          ]),

          const SizedBox(height: 24),

          // About
          const SRSectionHeader(title: 'About'),
          const SizedBox(height: 12),
          SRCard(child: Text(
            '$_name is a verified $sport coach based in $city with $sport coaching '
            'experience across $sessions completed sessions and a $rating-star average '
            'rating from student athletes on SportRise.',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5))),

          const SizedBox(height: 24),

          // XP note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SRColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SRColors.gold.withValues(alpha: 0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.bolt_rounded, color: SRColors.gold, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Every rated session earns you XP toward National Prospect — up to +75 for an exceptional rating.',
                style: GoogleFonts.inter(color: SRColors.gold, fontSize: 12))),
            ]),
          ),

          const SizedBox(height: 28),

          SRButton(label: 'Book a Session', onTap: _book, loading: _booking),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}
