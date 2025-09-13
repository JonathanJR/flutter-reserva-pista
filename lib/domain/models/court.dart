import 'package:equatable/equatable.dart';

/// Modelo de dominio para una Pista/Cancha
class Court extends Equatable {
  final String id;
  final String courtType; // 'tennis', 'padel', 'football'
  final String? specificOption; // 'exterior', 'interior', 'cemento', 'cristal', etc.
  final bool available;
  final int displayOrder;
  final String? imageUrl;

  const Court({
    required this.id,
    required this.courtType,
    this.specificOption,
    required this.available,
    required this.displayOrder,
    this.imageUrl,
  });

  /// Nombre completo de la pista para mostrar
  String get displayName {
    final baseName = courtType == 'tennis' 
        ? 'Tenis'
        : courtType == 'padel' 
            ? 'Pádel' 
            : 'Fútbol Sala';
    
    if (specificOption != null) {
      final option = _formatSpecificOption(specificOption!);
      return '$baseName - $option';
    }
    
    return baseName;
  }

  /// Formatear la opción específica para mostrar
  String _formatSpecificOption(String option) {
    switch (option.toLowerCase()) {
      case 'exterior':
        return 'Exterior';
      case 'interior':
        return 'Interior';
      case 'cemento':
        return 'Cemento';
      case 'cristal':
        return 'Cristal';
      case 'pasillo':
        return 'Pasillo';
      case 'piscina':
        return 'Piscina';
      default:
        return option;
    }
  }

  /// Crear copia con nuevos valores
  Court copyWith({
    String? id,
    String? courtType,
    String? specificOption,
    bool? available,
    int? displayOrder,
    String? imageUrl,
  }) {
    return Court(
      id: id ?? this.id,
      courtType: courtType ?? this.courtType,
      specificOption: specificOption ?? this.specificOption,
      available: available ?? this.available,
      displayOrder: displayOrder ?? this.displayOrder,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courtType,
    specificOption,
    available,
    displayOrder,
    imageUrl,
  ];
}
