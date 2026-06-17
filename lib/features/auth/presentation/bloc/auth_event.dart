abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });
}

class LogoutRequested extends AuthEvent {}
