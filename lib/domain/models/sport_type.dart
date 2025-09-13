/// Tipos de deporte disponibles
enum SportType {
  tennis('tennis', 'Tenis'),
  padel('padel', 'Pádel'), 
  football('football', 'Fútbol Sala');

  const SportType(this.id, this.displayName);

  final String id;
  final String displayName;

  /// Obtener SportType por ID
  static SportType? fromId(String id) {
    try {
      return SportType.values.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Información de tipo de deporte para la UI
class SportTypeInfo {
  final String id;
  final String name;
  final String imagePath;
  final bool isAvailable;

  const SportTypeInfo({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.isAvailable,
  });

  /// Crear SportTypeInfo desde SportType
  factory SportTypeInfo.fromSportType(
    SportType sportType, {
    required bool isAvailable,
  }) {
    return SportTypeInfo(
      id: sportType.id,
      name: sportType.displayName,
      imagePath: _getImagePath(sportType),
      isAvailable: isAvailable,
    );
  }

  static String _getImagePath(SportType sportType) {
    switch (sportType) {
      case SportType.tennis:
        return 'assets/images/img_tennis.png';
      case SportType.padel:
        return 'assets/images/img_padel.png';
      case SportType.football:
        return 'assets/images/img_football.png';
    }
  }

  SportTypeInfo copyWith({
    String? id,
    String? name,
    String? imagePath,
    bool? isAvailable,
  }) {
    return SportTypeInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
