// lib/models/promotion.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final bool isActive;
  final bool isSent;
  final DateTime? sentAt;
  final DateTime createdAt;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.isActive,
    this.isSent = false,
    this.sentAt,
    required this.createdAt,
  });

  // ── Firestore → Dart ──────────────────────────────────────────────────────
  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      isSent: data['isSent'] ?? false,
      sentAt: data['sentAt'] != null
          ? (data['sentAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // ── Dart → Firestore ──────────────────────────────────────────────────────
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'isActive': isActive,
      'isSent': isSent,
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Promotion copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? imageUrl,
    bool? isActive,
    bool? isSent,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}