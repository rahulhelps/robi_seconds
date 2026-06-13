part of 'payment_bloc.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final String priceText;

  PaymentLoaded(this.priceText);
}
