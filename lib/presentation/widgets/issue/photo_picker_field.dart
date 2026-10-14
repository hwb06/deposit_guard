import 'package:deposit_guard/services/image/image_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../injection_container.dart';

class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.fileName,
    required this.onPick,
    required this.onRemove,
  });

  final String? fileName;
  final ValueChanged<ImageSource> onPick;
  final VoidCallback onRemove;

  static const double _height = 200;

  Future<void> _chooseSource(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text(AppStrings.takePhoto),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(AppStrings.chooseGallery),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) onPick(source);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusMd);
    final name = fileName;

    return Material(
      color: context.colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.colors.outline),
      ),
      child: InkWell(
        onTap: () => _chooseSource(context),
        child: SizedBox(
          height: _height,
          width: double.infinity,
          child: name == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 40,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(AppStrings.addPhoto, style: context.text.bodyMedium),
            ],
          )
              : Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                sl<ImageService>().fileFor(name),
                fit: BoxFit.cover,
                cacheWidth: 1200,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 40),
                ),
              ),
              Positioned(
                top: AppDimensions.sm,
                right: AppDimensions.sm,
                child: IconButton.filledTonal(
                  tooltip: AppStrings.removePhoto,
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}