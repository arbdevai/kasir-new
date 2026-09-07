import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_new/src/app/app.dart';

void main() {
  testWidgets('KasirApp shell loads POS screen by default', (tester) async {
    await tester.pumpWidget(const KasirApp());
    await tester.pumpAndSettle();

    expect(find.text('Kasir POS'), findsOneWidget);
  });
}
