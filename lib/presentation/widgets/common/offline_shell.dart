import 'package:deposit_guard/bloc/backup/connectivity/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class OfflineShell extends StatelessWidget {
  const OfflineShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offline = context.select<ConnectivityCubit, bool>(
      (cubit) => !cubit.state.isOnline,
    );

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: offline
              ? const _OfflineBanner()
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: offline,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    const foreground = Colors.black87;

    return Semantics(
      liveRegion: true,
      child: Material(
        color: AppColors.warning,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 18,
                  color: foreground,
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    AppStrings.noInternet,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
