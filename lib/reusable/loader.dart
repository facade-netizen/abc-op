import 'package:flutter/material.dart';

import 'colors.dart';

class LoaderWithScaffold extends StatelessWidget {
  const LoaderWithScaffold({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(child: LoaderContainerWithMessage(message: message)),
    );
  }
}

class LoaderContainerWithMessage extends StatelessWidget {
  final String? message;
  const LoaderContainerWithMessage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 120,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4), spreadRadius: 2),
          ],
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const OverlappingLoader(),
              Text(
                message ?? "Loading...",
                style: TextStyle(color: black, fontSize: 12, height: 1.25, fontWeight: FontWeight.w300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlappingLoader extends StatefulWidget {
  const OverlappingLoader({super.key});

  @override
  State<OverlappingLoader> createState() => _OverlappingLoaderState();
}

class _OverlappingLoaderState extends State<OverlappingLoader> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation1;
  late Animation<double> animation2;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    animation1 = Tween<double>(begin: 0, end: 25).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
    animation2 = Tween<double>(begin: 25, end: 0).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          AnimatedBuilder(
            animation: animation2,
            builder: (_, __) => Positioned(left: animation2.value, top: 5, child: _buildBall(const Color(0xFF3B3F4A))),
          ),
          AnimatedBuilder(
            animation: animation1,
            builder: (_, __) => Positioned(left: animation1.value, top: 5, child: _buildBall(const Color(0xFFF2B01D))),
          ),
        ],
      ),
    );
  }

  Widget _buildBall(Color color) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
