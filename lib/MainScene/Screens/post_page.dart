import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/MainScene/Model/post_model.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // Firestore에서 postId에 해당하는 게시물 정보를 가져옴
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('posts').doc(postId).get(),
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
                // 이미지 리스트 출력
                Expanded(
                  child: ListView.builder(
                    itemCount: post['imageUrls'].length,
                    itemBuilder: (context, index) {
                      return Image.network(post['imageUrls'][index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
