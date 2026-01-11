import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({required this.imageUrl, super.key});
  final String imageUrl;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.pop(context);
    },
    child: Container(
      color: Colors.black,
      child: Image.network(imageUrl, fit: BoxFit.contain),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('imageUrl', imageUrl));
  }
}
