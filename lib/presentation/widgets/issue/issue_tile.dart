import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/extensions/date_extension.dart';
import '../../../data/models/issue_model.dart';
import 'photo_thumb.dart';
import 'severity_chip.dart';

class IssueTile extends StatelessWidget {
  const IssueTile({super.key, required this.issue, this.onTap});

  final IssueModel issue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusMd);

    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.colors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sm + AppDimensions.xs),
          child: Row(
            children: [
              PhotoThumb(fileName: issue.photoPath, size: 72),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: context.text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      '${issue.room}  |  ${issue.createdAt.formatted}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      children: [
                        SeverityChip(severity: issue.severity),
                        const SizedBox(width: AppDimensions.sm),
                        Flexible(
                          child: Text(
                            issue.stage.label,
                            style: context.text.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}