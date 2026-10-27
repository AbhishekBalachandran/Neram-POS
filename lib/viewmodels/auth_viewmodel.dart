import 'package:neram_pos/data/models/user_model.dart';
import 'package:neram_pos/data/repositories/auth_repository.dart';
import 'package:neram_pos/viewmodels/base_viewmodel.dart';

/// ViewModel managing staff authentication lifecycle.
class AuthViewModel extends BaseViewModel {
  AuthViewModel({required this.authRepository});

  final AuthRepository authRepository;

  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  /// Verifies whether staff has an active session on app launch.
  Future<void> checkAuthStatus() async {
    await runBusyFuture(() async {
      _isAuthenticated = await authRepository.isAuthenticated();
      if (_isAuthenticated) {
        _currentUser = await authRepository.getProfile();
      }
      notifyListeners();
    });
  }

  /// Staff login with username/PIN and password.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final user = await runBusyFuture<UserModel>(() async {
      return await authRepository.login(username: username, password: password);
    });

    if (user != null) {
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Logs out staff and clears secured tokens.
  Future<void> logout() async {
    await runBusyFuture(() async {
      await authRepository.logout();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    });
  }

  /// Changes the staff account password via API.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final success = await runBusyFuture<bool>(() async {
      return await authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    });
    return success ?? false;
  }

  /// Updates staff active/inactive status via API.
  Future<bool> updateStatus({required bool isActive}) async {
    final success = await runBusyFuture<bool>(() async {
      return await authRepository.updateStatus(isActive: isActive);
    });
    return success ?? false;
  }
}
