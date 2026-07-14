import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user    = await SRService.getUserById(widget.userId);
      final profile = await SRService.getStudentProfile(widget.userId);
      if (mounted) setState(() { _user = user; _profile = profile; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final xp     = _profile?['xp_total']  as int?    ?? 0;
    final level  = _profile?['level']     as int?    ?? 1;
    final lvName = _profile?['level_name']as String? ?? 'Rookie';
    final sport  = _profile?['sport']     as String? ?? 'Football';
    final isNP   = _profile?['is_national_prospect'] as bool? ?? false;
    final lvCol  = SRColors.levelColors[level - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SRColors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [

                // Avatar + name
                Center(child: Column(children: [
                  Stack(children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: SRColors.orange.withValues(alpha:0.15),
                      child: Text(
                        (_user?['name'] as String? ?? 'A')[0].toUpperCase(),
                        style: GoogleFonts.poppins(color: SRColors.orange, fontSize: 36, fontWeight: FontWeight.w800)),
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
                  const SizedBox(height: 14),
                  Text(_user?['name'] as String? ?? 'Athlete',
                    style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  LevelBadge(level: level, levelName: lvName, large: true),
                  const SizedBox(height: 6),
                  Text(sport, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 14)),
                ])),

                const SizedBox(height: 28),

                // Stats
                Row(children: [
                  StatCard(value: '$xp',   label: 'Total XP',  color: SRColors.orange),
                  const SizedBox(width: 12),
                  StatCard(value: 'L$level', label: 'Level',   color: lvCol),
                  const SizedBox(width: 12),
                  StatCard(value: isNP ? '⭐' : '—', label: 'NP Badge', color: SRColors.gold),
                ]),

                const SizedBox(height: 24),

                // XP progress
                SRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('XP Progress', style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('$xp XP', style: GoogleFonts.spaceGrotesk(color: lvCol, fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 12),
                  XPProgressBar(xp: xp, height: 10),
                  const SizedBox(height: 8),
                  if (level < 7)
                    Text('${(LevelSystem.fromXP(xp)['max'] as int) - xp} XP until ${LevelSystem.levels[level]['name']}',
                      style: GoogleFonts.inter(color: SRColors.muted, fontSize: 12))
                  else
                    Text('You have reached the highest level!',
                      style: GoogleFonts.inter(color: SRColors.gold, fontSize: 12)),
                ])),

                const SizedBox(height: 16),

                // Profile details
                SRCard(child: Column(children: [
                  _ProfileRow(icon: Icons.location_on_outlined,
                    label: 'City', value: _user?['city'] as String? ?? '—'),
                  const Divider(color: Color(0x1AFFFFFF)),
                  _ProfileRow(icon: Icons.cake_outlined,
                    label: 'Age', value: '${_user?['age'] ?? '—'} years'),
                  const Divider(color: Color(0x1AFFFFFF)),
                  _ProfileRow(icon: Icons.phone_outlined,
                    label: 'Mobile', value: '+91 ${_user?['mobile'] ?? '—'}'),
                  const Divider(color: Color(0x1AFFFFFF)),
                  _ProfileRow(icon: Icons.sports_rounded,
                    label: 'Sport', value: sport, isLast: true),
                ])),

                const SizedBox(height: 24),

                // NP banner
                if (isNP) Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      SRColors.gold.withValues(alpha:0.18), SRColors.orange.withValues(alpha:0.08)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SRColors.gold.withValues(alpha:0.5)),
                  ),
                  child: Row(children: [
                    const Text('⭐', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('National Prospect', style: GoogleFonts.poppins(
                        color: SRColors.gold, fontSize: 17, fontWeight: FontWeight.w800)),
                      Text('You are visible to national scouts across India. Keep competing.',
                        style: GoogleFonts.inter(color: SRColors.gold.withValues(alpha:0.75), fontSize: 12)),
                    ])),
                  ]),
                ),

                const SizedBox(height: 24),

                // Sign out
                SRButton(
                  label: 'Sign Out',
                  outlined: true,
                  color: SRColors.error,
                  onTap: () async {
                    await SRService.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                    }
                  },
                ),

                const SizedBox(height: 32),
              ]),
            ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isLast;
  const _ProfileRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
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
