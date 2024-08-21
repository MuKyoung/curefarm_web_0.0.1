import 'package:curefarm_beta/Extensions/Gaps.dart';
import 'package:curefarm_beta/Extensions/Sizes.dart';
import 'package:curefarm_beta/MainScene/Screens/main_navigation_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Direction { right, left }

enum Page { first, second }
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});
  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}
class _TutorialScreenState extends State<TutorialScreen> {
  Direction _direction = Direction.right;
  Page _showingPage = Page.first;
  void _onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0) {
      setState(() {
        _direction = Direction.right;
      });
    } else {
      setState(() {
        _direction = Direction.left;
      });
    }
  }
  void _onPanEnd(DragEndDetails detail) {
    if (_direction == Direction.left) {
      setState(() {
        _showingPage = Page.second;
      });
    } else {
      setState(() {
        _showingPage = Page.first;
      });
    }
  }

  void _onEnterAppTap() {
    context.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.size24),
          child: SafeArea(
            child: AnimatedCrossFade(
              firstChild: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gaps.v80,
                    Text(
                      "1. 쉽고 간편한 치유농업 경험",
                      style: TextStyle(
                        fontSize: Sizes.size40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v16,
                    Text(
                      "원클릭 예약시스템",
                      style: TextStyle(
                        fontSize: Sizes.size20,
                      ),
                    ),
                    Gaps.v16,
                    Text(
                      "전국 단위의 통합적인 치유농업 네트워크",
                      style: TextStyle(
                        fontSize: Sizes.size20,
                      ),
                    )
                  ]),
              secondChild: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gaps.v80,
                    Text(
                      "2. 치유효과를 극대화할 수 있는 부가 서비스",
                      style: TextStyle(
                        fontSize: Sizes.size40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v16,
                    Text(
                      "개인맞춤형 멘탈 건강 관리, 비대면 치유·심리 상담 서비스",
                      style: TextStyle(
                        fontSize: Sizes.size20,
                      ),
                    )
                  ]),
              crossFadeState: _showingPage == Page.first
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showingPage == Page.first ? 0 : 1,
            child: CupertinoButton(
              onPressed: _onEnterAppTap,
              color: Theme.of(context).primaryColor,
              child: const Text('들어가기'),
            ),
          ),
        ),
      ),
    );
  }
}