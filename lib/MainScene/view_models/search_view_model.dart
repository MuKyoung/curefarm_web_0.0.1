import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel() : super(SearchState.initial());

  final int postsPerPage = 10;

  // 게시물 검색 함수 (페이지네이션 포함)
  Future<void> searchPosts(String query,
      {int page = 1, QueryDocumentSnapshot? lastVisible}) async {
    try {
      state = state.copyWith(isLoading: true, posts: [], currentPage: page);

      final postsRef = FirebaseFirestore.instance.collection('posts');

      // 기본 쿼리
      Query titleQuery = postsRef
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(postsPerPage);

      Query tagsQuery =
          postsRef.where('tags', arrayContains: query).limit(postsPerPage);

      // 페이지네이션을 위한 커서 설정
      if (lastVisible != null) {
        titleQuery = titleQuery.startAfterDocument(lastVisible);
        tagsQuery = tagsQuery.startAfterDocument(lastVisible);
      }

      // 두 쿼리 결과를 가져옴
      final titleSnapshot = await titleQuery.get();
      final tagsSnapshot = await tagsQuery.get();

      // 두 결과를 합침
      final allPosts = <QueryDocumentSnapshot<Object?>>[
        ...titleSnapshot.docs,
        ...tagsSnapshot.docs,
      ];

      allPosts.sort((a, b) {
        int likeCountA = (a.data() as Map<String, dynamic>)['likeCount'] ?? 0;
        int likeCountB = (b.data() as Map<String, dynamic>)['likeCount'] ?? 0;
        return likeCountB.compareTo(likeCountA);
      });
      // 중복된 게시물 제거 (id 기준으로)
      final uniquePosts = allPosts.toSet().toList();

      // 상태 업데이트
      state = state.copyWith(
        posts: uniquePosts,
        isLoading: false,
        lastVisible: uniquePosts.isNotEmpty ? uniquePosts.last : null,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Error during search: $e');
    }
  }

  // 페이지네이션을 위한 페이지 변경
  Future<void> changePage(int newPage, String query) async {
    if (newPage > 0 && newPage <= state.totalPages) {
      // 타입 캐스팅을 통해 lastVisible을 QueryDocumentSnapshot으로 변환
      final lastVisible = state.lastVisible as QueryDocumentSnapshot<Object?>?;
      await searchPosts(query, page: newPage, lastVisible: lastVisible);
    }
  }
}

class SearchState {
  final List<QueryDocumentSnapshot> posts;
  final bool isLoading;
  final DocumentSnapshot? lastVisible;
  final int currentPage;
  final int totalPages;

  SearchState({
    required this.posts,
    required this.isLoading,
    this.lastVisible,
    required this.currentPage,
    required this.totalPages,
  });

  // 초기 상태를 반환하는 factory
  factory SearchState.initial() {
    return SearchState(
      posts: [],
      isLoading: false,
      lastVisible: null,
      currentPage: 1,
      totalPages: 1,
    );
  }

  // 기존 상태에서 특정 필드를 업데이트하는 메소드
  SearchState copyWith({
    List<QueryDocumentSnapshot>? posts,
    bool? isLoading,
    DocumentSnapshot? lastVisible,
    int? currentPage,
    int? totalPages,
  }) {
    return SearchState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      lastVisible: lastVisible ?? this.lastVisible,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel();
});
