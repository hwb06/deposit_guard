import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../data/models/issue_severity.dart';

class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity});

  final IssueSeverity severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      IssueSeverity.minor => AppColors.success,
      IssueSeverity.moderate => AppColors.warning,
      IssueSeverity.severe => AppColors.danger,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        severity.label,
        style: context.text.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}