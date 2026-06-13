import 'package:equatable/equatable.dart';

abstract class PaymentsEvent extends Equatable {
  const PaymentsEvent();

  @override
  List<Object> get props => [];
}

class SelectPaymentMethod extends PaymentsEvent {
  final String method;

  const SelectPaymentMethod(this.method);

  @override
  List<Object> get props => [method];
}

class ConfirmPayment extends PaymentsEvent {
  const ConfirmPayment();
}
