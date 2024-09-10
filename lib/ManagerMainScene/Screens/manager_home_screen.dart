import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagerHomeScreen extends ConsumerStatefulWidget {
  const ManagerHomeScreen({super.key});
  @override
  ConsumerState<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends ConsumerState<ManagerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 상품 업로드 화면'),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return const Column(
            children: [
              SizedBox(
                width: 800,
                child: Text("제목 내용"),
              ),
              SizedBox(
                width: 800,
                height: 100,
                child: TextField(
                  maxLines: 1,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                      hintText: '제목 내용'),
                ),
              ),
              SizedBox(
                width: 800,
                child: Text("본문 내용"),
              ),
              SizedBox(
                width: 800,
                child: TextField(
                  maxLines: 10,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(),
                      hintText: '본문 내용'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
