import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

class CoachDiscoveryScreen extends StatefulWidget {
  const CoachDiscoveryScreen({super.key});
  @override
  State<CoachDiscoveryScreen> createState() => _CoachDiscoveryScreenState();
}

class _CoachDiscoveryScreenState extends State<CoachDiscoveryScreen> {
  List<Map<String, dynamic>> _coaches = [];
  bool _loading = true;
  String _filterCity  = '';
  double _filterRating = 0;
  int    _filterFee   = 10000;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await SRService.getVerifiedCoaches(
        city: _filterCity.isEmpty ? null : _filterCity,
        minRating: _filterRating > 0 ? _filterRating : null,
        maxFee: _filterFee < 10000 ? _filterFee : null,
      );
      if (mounted) setState(() { _coaches = result; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SRColors.navyLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _FilterSheet(
        city: _filterCity, rating: _filterRating, fee: _filterFee,
        onApply: (city, rating, fee) {
          setState(() { _filterCity = city; _filterRating = rating; _filterFee = fee; });
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a Coach', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: SRColors.orange),
            onPressed: _showFilters),
        ],
      ),
      body: Column(children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search coaches by name…',
              prefixIcon: const Icon(Icons.search_rounded, color: SRColors.muted),
              filled: true,
              fillColor: SRColors.navyLight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: SRColors.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: SRColors.line)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: SRColors.orange)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // Filter chips
        if (_filterCity.isNotEmpty || _filterRating > 0 || _filterFee < 10000)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              if (_filterCity.isNotEmpty) _FilterChip(label: _filterCity, onRemove: () {
                setState(() => _filterCity = ''); _load(); }),
              if (_filterRating > 0) _FilterChip(label: '${_filterRating}+ ★', onRemove: () {
                setState(() => _filterRating = 0); _load(); }),
              if (_filterFee < 10000) _FilterChip(label: '≤ ₹$_filterFee', onRemove: () {
                setState(() => _filterFee = 10000); _load(); }),
            ]),
          ),

        // Coach list
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: SRColors.orange))
              : _coaches.isEmpty
                  ? const SREmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No coaches found',
                      subtitle: 'Try removing some filters to see more coaches',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _coaches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _CoachCard(coach: _coaches[i]),
                    ),
        ),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SRColors.orange.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: SRColors.orange.withValues(alpha:0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: GoogleFonts.inter(color: SRColors.orange, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        GestureDetector(onTap: onRemove,
          child: const Icon(Icons.close_rounded, color: SRColors.orange, size: 14)),
      ]),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;
  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    final name    = (coach['users']?['name'] as String?) ?? 'Coach';
    final city    = (coach['city'] as String?) ?? '';
    final fee     = coach['fee_per_session'] as int? ?? 0;
    final rating  = (coach['avg_rating'] as num?)?.toDouble() ?? 0;
    final sessions = coach['total_sessions'] as int? ?? 0;
    final sport   = coach['sport'] as String? ?? '';

    return SRCard(
      onTap: () => Navigator.pushNamed(context, '/coach/profile', arguments: coach),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: SRColors.orange.withValues(alpha:0.15),
          child: Text(name[0].toUpperCase(),
            style: GoogleFonts.poppins(color: SRColors.orange, fontSize: 22, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 14),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(name,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
            // Verified badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: SRColors.success.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SRColors.success.withValues(alpha:0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.verified_rounded, color: SRColors.success, size: 11),
                const SizedBox(width: 3),
                Text('Verified', style: GoogleFonts.inter(color: SRColors.success, fontSize: 9, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, color: SRColors.muted, size: 13),
            const SizedBox(width: 3),
            Text('$city · $sport', style: GoogleFonts.inter(color: SRColors.muted, fontSize: 12)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            // Rating
            Row(children: [
              const Icon(Icons.star_rounded, color: SRColors.gold, size: 15),
              const SizedBox(width: 3),
              Text(rating.toStringAsFixed(1),
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              Text(' ($sessions sessions)',
                style: GoogleFonts.inter(color: SRColors.muted, fontSize: 11)),
            ]),
            const Spacer(),
            // Fee
            Text('₹$fee / session',
              style: GoogleFonts.spaceGrotesk(color: SRColors.orange, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          SRButton(label: 'View Profile', onTap: () =>
            Navigator.pushNamed(context, '/coach/profile', arguments: coach)),
        ])),
      ]),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String city;
  final double rating;
  final int fee;
  final Function(String, double, int) onApply;
  const _FilterSheet({required this.city, required this.rating,
    required this.fee, required this.onApply});
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _city;
  late double _rating;
  late double _fee;

  static const _cities = ['', 'Hyderabad', 'Secunderabad', 'Warangal', 'Karimnagar', 'Nizamabad'];

  @override
  void initState() {
    super.initState();
    _city = widget.city; _rating = widget.rating; _fee = widget.fee.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Filters', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          TextButton(onPressed: () {
            setState(() { _city = ''; _rating = 0; _fee = 10000; });
          }, child: Text('Clear all', style: GoogleFonts.inter(color: SRColors.orange))),
        ]),
        const SizedBox(height: 20),
        Text('City', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: _cities.map((c) {
          final selected = c == _city;
          return ChoiceChip(
            label: Text(c.isEmpty ? 'Any' : c),
            selected: selected,
            onSelected: (_) => setState(() => _city = c),
            selectedColor: SRColors.orange.withValues(alpha:0.2),
            backgroundColor: SRColors.navyLight,
            side: BorderSide(color: selected ? SRColors.orange : SRColors.line),
            labelStyle: GoogleFonts.inter(color: selected ? SRColors.orange : Colors.white, fontSize: 13),
          );
        }).toList()),
        const SizedBox(height: 20),
        Row(children: [
          Text('Minimum Rating', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('${_rating.toStringAsFixed(1)} ★', style: GoogleFonts.spaceGrotesk(color: SRColors.gold, fontWeight: FontWeight.w700)),
        ]),
        Slider(value: _rating, min: 0, max: 5, divisions: 10,
          activeColor: SRColors.gold, inactiveColor: SRColors.line,
          onChanged: (v) => setState(() => _rating = v)),
        const SizedBox(height: 10),
        Row(children: [
          Text('Max Fee', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(_fee < 10000 ? '₹${_fee.round()}' : 'Any',
            style: GoogleFonts.spaceGrotesk(color: SRColors.orange, fontWeight: FontWeight.w700)),
        ]),
        Slider(value: _fee, min: 100, max: 10000, divisions: 99,
          activeColor: SRColors.orange, inactiveColor: SRColors.line,
          onChanged: (v) => setState(() => _fee = v)),
        const SizedBox(height: 20),
        SRButton(
          label: 'Apply Filters',
          onTap: () {
            widget.onApply(_city, _rating, _fee.round());
            Navigator.pop(context);
          },
        ),
      ]),
    );
  }
}
