import 'package:supabase_flutter/supabase_flutter.dart';

// ── CONFIG ─────────────────────────────────────────────────────
// Replace these with your actual Supabase credentials
const kSupabaseUrl    = 'https://zmgmcnkfiwxtpweopckh.supabase.co';
const kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptZ21jbmtmaXd4dHB3ZW9wY2toIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2NzQ1MzUsImV4cCI6MjA5NzI1MDUzNX0.aoqTBlJqI-d6tkMhkRZODGXdng5L3PLlLbbxbRWIVX0';

// ── XP RULES ───────────────────────────────────────────────────
class XPRules {
  static const coaching5Exceptional = 75;
  static const coaching5Star        = 25;
  static const coaching4Star        = 15;
  static const coaching1to3Star     = 10;
  static const tournamentReg        = 20;
  static const matchWin             = 40;
  static const runnerUp             = 60;
  static const tournamentWin        = 100;
  static const streak7Day           = 30;

  static int fromRating(int rating, {bool exceptional = false}) {
    if (rating == 5 && exceptional) return coaching5Exceptional;
    if (rating == 5) return coaching5Star;
    if (rating == 4) return coaching4Star;
    return coaching1to3Star;
  }

  static int fromTournamentResult(String result) {
    switch (result) {
      case 'winner':    return tournamentWin;
      case 'runner_up': return runnerUp;
      case 'match_win': return matchWin;
      default:          return 0;
    }
  }
}

// ── LEVEL SYSTEM ───────────────────────────────────────────────
class LevelSystem {
  static const levels = [
    {'level': 1, 'name': 'Rookie',            'min': 0,    'max': 100},
    {'level': 2, 'name': 'Contender',         'min': 101,  'max': 300},
    {'level': 3, 'name': 'Challenger',        'min': 301,  'max': 600},
    {'level': 4, 'name': 'Competitor',        'min': 601,  'max': 1000},
    {'level': 5, 'name': 'Elite',             'min': 1001, 'max': 1500},
    {'level': 6, 'name': 'Champion',          'min': 1501, 'max': 2000},
    {'level': 7, 'name': 'National Prospect', 'min': 2001, 'max': 99999},
  ];

  static Map<String, dynamic> fromXP(int xp) {
    for (final l in levels) {
      if (xp <= (l['max'] as int)) return l;
    }
    return levels.last;
  }

  static double progressInLevel(int xp) {
    final l = fromXP(xp);
    final min = l['min'] as int;
    final max = l['max'] as int;
    if (max == 99999) return 1.0;
    return ((xp - min) / (max - min)).clamp(0.0, 1.0);
  }
}

// ── SUPABASE SERVICE ───────────────────────────────────────────
class SRService {
  static SupabaseClient get _db => Supabase.instance.client;

