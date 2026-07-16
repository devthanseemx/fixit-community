import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../data/demo_data.dart';

/// Single entry point for all persistence in the app.
///
/// Every screen talks to this class instead of `FirebaseFirestore` directly.
/// When [demoModeEnabled] is on it serves the in-memory demo stores; otherwise
/// it performs the real Cloud Firestore operations (lifted from the screens).
///
/// All methods return plain `Map<String, dynamic>` / `List` data — never
/// Firestore document types — so callers (and tests) stay backend-agnostic.
class DataService {
  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------

  /// Returns category display names sorted by their `order` field.
  static Future<List<String>> loadCategories() async {
    if (demoModeEnabled) {
      final sorted = [...demoCategories]
        ..sort(
          (a, b) =>
              (a['order'] as int).compareTo(b['order'] as int),
        );
      return sorted.map((c) => c['name'] as String).toList();
    }

    final snap =
        await FirebaseFirestore.instance.collection('categories').get();

    if (snap.docs.isEmpty) {
      // Seed the default category list once (idempotent via fixed ids).
      const defaults = [
        {'name': 'Electronics', 'slug': 'electronics', 'order': 1},
        {'name': 'Computer', 'slug': 'computer', 'order': 2},
        {'name': 'Mobile', 'slug': 'mobile', 'order': 3},
        {'name': 'Home Repair', 'slug': 'home_repair', 'order': 4},
        {'name': 'Other', 'slug': 'other', 'order': 5},
        {'name': 'Laptop', 'slug': 'laptop', 'order': 6},
        {'name': 'Networking', 'slug': 'networking', 'order': 7},
        {'name': 'Printer', 'slug': 'printer', 'order': 8},
        {'name': 'Software', 'slug': 'software', 'order': 9},
        {'name': 'Gaming Console', 'slug': 'gaming_console', 'order': 10},
      ];
      final batch = FirebaseFirestore.instance.batch();
      for (final d in defaults) {
        batch.set(
          FirebaseFirestore.instance
              .collection('categories')
              .doc(d['slug'] as String),
          {'name': d['name'], 'order': d['order']},
        );
      }
      await batch.commit();
      return defaults.map((d) => d['name'] as String).toList();
    }

    final docs = snap.docs;
    docs.sort(
      (a, b) => ((a.data()['order'] ?? 0) as int)
          .compareTo((b.data()['order'] ?? 0) as int),
    );
    return docs.map((d) => (d.data()['name'] as String)).toList();
  }

  // ---------------------------------------------------------------------------
  // Problems
  // ---------------------------------------------------------------------------

  /// Returns all problems, newest first.
  static Future<List<Map<String, dynamic>>> loadProblems() async {
    if (demoModeEnabled) {
      final list = [...demoProblemsStore];
      list.sort(_byNewest);
      return list;
    }

    final snap =
        await FirebaseFirestore.instance.collection('problems').get();
    final docs = snap.docs.map((d) => d.data()).toList();
    docs.sort(_byNewest);
    return docs;
  }

  /// Adds a problem. [data] must NOT include `createdAt` — it is stamped here
  /// per mode (server timestamp for Firestore, local time for demo).
  static Future<void> addProblem(Map<String, dynamic> data) async {
    if (demoModeEnabled) {
      demoProblemsStore.insert(
        0,
        {
          ...data,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        },
      );
      return;
    }

    await FirebaseFirestore.instance.collection('problems').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // User profile
  // ---------------------------------------------------------------------------

  /// Returns the profile map for [username], or a minimal default if none
  /// exists (so the UI can still render an empty profile).
  static Future<Map<String, dynamic>?> loadUserProfile(String username) async {
    if (demoModeEnabled) {
      if (username == demoUsername) {
        return Map<String, dynamic>.from(demoUserStore);
      }
      return {
        'username': username,
        'fullName': '',
        'createdAt': null,
        'profileImage': null,
      };
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    return doc.exists ? doc.data() : null;
  }

  /// Persists profile fields for [username] (merge semantics).
  static Future<void> saveUserProfile(
    String username,
    Map<String, dynamic> data,
  ) async {
    if (demoModeEnabled) {
      demoUserStore = {...demoUserStore, ...data, 'username': username};
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(username).set(
      {
        ...data,
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Logs in an existing user or creates one if the username is new.
  static Future<void> createOrLoginUser(String username) async {
    if (demoModeEnabled) {
      if (demoUserStore['username'] != username) {
        demoUserStore = {
          'username': username,
          'fullName': '',
          'createdAt': null,
          'profileImage': null,
        };
      }
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(username).set({
        'username': username,
        'fullName': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Deletes a user and every problem they authored.
  static Future<void> deleteUser(String username) async {
    if (demoModeEnabled) {
      demoProblemsStore =
          demoProblemsStore.where((p) => p['authorUsername'] != username).toList();
      demoUserStore = {
        'username': username,
        'fullName': '',
        'createdAt': null,
        'profileImage': null,
      };
      return;
    }

    final users = FirebaseFirestore.instance.collection('users');
    await users.doc(username).delete();

    final problems = await FirebaseFirestore.instance
        .collection('problems')
        .where('authorUsername', isEqualTo: username)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in problems.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Sorts problem maps newest-first by `createdAt` (nulls sort last).
  static int _byNewest(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    final ta = a['createdAt'] as Timestamp?;
    final tb = b['createdAt'] as Timestamp?;
    if (ta == null && tb == null) return 0;
    if (ta == null) return 1;
    if (tb == null) return -1;
    return tb.compareTo(ta);
  }
}
