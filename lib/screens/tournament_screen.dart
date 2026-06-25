import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

class TournamentScreen extends StatefulWidget {
  final String studentId;
  const TournamentScreen({super.key, required this.studentId});
  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  List<Map<String, dynamic>> _tournaments = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await SRService.getVerifiedTournaments();
      if (mounted) setState(() { _tournaments = result; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tournaments', style: Theme.of(context).textTheme.titleLarge)),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SRColors.orange))
          : RefreshIndicator(
              onRefresh: _load,
              color: SRColors.orange,
              child: _tournaments.isEmpty
                  ? const SREmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: 'No tournaments yet',
                      subtitle: 'Check back soon — new tournaments are added weekly',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tournaments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _TournamentCard(
                        tournament: _tournaments[i],
                        studentId: widget.studentId,
                        onRegistered: _load,
                      ),
                    ),
            ),
    );
  }
}

class _TournamentCard extends StatefulWidget {
  final Map<String, dynamic> tournament;
  final String studentId;
  final VoidCallback onRegistered;
  const _TournamentCard({required this.tournament, required this.studentId, required this.onRegistered});
  @override
  State<_TournamentCard> createState() => _TournamentCardState();
}

class _TournamentCardState extends State<_TournamentCard> {
  bool _registering = false;
  bool _registered  = false;

  String _formatDate(String? iso) {
    if (iso == null) return 'TBD';
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(iso));
    } catch (_) { return iso; }
  }

  bool get _isOpen {
    final dl = widget.tournament['registration_deadline'] as String?;
    if (dl == null) return false;
    try { return DateTime.parse(dl).isAfter(DateTime.now()); }
    catch (_) { return false; }
  }

  Future<void> _register() async {
    if (_registered || !_isOpen) return;
    setState(() => _registering = true);
    try {
      await SRService.registerForTournament(
        tournamentId: widget.tournament['id'] as String,
        studentId: widget.studentId,
      );
      if (mounted) {
        setState(() { _registering = false; _registered = true; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: SRColors.success),
            const SizedBox(width: 10),
            Text('Registered! +${XPRules.tournamentReg} XP earned',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        ));
        widget.onRegistered();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _registering = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().contains('unique') ? 'Already registered!' : 'Registration failed'),
          backgroundColor: SRColors.error,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tournament;
    final name  = t['name'] as String? ?? 'Tournament';
    final city  = t['city'] as String? ?? '';
    final venue = t['venue'] as String? ?? '';
    final sport = t['sport'] as String? ?? 'Football';
    final eventDate = _formatDate(t['event_date'] as String?);
    final deadline  = _formatDate(t['registration_deadline'] as String?);

    return SRCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: SRColors.gold.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🏆', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(sport, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 12)),
          ])),
          // Open/Closed badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _isOpen ? SRColors.success.withValues(alpha:0.15) : SRColors.error.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: _isOpen ? SRColors.success.withValues(alpha:0.4) : SRColors.error.withValues(alpha:0.3)),
            ),
            child: Text(_isOpen ? 'Open' : 'Closed',
              style: GoogleFonts.inter(
                color: _isOpen ? SRColors.success : SRColors.error,
                fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),

        const SizedBox(height: 14),
        Divider(color: SRColors.line, height: 1),
        const SizedBox(height: 14),

        // Details grid
        Row(children: [
          _DetailItem(icon: Icons.calendar_today_rounded, label: 'Event Date', value: eventDate),
          const SizedBox(width: 20),
          _DetailItem(icon: Icons.timer_outlined, label: 'Deadline', value: deadline),
        ]),
        const SizedBox(height: 10),
        _DetailItem(icon: Icons.location_on_rounded, label: 'Venue', value: '$venue, $city', full: true),

        const SizedBox(height: 14),

        // XP reward hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: SRColors.gold.withValues(alpha:0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SRColors.gold.withValues(alpha:0.2)),
          ),
          child: Row(children: [
            const Icon(Icons.bolt_rounded, color: SRColors.gold, size: 14),
            const SizedBox(width: 6),
            Text('Register now → +${XPRules.tournamentReg} XP  |  Win → +${XPRules.tournamentWin} XP',
              style: GoogleFonts.inter(color: SRColors.gold, fontSize: 11)),
          ]),
        ),

        const SizedBox(height: 14),

        // Register button
        _registered
            ? Container(
                height: 46,
                decoration: BoxDecoration(
                  color: SRColors.success.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: SRColors.success.withValues(alpha:0.4)),
                ),
                child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_rounded, color: SRColors.success, size: 18),
                  const SizedBox(width: 8),
                  Text('Registered', style: GoogleFonts.poppins(
                    color: SRColors.success, fontSize: 15, fontWeight: FontWeight.w600)),
                ])),
              )
            : SRButton(
                label: _isOpen ? 'Register — 1 Tap →' : 'Registration Closed',
                onTap: _isOpen ? _register : null,
                loading: _registering,
                color: _isOpen ? SRColors.orange : SRColors.muted,
              ),
      ]),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool full;
  const _DetailItem({required this.icon, required this.label, required this.value, this.full = false});

  @override
  Widget build(BuildContext context) {
    final content = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: SRColors.muted, size: 14),
      const SizedBox(width: 5),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 10)),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ]);
    return full ? content : Expanded(child: content);
  }
}
