import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel() : super(SearchState.initial());

  final int postsPerPage = 10;

  // 게시물 검색 함수 (필터 적용 및 페이지네이션 포함)
  Future<void> searchPosts(
    String query, {
    int page = 1,
    QueryDocumentSnapshot? lastVisible,
    DateTime? reservationDate,
    String? reservationArea,
    String? reservationType,
    List<String>? services,
    int? minPrice,
    int? maxPrice,
  }) async {
    try {
      state = state.copyWith(isLoading: true, posts: [], currentPage: page);

      final postsRef = FirebaseFirestore.instance.collection('posts');

      // 제목으로 검색 쿼리
      Query titleQuery = postsRef
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(postsPerPage);

      // 태그로 검색 쿼리
      Query tagsQuery =
          postsRef.where('tags', arrayContains: query).limit(postsPerPage);

      // 페이지네이션 적용 (lastVisible 사용)
      if (lastVisible != null) {
        titleQuery = titleQuery.startAfterDocument(lastVisible);
        tagsQuery = tagsQuery.startAfterDocument(lastVisible);
      }

      // Firestore에서 게시물 가져오기 (제목과 태그로 각각)
      final titleSnapshot = await titleQuery.get();
      final tagsSnapshot = await tagsQuery.get();

      // 중복 게시물을 피하기 위해 ID 기준으로 병합
      final uniquePosts = <String, QueryDocumentSnapshot>{};

      // 제목 검색 결과 추가
      for (var doc in titleSnapshot.docs) {
        uniquePosts[doc.id] = doc;
      }

      // 태그 검색 결과 추가 (중복 시 덮어씌워지지 않음)
      for (var doc in tagsSnapshot.docs) {
        uniquePosts.putIfAbsent(doc.id, () => doc);
      }

      // 병합된 게시물들을 리스트로 변환
      List<QueryDocumentSnapshot> filteredPosts = uniquePosts.values.toList();

      // 가져온 게시물들에 대해 추가 필터링 작업을 로컬에서 수행
      filteredPosts = filteredPosts.where((doc) {
        final postData = doc.data() as Map<String, dynamic>;
        bool matches = true;

        // 예약 날짜 필터링
        if (reservationDate != null) {
          matches = matches && (postData['reservationDate'] == reservationDate);
        }

        // 예약 지역 필터링
        if (reservationArea != null) {
          matches = matches && (postData['reservationArea'] == reservationArea);
        }

        // 예약 유형 필터링
        if (reservationType != null) {
          matches = matches && (postData['reservationType'] == reservationType);
        }

        // 서비스 필터링 (배열에 포함 여부 체크)
        if (services != null && services.isNotEmpty) {
          matches = matches &&
              services.every((service) =>
                  (postData['services'] as List<dynamic>).contains(service));
        }

        // 가격 필터링
        if (minPrice != null) {
          matches = matches && (postData['price'] >= minPrice);
        }
        if (maxPrice != null) {
          matches = matches && (postData['price'] <= maxPrice);
        }

        return matches;
      }).toList();

      // 좋아요 순으로 정렬
      filteredPosts.sort((a, b) {
        int likeCountA = (a.data() as Map<String, dynamic>)['likeCount'] ?? 0;
        int likeCountB = (b.data() as Map<String, dynamic>)['likeCount'] ?? 0;
        return likeCountB.compareTo(likeCountA);
      });

      // 상태 업데이트
      state = state.copyWith(
        posts: filteredPosts,
        isLoading: false,
        lastVisible: filteredPosts.isNotEmpty ? filteredPosts.last : null,
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
