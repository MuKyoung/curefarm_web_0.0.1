import 'dart:io';
import 'dart:html' as html;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curefarm_beta/users/models/user_profile_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<void> createProfile(UserProfileModel profile) async {
    await _db.collection("users").doc(profile.uid).set(profile.toJson());
  }

  Future<Map<String, dynamic>?> findProfile(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();
    return doc.data();
  }

  Future<void> uploadAvatar(XFile file, String fileName) async {
    final storageRef =
        FirebaseStorage.instance.ref().child("avatars/$fileName");
    try {
      if (kIsWeb) {
        final uploadTask = storageRef.putData(
          await file.readAsBytes(),
        );

        await uploadTask.whenComplete(() async {
          final downloadUrl = await storageRef.getDownloadURL();
          print('Uploaded to Firebase Storage: $downloadUrl');
        });
      } else {
        await storageRef.putFile(File(file.path));
      }
    } catch (error) {
      print(error);
    }

    print(kIsWeb);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection("users").doc(uid).update(data);
  }
}

final userRepo = Provider(
  (ref) => UserRepository(),
);
