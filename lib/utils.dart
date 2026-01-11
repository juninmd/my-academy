import 'dart:math';

String getRandomImagePath(List<String> imagePaths) {
  if (imagePaths.isEmpty) {
    throw Exception('Image paths list is empty');
  }

  final randomIndex = Random().nextInt(imagePaths.length);
  return imagePaths[randomIndex];
}
