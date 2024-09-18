import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/MainScene/Model/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  Future<void> _fetchPostData() async {
    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();
    if (postDoc.exists) {
      final postData = postDoc.data() as Map<String, dynamic>;
      setState(() {
        likeCount = postData['likeCount'] ?? 0;
        // 사용자가 이전에 좋아요를 눌렀는지 확인 (여기서는 단순히 기본값 false)
        isLiked = false; // 실제로는 유저 데이터와 비교해서 처리해야 함
      });
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .update({
      'likeCount': likeCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('게시물을 찾을 수 없습니다.'));
        }

        final post = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text(post['title']),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('작성자: ${post['uploader']}'),
                const SizedBox(height: 8),
                Text('태그: ${post['tags'].join(', ')}'),
                const SizedBox(height: 8),
                Text(post['description']),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: post['imageUrls'].length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        post['imageUrls'][index],
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width, // 화면 너비 맞춤
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('좋아요 $likeCount개'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
