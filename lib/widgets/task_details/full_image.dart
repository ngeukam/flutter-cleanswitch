import 'package:flutter/material.dart';
import 'dart:io';

class FullImageView extends StatelessWidget {
  final String imagePath;

  const FullImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');
    return Scaffold(
      appBar: AppBar(title: const Text('Image Preview')),
      body: Center(
        child: isNetwork
            ? Image.network(imagePath)
            : Image.file(File(imagePath)),
      ),
    );
  }
}
