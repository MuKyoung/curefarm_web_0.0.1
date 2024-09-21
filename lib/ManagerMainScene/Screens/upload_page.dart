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
  final _priceController = TextEditingController(); // 가격 입력 필드 추가
  DateTime? _selectedDate; // 예약 날짜
  String? _selectedArea; // 예약 지역
  String? _selectedReservationType; // 예약 유형
  final List<String> _selectedServices = []; // 제공 서비스
  final Set<XFile> _selectedImages = {}; // 모바일 이미지
  final Set<Uint8List> _selectedWebImages = {}; // 웹 이미지
  final ImagePicker _picker = ImagePicker();
  List<String> _webImageUrls = []; // 웹 이미지 URL 저장

  // 지역 목록 및 예약 유형/서비스 목록
  final List<String> _areas = ['서울', '경기도', '부산'];
  final List<String> _reservationTypes = ['일일체험', '숙박형 체험'];
  final List<String> _services = ['반려동물 가능', '와이파이', '픽업 서비스'];

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
        _webImageUrls.removeAt(index);
      } else {
        _selectedImages.remove(_selectedImages.elementAt(index));
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            const Text('예약 날짜'),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text(_selectedDate != null
                  ? _selectedDate!.toLocal().toString().split(' ')[0]
                  : '날짜 선택'),
            ),
            const SizedBox(height: 10),
            const Text('예약 지역'),
            DropdownButton<String>(
              value: _selectedArea,
              hint: const Text('지역 선택'),
              onChanged: (newValue) {
                setState(() {
                  _selectedArea = newValue;
                });
              },
              items: _areas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text('예약 유형'),
            DropdownButton<String>(
              value: _selectedReservationType,
              hint: const Text('유형 선택'),
              onChanged: (newValue) {
                setState(() {
                  _selectedReservationType = newValue;
                });
              },
              items: _reservationTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text('제공 서비스'),
            Wrap(
              spacing: 8.0,
              children: _services.map((service) {
                return FilterChip(
                  label: Text(service),
                  selected: _selectedServices.contains(service),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            const Text('이미지 선택 (최대 5개)'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: kIsWeb
                  ? [
                      for (var i = 0; i < _webImageUrls.length; i++)
                        GestureDetector(
                          onTap: () => _removeImage(i, isWeb: true),
                          child: Image.network(
                            _webImageUrls[i],
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
                          onTap: () => _removeImage(i),
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

                final User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final uploader = user.displayName ?? "unknown";

                  if (_selectedDate != null &&
                      _selectedArea != null &&
                      _selectedReservationType != null &&
                      _priceController.text.isNotEmpty) {
                    ref.read(uploadViewModelProvider.notifier).uploadPost(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          tags: tags,
                          selectedImages: _selectedImages.toList(),
                          selectedWebImages: _selectedWebImages.toList(),
                          uploader: uploader,
                          reservationDate: _selectedDate!,
                          reservationArea: _selectedArea!,
                          reservationType: _selectedReservationType!,
                          services: _selectedServices,
                          price: int.parse(_priceController.text),
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('모든 필드를 입력해주세요.')),
                    );
                  }
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
