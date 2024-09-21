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
                      searchViewModel.searchPosts(searchTerm);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('검색어를 입력하세요.')),
                      );
                    }
                  },
                ),
              ),
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
