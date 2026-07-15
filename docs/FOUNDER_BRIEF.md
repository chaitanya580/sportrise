# SportRise — Founder's Briefing

Everything to know cold before pitching. The talk track lives in `PITCH.md`;
this is the knowledge underneath it.

## 1. The one-liner (memorize)
"SportRise is a two-sided marketplace that connects India's school athletes
with verified coaches, tournaments, and scouts — with a gamified XP system
that turns performance into a verifiable track record."
Backup metaphor: **"a CIBIL score for sporting talent."**

## 2. The three numbers on your own website
- **$19B** — India sportstech market
- **47 crore** — active athletes in India
- **0.16%** — share with any digital performance record

These are on sportrise.in, so someone will quote them back at you. Honest
caveat if probed: directional market-research figures, not primary data.

## 3. What exists TODAY
- Live marketing site + waitlist at sportrise.in (custom domain, GA4
  conversion tracking)
- Playable app at sportrise.in/demo — any phone, via QR
- Working phone-OTP authentication (Supabase Auth), persisted sessions
- Parental consent flow for under-18s, enforced at app AND database level
- XP engine live end-to-end: tournament registration awards XP atomically,
  with anti-farming constraints
- Verified-coach discovery with filters, tournament listings, scout
  dashboard with sport/city/level filters
- Owner-scoped database security (users can only write their own data)
- BRD/FDD documentation, pitch deck, 3-year roadmap

## 4. What does NOT exist yet (own the gaps first)
- Coach self-registration — early supply is manually onboarded
  (spin: supply-first marketplaces SHOULD hand-pick early supply; Airbnb
  photographed apartments manually)
- Coach/athlete detail pages and session booking UI
- Admin verification workflow (manual DB action today)
- Real SMS — OTP runs on test numbers; Textlocal/Twilio plugs in pre-launch
- App-store presence — web build/PWA today; Android build unpublished
- Revenue: zero. Pre-launch. Say it plainly.

## 5. Business model (know the why)
- Commission on coaching sessions (core take-rate)
- Tournament listing/registration fees from organizers
- Scout subscriptions to the ranked National Prospect database — the most
  defensible asset: nobody else has verified youth performance data
- Promoted listings / verification services for coaches
- Always free for athletes (pre-answers the "monetizing children" question)
- Take-rate if pushed: "10–20% is the marketplace norm; we set it after
  pilot data on session pricing."

## 6. The XP system (your differentiator — mechanics)
- Coach ratings +10 to +75 (75 = exceptional 5-star) · tournament
  registration +20 · match win +40 · runner-up +60 · champion +100 ·
  7-day streak +30
- 7 levels: Rookie → Contender → Challenger → Competitor → Elite →
  Champion → National Prospect at 2001+ XP = scout visibility
- Integrity story: append-only transaction ledger, atomic increments,
  unique constraints against farming, ratings only from verified coaches

## 7. Go-to-market
Supply-first: 50 founding coaches at zero commission year one → school
partnerships (free athlete profiles) → co-organized tournaments where every
participant onboards through the platform → referral XP + leaderboards as
the built-in viral loop. Hyderabad only, Football + Cricket, September 2026.
One city until liquidity, then replicate the playbook.

## 8. The five questions you WILL get
1. **Chicken-and-egg?** Supply-first with founding-coach incentives;
   athletes follow coaches; tournaments generate both sides at once.
2. **Why won't a big academy or Khelo India build this?** Academies profit
   from opacity — their model is enrollment fees, not transparency.
   Government moves slowly and needs private data layers. We win by being
   the neutral record.
3. **How do you verify coaches?** Document + certification checks at
   onboarding, admin approval before listing, ratings after. Honest add:
   verification is manual today — appropriate at 50-coach scale.
4. **Minors — safety?** Mandatory parental consent enforced at the database
   level, guardian contact on record, free forever for athletes. Built
   before anyone forced us to — say so.
5. **Why you?** Same age as the users' older brothers, built the entire
   product solo at zero cost, from the region we're launching in.

## 9. Honesty guardrails
- Waitlist: give the real number + growth plan. Never quote the landing
  page's "500+" as fact.
- Say "built and live in demo," not "launched." Launch = Sep 2026 Hyderabad.
- Unknown answer: "I don't know yet — here's how I'd find out."

## 10. Logistics before any pitch
- QR code to the demo (on phone + printed)
- Deck: Gamma link + offline PPTX copy
- Demo rehearsed INCLUDING the XP moment: register for a tournament live,
  +20 XP appears — the showstopper
- Test phone number + fixed OTP (123456) memorized so a live demo never
  stalls on login
