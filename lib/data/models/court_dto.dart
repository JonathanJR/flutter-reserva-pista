import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/court.dart';

/// Data Transfer Object para Court desde Firestore
class CourtDto {
  final String id;
  final String courtType;
  final String? specificOption;
  final bool available;
  final int displayOrder;
  final String? imageUrl;

  const CourtDto({
    required this.id,
    required this.courtType,
    this.specificOption,
    required this.available,
    required this.displayOrder,
    this.imageUrl,
  });

  /// Crear CourtDto desde DocumentSnapshot de Firestore
  factory CourtDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CourtDto(
      id: doc.id,
      courtType: data['courtType'] as String,
      specificOption: data['specificOption'] as String?,
      available: data['available'] as bool? ?? false,
      displayOrder: data['displayOrder'] as int? ?? 0,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  /// Crear CourtDto desde Map (útil para testing)
  factory CourtDto.fromMap(String id, Map<String, dynamic> data) {
    return CourtDto(
      id: id,
      courtType: data['courtType'] as String,
      specificOption: data['specificOption'] as String?,
      available: data['available'] as bool? ?? false,
      displayOrder: data['displayOrder'] as int? ?? 0,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'courtType': courtType,
      'specificOption': specificOption,
      'available': available,
      'displayOrder': displayOrder,
      'imageUrl': imageUrl,
    };
  }

  /// Convertir DTO a modelo de dominio
  Court toDomain() {
    return Court(
      id: id,
      courtType: courtType,
      specificOption: specificOption,
      available: available,
      displayOrder: displayOrder,
      imageUrl: imageUrl,
    );
  }

  /// Crear DTO desde modelo de dominio
  factory CourtDto.fromDomain(Court court) {
    return CourtDto(
      id: court.id,
      courtType: court.courtType,
      specificOption: court.specificOption,
      available: court.available,
      displayOrder: court.displayOrder,
      imageUrl: court.imageUrl,
    );
  }
}
