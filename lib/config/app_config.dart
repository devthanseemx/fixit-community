/// Global application configuration.
///
/// [demoModeEnabled] is the single switch that controls whether the app uses
/// the in-memory demo data store ([demo_data.dart]) instead of Cloud
/// Firestore. When `true` the app runs fully offline with seeded data, which
/// is what makes it demoable and unit-testable without a network connection.
///
/// Set this to `false` (or guard it with `--dart-define=DEMO=false`) to use
/// the real Firebase/Firestore backend in production.
bool demoModeEnabled = true;
