// item_view_model.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/ManagerMainScene/Models/product_model.dart';
import 'package:curefarm_beta/ManagerMainScene/repositories/product_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final uploadViewModelProvider =
    StateNotifierProvider<UploadViewModel, _UploadState>(
  (ref) => UploadViewModel(),
);

class _UploadState {
  final bool isLoading;
  final String errorMessage;

  _UploadState({this.isLoading = false, this.errorMessage = ''});
}

class UploadViewModel extends StateNotifier<_UploadState> {
  UploadViewModel() : super(_UploadState());

  Future<void> uploadData({
    required String title,
    required String description,
    required List<String> tags,
    List<XFile>? selectedImages,
    List<Uint8List>? selectedWebImages,
    required String uploader,
  }) async {
    if (title.isEmpty ||
        description.isEmpty ||
        (selectedImages == null && selectedWebImages == null)) {
      state = _UploadState(errorMessage: '모든 필드를 채우고 이미지를 선택하세요.');
      return;
    }

    state = _UploadState(isLoading: true);

    List<String> uploadedImageUrls = [];

    try {
      if (kIsWeb) {
        for (var fileBytes in selectedWebImages!) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('productImages/${DateTime.now().millisecondsSinceEpoch}');
          final uploadTask = await ref.putData(fileBytes); // 웹에서 데이터 업로드
          final imageUrl = await uploadTask.ref.getDownloadURL();
          uploadedImageUrls.add(imageUrl);
        }
      } else {
        for (var image in selectedImages!) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('productImages/${DateTime.now().millisecondsSinceEpoch}');
          final uploadTask =
              await ref.putFile(File(image.path)); // 모바일에서 파일 업로드
          final imageUrl = await uploadTask.ref.getDownloadURL();
          uploadedImageUrls.add(imageUrl);
        }
      }

      // Firestore에 데이터 저장
      await FirebaseFirestore.instance.collection('products').add({
        'title': title,
        'description': description,
        'tags': tags,
        'imageUrls': uploadedImageUrls,
        'uploader': uploader,
      });

      state = _UploadState(); // 완료 상태로 전환
    } catch (e) {
      state = _UploadState(errorMessage: '업로드 실패: $e');
    }
  }
}
