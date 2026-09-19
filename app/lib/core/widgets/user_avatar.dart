import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Photo avatar that falls back to the name initial when the image is
/// missing or fails to load (e.g. hotlink/CORS blocked on web).
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    required this.name,
    this.photoUrl,
    this.radius = 28,
    super.key,
  });

  final String? name;
  final String? photoUrl;
  final double radius;

  String get initial {
    final trimmed = name?.trim() ?? '';
    return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = photoUrl;
    final hasPhoto = url != null && url.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      foregroundImage: hasPhoto ? CachedNetworkImageProvider(url) : null,
      onForegroundImageError: hasPhoto ? (_, _) {} : null,
      child: Text(
        initial,
        semanticsLabel: name,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}
