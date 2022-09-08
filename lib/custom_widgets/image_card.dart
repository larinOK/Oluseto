import 'package:flutter/material.dart';
import 'package:meme_cloud/models/photo_item.dart';

class ImageCard extends StatelessWidget {
  final PhotoItem item;

  const ImageCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.network(item.image, fit: BoxFit.cover),
    );
  }
}
