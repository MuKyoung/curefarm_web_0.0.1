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
  DateTime? _selectedDate;
  String? _selectedArea;
  String? _selectedReservationType;
  final List<String> _selectedServices = [];
  final List<String> _areas = ['서울', '경기도', '부산'];
  final List<String> _reservationTypes = ['일일체험', '숙박형 체험'];
  final List<String> _services = ['반려동물 가능', '와이파이', '픽업 서비스'];
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

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
    final searchState = ref.watch(searchViewModelProvider);
    final searchViewModel = ref.read(searchViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '검색어 입력',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final searchTerm = _searchController.text.trim();
                    if (searchTerm.isNotEmpty) {
                      final minPrice = _minPriceController.text.isNotEmpty
                          ? int.parse(_minPriceController.text)
                          : null;
                      final maxPrice = _maxPriceController.text.isNotEmpty
                          ? int.parse(_maxPriceController.text)
                          : null;

                      searchViewModel.searchPosts(
                        searchTerm,
                        reservationDate: _selectedDate,
                        reservationArea: _selectedArea,
                        reservationType: _selectedReservationType,
                        services: _selectedServices,
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('검색어를 입력하세요.')),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text(_selectedDate != null
                  ? _selectedDate!.toLocal().toString().split(' ')[0]
                  : '예약 날짜 선택'),
            ),
            DropdownButton<String>(
              value: _selectedArea,
              hint: const Text('예약 지역 선택'),
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
            DropdownButton<String>(
              value: _selectedReservationType,
              hint: const Text('예약 유형 선택'),
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
            Wrap(
              children: _services.map((service) {
                return CheckboxListTile(
                  title: Text(service),
                  value: _selectedServices.contains(service),
                  onChanged: (bool? isChecked) {
                    setState(() {
                      if (isChecked == true) {
                        _selectedServices.add(service);
                      } else {
                        _selectedServices.remove(service);
                      }
                    });
                  },
                );
              }).toList(),
            ),
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
            Expanded(
              child: searchState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchState.posts.isEmpty
                      ? const Text('검색 결과가 없습니다.')
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: searchState.posts.length,
                                itemBuilder: (context, index) {
                                  final post = searchState.posts[index].data()
                                      as Map<String, dynamic>;
                                  return ListTile(
                                    leading:
                                        Image.network(post['imageUrls'][0]),
                                    title: Text(post['title']),
                                    subtitle: Text('좋아요 ${post['likeCount']}개'),
                                    onTap: () {
                                      // 게시물 상세 페이지로 이동
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PostDetailPage(
                                              postId:
                                                  searchState.posts[index].id),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(searchState.totalPages,
                                  (pageIndex) {
                                return TextButton(
                                  onPressed: () {
                                    searchViewModel.changePage(pageIndex + 1,
                                        _searchController.text.trim());
                                  },
                                  child: Text('${pageIndex + 1}'),
                                );
                              }),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
