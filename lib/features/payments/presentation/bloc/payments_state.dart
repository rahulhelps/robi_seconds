import 'package:equatable/equatable.dart';

class PaymentsState extends Equatable {
  final String selectedMethod;

  const PaymentsState({
    this.selectedMethod = 'robi',
  });

  PaymentsState copyWith({
    String? selectedMethod,
  }) {
    return PaymentsState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }

  @override
  List<Object> get props => [selectedMethod];
}
