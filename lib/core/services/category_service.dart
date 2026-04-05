import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_record.dart';

class CategoryService {
  static final _col = FirebaseFirestore.instance.collection('categories');

  /// Fetches all dynamic categories from Firestore.
  static Future<List<CategoryRecord>> getCategories() async {
    try {
      final snap = await _col.orderBy('title').get();
      return snap.docs.map(CategoryRecord.fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  /// Streams dynamic categories for real-time updates.
  static Stream<List<CategoryRecord>> streamCategories() {
    return _col
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs.map(CategoryRecord.fromFirestore).toList());
  }
}
