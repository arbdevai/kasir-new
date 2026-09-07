import 'package:flutter_test/flutter_test.dart';

import 'package:kasir_new/main.dart';

void main() {
  testWidgets('KasirApp shell loads POS navigation by default', (tester) async {
    await tester.pumpWidget(const KasirApp());
    await tester.pumpAndSettle();

    expect(find.text('Kasir / POS'), findsWidgets);
  });
}
