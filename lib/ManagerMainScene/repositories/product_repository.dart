import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/ManagerMainScene/Models/product_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<ProductModel>> fetchItemsByTitle(String title) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('title', isEqualTo: title)
        .limit(5)
        .get();

    return querySnapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data()))
        .toList();
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      final ref = _storage
          .ref()
          .child('productsImages/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await ref.putFile(image);
      final imageUrl = await uploadTask.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }
    return imageUrls;
  }

  Future<void> uploadItem(ProductModel item) async {
    await _firestore.collection('products').add(item.toFirestore());
  }
}
