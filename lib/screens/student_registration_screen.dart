import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/sr_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/sr_service.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});
  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _ageCtrl    = TextEditingController();
  final _mobileCtrl = TextEditingController();

  int    _step       = 0;
  String _selectedCity  = '';
  String _selectedSport = '';
  bool   _loading    = false;

  static const _cities = ['Hyderabad', 'Secunderabad', 'Warangal', 'Karimnagar', 'Nizamabad', 'Other'];
  static const _sports = ['Football', 'Cricket', 'Kabaddi', 'Badminton', 'Athletics', 'Volleyball', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose(); _ageCtrl.dispose(); _mobileCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      if (!_formKey.currentState!.validate()) return;
      if (_selectedCity.isEmpty) {
        _showSnack('Please select your city'); return;
      }
    }
    if (_step == 1 && _selectedSport.isEmpty) {
      _showSnack('Please select your sport'); return;
    }
    if (_step < 2) setState(() => _step++);
    else _submit();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: SRColors.error));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final user = await SRService.registerStudent(
        name:   _nameCtrl.text.trim(),
        mobile: _mobileCtrl.text.trim(),
        age:    int.parse(_ageCtrl.text.trim()),
        city:   _selectedCity,
        sport:  _selectedSport,
      );
      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/otp',
            arguments: {'mobile': _mobileCtrl.text.trim(), 'userId': user['id']});
      }
    } catch (e) {
      _showSnack('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _ProgressBar(step: _step),
        leading: _step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => setState(() => _step--))
            : IconButton(icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 0 ? _Step1(
                    formKey: _formKey, nameCtrl: _nameCtrl,
                    ageCtrl: _ageCtrl, mobileCtrl: _mobileCtrl,
                    cities: _cities, selectedCity: _selectedCity,
                    onCityChanged: (v) => setState(() => _selectedCity = v ?? ''))
                    : _step == 1 ? _Step2(
                        sports: _sports, selectedSport: _selectedSport,
                        onSelect: (s) => setState(() => _selectedSport = s))
                    : _Step3(
                        name: _nameCtrl.text, age: _ageCtrl.text,
                        city: _selectedCity, sport: _selectedSport,
                        mobile: _mobileCtrl.text),
              ),
            ),
            SRButton(
              label: _step < 2 ? 'Continue →' : 'Create My Profile',
              onTap: _nextStep,
              loading: _loading,
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});
  @override
  Widget build(BuildContext context) {
    return Row(children: List.generate(3, (i) => Expanded(
      child: Container(
        height: 4, margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: i <= step ? SRColors.orange : Colors.white.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    )));
  }
}

class _Step1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, ageCtrl, mobileCtrl;
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String?> onCityChanged;
  const _Step1({required this.formKey, required this.nameCtrl,
    required this.ageCtrl, required this.mobileCtrl,
    required this.cities, required this.selectedCity, required this.onCityChanged});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(children: [
        Text('Personal Details', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('Step 1 of 3', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 32),
        SRTextField(
          label: 'Full Name',
          hint: 'e.g. Ravi Teja',
          controller: nameCtrl,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter your full name';
            if (v.trim().length < 2) return 'Name must be at least 2 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        SRTextField(
          label: 'Age',
          hint: '5 – 30',
          controller: ageCtrl,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your age';
            final age = int.tryParse(v);
            if (age == null || age < 5 || age > 30) return 'Age must be between 5 and 30';
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedCity.isEmpty ? null : selectedCity,
          hint: Text('Select your city', style: GoogleFonts.inter(color: const Color(0xFF5D7A96), fontSize: 14)),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          dropdownColor: SRColors.navyLight,
          decoration: const InputDecoration(labelText: 'City'),
          items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onCityChanged,
        ),
        const SizedBox(height: 16),
        SRTextField(
          label: 'Mobile Number',
          hint: '10-digit WhatsApp number',
          controller: mobileCtrl,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Text('+91', style: GoogleFonts.inter(color: SRColors.muted, fontSize: 14)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please enter your mobile number';
            if (v.length != 10 || !RegExp(r'^\d{10}$').hasMatch(v))
              return 'Enter a valid 10-digit number';
            return null;
          },
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _Step2 extends StatelessWidget {
  final List<String> sports;
  final String selectedSport;
  final ValueChanged<String> onSelect;
  const _Step2({required this.sports, required this.selectedSport, required this.onSelect});

  static const _icons = {
    'Football': '⚽', 'Cricket': '🏏', 'Kabaddi': '🤼',
    'Badminton': '🏸', 'Athletics': '🏃', 'Volleyball': '🏐', 'Other': '🏅',
  };

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select Your Sport', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text('Step 2 of 3 · Choose your primary sport',
        style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 32),
      Expanded(
        child: GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: sports.map((s) {
            final selected = s == selectedSport;
            return GestureDetector(
              onTap: () => onSelect(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? SRColors.orange.withValues(alpha:0.15) : SRColors.navyLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? SRColors.orange : SRColors.line,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_icons[s] ?? '🏅', style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(s, style: GoogleFonts.poppins(
                    color: selected ? SRColors.orange : Colors.white,
                    fontSize: 13, fontWeight: FontWeight.w600)),
                  if (s == 'Football')
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SRColors.orange, borderRadius: BorderRadius.circular(6)),
                      child: Text('FIRST', style: GoogleFonts.spaceGrotesk(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}

class _Step3 extends StatelessWidget {
  final String name, age, city, sport, mobile;
  const _Step3({required this.name, required this.age,
    required this.city, required this.sport, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Confirm Your Details', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text('Step 3 of 3 · Review before creating your profile',
        style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 32),
      SRCard(
        child: Column(children: [
          _ConfirmRow('Full Name', name, Icons.person_rounded),
          _ConfirmRow('Age', '$age years', Icons.cake_rounded),
          _ConfirmRow('City', city, Icons.location_on_rounded),
          _ConfirmRow('Sport', sport, Icons.sports_rounded),
          _ConfirmRow('Mobile', '+91 $mobile', Icons.phone_rounded, isLast: true),
        ]),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SRColors.gold.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SRColors.gold.withValues(alpha:0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.verified_rounded, color: SRColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(
            'You\'ll start at Level 1 — Rookie. Every session and tournament earns XP toward National Prospect.',
            style: GoogleFonts.inter(color: SRColors.gold, fontSize: 13))),
        ]),
      ),
    ]);
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool isLast;
  const _ConfirmRow(this.label, this.value, this.icon, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Icon(icon, color: SRColors.orange, size: 18),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.inter(color: SRColors.muted, fontSize: 11)),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      ]),
      if (!isLast) ...[
        const SizedBox(height: 14),
        Divider(color: SRColors.line, height: 1),
        const SizedBox(height: 14),
      ],
    ]);
  }
}
