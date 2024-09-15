import 'package:curefarm_beta/MainScene/Screens/post_page.dart';
import 'package:curefarm_beta/MainScene/view_models/search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController searchController = TextEditingController();
    final searchState = ref.watch(searchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: '검색어 입력',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    ref
                        .read(searchViewModelProvider.notifier)
                        .searchPosts(searchController.text);
                  },
                ),
              ),
            ),
            Expanded(
              child: searchState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchState.posts.isEmpty
                      ? const Text('검색 결과가 없습니다')
                      : ListView.builder(
                          itemCount: searchState.posts.length,
                          itemBuilder: (context, index) {
                            final post = searchState.posts[index].data()
                                as Map<String, dynamic>;
                            return ListTile(
                              leading: Image.network(
                                  post['imageUrls'][0]), // 첫 번째 이미지
                              title: Text(post['title']),
                              subtitle: Text(post['uploader']),
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
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
