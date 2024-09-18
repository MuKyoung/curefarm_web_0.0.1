import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<String>> downloadBannerImages() async {
    try {
      // Firestore에서 homebanner 컬렉션의 childCount 필드를 가져옴
      DocumentSnapshot bannerDoc =
          await _firestore.collection('home').doc('banner').get();
      int childCount = bannerDoc['childCount'];

      // childCount만큼 Firebase Storage에서 이미지 URL을 가져옴
      List<String> imageUrls = [];
      for (int i = 0; i < childCount; i++) {
        String imageUrl = await _storage
            .refFromURL('gs://curefarm.appspot.com/banners/banner_$i.JPG')
            .getDownloadURL();
        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (e) {
      print('Error fetching banner images: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: downloadBannerImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading images'));
        } else if (snapshot.hasData) {
          final images = snapshot.data!;

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CarouselSlider.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index, realIdx) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand, // 부모의 크기에 맞게 자식 위젯을 확장
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[200],
                            ),
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          CachedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.transparent, // 배경을 투명하게 설정
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    clipBehavior: Clip.hardEdge,
                    height:
                        MediaQuery.of(context).size.width > 1080 ? 360 : 180,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    enableInfiniteScroll: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction:
                        MediaQuery.of(context).size.width > 1080 ? .4 : .8,
                    pageSnapping: true,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '새로운 기능 : 게시물 검색 및 조회 기능',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No images found'));
        }
      },
    );
  }
}
