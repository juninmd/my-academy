import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders an image that may be a bundled asset (seeded exercises use
/// `assets/images/...`) or a remote URL, with one fallback for both.
class AppImage extends StatelessWidget {
  const AppImage({
    required this.source,
    this.fit = BoxFit.cover,
    this.fallback = const Icon(Icons.fitness_center),
    this.color,
    this.colorBlendMode,
    super.key,
  });

  final String source;
  final BoxFit fit;
  final Widget fallback;
  final Color? color;
  final BlendMode? colorBlendMode;

  static bool isRemote(String source) =>
      source.startsWith('http://') || source.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return fallback;
    if (!isRemote(source)) {
      return Image.asset(
        source,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    return CachedNetworkImage(
      imageUrl: source,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
