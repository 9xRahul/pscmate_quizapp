part of 'auth_bloc.dart';

class AuthState extends Equatable {
  bool isLoading;
  bool googleIsLoading;
  bool isAuthenticated;
  String error;
  bool isError;
  AuthUser? user;
  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error = "",
    this.isError = false,
    this.user,
    this.googleIsLoading = false,
  });

  @override
  List<Object?> get props => [isLoading, isAuthenticated, isError, error];

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isError,
    String? error,
    AuthUser? user,
    bool? googleIsLoading,
  }) {
    return AuthState(
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      googleIsLoading: googleIsLoading ?? this.googleIsLoading,
    );
  }
}

class AuthInitial extends AuthState {
  AuthInitial();
}

class AuthLoading extends AuthState {
  AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  AuthUnauthenticated();
}

class AuthPhoneCodeSent extends AuthState {
  final String verificationId;

  AuthPhoneCodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
