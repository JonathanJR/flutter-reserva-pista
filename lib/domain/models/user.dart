import 'package:equatable/equatable.dart';

/// Modelo de dominio para un Usuario
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String fullName;
  final DateTime registrationDate;
  final bool isActive;
  final int reservationCount;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.fullName,
    required this.registrationDate,
    this.isActive = true,
    this.reservationCount = 0,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? fullName,
    DateTime? registrationDate,
    bool? isActive,
    int? reservationCount,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      fullName: fullName ?? this.fullName,
      registrationDate: registrationDate ?? this.registrationDate,
      isActive: isActive ?? this.isActive,
      reservationCount: reservationCount ?? this.reservationCount,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, fullName, registrationDate, isActive, reservationCount];
}
