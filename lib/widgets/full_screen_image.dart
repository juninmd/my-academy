import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.black,
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
