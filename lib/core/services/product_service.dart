import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_record.dart';

class ProductService {
  static final _col = FirebaseFirestore.instance.collection('products');

  /// Fetches all product records from Firestore, grouped by their asset folder.
  static Future<Map<String, List<ProductRecord>>> fetchGroupedProducts() async {
    final query = await _col.orderBy('createdAt', descending: true).get();

    final allProducts = query.docs
        .map((doc) => ProductRecord.fromFirestore(doc))
        .toList();

    final Map<String, List<ProductRecord>> grouped = {};
    for (var product in allProducts) {
      grouped.putIfAbsent(product.assetFolder, () => []).add(product);
    }

    return grouped;
  }

  /// Streams all product records from Firestore in real-time, grouped by their asset folder.
  static Stream<Map<String, List<ProductRecord>>> streamGroupedProducts() {
    return _col.orderBy('createdAt', descending: true).snapshots().map((query) {
      final allProducts = query.docs
          .map((doc) => ProductRecord.fromFirestore(doc))
          .toList();

      final Map<String, List<ProductRecord>> grouped = {};
      for (var product in allProducts) {
        grouped.putIfAbsent(product.assetFolder, () => []).add(product);
      }
      return grouped;
    });
  }

  /// Fetches a flat list of products, optionally filtering to only products with video type.
  static Future<List<ProductRecord>> fetchProducts({
    bool onlyVideos = false,
  }) async {
    final query = await _col.orderBy('createdAt', descending: true).get();
    var allProducts = query.docs
        .map((doc) => ProductRecord.fromFirestore(doc))
        .toList();

    if (onlyVideos) {
      allProducts = allProducts
          .where((p) => p.type == MediaType.video)
          .toList();
    }

    return allProducts;
  }
}
