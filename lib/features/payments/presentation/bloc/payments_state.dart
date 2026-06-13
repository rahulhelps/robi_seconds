import 'package:equatable/equatable.dart';

class PaymentsState extends Equatable {
  final String selectedMethod;

  const PaymentsState({
    this.selectedMethod = 'bkash', // default mapped from HTML checked="checked"
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
