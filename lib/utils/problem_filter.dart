/// Pure, testable search-match logic for the home feed.
///
/// Returns true when [data] (a Firestore problem document) matches the
/// given [query]. The match is case-insensitive and searches the title,
/// description, category, author, and solution steps. An empty/whitespace
/// query always matches (i.e. "show everything").
///
/// Multi-word queries use AND semantics: every whitespace-separated word
/// must appear somewhere in the document, so "drops connection" still
/// matches "My laptop drops the WiFi connection ...".
bool problemMatchesQuery(Map<String, dynamic> data, String query) {
  final words = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return true;

  final haystack = [
    (data['title'] ?? '').toString(),
    (data['description'] ?? '').toString(),
    (data['category'] ?? '').toString(),
    (data['authorName'] ?? '').toString(),
    (data['authorUsername'] ?? '').toString(),
    ...((data['steps'] as List?)?.map((s) => s.toString()) ?? []),
  ].join(' ').toLowerCase();

  return words.every((w) => haystack.contains(w));
}
