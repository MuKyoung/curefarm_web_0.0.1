import 'package:curefarm_beta/MainScene/Screens/post_page.dart';
import 'package:curefarm_beta/MainScene/view_models/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  // 필터 조건 변수들
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedReservationType;
  final List<String> _selectedServices = [];

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

  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  // 시작 날짜 선택 함수
  Future<void> _selectStartDate(
      BuildContext context, StateSetter modalSetState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('ko'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
      modalSetState(() {});
    }
  }

  // 종료 날짜 선택 함수
  Future<void> _selectEndDate(
      BuildContext context, StateSetter modalSetState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('ko'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
      modalSetState(() {});
    }
  }

  // 필터 모달 창 열기
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 예약 시작 날짜
                    ListTile(
                      title: const Text('예약 시작 날짜'),
                      subtitle: Text(_selectedStartDate != null
                          ? _selectedStartDate!
                              .toLocal()
                              .toString()
                              .split(' ')[0]
                          : '날짜 선택'),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () =>
                            _selectStartDate(context, modalSetState),
                      ),
                    ),
                    const Divider(),

                    // 예약 종료 날짜
                    ListTile(
                      title: const Text('예약 종료 날짜'),
                      subtitle: Text(_selectedEndDate != null
                          ? _selectedEndDate!.toLocal().toString().split(' ')[0]
                          : '날짜 선택'),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectEndDate(context, modalSetState),
                      ),
                    ),
                    const Divider(),

                    // 예약 지역 선택 (도/광역시)
                    DropdownButtonFormField<String>(
                      value: _selectedProvince,
                      decoration: const InputDecoration(labelText: '도/광역시 선택'),
                      items: _provinces.map((province) {
                        return DropdownMenuItem(
                          value: province,
                          child: Text(province),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        modalSetState(() {
                          _selectedProvince = newValue;
                          _selectedCity = null; // 도 변경 시, 시/군/구 초기화
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // 예약 지역 선택 (시/군/구)
                    if (_selectedProvince != null)
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration:
                            const InputDecoration(labelText: '시/군/구 선택'),
                        items: _cities[_selectedProvince]!.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          modalSetState(() {
                            _selectedCity = newValue;
                          });
                        },
                      ),
                    const Divider(),

                    // 예약 유형 선택
                    DropdownButtonFormField<String>(
                      value: _selectedReservationType,
                      decoration: const InputDecoration(labelText: '예약 유형 선택'),
                      items: _reservationTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        modalSetState(() {
                          _selectedReservationType = newValue;
                        });
                      },
                    ),
                    const Divider(),

                    // 서비스 선택
                    const Text('서비스 옵션'),
                    Wrap(
                      children: _services.map((service) {
                        return FilterChip(
                          label: Text(service),
                          selected: _selectedServices.contains(service),
                          onSelected: (bool selected) {
                            modalSetState(() {
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
                    const Divider(),

                    // 가격 범위
                    TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '최소 가격'),
                    ),
                    TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '최대 가격'),
                    ),

                    const SizedBox(height: 20),

                    // 필터 적용 버튼
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 필터 모달 닫기
                        _applySearchFilter(); // 필터 적용 함수 호출
                      },
                      child: const Text('필터 적용'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 필터 적용 후 검색 수행 함수
  void _applySearchFilter() {
    final searchTerm = _searchController.text.trim();
    final minPrice = _minPriceController.text.isNotEmpty
        ? int.parse(_minPriceController.text)
        : null;
    final maxPrice = _maxPriceController.text.isNotEmpty
        ? int.parse(_maxPriceController.text)
        : null;

    // 검색 요청 수행
    ref.read(searchViewModelProvider.notifier).searchPosts(
          searchTerm,
          reservationStartDate: _selectedStartDate,
          reservationEndDate: _selectedEndDate,
          reservationArea: _selectedProvince != null && _selectedCity != null
              ? '$_selectedProvince$_selectedCity'
              : null,
          reservationType: _selectedReservationType,
          services: _selectedServices,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          title: const Text('게시물 검색'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '검색어 입력',
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _applySearchFilter,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterModal(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: searchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchState.posts.isEmpty
              ? const Center(child: Text('검색 결과가 없습니다.'))
              : ListView.builder(
                  itemCount: searchState.posts.length,
                  itemBuilder: (context, index) {
                    final post =
                        searchState.posts[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Image.network(post['imageUrls'][0]),
                      title: Text(post['title']),
                      onTap: () {
                        // 게시물 상세 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostDetailPage(
                                postId: searchState.posts[index].id),
                          ),
                        );
                      },
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('좋아요 ${post['likeCount']}개'),
                          Text((post['reservationProvince'] +
                                  " " +
                                  post['reservationCity']) ??
                              ''),
                          Text(post['reservationType'] ?? ''),
                          Text('₩${post['price']}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
