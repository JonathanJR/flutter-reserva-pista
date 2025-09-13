import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/court_dto.dart';

/// DataSource remoto para courts desde Firestore
class CourtRemoteDataSource {
  final FirebaseFirestore _firestore;

  const CourtRemoteDataSource(this._firestore);

  /// Colección de courts en Firestore
  static const String _courtsCollection = 'courts';

  /// Stream de todas las courts (tiempo real)
  Stream<List<CourtDto>> getCourtsStream() {
    return _firestore
        .collection(_courtsCollection)
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourtDto.fromFirestore(doc))
            .toList());
  }

  /// Stream de courts por tipo de deporte (tiempo real)
  Stream<List<CourtDto>> getCourtsBySportTypeStream(String sportType) {
    return _firestore
        .collection(_courtsCollection)
        .where('courtType', isEqualTo: sportType)
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CourtDto.fromFirestore(doc))
            .toList());
  }
}
