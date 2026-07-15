import 'package:flutter_test/flutter_test.dart';
import 'package:fixit_community/utils/problem_filter.dart';

void main() {
  group('problemMatchesQuery', () {
    final problem = {
      'title': 'WiFi keeps disconnecting on laptop',
      'description': 'My laptop drops the WiFi connection every few minutes.',
      'category': 'Networking',
      'authorName': 'Alice Smith',
      'authorUsername': 'alice',
      'steps': [
        'Forget the network and reconnect',
        'Update the network driver',
        'Switch to 5GHz band',
      ],
    };

    test('empty query matches everything', () {
      expect(problemMatchesQuery(problem, ''), isTrue);
      expect(problemMatchesQuery(problem, '   '), isTrue);
    });

    test('matches title (case-insensitive)', () {
      expect(problemMatchesQuery(problem, 'WIFI'), isTrue);
      expect(problemMatchesQuery(problem, 'laptop'), isTrue);
    });

    test('matches description', () {
      expect(problemMatchesQuery(problem, 'drops the connection'), isTrue);
    });

    test('matches category', () {
      expect(problemMatchesQuery(problem, 'networking'), isTrue);
    });

    test('matches author name and username', () {
      expect(problemMatchesQuery(problem, 'Alice'), isTrue);
      expect(problemMatchesQuery(problem, 'alice'), isTrue);
    });

    test('matches solution steps (the "search solution" requirement)', () {
      // Keyword that only appears inside a solution step.
      expect(problemMatchesQuery(problem, 'driver'), isTrue);
      expect(problemMatchesQuery(problem, '5ghz'), isTrue);
      expect(problemMatchesQuery(problem, 'reconnect'), isTrue);
    });

    test('does not match unrelated keywords', () {
      expect(problemMatchesQuery(problem, 'printer'), isFalse);
      expect(problemMatchesQuery(problem, 'battery'), isFalse);
    });

    test('handles missing fields gracefully', () {
      final sparse = <String, dynamic>{'title': 'Blue screen on boot'};
      expect(problemMatchesQuery(sparse, 'blue'), isTrue);
      expect(problemMatchesQuery(sparse, 'missing'), isFalse);
    });

    test('handles missing steps field', () {
      final noSteps = {
        'title': 'Camera not working',
        'description': 'Front camera is black',
        'category': 'Hardware',
      };
      expect(problemMatchesQuery(noSteps, 'camera'), isTrue);
      expect(problemMatchesQuery(noSteps, 'driver'), isFalse);
    });
  });
}