  // ── AUTH ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> registerStudent({
    required String name,
    required String mobile,
    required int    age,
    required String city,
    required String sport,
    String? guardianName,
    String? guardianMobile,
    bool    parentalConsent = false,
  }) async {
    final bool isMinor = age < 18;

    // Insert user
    final userRes = await _db.from('users').insert({
      'name':             name,
      'mobile':           mobile,
      'age':              age,
      'city':             city,
      'role':             'student',
      'is_minor':         isMinor,
      'guardian_name':    isMinor ? guardianName : null,
      'guardian_mobile':  isMinor ? guardianMobile : null,
      'parental_consent': isMinor ? parentalConsent : true,
      'consent_given_at': isMinor && parentalConsent ? DateTime.now().toIso8601String() : null,
    }).select().single();

    // Insert student profile
    await _db.from('student_profiles').insert({
      'user_id':    userRes['id'],
      'sport':      sport,
      'xp_total':   0,
      'level':      1,
      'level_name': 'Rookie',
      'profile_complete': true,
    });

    return userRes;
  }

  static Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    final res = await _db
        .from('users')
        .select()
        .eq('mobile', mobile)
        .maybeSingle();
    return res;
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    return await _db.from('users').select().eq('id', userId).maybeSingle();
  }

  static Future<Map<String, dynamic>?> getStudentProfile(String userId) async {
    return await _db
        .from('student_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  // ── COACHES ───────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getVerifiedCoaches({
    String? sport,
    String? city,
    double? minRating,
    int? maxFee,
  }) async {
    var query = _db
        .from('coach_profiles')
        .select('*, users!inner(name, city, age)')
        .eq('is_verified', true);

    if (sport != null) query = query.eq('sport', sport);
    if (city  != null) query = query.eq('city',  city);
    if (minRating != null) query = query.gte('avg_rating', minRating);
    if (maxFee != null)    query = query.lte('fee_per_session', maxFee);

    final res = await query.order('avg_rating', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ── TOURNAMENTS ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getVerifiedTournaments({
    String? sport,
    String? city,
  }) async {
    var query = _db
        .from('tournaments')
        .select()
        .eq('is_verified', true)
        .gte('registration_deadline', DateTime.now().toIso8601String());

    if (sport != null) query = query.eq('sport', sport);
    if (city  != null) query = query.eq('city',  city);

    final res = await query.order('event_date');
    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> registerForTournament({
    required String tournamentId,
    required String studentId,
  }) async {
    await _db.from('tournament_registrations').insert({
      'tournament_id': tournamentId,
      'student_id':    studentId,
      'result':        'registered',
    });
    // Award registration XP
    await awardXP(
      studentId:  studentId,
      xpAmount:   XPRules.tournamentReg,
      sourceType: 'tournament_registration',
      sourceId:   tournamentId,
    );
  }

  // ── XP ENGINE ─────────────────────────────────────────────────
  static Future<void> awardXP({
    required String studentId,
    required int    xpAmount,
    required String sourceType,
    required String sourceId,
  }) async {
    // 1. Insert immutable XP transaction
    await _db.from('xp_transactions').insert({
      'student_id':  studentId,
      'xp_amount':   xpAmount,
      'source_type': sourceType,
      'source_id':   sourceId,
    });

    // 2. Get current XP
    final profile = await _db
        .from('student_profiles')
        .select('xp_total')
        .eq('user_id', studentId)
        .single();

    final int currentXP = profile['xp_total'] as int;
    final int newXP     = currentXP + xpAmount;

    // 3. Calculate new level
    final levelData = LevelSystem.fromXP(newXP);
    final bool isNP = (levelData['level'] as int) >= 7;

    // 4. Update student profile
    await _db.from('student_profiles').update({
      'xp_total':              newXP,
      'level':                 levelData['level'],
      'level_name':            levelData['name'],
      'is_national_prospect':  isNP,
    }).eq('user_id', studentId);
  }

  // ── XP HISTORY ────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getXPHistory(String studentId) async {
    final res = await _db
        .from('xp_transactions')
        .select()
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(20);
    return List<Map<String, dynamic>>.from(res);
  }

  // ── SESSIONS ──────────────────────────────────────────────────
  static Future<void> bookSession({
    required String coachId,
    required String studentId,
    required DateTime sessionDate,
  }) async {
    await _db.from('coaching_sessions').insert({
      'coach_id':    coachId,
      'student_id':  studentId,
      'session_date': sessionDate.toIso8601String().split('T').first,
      'status':      'confirmed',
    });
  }

  static Future<List<Map<String, dynamic>>> getStudentSessions(String studentId) async {
    final res = await _db
        .from('coaching_sessions')
        .select('*, coach:coach_id(name)')
        .eq('student_id', studentId)
        .order('session_date', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // ── SCOUT ─────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> searchAthletes({
    String? sport,
    String? city,
    int?    minLevel,
  }) async {
    var query = _db
        .from('student_profiles')
        .select('*, user:user_id(name, city, age, sport)')
        .eq('profile_complete', true);

    if (minLevel != null) query = query.gte('level', minLevel);

    final res = await query.order('xp_total', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }
}
