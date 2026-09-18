import 'package:flutter_test/flutter_test.dart';
import 'package:sawalove/shared/services/backend_service.dart';

void main() {
  test('maps disabled phone provider errors to a safe message', () {
    final error = BackendAuthException(
      code: 'phone_provider_disabled',
      message: 'Phone sign-in is disabled.',
      statusCode: 403,
    );

    final message = authErrorMessage(error);

    expect(message, contains('Phone sign-in is temporarily unavailable'));
    expect(message, isNot(contains('BackendAuthException')));
    expect(message, isNot(contains('phone_provider_disabled')));
  });

  test('maps raw disabled phone provider strings to the same safe message', () {
    final message = authErrorMessage(
      'BackendAuthException(message: Unsupported phone provider, '
      'statusCode: 400, code: phone_provider_disabled)',
    );

    expect(message, contains('Phone sign-in is temporarily unavailable'));
    expect(message, isNot(contains('BackendAuthException')));
  });

  test('maps invalid credentials to a friendly message', () {
    final message = authErrorMessage(
      BackendAuthException(code: 'invalid_credentials', statusCode: 401),
    );

    expect(message, contains('email, phone, or password is incorrect'));
  });
}
