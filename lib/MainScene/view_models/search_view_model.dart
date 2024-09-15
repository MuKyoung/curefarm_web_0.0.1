import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/MainScene/Model/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel() : super(SearchState());

  Future<void> searchPosts(String searchTerm) async {
    state = state.copyWith(isLoading: true);

    try {
      // 제목 검색: 제목이 검색어로 시작하는 모든 게시물 찾기
      final titleQuery = FirebaseFirestore.instance
          .collection('posts')
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();

      // 태그 검색: 태그 배열에 검색어가 포함된 모든 게시물 찾기
      final tagQuery = FirebaseFirestore.instance
          .collection('posts')
          .where('tags', arrayContains: searchTerm)
          .get();

      // 두 쿼리를 동시에 실행
      final results = await Future.wait([titleQuery, tagQuery]);

      // 결과 합치기 (중복 제거)
      final posts = <DocumentSnapshot>{};
      posts.addAll(results[0].docs);
      posts.addAll(results[1].docs);

      // 검색 결과를 상태에 저장
      state = state.copyWith(posts: posts.toList(), isLoading: false);
    } catch (e) {
      print('검색 오류: $e');
      state =
          state.copyWith(errorMessage: '검색 중 오류가 발생했습니다.', isLoading: false);
    }
  }
}

class SearchState {
  final List<DocumentSnapshot> posts;
  final bool isLoading;
  final String errorMessage;

  SearchState({
    this.posts = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  SearchState copyWith({
    List<DocumentSnapshot>? posts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel();
});
