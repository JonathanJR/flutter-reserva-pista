import 'package:equatable/equatable.dart';

/// Estado de la pantalla Home
class HomeState extends Equatable {
  final bool isLoading;
  final List<SportInfo> sports;

  const HomeState({
    required this.isLoading,
    required this.sports,
  });

  factory HomeState.initial() {
    return const HomeState(
      isLoading: false,
      sports: [
        SportInfo(
          id: 'tennis',
          name: 'Tenis',
          imagePath: 'assets/images/img_tennis.png',
          isAvailable: true,
        ),
        SportInfo(
          id: 'padel',
          name: 'Pádel',
          imagePath: 'assets/images/img_padel.png',
          isAvailable: true,
        ),
        SportInfo(
          id: 'football',
          name: 'Fútbol Sala',
          imagePath: 'assets/images/img_football.png',
          isAvailable: true,
        ),
      ],
    );
  }

  HomeState copyWith({
    bool? isLoading,
    List<SportInfo>? sports,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      sports: sports ?? this.sports,
    );
  }

  @override
  List<Object?> get props => [isLoading, sports];
}

/// Información de un deporte para mostrar en la Home
class SportInfo extends Equatable {
  final String id;
  final String name;
  final String imagePath;
  final bool isAvailable;

  const SportInfo({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isAvailable = true,
  });

  SportInfo copyWith({
    String? id,
    String? name,
    String? imagePath,
    bool? isAvailable,
  }) {
    return SportInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [id, name, imagePath, isAvailable];
}
