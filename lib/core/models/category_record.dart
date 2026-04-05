import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';

class CategoryRecord {
  final String id;
  final String title;
  final String type; // "service" or "product"
  final String folderKey;
  final String videoFolderKey;
  final List<Map<String, dynamic>> mediaItems;

  CategoryRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.folderKey,
    required this.videoFolderKey,
    this.mediaItems = const [],
  });

  factory CategoryRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryRecord(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? 'service',
      folderKey: data['imageFolder'] ?? '',
      videoFolderKey: data['videoFolder'] ?? '',
      mediaItems: List<Map<String, dynamic>>.from(data['mediaItems'] ?? []),
    );
  }

  /// Helper to convert a record to the legacy Map format used in AppConstants
  Map<String, dynamic> toLegacyMap() {
    return {
      'title': title,
      'folderKey': folderKey,
      'videoFolderKey': videoFolderKey,
      // Convert raw maps to CloudinaryResource objects for the UI
      'media': mediaItems.map((m) => CloudinaryResource(
        url: m['url'] ?? '',
        publicId: m['publicId'] ?? '',
        type: m['type'] == 'video' ? CloudinaryResourceType.video : CloudinaryResourceType.image,
      )).toList(),
      'img': mediaItems.map((m) => m['url'] ?? '').toList(),
    };
  }
}
