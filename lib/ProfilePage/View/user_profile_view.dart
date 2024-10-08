import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/Extensions/Gaps.dart';
import 'package:curefarm_beta/Extensions/Sizes.dart';
import 'package:curefarm_beta/users/models/user_profile_model.dart';
import 'package:curefarm_beta/users/view_models/users_view_model.dart';
import 'package:curefarm_beta/widgets/avatar.dart';
import 'package:curefarm_beta/widgets/persistent_tab_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});
  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<List<DocumentSnapshot>> getLikedPosts() async {
    // 좋아요 누른 게시물 ID 가져오기
    QuerySnapshot likedPostsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('likes')
        .get();

    // 각 게시물의 데이터를 가져오기
    List<DocumentSnapshot> likedPosts = [];
    for (var doc in likedPostsSnapshot.docs) {
      var post = await FirebaseFirestore.instance
          .collection('posts')
          .doc(doc.id)
          .get();
      likedPosts.add(post);
    }

    return likedPosts;
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(usersProvider).when(
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          data: (data) => SafeArea(
            child: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // SliverAppBar(
                  //   //title: Text(data.name),
                  //   actions: [
                  //     IconButton(
                  //       onPressed: () => {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => const SettingsScreen(),
                  //           ),
                  //         ),
                  //       },
                  //       icon: const FaIcon(
                  //         FontAwesomeIcons.gear,
                  //         size: Sizes.size20,
                  //       ),
                  //     )
                  //   ],
                  // ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Avatar(
                          uid: data.uid,
                          name: data.name,
                          hasAvatar: data.hasAvatar,
                        ),
                        Gaps.v20,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "@${data.name}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Sizes.size16 + Sizes.size2,
                              ),
                            ),
                            Gaps.h5,
                            FaIcon(
                              FontAwesomeIcons.solidCircleCheck,
                              size: Sizes.size16,
                              color: Colors.blue.shade500,
                            )
                          ],
                        ),
                        Gaps.v24,
                        SizedBox(
                          height: Sizes.size48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    "97",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Sizes.size16 + Sizes.size2,
                                    ),
                                  ),
                                  Gaps.v1,
                                  Text("Following",
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ))
                                ],
                              ),
                              VerticalDivider(
                                width: Sizes.size32,
                                thickness: Sizes.size1,
                                color: Colors.grey.shade400,
                                indent: Sizes.size14,
                                endIndent: Sizes.size14,
                              ),
                              Column(
                                children: [
                                  const Text(
                                    "10M",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Sizes.size18,
                                    ),
                                  ),
                                  Gaps.v1,
                                  Text(
                                    "Followers",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  )
                                ],
                              ),
                              VerticalDivider(
                                width: Sizes.size32,
                                thickness: Sizes.size1,
                                color: Colors.grey.shade400,
                                indent: Sizes.size14,
                                endIndent: Sizes.size14,
                              ),
                              Column(
                                children: [
                                  const Text(
                                    "194.3M",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: Sizes.size18,
                                    ),
                                  ),
                                  Gaps.v1,
                                  Text(
                                    "Likes",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Gaps.v14,
                        FractionallySizedBox(
                          widthFactor: 0.33,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.size12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(Sizes.size4),
                              ),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Gaps.v14,
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Sizes.size32,
                          ),
                          child: Text(
                            "All highlights and where to watch live matches on FIFA+ I wonder how it would loook",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Gaps.v14,
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.link,
                              size: Sizes.size12,
                            ),
                            Gaps.h4,
                            Text(
                              "https://nomadcoders.co",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Gaps.v20,
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: PersistentTabBar(),
                    pinned: true,
                  ),
                ];
              }, body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double screenWidth = constraints.maxWidth;

                  EdgeInsets padding = screenWidth >= 1080
                      ? const EdgeInsets.symmetric(horizontal: 200.0)
                      : EdgeInsets.zero;

                  return Padding(
                    padding: padding,
                    child: TabBarView(
                      children: [
                        // GridView.builder(
                        //   itemCount: 20,
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: Sizes.size10),
                        //   gridDelegate:
                        //       const SliverGridDelegateWithFixedCrossAxisCount(
                        //     crossAxisCount: 3,
                        //     crossAxisSpacing: Sizes.size4,
                        //     mainAxisSpacing: Sizes.size4,
                        //     childAspectRatio: 9 / 14,
                        //   ),
                        //   itemBuilder: (context, index) => Column(
                        //     children: [
                        //       AspectRatio(
                        //         aspectRatio: 9 / 14,
                        //         child: FadeInImage.assetNetwork(
                        //           fit: BoxFit.cover,
                        //           placeholder: "assets/images/placeholder.jpg",
                        //           image: "",
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        FutureBuilder<List<DocumentSnapshot>>(
                          future: getLikedPosts(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            List<DocumentSnapshot> posts = snapshot.data!;

                            return ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                var postData =
                                    posts[index].data() as Map<String, dynamic>;
                                return ListTile(
                                  title: Text(postData['title']),
                                  subtitle: Text(postData['description']),
                                );
                              },
                            );
                          },
                        ),
                        FutureBuilder<List<DocumentSnapshot>>(
                          future: getLikedPosts(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            List<DocumentSnapshot> posts = snapshot.data!;

                            return ListView.builder(
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                var postData =
                                    posts[index].data() as Map<String, dynamic>;
                                return ListTile(
                                  title: Text(postData['title']),
                                  subtitle: Text(postData['description']),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              )),
            ),
          ),
        );
  }
}
