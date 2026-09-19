import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quickcvpro/core/models/checkout_summary.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

abstract final class DashboardNavIndex {
  static const int home = 0;
  static const int profile = 1;
  static const int services = 2;
  static const int payments = 3;
  static const int mockTest = 4;
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardState()) {
    on<DashboardNavTabChanged>(_onNavTabChanged);
    on<DashboardNavigateToPayments>(_onNavigateToPayments);
  }

  void _onNavTabChanged(
    DashboardNavTabChanged event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(selectedNavIndex: event.index));
  }

  void _onNavigateToPayments(
    DashboardNavigateToPayments event,
    Emitter<DashboardState> emit,
  ) {
    emit(
      state.copyWith(
        selectedNavIndex: DashboardNavIndex.payments,
        activeCheckoutSummary: event.summary,
      ),
    );
  }
}
