import 'package:flutter_test/flutter_test.dart';
import 'package:field_officer_app/data/repositories/auth_repository.dart';
import 'package:field_officer_app/core/storage/secure_storage_service.dart';
import 'package:field_officer_app/core/network/api_exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #write) {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String?;
      if (value != null) _data[key] = value;
      return Future<void>.value();
    }
    if (invocation.memberName == #read) {
      final key = invocation.namedArguments[#key] as String;
      return Future<String?>.value(_data[key]);
    }
    if (invocation.memberName == #delete) {
      final key = invocation.namedArguments[#key] as String;
      _data.remove(key);
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late MockAuthRepository authRepo;
  late SecureStorageService secureStorage;

  setUp(() {
    secureStorage = SecureStorageService(storage: FakeSecureStorage());
    authRepo = MockAuthRepository(secureStorage: secureStorage);
  });

  test('MockAuthRepository logs in with demo credentials successfully', () async {
    final user = await authRepo.login(
      email: 'field.demo@bhoomisetu.gov.in',
      password: 'demo@123',
    );

    expect(user.email, 'field.demo@bhoomisetu.gov.in');
    expect(user.officerId, 'FO-MH-PUN-0842');
    expect(await authRepo.isLoggedIn(), true);
  });

  test('MockAuthRepository rejects invalid credentials', () async {
    expect(
      () => authRepo.login(email: 'wrong@bhoomisetu.gov.in', password: 'wrongpassword'),
      throwsA(isA<ValidationException>()),
    );
  });

  test('MockAuthRepository logs out and clears session', () async {
    await authRepo.login(email: 'field.demo@bhoomisetu.gov.in', password: 'demo@123');
    expect(await authRepo.isLoggedIn(), true);

    await authRepo.logout();
    expect(await authRepo.isLoggedIn(), false);
  });
}
