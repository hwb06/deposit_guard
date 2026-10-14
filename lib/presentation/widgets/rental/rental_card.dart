import 'package:flutter/material.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/extensions/date_extension.dart';
import '../../../data/models/rental_model.dart';
import 'lease_chip.dart';

class RentalCard extends StatelessWidget {
  const RentalCard({super.key, required this.rental, this.onTap});

  final RentalModel rental;
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
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rental.name,
                style: context.text.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                rental.address,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Lease ends ${rental.leaseEnd.formatted}',
                      style: context.text.bodySmall,
                    ),
                  ),
                  LeaseChip(daysLeft: rental.leaseEnd.daysFromNow),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}