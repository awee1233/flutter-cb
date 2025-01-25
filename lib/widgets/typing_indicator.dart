import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: -2, end: 2).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _animationControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animationControllers[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                transform: Matrix4.translationValues(
                  0,
                  _animations[index].value,
                  0,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
