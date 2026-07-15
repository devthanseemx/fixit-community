// lib/widgets/home_header.dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'search_bar.dart';

class HomeHeader extends StatelessWidget {
  final Function(String)? onSearchChanged;

  const HomeHeader({super.key, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
          stops: [0.4, 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: ClipPath(
        clipper: _HeaderWaveClipper(),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 15,
            bottom: 110, // Adjust this for search bar breathing room
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "FixIt Community",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "Crowd sourced IT issues and Solutions",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 45), // Moves Search Bar down
              CustomSearchBar(onChanged: onSearchChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 4, size.height, size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(size.width - (size.width / 3.25), size.height - 65, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}