import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:soulie/main.dart';
import 'package:soulie/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('App should start', (WidgetTester tester) async {
    final mockClient = MockClient((request) async {
      return http.Response('{}', 401);
    });
    final authRepository = AuthRepository(httpClient: mockClient);

    await tester.pumpWidget(SoulieApp(authRepository: authRepository));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Soulie'), findsOneWidget);
  });
}
