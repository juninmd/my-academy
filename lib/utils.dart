import 'dart:math';

String getRandomImagePath(List<String> imagePaths) {
    if (imagePaths.isEmpty) {
        throw Exception('Image paths list is empty');
    }

    var randomIndex = Random().nextInt(imagePaths.length);
    return imagePaths[randomIndex];
}