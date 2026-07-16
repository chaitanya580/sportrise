import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

/// Full athlete profile for scouts.
/// Receives the student_profiles row (with embedded `user`) from the scout list.
class AthleteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> athlete;
  const AthleteDetailScreen({super.key, required this.athlete});

  @override
  State<AthleteDetailScreen> createState() => _AthleteDetailScreenState();
}

class _AthleteDetailScreenState extends State<AthleteDetailScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final uid = widget.athlete['user_id'] as String?;
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final h = await SRService.getXPHistory(uid);
      if (mounted) setState(() { _history = h; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatSource(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final a      = widget.athlete;
    final name   = (a['user']?['name'] as String?) ?? 'Athlete';
    final city   = (a['user']?['city'] as String?) ?? '';
    final age    = a['user']?['age'];
    final sport  = (a['sport'] as String?) ?? '';
    final xp     = a['xp_total'] as int? ?? 0;
    final level  = a['level'] as int? ?? 1;
    final lvName = (a['level_name'] as String?) ?? 'Rookie';
    final isNP   = a['is_national_prospect'] as bool? ?? false;
    final lvCol  = SRColors.levelColors[level - 1];

    return Scaffold(
      appBar: AppBar(title: Text(name, style: Theme.of(context).textTheme.titleLarge)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Center(child: Column(children: [
            Stack(children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: lvCol.withValues(alpha: 0.15),
                child: Text(name[0].toUpperCase(),
                  style: GoogleFonts.poppins(color: lvCol, fontSize: 34, fontWeight: FontWeight.w800)),
              ),
              if (isNP) Positioned(
                right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: SRColors.gold, shape: BoxShape.circle,
                    border: Border.all(color: SRColors.navy, width: 2)),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            LevelBadge(level: level, levelName: lvName, large: true),
          ])),

          const SizedBox(height: 24),

          // Stats
          Row(children: [
            StatCard(value: '$xp', label: 'Total XP', color: lvCol),
            const SizedBox(width: 12),
            StatCard(value: 'L$level', label: 'Level', color: SRColors.orange),
            const SizedBox(width: 12),
            StatCard(value: isNP ? '⭐' : '—', label: 'Prospect', color: SRColors.gold),
          ]),

          const SizedBox(height: 24),

          // XP progress
          SRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Progress', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            XPProgressBar(xp: xp, height: 10),
            const SizedBox(height: 8),
            Text(level < 7
                ? '${(LevelSystem.fromXP(xp)['max'] as int) - xp} XP to ${LevelSystem.levels[level]['name']}'
                : 'National Prospect — top tier',
              style: GoogleFonts.inter(color: SRColors.muted, fontSize: 12)),
          ])),

          const SizedBox(height: 16),

          // Profile details
          SRCard(child: Column(children: [
            _row(Icons.sports_rounded, 'Sport', sport),
            const Divider(color: Color(0x1AFFFFFF)),
            _row(Icons.location_on_outlined, 'City', city),
            const Divider(color: Color(0x1AFFFFFF)),
            _row(Icons.cake_outlined, 'Age', age == null ? '—' : '$age years', isLast: true),
          ])),

          const SizedBox(height: 24),

          // Performance timeline
          const SRSectionHeader(title: 'Performance History'),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: SRColors.orange)))
          else if (_history.isEmpty)
            const SREmptyState(
              icon: Icons.timeline_rounded,
              title: 'No activity yet',
              subtitle: 'This athlete has not earned XP from sessions or tournaments yet')
          else
            ..._history.map((tx) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SRCard(child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: SRColors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9)),
                  child: const Icon(Icons.bolt_rounded, color: SRColors.orange, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Text(_formatSource(tx['source_type'] as String? ?? ''),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
                XPChip(xp: tx['xp_amount'] as int? ?? 0),
              ])),
            )),

          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLast ? 4 : 10),
      child: Row(children: [
        Icon(icon, color: SRColors.orange, size: 18),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 11)),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}
