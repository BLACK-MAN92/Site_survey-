import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  LoginStateNotifier() : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Call API to login
      // For now, mock success
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        accessToken: 'mock_token',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoggedIn: false, accessToken: null);
  }
}

class RegisterStateNotifier extends StateNotifier<AuthState> {
  RegisterStateNotifier() : super(AuthState());

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Call API to register
      // For now, mock success
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        accessToken: 'mock_token',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final loginStateProvider = StateNotifierProvider<LoginStateNotifier, AuthState>((ref) {
  return LoginStateNotifier();
});

final registerStateProvider = StateNotifierProvider<RegisterStateNotifier, AuthState>((ref) {
  return RegisterStateNotifier();
});

// Overall auth state that combines login/register
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // TODO: Check if tokens exist in secure storage
    // For now, assume not logged in
    state = state.copyWith(isLoggedIn: false);
  }

  Future<void> logout() async {
    // TODO: Clear tokens from secure storage
    state = state.copyWith(isLoggedIn: false, accessToken: null);
  }
}
