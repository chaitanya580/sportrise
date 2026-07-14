import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/sr_theme.dart';
import 'services/sr_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/student_registration_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/coach_discovery_screen.dart';
import 'screens/tournament_screen.dart';
import 'screens/xp_level_screen.dart';
import 'screens/scout_dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url:    kSupabaseUrl,
      anonKey: kSupabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }

  runApp(const SportRiseApp());
}

class SportRiseApp extends StatelessWidget {
  const SportRiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportRise',
      theme: SRTheme.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: _routes,
    );
  }

  Route<dynamic>? _routes(RouteSettings settings) {
    // Extract userId argument safely
    String userId(Object? args) {
      if (args is String) return args;
      if (args is Map) return args['userId'] as String? ?? '';
      return '';
    }

    switch (settings.name) {
      case '/':
        return _fade(const WelcomeScreen());

      case '/register/student':
        return _slide(const StudentRegistrationScreen());

      case '/dashboard':
        return _fade(StudentDashboardScreen(userId: userId(settings.arguments)));

      case '/coaches':
        return _slide(const CoachDiscoveryScreen());

      case '/tournaments':
        return _slide(TournamentScreen(studentId: userId(settings.arguments)));

      case '/xp':
        return _slide(XPLevelScreen(userId: userId(settings.arguments)));

      case '/scout/dashboard':
        return _slide(const ScoutDashboardScreen());

      case '/profile':
        return _slide(ProfileScreen(userId: userId(settings.arguments)));

      case '/login':
        return _slide(const LoginScreen());

      case '/register/coach':
        return _slide(const _ComingSoonPlaceholder(title: 'Coach Registration'));

      case '/coach/profile':
        final coachArgs = settings.arguments as Map<String, dynamic>?;
        return _slide(_CoachProfilePlaceholder(
          name: coachArgs?['name'] as String? ?? 'Coach',
        ));

      case '/athlete/profile':
        final athleteArgs = settings.arguments as Map<String, dynamic>?;
        return _slide(_AthleteProfilePlaceholder(
          name: athleteArgs?['name'] as String? ?? 'Athlete',
        ));

      case '/otp':
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(OTPScreen(
          mobile: args?['mobile'] as String? ?? '',
          registration: args?['registration'] as Map<String, dynamic>?,
        ));

      default:
        return _fade(const WelcomeScreen());
    }
  }

  static PageRoute _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 300),
  );

  static PageRoute _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 280),
  );
}

class _ComingSoonPlaceholder extends StatelessWidget {
  final String title;
  const _ComingSoonPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.construction_rounded, color: SRColors.gold, size: 64),
            const SizedBox(height: 24),
            Text('Coming soon',
              style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('This feature is under development.',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ]),
        ),
      ),
    );
  }
}

class _CoachProfilePlaceholder extends StatelessWidget {
  final String name;
  const _CoachProfilePlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: SRColors.gold.withValues(alpha:0.15),
            child: Text(name[0].toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: SRColors.gold)),
          ),
          const SizedBox(height: 20),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Coach profile details coming soon.',
            style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ]),
      ),
    );
  }
}

class _AthleteProfilePlaceholder extends StatelessWidget {
  final String name;
  const _AthleteProfilePlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Athlete Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: SRColors.orange.withValues(alpha:0.15),
            child: Text(name[0].toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: SRColors.orange)),
          ),
          const SizedBox(height: 20),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Athlete profile details coming soon.',
            style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ]),
      ),
    );
  }
}
