part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  final int selectedNavIndex;
  final CheckoutSummary? activeCheckoutSummary;

  const DashboardState({
    this.selectedNavIndex = 0,
    this.activeCheckoutSummary,
  });

  DashboardState copyWith({
    int? selectedNavIndex,
    CheckoutSummary? activeCheckoutSummary,
  }) {
    return DashboardState(
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      activeCheckoutSummary: activeCheckoutSummary ?? this.activeCheckoutSummary,
    );
  }

  @override
  List<Object?> get props => [selectedNavIndex, activeCheckoutSummary];
}
