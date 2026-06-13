part of 'packages_bloc.dart';

abstract class PackagesState {
  const PackagesState();
}

class PackagesInitial extends PackagesState {
  const PackagesInitial();
}

class PackagesLoading extends PackagesState {
  const PackagesLoading();
}

class PackagesLoaded extends PackagesState {
  final String? selectedPackageId;
  const PackagesLoaded({this.selectedPackageId});
}

/// Emitted after validation; UI listens and forwards to [DashboardBloc].
class PackagesNavigateToPayments extends PackagesState {
  final CheckoutSummary summary;
  const PackagesNavigateToPayments(this.summary);
}

class PackagesError extends PackagesState {
  final String message;
  const PackagesError(this.message);
}
