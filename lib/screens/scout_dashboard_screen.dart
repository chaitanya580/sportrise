import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

class ScoutDashboardScreen extends StatefulWidget {
  const ScoutDashboardScreen({super.key});
  @override
  State<ScoutDashboardScreen> createState() => _ScoutDashboardScreenState();
}

class _ScoutDashboardScreenState extends State<ScoutDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _npAthletes = [];
  List<Map<String, dynamic>> _allAthletes = [];
  bool _loading = true;
  String _filterSport = '';
  String _filterCity  = '';
  int    _filterLevel = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await SRService.searchAthletes(
        sport:    _filterSport.isEmpty ? null : _filterSport,
        city:     _filterCity.isEmpty  ? null : _filterCity,
        minLevel: _filterLevel > 0     ? _filterLevel : null,
      );
      final np  = all.where((a) => a['is_national_prospect'] == true).toList();
      if (mounted) setState(() { _allAthletes = all; _npAthletes = np; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scout Dashboard', style: Theme.of(context).textTheme.titleLarge),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: SRColors.gold,
          labelColor: SRColors.gold,
          unselectedLabelColor: SRColors.muted,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: '⭐ National Prospects (${_npAthletes.length})'),
            Tab(text: 'All Athletes (${_allAthletes.length})'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.tune_rounded, color: SRColors.orange),
            onPressed: _showFilters),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: SRColors.orange))
          : TabBarView(controller: _tabs, children: [
              // NP Tab
              _npAthletes.isEmpty
                  ? const SREmptyState(
                      icon: Icons.star_border_rounded,
                      title: 'No National Prospects yet',
                      subtitle: 'Athletes who reach 2001+ XP, win 3+ tournaments, or earn exceptional ratings from 3+ coaches will appear here',
                    )
                  : _AthleteList(athletes: _npAthletes, isNPList: true),

              // All athletes tab
              _allAthletes.isEmpty
                  ? const SREmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No athletes match your filters',
                      subtitle: 'Try adjusting the sport, city, or level filters',
                    )
                  : _AthleteList(athletes: _allAthletes, isNPList: false),
            ]),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SRColors.navyLight,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ScoutFilterSheet(
        sport: _filterSport, city: _filterCity, level: _filterLevel,
        onApply: (sport, city, level) {
          setState(() { _filterSport = sport; _filterCity = city; _filterLevel = level; });
          _load();
        },
      ),
    );
  }
}

class _AthleteList extends StatelessWidget {
  final List<Map<String, dynamic>> athletes;
  final bool isNPList;
  const _AthleteList({required this.athletes, required this.isNPList});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: athletes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AthleteCard(athlete: athletes[i], highlight: isNPList),
    );
  }
}

class _AthleteCard extends StatelessWidget {
  final Map<String, dynamic> athlete;
  final bool highlight;
  const _AthleteCard({required this.athlete, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final name  = (athlete['user']?['name']  as String?) ?? (athlete['users']?['name'] as String?) ?? 'Athlete';
    final city  = (athlete['user']?['city']  as String?) ?? '';
    final xp    = athlete['xp_total']  as int? ?? 0;
    final level = athlete['level']     as int? ?? 1;
    final lvName= athlete['level_name']as String? ?? 'Rookie';
    final isNP  = athlete['is_national_prospect'] as bool? ?? false;
    final lvCol = SRColors.levelColors[level - 1];

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/athlete/profile', arguments: athlete),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNP ? SRColors.gold.withValues(alpha:0.08) : SRColors.navyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isNP ? SRColors.gold.withValues(alpha:0.4) : SRColors.line),
          boxShadow: isNP ? [BoxShadow(color: SRColors.gold.withValues(alpha:0.12), blurRadius: 12)] : null,
        ),
        child: Row(children: [
          // Rank number
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: lvCol.withValues(alpha:0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isNP
                  ? const Icon(Icons.star_rounded, color: SRColors.gold, size: 24)
                  : Text('L$level', style: GoogleFonts.spaceGrotesk(
                      color: lvCol, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(name, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              if (isNP) ...[
                const SizedBox(width: 6),
                const Text('⭐', style: TextStyle(fontSize: 13)),
              ],
            ]),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.location_on_outlined, color: SRColors.muted, size: 12),
              const SizedBox(width: 3),
              Text(city, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              LevelBadge(level: level, levelName: lvName),
              const Spacer(),
              Text('$xp XP', style: GoogleFonts.spaceGrotesk(
                color: lvCol, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ])),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_ios_rounded, color: SRColors.muted, size: 14),
        ]),
      ),
    );
  }
}

class _ScoutFilterSheet extends StatefulWidget {
  final String sport, city;
  final int level;
  final Function(String, String, int) onApply;
  const _ScoutFilterSheet({required this.sport, required this.city,
    required this.level, required this.onApply});
  @override
  State<_ScoutFilterSheet> createState() => _ScoutFilterSheetState();
}

class _ScoutFilterSheetState extends State<_ScoutFilterSheet> {
  late String _sport, _city;
  late int    _level;

  static const _sports = ['', 'Football', 'Cricket', 'Kabaddi', 'Badminton', 'Athletics'];
  static const _cities = ['', 'Hyderabad', 'Secunderabad', 'Warangal', 'Karimnagar'];
  static const _levels = [0, 3, 5, 7];
  static const _lLabels = ['Any level', 'Level 3+', 'Level 5+', 'Level 7 only'];

  @override
  void initState() {
    super.initState();
    _sport = widget.sport; _city = widget.city; _level = widget.level;
  }

  Widget _section(String title, List<String> options, String selected, ValueChanged<String> onSelect) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: options.map((o) {
        final sel = o == selected;
        return ChoiceChip(
          label: Text(o.isEmpty ? 'Any' : o),
          selected: sel,
          onSelected: (_) => onSelect(o),
          selectedColor: SRColors.orange.withValues(alpha:0.2),
          backgroundColor: SRColors.navyLight,
          side: BorderSide(color: sel ? SRColors.orange : SRColors.line),
          labelStyle: GoogleFonts.inter(color: sel ? SRColors.orange : Colors.white, fontSize: 13),
        );
      }).toList()),
      const SizedBox(height: 20),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Search Filters', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        _section('Sport', _sports, _sport, (v) => setState(() => _sport = v)),
        _section('City', _cities, _city, (v) => setState(() => _city = v)),
        Text('Minimum Level', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: List.generate(_levels.length, (i) {
          final sel = _levels[i] == _level;
          return ChoiceChip(
            label: Text(_lLabels[i]),
            selected: sel,
            onSelected: (_) => setState(() => _level = _levels[i]),
            selectedColor: SRColors.orange.withValues(alpha:0.2),
            backgroundColor: SRColors.navyLight,
            side: BorderSide(color: sel ? SRColors.orange : SRColors.line),
            labelStyle: GoogleFonts.inter(color: sel ? SRColors.orange : Colors.white, fontSize: 13),
          );
        })),
        const SizedBox(height: 24),
        SRButton(label: 'Search Athletes', onTap: () {
          widget.onApply(_sport, _city, _level);
          Navigator.pop(context);
        }),
      ]),
    );
  }
}
