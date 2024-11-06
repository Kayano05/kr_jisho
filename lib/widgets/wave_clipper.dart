import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    
    // 添加曲线
    path.quadraticBezierTo(
      size.width * 0.5,  // 控制点 x
      size.height * 0.3, // 控制点 y
      size.width,        // 终点 x
      size.height        // 终点 y
    );
    
    // 完成路径
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 