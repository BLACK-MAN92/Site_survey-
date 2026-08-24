import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/api/auth_api.dart';
import '../../data/api/auth_storage.dart';

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final String? accessToken;

  AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
    this.accessToken,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    String? accessToken,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}

class LoginStateNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final AuthStorage _authStorage;
  final void Function(String) _onLoginSuccess;

  LoginStateNotifier(this._authApi, this._authStorage, this._onLoginSuccess) : super(AuthState());

  Future<void> login(String email, String password) async {
    debugPrint('📱 FLUTTER: Attempting to login with email: $email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authApi.login(email, password);
      
      debugPrint('📱 FLUTTER: Login API call successful! Extracting tokens...');
      
      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];
      
      await _authStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      debugPrint('📱 FLUTTER: Tokens securely saved. Logging user in locally...');
      state = state.copyWith(isLoading: false);
      _onLoginSuccess(accessToken);
    } catch (e) {
      debugPrint('📱 FLUTTER: Login failed with error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

class RegisterStateNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final AuthStorage _authStorage;
  final void Function(String) _onRegisterSuccess;

  RegisterStateNotifier(this._authApi, this._authStorage, this._onRegisterSuccess) : super(AuthState());

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authApi.register(name, email, password);
      
      final accessToken = result['accessToken'];
      final refreshToken = result['refreshToken'];
      
      await _authStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      state = state.copyWith(isLoading: false);
      _onRegisterSuccess(accessToken);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Overall auth state that combines login/register
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authStorage = ref.watch(authStorageProvider);
  return AuthStateNotifier(authStorage);
});

final loginStateProvider = StateNotifierProvider<LoginStateNotifier, AuthState>((ref) {
  final authApi = ref.watch(authApiProvider);
  final authStorage = ref.watch(authStorageProvider);
  return LoginStateNotifier(authApi, authStorage, (token) {
    ref.read(authStateProvider.notifier).setLoggedIn(token);
  });
});

final registerStateProvider = StateNotifierProvider<RegisterStateNotifier, AuthState>((ref) {
  final authApi = ref.watch(authApiProvider);
  final authStorage = ref.watch(authStorageProvider);
  return RegisterStateNotifier(authApi, authStorage, (token) {
    ref.read(authStateProvider.notifier).setLoggedIn(token);
  });
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthStorage _authStorage;

  AuthStateNotifier(this._authStorage) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // TODO: Check if tokens exist in secure storage
    // For now, assume not logged in
    state = state.copyWith(isLoggedIn: false);
  }

  void setLoggedIn(String token) {
    state = state.copyWith(isLoggedIn: true, accessToken: token);
  }

  Future<void> logout() async {
    debugPrint('📱 FLUTTER: Logging out and clearing tokens...');
    await _authStorage.clearTokens();
    state = state.copyWith(isLoggedIn: false, accessToken: null);
    debugPrint('📱 FLUTTER: Logout complete.');
  }
}
