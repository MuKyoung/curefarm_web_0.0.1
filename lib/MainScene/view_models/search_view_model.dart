import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel() : super(SearchState.initial());

  final int postsPerPage = 10;
  DocumentSnapshot? lastDocument;

  // 좋아요 개수로 정렬하여 게시물 불러오기
  Future<void> loadPostsByPage(int page) async {
    state = state.copyWith(isLoading: true);

    QuerySnapshot snapshot;
    final postsRef = FirebaseFirestore.instance.collection('posts');

    if (lastDocument == null) {
      snapshot = await postsRef
          .orderBy('likeCount', descending: true)
          .limit(postsPerPage)
          .get();
    } else {
      snapshot = await postsRef
          .orderBy('likeCount', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(postsPerPage)
          .get();
    }

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last; // 마지막 문서 업데이트
    }

    int totalDocuments = (await postsRef.get()).size;
    int totalPages = (totalDocuments / postsPerPage).ceil();

    state = state.copyWith(
      posts: [...state.posts, ...snapshot.docs],
      isLoading: false,
      lastVisible: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      totalPages: totalPages,
    );
  }

  // 검색 기능 구현
  Future<void> searchPosts(String query) async {
    state = state.copyWith(isLoading: true);

    final postsRef = FirebaseFirestore.instance.collection('posts');
    final snapshot = await postsRef
        .where('tags', arrayContains: query)
        .orderBy('likeCount', descending: true)
        .limit(postsPerPage)
        .get();

    state = state.copyWith(
      posts: snapshot.docs,
      isLoading: false,
      lastVisible: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }
}

class SearchState {
  final List<QueryDocumentSnapshot> posts;
  final bool isLoading;
  final DocumentSnapshot? lastVisible;
  final int totalPages;

  SearchState({
    required this.posts,
    required this.isLoading,
    this.lastVisible,
    required this.totalPages,
  });

  // 초기 상태를 반환하는 factory
  factory SearchState.initial() {
    return SearchState(
      posts: [],
      isLoading: false,
      lastVisible: null,
      totalPages: 1,
    );
  }

  // 기존 상태에서 특정 필드를 업데이트하는 메소드
  SearchState copyWith({
    List<QueryDocumentSnapshot>? posts,
    bool? isLoading,
    DocumentSnapshot? lastVisible,
    int? totalPages,
  }) {
    return SearchState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      lastVisible: lastVisible ?? this.lastVisible,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  return SearchViewModel();
});
