import 'package:deposit_guard/services/image/image_service.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../injection_container.dart';


class PhotoThumb extends StatelessWidget {
  const PhotoThumb({super.key, required this.fileName, this.size = 64});

  final String? fileName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final name = fileName;
    final placeholder = Container(
      width: size,
      height: size,
      color: context.colors.outline.withValues(alpha: 0.15),
      child: Icon(
        Icons.photo_outlined,
        color: context.colors.onSurfaceVariant,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: name == null
          ? placeholder
          : Image.file(
        sl<ImageService>().fileFor(name),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
            .round(),
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}