// lib/services/promotion_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion.dart';

class PromotionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('promotions');

  Stream<List<Promotion>> getPromotions() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Promotion.fromFirestore).toList());
  }

  Future<void> createPromotion({
    required String title,
    required String description,
    required DateTime date,
    required bool isActive,
    String? imageUrl, // URL externa, no se sube ningún archivo
  }) async {
    final promo = Promotion(
      id: '',
      title: title,
      description: description,
      date: date,
      imageUrl: imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
      isActive: isActive,
      createdAt: DateTime.now(),
    );
    await _col.add(promo.toFirestore());
  }

  Future<void> toggleStatus(String id, bool isActive) async {
    await _col.doc(id).update({'isActive': isActive});
  }

  Future<void> sendPromotion(String id) async {
    await _col.doc(id).update({
      'isSent': true,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePromotion(String id) async {
    await _col.doc(id).delete();
  }
}