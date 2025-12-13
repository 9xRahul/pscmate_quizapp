import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pscmate/features/auth/domain/entities/AuthUser.dart';
import 'package:pscmate/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  String? _verificationId; // for phone login

  AuthBloc(this._authRepository)
    : super(AuthState(error: "", googleIsLoading: false, isLoading: false)) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<EmailSignInRequested>(_onEmailSignInRequested);
    on<EmailRegisterRequested>(_onEmailRegisterRequested);
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<SignedOut>(_onSignedOut);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: false,
        error: "",
        isAuthenticated: false,
        isError: false,
      ),
    );
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      state.copyWith(
        isLoading: false,
        error: "",
        isAuthenticated: false,
        isError: true,
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: "User not found",
          isAuthenticated: true,
          isError: false,
        ),
      );
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        error: "",
        isAuthenticated: false,
        isError: false,
        googleIsLoading: true,
      ),
    );
    try {
      final user = await _authRepository.signInWithGoogle();

      emit(
        state.copyWith(
          error: "",
          isAuthenticated: true,
          user: user,
          isError: false,
          isLoading: false,
          googleIsLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          isAuthenticated: false,
          isError: true,
          googleIsLoading: false,
        ),
      );
    }
  }

  Future<void> _onEmailSignInRequested(
    EmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        error: "",
        isAuthenticated: false,

        isError: false,
        isLoading: true,
      ),
    );
    try {
      final user = await _authRepository.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );

      emit(
        state.copyWith(
          error: "",
          isAuthenticated: true,
          user: user,
          isError: false,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          isAuthenticated: false,
          isError: true,
        ),
      );
    }
  }

  Future<void> _onEmailRegisterRequested(
    EmailRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        error: "",
        isAuthenticated: false,

        isError: false,
        isLoading: true,
      ),
    );
    try {
      // final user = await _authRepository.registerWithEmailPassword(
      //   email: event.email,
      //   password: event.password,
      // );

      final user = await _authRepository.registerWithEmailAndProfile(
        email: event.email,
        password: event.password,
        name: event.name,
        
      );

      emit(
        state.copyWith(
          error: "",
          isAuthenticated: true,
          // user: user,
          isError: false,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          isAuthenticated: false,
          isError: true,
        ),
      );
    }
  }

  Future<void> _onPhoneNumberSubmitted(
    PhoneNumberSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        codeSent: (verificationId) {
          _verificationId = verificationId;
        },
        onError: (err) {
          addError(Exception(err));
        },
      );
      if (_verificationId != null) {
        emit(AuthPhoneCodeSent(_verificationId!));
      } else {
        emit(AuthError('Failed to send OTP'));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (_verificationId == null) {
        emit(AuthError('Missing verificationId'));
        emit(AuthUnauthenticated());
        return;
      }
      final user = await _authRepository.signInWithSmsCode(
        verificationId: _verificationId!,
        smsCode: event.smsCode,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignedOut(SignedOut event, Emitter<AuthState> emit) async {
    // Start loading state
    emit(state.copyWith(isLoading: true, error: "", isError: false));

    try {
      // Attempt logout
      await _authRepository.signOut();

      // Only emit unauthenticated AFTER success
      emit(
        state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          user: null,
          error: "",
          isError: false,
        ),
      );
    } catch (e) {
      // Emit failure state — do NOT logout
      emit(
        state.copyWith(isLoading: false, error: e.toString(), isError: true),
      );
    }
  }
}
