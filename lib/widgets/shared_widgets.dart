import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../services/sr_service.dart';

// ── SR BUTTON ─────────────────────────────────────────────────
class SRButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool outlined;
  final Color? color;
  const SRButton({super.key, required this.label, this.onTap,
    this.loading = false, this.outlined = false, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 54,
      child: outlined
          ? OutlinedButton(
              onPressed: loading ? null : onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color ?? SRColors.orange),
                foregroundColor: color ?? SRColors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: SRColors.orange))
                  : Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
            )
          : ElevatedButton(
              onPressed: loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? SRColors.orange,
                disabledBackgroundColor: SRColors.orange.withValues(alpha:0.5),
              ),
              child: loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(label),
            ),
    );
  }
}

// ── SR TEXT FIELD ─────────────────────────────────────────────
class SRTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final int? maxLength;
  final Widget? prefix;
  const SRTextField({super.key, required this.label, required this.controller,
    this.hint, this.keyboardType, this.obscure = false,
    this.validator, this.maxLength, this.prefix});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      validator: validator,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: prefix,
      ),
    );
  }
}

// ── SR CARD ───────────────────────────────────────────────────
class SRCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  const SRCard({super.key, required this.child, this.padding, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? SRColors.navyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SRColors.line),
        ),
        padding: padding ?? const EdgeInsets.all(18),
        child: child,
      ),
    );
  }
}

// ── XP PROGRESS BAR ───────────────────────────────────────────
class XPProgressBar extends StatelessWidget {
  final int xp;
  final double height;
  const XPProgressBar({super.key, required this.xp, this.height = 8});

  @override
  Widget build(BuildContext context) {
    final progress = LevelSystem.progressInLevel(xp);
    final levelData = LevelSystem.fromXP(xp);
    final level = levelData['level'] as int;
    final levelColor = SRColors.levelColors[level - 1];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: height,
          backgroundColor: Colors.white.withValues(alpha:0.1),
          valueColor: AlwaysStoppedAnimation<Color>(levelColor),
        ),
      ),
    ]);
  }
}

// ── LEVEL BADGE ───────────────────────────────────────────────
class LevelBadge extends StatelessWidget {
  final int level;
  final String levelName;
  final bool large;
  const LevelBadge({super.key, required this.level,
    required this.levelName, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = SRColors.levelColors[level - 1];
    final isNP = level >= 7;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 16 : 10, vertical: large ? 8 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha:isNP ? 0.7 : 0.4)),
        boxShadow: isNP ? [BoxShadow(color: color.withValues(alpha:0.3), blurRadius: 12)] : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (isNP) ...[
          Icon(Icons.star_rounded, color: color, size: large ? 18 : 13),
          const SizedBox(width: 4),
        ],
        Text(
          'L$level · $levelName',
          style: GoogleFonts.spaceGrotesk(
            color: color,
            fontSize: large ? 15 : 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    );
  }
}

// ── XP CHIP ───────────────────────────────────────────────────
class XPChip extends StatelessWidget {
  final int xp;
  const XPChip({super.key, required this.xp});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: SRColors.gold.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: SRColors.gold.withValues(alpha:0.4)),
      ),
      child: Text(
        '+$xp XP',
        style: GoogleFonts.spaceGrotesk(color: SRColors.gold, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── SECTION HEADER ────────────────────────────────────────────
class SRSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SRSectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: GoogleFonts.inter(color: SRColors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
    ]);
  }
}

// ── STAT CARD ─────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const StatCard({super.key, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha:0.25)),
        ),
        child: Column(children: [
          Text(value, style: GoogleFonts.spaceGrotesk(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 11), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────
class SREmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const SREmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 56, color: SRColors.muted),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
