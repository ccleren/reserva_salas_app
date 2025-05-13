import 'package:cloud_firestore/cloud_firestore.dart';

class RoomsQueryBuilder {
  const RoomsQueryBuilder._();

  static Query<Map<String, dynamic>> build({
    String? textQuery,
    String? status,
    int? minCapacity,
    int? maxCapacity,
    double? maxPrice,
    List<String>? requiredAmenities,
  }) {
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance.collection('rooms');

    if (status != null && status != 'Todas') {
      q = q.where('status', isEqualTo: status);
    }
    if (minCapacity != null) {
      q = q.where('capacity', isGreaterThanOrEqualTo: minCapacity);
    }
    if (maxCapacity != null) {
      q = q.where('capacity', isLessThanOrEqualTo: maxCapacity);
    }
    if (maxPrice != null) {
      q = q.where('hourlyPrice', isLessThanOrEqualTo: maxPrice);
    }
    if (requiredAmenities != null && requiredAmenities.isNotEmpty) {
      for (final amenity in requiredAmenities) {
        q = q.where('amenities', arrayContains: amenity);
      }
    }
    if (textQuery != null && textQuery.isNotEmpty) {
      final tq = textQuery.toLowerCase();
      q = q
          .where('nameLower', isGreaterThanOrEqualTo: tq)
          .where('nameLower', isLessThan: '$tq\uf8ff');
    }
    return q.orderBy('nameLower');
  }
}