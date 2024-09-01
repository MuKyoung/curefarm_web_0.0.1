import 'package:curefarm_beta/ProfilePage/ViewModels/avatar_view_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class Avatar extends ConsumerWidget {
  final String name;
  final bool hasAvatar;
  final String uid;

  const Avatar({
    super.key,
    required this.uid,
    required this.hasAvatar,
    required this.name,
  });

  Future<void> _onAvatarTap(WidgetRef ref) async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxHeight: 400,
      maxWidth: 400,
    );
    if (xfile != null) {
      //final file = File(xfile.path);
      ref.read(avatarProvider.notifier).uploadAvatar(xfile);
    }
  }

  Future<String> downloadAvatarImageUrl() {
    return FirebaseStorage.instance
        .refFromURL('gs://curefarm.appspot.com/')
        .child('avatars/')
        .child(uid)
        .getDownloadURL();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(avatarProvider).isLoading;

    return StreamBuilder<String>(
        stream: downloadAvatarImageUrl().asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return GestureDetector(
            onTap: isLoading ? null : () => _onAvatarTap(ref),
            child: isLoading
                ? Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(),
                  )
                : CircleAvatar(
                    radius: 50,
                    foregroundImage: hasAvatar
                        ? NetworkImage(snapshot.data.toString())
                        : null,
                    child: hasAvatar ? null : Text(name),
                  ),
          );
        });
  }
}
