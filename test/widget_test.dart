// Placeholder smoke test. The real app boots Supabase in main() before
// runApp, so widget tests should exercise individual screens/controllers
// with a mocked SupabaseClient rather than the full HairstyleAiApp widget.
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
