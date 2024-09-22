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
  DateTime? _startDate; // 시작일
  DateTime? _endDate; // 종료일
  String? _selectedProvince; // 선택된 도/특별시/광역시
  String? _selectedCity; // 선택된 시/군/구
  String? _selectedReservationType; // 예약 유형
  final List<String> _selectedServices = []; // 제공 서비스
  final Set<XFile> _selectedImages = {}; // 모바일 이미지
  final Set<Uint8List> _selectedWebImages = {}; // 웹 이미지
  final ImagePicker _picker = ImagePicker();
  List<String> _webImageUrls = []; // 웹 이미지 URL 저장

  // 도/특별시/광역시 목록
  final List<String> _provinces = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원특별자치도',
    '충청북도',
    '충청남도',
    '전북특별자치도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  // 각 도에 속한 시/군/구 목록
  final Map<String, List<String>> _cities = {
    '서울특별시': [
      '종로구',
      '중구',
      '용산구',
      '성동구',
      '광진구',
      '동대문구',
      '중랑구',
      '성북구',
      '강북구',
      '도봉구',
      '노원구',
      '은평구',
      '서대문구',
      '마포구',
      '양천구',
      '강서구',
      '구로구',
      '금천구',
      '영등포구',
      '동작구',
      '관악구',
      '서초구',
      '강남구',
      '송파구',
      '강동구'
    ],
    '부산광역시': [
      '중구',
      '서구',
      '동구',
      '영도구',
      '부산진구',
      '동래구',
      '남구',
      '북구',
      '해운대구',
      '사하구',
      '금정구',
      '강서구',
      '연제구',
      '수영구',
      '사상구',
      '기장군'
    ],
    '대구광역시': [
      '중구',
      '동구',
      '서구',
      '남구',
      '북구',
      '수성구',
      '달서구',
      '달성군',
    ],
    '인천광역시': [
      '중구',
      '동구',
      '미추홀구',
      '연수구',
      '남동구',
      '부평구',
      '계양구',
      '서구',
      '강화군',
      '옹진군',
    ],
    '광주광역시': [
      '동구',
      '서구',
      '남구',
      '북구',
      '광산구',
    ],
    '대전광역시': [
      '동구',
      '중구',
      '서구',
      '유성구',
      '대덕구',
    ],
    '울산광역시': [
      '중구',
      '남구',
      '동구',
      '북구',
      '울주군',
    ],
    '경기도': [
      '수원시',
      '성남시',
      '의정부시',
      '안양시',
      '부천시',
      '광명시',
      '평택시',
      '동두천시',
      '안산시',
      '고양시',
      '과천시',
      '구리시',
      '남양주시',
      '오산시',
      '시흥시',
      '군포시',
      '의왕시',
      '하남시',
      '용인시',
      '파주시',
      '이천시',
      '안성시',
      '김포시',
      '화성시',
      '광주시',
      '양주시',
      '포천시',
      '여주시',
      '연천군',
      '가평군',
      '양평군',
    ],
    '강원특별자치도': [
      '춘천시',
      '원주시',
      '강릉시',
      '동해시',
      '태백시',
      '속초시',
      '삼척시',
      '홍천군',
      '횡성군',
      '영월군',
      '평창군',
      '정선군',
      '철원군',
      '화천군',
      '양구군',
      '인제군',
      '고성군',
      '양양군',
    ],
    '충청북도': [
      '청주시',
      '충주시',
      '제천시',
      '보은군',
      '옥천군',
      '영동군',
      '증평군',
      '진천군',
      '괴산군',
      '음성군',
      '단양군',
    ],
    '충청남도': [
      '천안시',
      '공주시',
      '당진시',
      '보령시',
      '아산시',
      '서산시',
      '논산시',
      '계룡시',
      '금산군',
      '부여군',
      '서천군',
      '청양군',
      '홍성군',
      '예산군',
      '태안군',
    ],
    '전북특별자치도': [
      '전주시',
      '군산시',
      '익산시',
      '정읍시',
      '남원시',
      '김제시',
      '완주군',
      '진안군',
      '무주군',
      '장수군',
      '임실군',
      '순창군',
      '고창군',
      '부안군',
    ],
    '전라남도': [
      '목포시',
      '여수시',
      '순천시',
      '나주시',
      '광양시',
      '담양군',
      '곡성군',
      '구례군',
      '고흥군',
      '보성군',
      '화순군',
      '장흥군',
      '강진군',
      '해남군',
      '영암군',
      '무안군',
      '함평군',
      '영광군',
      '장성군',
      '완도군',
      '진도군',
      '신안군',
    ],
    '경상북도': [
      '포항시',
      '경주시',
      '김천시',
      '안동시',
      '구미시',
      '영주시',
      '영천시',
      '상주시',
      '문경시',
      '경산시',
      '군위군',
      '의성군',
      '청송군',
      '영양군',
      '영덕군',
      '청도군',
      '고령군',
      '성주군',
      '칠곡군',
      '예천군',
      '봉화군',
      '울진군',
      '울릉군',
    ],
    '경상남도': [
      '창원시',
      '진주시',
      '통영시',
      '사천시',
      '김해시',
      '밀양시',
      '거제시',
      '양산시',
      '의령군',
      '함안군',
      '창녕군',
      '고성군',
      '남해군',
      '하동군',
      '산청군',
      '함양군',
      '거창군',
      '합천군,'
    ],
    '제주특별자치도': [
      '제주시',
      '서귀포시',
    ],
  };
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
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
            const Text('예약 기간'),
            TextButton(
              onPressed: () => _selectDateRange(context),
              child: Text(_startDate != null && _endDate != null
                  ? '${_startDate!.toLocal().toString().split(' ')[0]} ~ ${_endDate!.toLocal().toString().split(' ')[0]}'
                  : '기간 선택'),
            ),
            const SizedBox(height: 10),
            const Text('예약 지역'),
            DropdownButton<String>(
              value: _selectedProvince,
              hint: const Text('도/특별시/광역시 선택'),
              onChanged: (newValue) {
                setState(() {
                  _selectedProvince = newValue;
                  _selectedCity = null; // 도를 변경하면 시/군/구는 초기화
                });
              },
              items: _provinces.map((province) {
                return DropdownMenuItem(
                  value: province,
                  child: Text(province),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCity,
              hint: const Text('시/군/구 선택'),
              onChanged: (newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
              items: (_selectedProvince != null &&
                      _cities.containsKey(_selectedProvince))
                  ? _cities[_selectedProvince]!.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList()
                  : [],
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

                  if (_startDate != null &&
                      _endDate != null &&
                      _selectedProvince != null &&
                      _selectedCity != null &&
                      _selectedReservationType != null &&
                      _priceController.text.isNotEmpty) {
                    ref.read(uploadViewModelProvider.notifier).uploadPost(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          tags: tags,
                          selectedImages: _selectedImages.toList(),
                          selectedWebImages: _selectedWebImages.toList(),
                          uploader: uploader,
                          startDate: _startDate!, // 시작일
                          endDate: _endDate!, // 종료일
                          reservationProvince: _selectedProvince!,
                          reservationCity: _selectedCity!,
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
