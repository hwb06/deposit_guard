import 'package:deposit_guard/presentation/widgets/common/app_search_field.dart';
import 'package:deposit_guard/presentation/widgets/common/empty_view.dart';
import 'package:deposit_guard/presentation/widgets/common/error_view.dart';
import 'package:deposit_guard/presentation/widgets/common/filter_chips_row.dart';
import 'package:deposit_guard/presentation/widgets/common/loading_view.dart';
import 'package:deposit_guard/presentation/widgets/issue/issue_tile.dart';
import 'package:deposit_guard/presentation/widgets/rental/lease_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../bloc/issue/issue_bloc.dart';
import '../../../bloc/issue/issue_event.dart';
import '../../../bloc/issue/issue_filter.dart';
import '../../../bloc/issue/issue_state.dart';
import '../../../bloc/rental/rental_bloc.dart';
import '../../../bloc/rental/rental_event.dart';
import '../../../bloc/rental/rental_state.dart';
import '../../../bloc/rental_detail/rental_detail_cubit.dart';
import '../../../bloc/rental_detail/rental_detail_state.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_rooms.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/extensions/date_extension.dart';
import '../../../data/models/issue_model.dart';
import '../../../data/models/issue_severity.dart';
import '../../../data/models/rental_model.dart';
import '../../../injection_container.dart';
import '../../../services/report_service.dart';


/// Opens the issue form, then refreshes the issue list and the count.
Future<void> _openIssueForm(
    BuildContext context,
    String rentalId, {
      IssueModel? issue,
    }) async {
  final path = issue == null
      ? AppRoutes.issueNewPath(rentalId)
      : AppRoutes.issueEditPath(rentalId, issue.id);

  await context.push(path, extra: issue);
  if (!context.mounted) return;

  context.read<IssueBloc>().add(const IssuesRefreshed());
  context.read<RentalDetailCubit>().load(rentalId);
}

class RentalDetailScreen extends StatelessWidget {
  const RentalDetailScreen({super.key, required this.rentalId});

  final String rentalId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<RentalDetailCubit>()..load(rentalId),
        ),
        BlocProvider(
          create: (_) => sl<IssueBloc>()..add(IssuesLoaded(rentalId)),
        ),
      ],
      child: _RentalDetailView(rentalId: rentalId),
    );
  }
}

class _RentalDetailView extends StatelessWidget {
  const _RentalDetailView({required this.rentalId});

  final String rentalId;

  @override
  Widget build(BuildContext context) {
    // Reload whenever the shared rentals list changes (e.g. after an edit).
    return BlocListener<RentalBloc, RentalState>(
      listenWhen: (_, current) => current.status == RentalStatus.success,
      listener: (context, _) =>
          context.read<RentalDetailCubit>().load(rentalId),
      child: Scaffold(
        appBar: AppBar(actions: const [_DetailActions()]),
        body: _DetailBody(rentalId: rentalId),
        floatingActionButton: _AddIssueButton(rentalId: rentalId),
      ),
    );
  }
}

class _AddIssueButton extends StatelessWidget {
  const _AddIssueButton({required this.rentalId});

  final String rentalId;

  @override
  Widget build(BuildContext context) {
    final hasRental = context.select<RentalDetailCubit, bool>(
          (cubit) => cubit.state.rental != null,
    );
    if (!hasRental) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: () => _openIssueForm(context, rentalId),
      icon: const Icon(Icons.add),
      label: const Text(AppStrings.addIssue),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions();

  @override
  Widget build(BuildContext context) {
    final rental = context.select<RentalDetailCubit, RentalModel?>(
          (cubit) => cubit.state.rental,
    );
    if (rental == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: AppStrings.exportReport,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          onPressed: () => _exportPdf(context, rental),
        ),
        IconButton(
          tooltip: 'Edit',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () =>
              context.push(AppRoutes.editPath(rental.id), extra: rental),
        ),
        IconButton(
          tooltip: AppStrings.delete,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, rental),
        ),
      ],
    );
  }

  Future<void> _exportPdf(BuildContext context, RentalModel rental) async {
    context.showSnack(AppStrings.preparingReport);
    try {
      await sl<ReportService>().shareRentalReport(rental);
    } catch (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
      if (!context.mounted) return;
      context.showSnack(AppStrings.reportFailed, isError: true);
    }
  }

  Future<void> _confirmDelete(BuildContext context, RentalModel rental) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteRentalTitle),
        content: const Text(AppStrings.deleteRentalMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: dialogContext.colors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    context.read<RentalBloc>().add(RentalDeleted(rental.id));
    context.pop();
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.rentalId});

  final String rentalId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalDetailCubit, RentalDetailState>(
      builder: (context, state) {
        final rental = state.rental;
        return switch (state.status) {
          RentalDetailStatus.loading => const LoadingView(),
          RentalDetailStatus.failure => ErrorView(
            message: AppStrings.somethingWentWrong,
            onRetry: () => context.read<RentalDetailCubit>().load(rentalId),
          ),
          RentalDetailStatus.notFound => const EmptyView(
            icon: Icons.search_off,
            title: AppStrings.rentalNotFoundTitle,
            message: AppStrings.rentalNotFoundMessage,
          ),
          RentalDetailStatus.success when rental != null => _DetailContent(
            rental: rental,
            issueCount: state.issueCount,
          ),
          RentalDetailStatus.success => const LoadingView(),
        };
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.rental, required this.issueCount});

  final RentalModel rental;
  final int issueCount;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppDimensions.md),
          sliver: SliverToBoxAdapter(child: _RentalSummary(rental: rental)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              0,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: Text(
              '${AppStrings.issuesTitle} ($issueCount)',
              style: context.text.titleMedium,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _IssueControls(issueCount: issueCount)),
        _IssueList(rentalId: rental.id),
        // Space so the floating button never covers the last item.
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}

