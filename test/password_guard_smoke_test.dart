import 'package:flutter_test/flutter_test.dart';
import 'package:password_guard/password_guard.dart';

void main() {
  test('hash et vérification d\'un mot de passe court', () async {
    final result = await PasswordGuard.hash(password: 'court');
    expect(result.hash, isNotEmpty);
    expect(
      await PasswordGuard.verify(password: 'court', hash: result.hash),
      isTrue,
    );
    expect(
      await PasswordGuard.verify(password: 'autre', hash: result.hash),
      isFalse,
    );
  }, timeout: const Timeout(Duration(seconds: 30)));
}
