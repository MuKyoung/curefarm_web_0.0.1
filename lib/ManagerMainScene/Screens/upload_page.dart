import 'dart:io';
import 'dart:html' as html; // 웹에서 Blob URL을 사용하기 위함
import 'dart:typed_data'; // Uint8List 사용
import 'package:curefarm_beta/ManagerMainScene/Models/product_model.dart';
import 'package:curefarm_beta/ManagerMainScene/view_models/upload_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final Set<XFile> _selectedImages = {}; // 중복 방지 위해 Set 사용
  final Set<Uint8List> _selectedWebImages = {}; // 웹 이미지도 Set 사용
  List<String>? _webImageUrls = []; // 웹 이미지 URL 저장
  final ImagePicker _picker = ImagePicker();

  // 최대 업로드 가능한 이미지 개수
  static const int maxImages = 5;

  // Firebase Auth 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 이미지 선택
  Future<void> _pickImages() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null) {
        final newImagesCount = result.files.length;

        if (_selectedWebImages.length + newImagesCount > maxImages) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('최대 5개의 이미지만 선택할 수 있습니다.')),
          );
        } else {
          setState(() {
            _selectedWebImages.addAll(result.files.map((file) => file.bytes!));
            _webImageUrls = _selectedWebImages.map((fileBytes) {
              final blob = html.Blob([fileBytes]);
              return html.Url.createObjectUrlFromBlob(blob);
            }).toList();
          });
        }
      }
    } else {
      final pickedImages = await _picker.pickMultiImage(imageQuality: 85);
      final newImagesCount = pickedImages.length;

      if (_selectedImages.length + newImagesCount > maxImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최대 5개의 이미지만 선택할 수 있습니다.')),
        );
      } else {
        setState(() {
          _selectedImages.addAll(pickedImages);
        });
      }
    }
  }

  // 이미지 클릭 시 선택 해제
  void _removeImage(int index, {bool isWeb = false}) {
    setState(() {
      if (isWeb) {
        _selectedWebImages.remove(_selectedWebImages.elementAt(index));
        _webImageUrls?.removeAt(index);
      } else {
        _selectedImages.remove(_selectedImages.elementAt(index));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 업로드'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '본문 내용'),
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: '태그 (쉼표로 구분)',
              ),
            ),
            const SizedBox(height: 10),
            const Text('이미지 선택 (최대 5개)'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: kIsWeb
                  ? [
                      for (var i = 0; i < _webImageUrls!.length; i++)
                        GestureDetector(
                          onTap: () =>
                              _removeImage(i, isWeb: true), // 클릭 시 선택 해제
                          child: Image.network(
                            _webImageUrls![i],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('이미지 로드 실패');
                            },
                          ),
                        ),
                    ]
                  : [
                      for (var i = 0; i < _selectedImages.length; i++)
                        GestureDetector(
                          onTap: () => _removeImage(i), // 클릭 시 선택 해제
                          child: Image.file(
                            File(_selectedImages.elementAt(i).path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('이미지 선택'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final tags = _tagsController.text.split(',');

                // 업로드하는 사용자 정보 가져오기
                final User? user = _auth.currentUser;
                if (user != null) {
                  final uploader = user.displayName ?? "unknown"; // 업로더의 이메일

                  // 데이터 업로드 로직 호출 시 업로더 정보 포함
                  ref.read(uploadViewModelProvider.notifier).uploadPost(
                        title: _titleController.text,
                        description: _descriptionController.text,
                        tags: tags,
                        selectedImages: _selectedImages.toList(),
                        selectedWebImages: _selectedWebImages.toList(),
                        uploader: uploader, // 추가된 업로더 정보
                      );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인이 필요합니다.')),
                  );
                }
              },
              child: uploadState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('업로드'),
            ),
            if (uploadState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(uploadState.errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
