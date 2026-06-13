part of 'dashboard_bloc.dart';

abstract class DashboardEvent {
  const DashboardEvent();
}

class DashboardNavTabChanged extends DashboardEvent {
  final int index;
  const DashboardNavTabChanged(this.index);
}

/// Opens the Payments tab and stores [summary] for [OrderSummaryCard].
class DashboardNavigateToPayments extends DashboardEvent {
  final CheckoutSummary summary;
  const DashboardNavigateToPayments(this.summary);
}
