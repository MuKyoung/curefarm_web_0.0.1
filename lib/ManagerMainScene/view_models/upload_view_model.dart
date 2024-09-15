// item_view_model.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/MainScene/Model/post_model.dart';
import 'package:curefarm_beta/ManagerMainScene/Models/product_model.dart';
import 'package:curefarm_beta/ManagerMainScene/repositories/product_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UploadViewModel extends StateNotifier<UploadState> {
  UploadViewModel() : super(UploadState());

  Future<void> uploadData({
    required String title,
    required String description,
    required List<XFile> selectedImages, // 모바일용
    required List<Uint8List> selectedWebImages, // 웹용
    required String uploader,
    required List<String> tags,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      List<String> imageUrls = []; // 업로드된 이미지들의 URL을 저장할 리스트

      // 모바일에서 이미지를 선택한 경우
      for (var image in selectedImages) {
        final String imageId = DateTime.now()
            .millisecondsSinceEpoch
            .toString(); // 현재 시간을 기준으로 고유한 이미지 ID 생성
        final ref = FirebaseStorage.instance
            .ref()
            .child('uploads/$imageId'); // Firebase Storage에 경로 설정
        final uploadTask = await ref.putFile(File(image.path)); // 이미지 업로드

        // 업로드 완료 후 URL 가져오기
        final imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl); // URL 리스트에 추가
      }

      // 웹에서 이미지를 선택한 경우
      for (var image in selectedWebImages) {
        final String imageId =
            DateTime.now().millisecondsSinceEpoch.toString(); // 고유한 이미지 ID 생성
        final ref = FirebaseStorage.instance.ref().child('uploads/$imageId');
        final uploadTask = await ref.putData(image); // Uint8List로 이미지 업로드

        // 업로드 완료 후 URL 가져오기
        final imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // 모든 이미지 업로드 후 Firestore에 데이터 저장
      final post = {
        'title': title,
        'description': description,
        'imageUrls': imageUrls, // 업로드한 이미지들의 URL 리스트
        'tags': tags,
        'uploader': uploader,
        'createdAt': FieldValue.serverTimestamp(), // 생성 시간
      };

      await FirebaseFirestore.instance.collection('posts').add(post);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('업로드 오류: $e'); // 콘솔에 오류 로그 출력
      state =
          state.copyWith(errorMessage: '업로드 중 오류가 발생했습니다.', isLoading: false);
    }
  }
}

class UploadState {
  final bool isLoading;
  final String errorMessage;

  UploadState({
    this.isLoading = false,
    this.errorMessage = '',
  });

  UploadState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final uploadViewModelProvider =
    StateNotifierProvider<UploadViewModel, UploadState>((ref) {
  return UploadViewModel();
});
