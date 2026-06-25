import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

class XPLevelScreen extends StatefulWidget {
  final String userId;
  const XPLevelScreen({super.key, required this.userId});
  @override
  State<XPLevelScreen> createState() => _XPLevelScreenState();
}

class _XPLevelScreenState extends State<XPLevelScreen> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await SRService.getStudentProfile(widget.userId);
      final history = await SRService.getXPHistory(widget.userId);
      if (mounted) setState(() { _profile = profile; _history = history; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final xp      = _profile?['xp_total'] as int? ?? 0;
    final level   = _profile?['level'] as int? ?? 1;
    final lvName  = _profile?['level_name'] as String? ?? 'Rookie';

    return Scaffold(
      appBar: AppBar(title: Text('XP & Levels', style: Theme.of(context).textTheme.titleLarge)),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SRColors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Current XP card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SRColors.navyLight, SRColors.navy.withValues(alpha:0.8)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SRColors.levelColors[level - 1].withValues(alpha:0.4)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    LevelBadge(level: level, levelName: lvName, large: true),
                    const SizedBox(height: 16),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('$xp', style: GoogleFonts.spaceGrotesk(
                        color: SRColors.levelColors[level - 1], fontSize: 48, fontWeight: FontWeight.w700)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 6),
                        child: Text('XP', style: GoogleFonts.spaceGrotesk(
                          color: SRColors.levelColors[level - 1].withValues(alpha:0.6),
                          fontSize: 22, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    XPProgressBar(xp: xp, height: 12),
                    const SizedBox(height: 8),
                    if (level < 7)
                      Text('${(LevelSystem.fromXP(xp)['max'] as int) - xp} XP to ${LevelSystem.levels[level]['name']}',
                        style: GoogleFonts.inter(color: SRColors.muted, fontSize: 13))
                    else
                      Text('🏆 Maximum level achieved — visible to national scouts!',
                        style: GoogleFonts.inter(color: SRColors.gold, fontSize: 13)),
                  ]),
                ),

                const SizedBox(height: 28),

                // Level ladder
                const SRSectionHeader(title: 'The Climb'),
                const SizedBox(height: 14),
                ...LevelSystem.levels.asMap().entries.map((e) {
                  final i      = e.key;
                  final l      = e.value;
                  final lvNum  = l['level'] as int;
                  final lvNm   = l['name'] as String;
                  final min    = l['min'] as int;
                  final max    = l['max'] as int;
                  final col    = SRColors.levelColors[i];
                  final done   = xp >= min;
                  final active = lvNum == level;
                  final isNpRow = lvNum == 7;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: isNpRow && done
                          ? SRColors.gold.withValues(alpha:0.1)
                          : active ? col.withValues(alpha:0.1) : SRColors.navyLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active ? col : isNpRow && done ? SRColors.gold.withValues(alpha:0.5) : SRColors.line,
                        width: active ? 1.5 : 1,
                      ),
                      boxShadow: isNpRow && done
                          ? [BoxShadow(color: SRColors.gold.withValues(alpha:0.2), blurRadius: 16)]
                          : null,
                    ),
                    child: Row(children: [
                      // Level number
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: done ? col.withValues(alpha:0.2) : Colors.white.withValues(alpha:0.05),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Center(child: done
                            ? Icon(isNpRow ? Icons.star_rounded : Icons.check_rounded, color: col, size: 20)
                            : Text('L$lvNum', style: GoogleFonts.spaceGrotesk(
                                color: SRColors.muted, fontSize: 11, fontWeight: FontWeight.w700))),
                      ),
                      const SizedBox(width: 14),
                      // Name and range
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(lvNm, style: GoogleFonts.poppins(
                          color: done ? Colors.white : SRColors.muted,
                          fontSize: 15, fontWeight: FontWeight.w700)),
                        Text(max == 99999 ? '${min}+ XP' : '$min – $max XP',
                          style: GoogleFonts.spaceGrotesk(
                            color: done ? col.withValues(alpha:0.8) : SRColors.muted,
                            fontSize: 12, fontWeight: FontWeight.w600)),
                      ])),
                      // Progress or "current"
                      if (active)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: col.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('Current', style: GoogleFonts.inter(
                            color: col, fontSize: 11, fontWeight: FontWeight.w700)),
                        )
                      else if (done)
                        Icon(Icons.check_circle_rounded, color: col, size: 20)
                      else
                        Text('🔒', style: const TextStyle(fontSize: 16)),
                    ]),
                  );
                }).toList(),

                const SizedBox(height: 28),

                // How to earn XP
                const SRSectionHeader(title: 'How to Earn XP'),
                const SizedBox(height: 14),
                SRCard(child: Column(children: [
                  _XPRule('Coach rates 5/5 + Exceptional', 75, SRColors.gold),
                  _XPDivider(),
                  _XPRule('Coach rates 5/5 (standard)', 25, SRColors.orange),
                  _XPDivider(),
                  _XPRule('Coach rates 4/5', 15, SRColors.orange),
                  _XPDivider(),
                  _XPRule('Coach rates 1–3/5', 10, SRColors.muted),
                  _XPDivider(),
                  _XPRule('Tournament registration', 20, const Color(0xFF2E86DE)),
                  _XPDivider(),
                  _XPRule('Tournament match win', 40, SRColors.success),
                  _XPDivider(),
                  _XPRule('Runner-up', 60, SRColors.success),
                  _XPDivider(),
                  _XPRule('Tournament champion', 100, SRColors.gold),
                  _XPDivider(),
                  _XPRule('7-day training streak', 30, const Color(0xFF8E44AD)),
                ])),

                const SizedBox(height: 28),

                // Recent history
                if (_history.isNotEmpty) ...[
                  const SRSectionHeader(title: 'Recent Activity'),
                  const SizedBox(height: 14),
                  ..._history.take(8).map((tx) {
                    final xpAmt = tx['xp_amount'] as int? ?? 0;
                    final src   = (tx['source_type'] as String? ?? '').replaceAll('_', ' ');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SRCard(child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: SRColors.orange.withValues(alpha:0.12),
                            borderRadius: BorderRadius.circular(9)),
                          child: const Icon(Icons.bolt_rounded, color: SRColors.orange, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(src, style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
                        XPChip(xp: xpAmt),
                      ])),
                    );
                  }).toList(),
                ],

                const SizedBox(height: 24),
              ]),
            ),
    );
  }
}

class _XPRule extends StatelessWidget {
  final String label;
  final int xp;
  final Color color;
  const _XPRule(this.label, this.xp, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 13))),
        XPChip(xp: xp),
      ]),
    );
  }
}

class _XPDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(color: SRColors.line, height: 1);
}
