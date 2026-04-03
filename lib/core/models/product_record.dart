import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { image, video }

class ProductRecord {
  final String id;
  final String publicId; // The Cloudinary public ID
  final String url; // Cloudinary URL
  final MediaType type;
  final String assetFolder;
  final String title;
  final double? price;
  final bool isAvailable;
  final DateTime createdAt;

  ProductRecord({
    required this.id,
    required this.publicId,
    required this.url,
    required this.type,
    required this.assetFolder,
    required this.title,
    this.price,
    required this.isAvailable,
    required this.createdAt,
  });

  factory ProductRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductRecord(
      id: doc.id,
      publicId: data['publicId'] ?? '',
      url: data['url'] ?? '',
      type: (data['type'] == 'video' || data['assetType'] == 'video')
          ? MediaType.video
          : MediaType.image,
      assetFolder: data['assetFolder'] ?? 'moblack/products',
      title: data['title'] ?? 'Moblack Product',
      price: data['price'] != null ? (data['price'] as num).toDouble() : null,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
