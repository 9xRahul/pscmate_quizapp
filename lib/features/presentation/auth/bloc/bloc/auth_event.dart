part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailSignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class EmailRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailRegisterRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class PhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;

  const PhoneNumberSubmitted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class OtpSubmitted extends AuthEvent {
  final String smsCode;

  const OtpSubmitted(this.smsCode);

  @override
  List<Object?> get props => [smsCode];
}

class SignedOut extends AuthEvent {
  const SignedOut();
}
