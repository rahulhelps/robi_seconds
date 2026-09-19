import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickcvpro/core/models/checkout_summary.dart';

part 'packages_event.dart';
part 'packages_state.dart';

class PackagesBloc extends Bloc<PackagesEvent, PackagesState> {
  PackagesBloc() : super(const PackagesInitial()) {
    on<FetchPackages>(_onFetchPackages);
    on<SelectPackage>(_onSelectPackage);
    on<ForeignPackageCheckoutRequested>(_onForeignPackageCheckoutRequested);
    on<PackagesCheckoutNavigationConsumed>(_onCheckoutNavigationConsumed);
    on<PackagesCheckoutAborted>(_onCheckoutAborted);
    on<PackagesCheckoutStarted>(_onPackagesCheckoutStarted);
  }


  Future<void> _onFetchPackages(
    FetchPackages event,
    Emitter<PackagesState> emit,
  ) async {
    emit(const PackagesLoading());
    try {
      // Placeholder for future API / cache load
      await Future<void>.delayed(const Duration(milliseconds: 50));
      emit(const PackagesLoaded());
    } catch (e) {
      emit(
        PackagesError(
          'We could not load packages. Check your connection and try again.',
        ),
      );
    }
  }

  void _onSelectPackage(
    SelectPackage event,
    Emitter<PackagesState> emit,
  ) {
    final id = event.packageId.trim();
    if (id.isEmpty) {
      emit(const PackagesError('That package is not available.'));
      return;
    }
    final known = {PackageIds.foreignGlobal, PackageIds.premiumMonthly};
    if (!known.contains(id)) {
      emit(PackagesError('Unknown package: $id'));
      return;
    }
    emit(PackagesLoaded(selectedPackageId: id));

  }

  void _onForeignPackageCheckoutRequested(
    ForeignPackageCheckoutRequested event,
    Emitter<PackagesState> emit,
  ) {
    if (state is PackagesLoading || state is PackagesInitial) {
      emit(
        const PackagesError(
          'Packages are still loading. Please wait a moment and try again.',
        ),
      );
      return;
    }
    if (state is PackagesError) {
      emit(const PackagesLoaded());
    }
    emit(
      const PackagesNavigateToPayments(CheckoutSummary.foreignGlobal),
    );
  }

  void _onCheckoutNavigationConsumed(
    PackagesCheckoutNavigationConsumed event,
    Emitter<PackagesState> emit,
  ) {
    if (state is! PackagesNavigateToPayments) return;
    final summary = (state as PackagesNavigateToPayments).summary;
    emit(PackagesLoaded(selectedPackageId: summary.packageId));
  }


  void _onCheckoutAborted(
    PackagesCheckoutAborted event,
    Emitter<PackagesState> emit,
  ) {
    if (state is PackagesNavigateToPayments) {
      emit(const PackagesLoaded());
    }
  }

  void _onPackagesCheckoutStarted(
    PackagesCheckoutStarted event,
    Emitter<PackagesState> emit,
  ) {
    emit(const PackagesNavigateToPayments(CheckoutSummary.premiumMonthly));
  }
}

