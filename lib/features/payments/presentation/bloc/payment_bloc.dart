import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentInitial()) {
    on<LoadPaymentData>((event, emit) {
      const priceText = "৳ 1100 / month";
      emit(PaymentLoaded(priceText));
    });
  }
}
