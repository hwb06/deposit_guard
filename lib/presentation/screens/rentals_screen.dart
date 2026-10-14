import 'package:deposit_guard/presentation/widgets/common/app_search_field.dart';
import 'package:deposit_guard/presentation/widgets/common/empty_view.dart';
import 'package:deposit_guard/presentation/widgets/common/error_view.dart';
import 'package:deposit_guard/presentation/widgets/common/loading_view.dart';
import 'package:deposit_guard/presentation/widgets/rental/rental_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/rental/rental_bloc.dart';
import '../../../bloc/rental/rental_event.dart';
import '../../../bloc/rental/rental_state.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';


class RentalsScreen extends StatelessWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.rentalsTitle),
        actions: [
          IconButton(
            tooltip: AppStrings.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.sm,
              AppDimensions.md,
              AppDimensions.md,
            ),
            child: AppSearchField(
              hint: AppStrings.searchRentals,
              onChanged: (query) =>
                  context.read<RentalBloc>().add(RentalsSearched(query)),
            ),
          ),
          const Expanded(child: _RentalsBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.rentalNew),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addRental),
      ),
    );
  }
}

class _RentalsBody extends StatelessWidget {
  const _RentalsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalBloc, RentalState>(
      builder: (context, state) {
        return switch (state.status) {
          RentalStatus.loading => const LoadingView(),
          RentalStatus.failure => ErrorView(
            message: state.errorMessage ?? AppStrings.somethingWentWrong,
            onRetry: () =>
                context.read<RentalBloc>().add(const RentalsLoaded()),
          ),
          RentalStatus.success when state.rentals.isEmpty => EmptyView(
            icon: state.isSearching
                ? Icons.search_off
                : Icons.home_work_outlined,
            title: state.isSearching
                ? AppStrings.noResultsTitle
                : AppStrings.noRentalsTitle,
            message: state.isSearching
                ? AppStrings.noResultsMessage
                : AppStrings.noRentalsMessage,
            actionLabel: state.isSearching ? null : AppStrings.addRental,
            onAction: state.isSearching
                ? null
                : () => context.push(AppRoutes.rentalNew),
          ),
          RentalStatus.success => ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              0,
              AppDimensions.md,
              96,
            ),
            itemCount: state.rentals.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.sm),
            itemBuilder: (_, index) {
              final rental = state.rentals[index];
              return RentalCard(
                rental: rental,
                onTap: () =>
                    context.push(AppRoutes.detailPath(rental.id)),
              );
            },
          ),
        };
      },
    );
  }
}