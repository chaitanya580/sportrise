import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String userId;
  const StudentDashboardScreen({super.key, required this.userId});
  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _xpHistory = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final user    = await SRService.getUserById(widget.userId);
      final profile = await SRService.getStudentProfile(widget.userId);
      final xpHist  = await SRService.getXPHistory(widget.userId);
      if (mounted) setState(() {
        _user = user; _profile = profile; _xpHistory = xpHist; _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final xp       = _profile?['xp_total'] as int? ?? 0;
    final level    = _profile?['level'] as int? ?? 1;
    final lvName   = _profile?['level_name'] as String? ?? 'Rookie';
    final isNP     = _profile?['is_national_prospect'] as bool? ?? false;
    final lvData   = LevelSystem.fromXP(xp);
    final nextXP   = lvData['max'] as int;
    final xpLeft   = (nextXP - xp).clamp(0, 99999);
    final lvColor  = SRColors.levelColors[level - 1];

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SRColors.orange))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: SRColors.orange,
              child: CustomScrollView(slivers: [

                // ── HEADER ──────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: SRColors.navy,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [SRColors.navyLight, SRColors.navy],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // Top bar
                            Row(children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Good morning 👋',
                                  style: GoogleFonts.inter(color: SRColors.muted, fontSize: 13)),
                                Text(_user?['name'] as String? ?? 'Athlete',
                                  style: GoogleFonts.poppins(color: Colors.white,
                                    fontSize: 20, fontWeight: FontWeight.w700)),
                              ]),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                onPressed: () {},
                              ),
                              CircleAvatar(
                                radius: 20, backgroundColor: SRColors.orange,
                                child: Text((_user?['name'] as String? ?? 'A')[0].toUpperCase(),
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                            ]),

                            const SizedBox(height: 20),

                            // Level badge
                            LevelBadge(level: level, levelName: lvName, large: true),
                            const SizedBox(height: 12),

                            // XP display
                            Row(children: [
                              Text('$xp', style: GoogleFonts.spaceGrotesk(
                                color: lvColor, fontSize: 36, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 6),
                              Text('XP', style: GoogleFonts.spaceGrotesk(
                                color: lvColor.withValues(alpha:0.6), fontSize: 20, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              if (!isNP) Text('$xpLeft XP to next level',
                                style: GoogleFonts.inter(color: SRColors.muted, fontSize: 12)),
                            ]),
                            const SizedBox(height: 8),
                            XPProgressBar(xp: xp, height: 10),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── BODY ────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(delegate: SliverChildListDelegate([

                    // NP Banner
                    if (isNP) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            SRColors.gold.withValues(alpha:0.2),
                            SRColors.orange.withValues(alpha:0.1),
                          ]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: SRColors.gold.withValues(alpha:0.5)),
                          boxShadow: [BoxShadow(color: SRColors.gold.withValues(alpha:0.15), blurRadius: 20)],
                        ),
                        child: Row(children: [
                          const Text('⭐', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('National Prospect', style: GoogleFonts.poppins(
                              color: SRColors.gold, fontSize: 16, fontWeight: FontWeight.w700)),
                            Text('You\'re now visible to national scouts across India.',
                              style: GoogleFonts.inter(color: SRColors.gold.withValues(alpha:0.8), fontSize: 12)),
                          ])),
                        ]),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Quick Actions
                    const SRSectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 14),
                    Row(children: [
                      _QuickAction(icon: Icons.sports_rounded, label: 'Find Coach', color: SRColors.orange,
                        onTap: () => Navigator.pushNamed(context, '/coaches')),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.emoji_events_rounded, label: 'Tournaments', color: SRColors.gold,
                        onTap: () => Navigator.pushNamed(context, '/tournaments', arguments: widget.userId)),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.bolt_rounded, label: 'My XP', color: const Color(0xFF2E86DE),
                        onTap: () => Navigator.pushNamed(context, '/xp', arguments: widget.userId)),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.person_rounded, label: 'Profile', color: const Color(0xFF8E44AD),
                        onTap: () => Navigator.pushNamed(context, '/profile', arguments: widget.userId)),
                    ]),

                    const SizedBox(height: 28),

                    // Stats row
                    const SRSectionHeader(title: 'My Stats'),
                    const SizedBox(height: 14),
                    Row(children: [
                      StatCard(value: '$xp', label: 'Total XP', color: SRColors.orange),
                      const SizedBox(width: 12),
                      StatCard(value: '$level', label: 'Level', color: lvColor),
                      const SizedBox(width: 12),
                      StatCard(value: '${_xpHistory.length}', label: 'XP Events', color: const Color(0xFF2E86DE)),
                    ]),

                    const SizedBox(height: 28),

                    // Recent XP activity
                    const SRSectionHeader(title: 'Recent XP Activity'),
                    const SizedBox(height: 14),
                    if (_xpHistory.isEmpty)
                      const SREmptyState(
                        icon: Icons.bolt_rounded,
                        title: 'No XP yet',
                        subtitle: 'Book your first coaching session to start earning XP',
                      )
                    else
                      ...(_xpHistory.take(5).map((tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SRCard(child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: SRColors.orange.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.bolt_rounded, color: SRColors.orange, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(_formatSource(tx['source_type'] as String? ?? ''),
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(_formatDate(tx['created_at'] as String? ?? ''),
                              style: GoogleFonts.inter(color: SRColors.muted, fontSize: 11)),
                          ])),
                          XPChip(xp: tx['xp_amount'] as int? ?? 0),
                        ])),
                      ))).toList(),

                    const SizedBox(height: 24),
                  ])),
                ),
              ]),
            ),
      bottomNavigationBar: _BottomNav(currentIndex: 0, userId: widget.userId),
    );
  }

  String _formatSource(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) { return ''; }
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha:0.25)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final String userId;
  const _BottomNav({required this.currentIndex, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        switch (i) {
          case 0: Navigator.pushReplacementNamed(context, '/dashboard', arguments: userId);
          case 1: Navigator.pushNamed(context, '/coaches');
          case 2: Navigator.pushNamed(context, '/tournaments', arguments: userId);
          case 3: Navigator.pushNamed(context, '/profile', arguments: userId);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Coaches'),
        BottomNavigationBarItem(icon: Icon(Icons.emoji_events_rounded), label: 'Compete'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
    );
  }
}
