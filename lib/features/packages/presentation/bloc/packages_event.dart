part of 'packages_bloc.dart';

abstract class PackagesEvent {
  const PackagesEvent();
}

class FetchPackages extends PackagesEvent {
  const FetchPackages();
}

class SelectPackage extends PackagesEvent {
  final String packageId;
  const SelectPackage(this.packageId);
}

/// User chose Foreign Package checkout from [ForeignPackageCard].
class ForeignPackageCheckoutRequested extends PackagesEvent {
  const ForeignPackageCheckoutRequested();
}

/// Clears one-shot navigation state after [DashboardBloc] handled tab switch.
class PackagesCheckoutNavigationConsumed extends PackagesEvent {
  const PackagesCheckoutNavigationConsumed();
}

/// Checkout UI could not open (e.g. [DashboardBloc] not in scope).
class PackagesCheckoutAborted extends PackagesEvent {
  const PackagesCheckoutAborted();
}
/// User chose specific package checkout.
class PackagesCheckoutStarted extends PackagesEvent {
  final String planName;
  final double price;

  const PackagesCheckoutStarted({
    required this.planName,
    required this.price,
  });
}
