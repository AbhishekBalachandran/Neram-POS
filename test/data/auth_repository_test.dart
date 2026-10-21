import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neram_pos/core/errors/app_exception.dart';
import 'package:neram_pos/core/network/api_client.dart';
import 'package:neram_pos/core/security/secure_storage_service.dart';
import 'package:neram_pos/core/security/token_manager.dart';
import 'package:neram_pos/data/models/user_model.dart';
import 'package:neram_pos/data/repositories/auth_repository.dart';

class MockApiClient implements ApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TokenManager tokenManager;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    final storage = SecureStorageService();
    tokenManager = TokenManager(storageService: storage);
    authRepository = AuthRepositoryImpl(
      apiClient: MockApiClient(),
      tokenManager: tokenManager,
    );
  });

  group('AuthRepository Sample Login', () {
    test('succeeds with sample credentials abhishek / 123456', () async {
      final user = await authRepository.login(
        username: 'abhishek',
        password: '123456',
      );

      expect(user.name, 'Abhishek');
      expect(user.role, StaffRole.manager);

      final isAuth = await authRepository.isAuthenticated();
      expect(isAuth, isTrue);

      final profile = await authRepository.getProfile();
      expect(profile?.name, 'Abhishek');
    });

    test(
      'case-insensitively handles username Abhishek with whitespace',
      () async {
        final user = await authRepository.login(
          username: 'Abhishek ',
          password: '123456',
        );

        expect(user.name, 'Abhishek');
      },
    );

    test('fails with invalid password for sample username', () async {
      expect(
        () => authRepository.login(
          username: 'abhishek',
          password: 'wrong_password',
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('logout clears sample session and tokens', () async {
      await authRepository.login(username: 'abhishek', password: '123456');

      expect(await authRepository.isAuthenticated(), isTrue);

      await authRepository.logout();

      expect(await authRepository.isAuthenticated(), isFalse);
    });
  });
}
