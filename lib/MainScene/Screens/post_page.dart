import 'dart:async';

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
                      return FutureBuilder<Image>(
                        future: _loadNetworkImage(post['imageUrls'][index]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Text('이미지를 로드할 수 없습니다.');
                          }
                          final image = snapshot.data!;
                          return image;
                        },
                      );
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

  Future<Image> _loadNetworkImage(String imageUrl) async {
    final image = NetworkImage(imageUrl);
    final completer = Completer<Size>();
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final myImage = info.image;
        final size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      }),
    );
    final size = await completer.future;

    // 고정된 가로 크기를 300으로 설정하고 비율 유지
    const fixedWidth = 600.0;
    final aspectRatio = size.width / size.height;
    final height = fixedWidth / aspectRatio;

    return Image.network(
      imageUrl,
      width: fixedWidth,
      height: height,
      fit: BoxFit.contain, // 이미지 비율을 유지하면서 크기에 맞춤
    );
  }
}
