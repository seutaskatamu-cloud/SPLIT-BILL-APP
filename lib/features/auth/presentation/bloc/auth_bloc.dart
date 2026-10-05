import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/security/security_service.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/user_model.dart';

// EVENTS
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;
  const AuthLoginRequested({required this.identifier, required this.password});
  @override
  List<Object?> get props => [identifier, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  const AuthRegisterRequested({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
  });
  @override
  List<Object?> get props => [fullName, phone, email, password];
}

class AuthBiometricLoginRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

// STATES
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailureState extends AuthState {
  final String message;
  const AuthFailureState(this.message);
  @override
  List<Object?> get props => [message];
}

// BLOC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecurityService _security = SecurityService.instance;

  AuthBloc({required this.authRepository})
      : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthBiometricLoginRequested>(_onAuthBiometricLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.identifier, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailureState('Gagal masuk: ${e.toString()}'));
    }
  }

  Future<void> _onAuthRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        event.fullName,
        event.phone,
        event.email,
        event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailureState('Gagal mendaftar: ${e.toString()}'));
    }
  }

  Future<void> _onAuthBiometricLoginRequested(AuthBiometricLoginRequested event, Emitter<AuthState> emit) async {
    final authenticated = await _security.authenticateBiometrics(
      localizedReason: 'Pindai sidik jari Anda untuk masuk ke Patungan',
    );
    if (authenticated) {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        // Fallback default user
        final defaultUser = await authRepository.login('achmad@patungan.id', 'password');
        emit(Authenticated(defaultUser));
      }
    } else {
      emit(const AuthFailureState('Autentikasi biometrik dibatalkan atau gagal'));
    }
  }

  Future<void> _onAuthLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(Unauthenticated());
  }
}