class _RentalSummary extends StatelessWidget {
  const _RentalSummary({required this.rental});

  final RentalModel rental;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rental.name, style: context.text.titleLarge),
          const SizedBox(height: AppDimensions.xs),
          Text(
            rental.address,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          _InfoRow(
            label: AppStrings.leaseStartLabel,
            value: rental.leaseStart.formatted,
          ),
          const SizedBox(height: AppDimensions.sm),
          _InfoRow(
            label: AppStrings.leaseEndLabel,
            value: rental.leaseEnd.formatted,
          ),
          const SizedBox(height: AppDimensions.md),
          LeaseChip(daysLeft: rental.leaseEnd.daysFromNow),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(value, style: context.text.bodyMedium),
      ],
    );
  }
}

class _IssueControls extends StatelessWidget {
  const _IssueControls({required this.issueCount});

  final int issueCount;

  @override
  Widget build(BuildContext context) {
    final filter = context.select<IssueBloc, IssueFilter>(
          (bloc) => bloc.state.filter,
    );
    if (issueCount == 0 && !filter.isActive) return const SizedBox.shrink();

    final bloc = context.read<IssueBloc>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: AppSearchField(
            hint: AppStrings.searchIssues,
            onChanged: (query) => bloc.add(IssueSearched(query)),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        FilterChipsRow<String>(
          items: AppRooms.all,
          selected: filter.room,
          labelOf: (room) => room,
          onSelected: (room) => bloc.add(IssueRoomSelected(room)),
        ),
        const SizedBox(height: AppDimensions.sm),
        FilterChipsRow<IssueSeverity>(
          items: IssueSeverity.values,
          selected: filter.severity,
          labelOf: (severity) => severity.label,
          onSelected: (severity) => bloc.add(IssueSeveritySelected(severity)),
        ),
        const SizedBox(height: AppDimensions.md),
      ],
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({required this.rentalId});

  final String rentalId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IssueBloc, IssueState>(
      builder: (context, state) {
        return switch (state.status) {
          IssueStatus.loading => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.xl),
              child: LoadingView(),
            ),
          ),
          IssueStatus.failure => SliverToBoxAdapter(
            child: ErrorView(
              message: state.errorMessage ?? AppStrings.somethingWentWrong,
              onRetry: () =>
                  context.read<IssueBloc>().add(const IssuesRefreshed()),
            ),
          ),
          IssueStatus.success when state.issues.isEmpty => SliverToBoxAdapter(
            child: state.filter.isActive
                ? const EmptyView(
              icon: Icons.search_off,
              title: AppStrings.noIssueMatchesTitle,
              message: AppStrings.noIssueMatchesMessage,
            )
                : EmptyView(
              icon: Icons.photo_camera_outlined,
              title: AppStrings.noIssuesTitle,
              message: AppStrings.noIssuesMessage,
              actionLabel: AppStrings.addIssue,
              onAction: () => _openIssueForm(context, rentalId),
            ),
          ),
          IssueStatus.success => SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
            ),
            sliver: SliverList.separated(
              itemCount: state.issues.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimensions.sm),
              itemBuilder: (_, index) {
                final issue = state.issues[index];
                return IssueTile(
                  issue: issue,
                  onTap: () =>
                      _openIssueForm(context, rentalId, issue: issue),
                );
              },
            ),
          ),
        };
      },
    );
  }
}