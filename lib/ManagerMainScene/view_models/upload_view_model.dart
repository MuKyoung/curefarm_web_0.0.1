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
  UploadViewModel() : super(UploadState.initial());

  Future<void> uploadPost({
    required String title,
    required String description,
    required List<XFile> selectedImages,
    required List<Uint8List> selectedWebImages,
    required List<String> tags,
    required String uploader,
    required DateTime startDate, // 시작일
    required DateTime endDate, // 종료일
    required String reservationProvince, // 도/특별시/광역시
    required String reservationCity, // 시/군/구
    required String reservationType,
    required List<String> services,
    required int price,
  }) async {
    try {
      // 로딩 상태 설정
      state = state.copyWith(isLoading: true);

      // 이미지 업로드 처리
      List<String> imageUrls = [];

      // 모바일 이미지 업로드
      for (XFile image in selectedImages) {
        String imageUrl = await _uploadImageToStorage(image.path);
        imageUrls.add(imageUrl);
      }

      // 웹 이미지 업로드
      for (Uint8List webImage in selectedWebImages) {
        String imageUrl = await _uploadWebImageToStorage(webImage);
        imageUrls.add(imageUrl);
      }

      // 태그 전처리
      List<String> processedTags = tags.map((tag) => tag.trim()).toList();

      // Firestore에 게시물 저장
      await FirebaseFirestore.instance.collection('posts').add({
        'title': title,
        'description': description,
        'imageUrls': imageUrls,
        'tags': processedTags,
        'uploader': uploader,
        'createdAt': FieldValue.serverTimestamp(),
        'startDate': startDate, // 시작일 추가
        'endDate': endDate, // 종료일 추가
        'reservationProvince': reservationProvince, // 도/특별시/광역시 추가
        'reservationCity': reservationCity, // 시/군/구 추가
        'reservationType': reservationType,
        'services': services,
        'price': price,
        'likeCount': 0,
      });
      // 성공 후 로딩 해제
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // 오류 발생 시 처리
      state =
          state.copyWith(isLoading: false, errorMessage: '게시물 업로드에 실패했습니다.');
      throw Exception('게시물 업로드에 실패했습니다.');
    }
  }

  // 이미지 업로드 로직 (모바일)
  Future<String> _uploadImageToStorage(String imagePath) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(File(imagePath));
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('이미지 업로드에 실패했습니다.');
    }
  }

  // 이미지 업로드 로직 (웹)
  Future<String> _uploadWebImageToStorage(Uint8List webImage) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putData(webImage);
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('이미지 업로드에 실패했습니다.');
    }
  }
}

class UploadState {
  final bool isLoading;
  final String? errorMessage;

  UploadState({required this.isLoading, this.errorMessage});

  factory UploadState.initial() {
    return UploadState(isLoading: false, errorMessage: null);
  }

  UploadState copyWith({bool? isLoading, String? errorMessage}) {
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
