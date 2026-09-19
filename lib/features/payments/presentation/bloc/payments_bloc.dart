import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:quickcvpro/core/constants.dart';
import 'package:quickcvpro/core/storage/token_manager.dart';
import 'package:quickcvpro/core/storage/user_storage.dart';
import 'payments_event.dart';
import 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  PaymentsBloc() : super(const PaymentsState()) {
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ConfirmPayment>(_onConfirmPayment);
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<PaymentsState> emit,
  ) {
    emit(state.copyWith(selectedMethod: event.method));
  }

  Future<void> _onConfirmPayment(
    ConfirmPayment event,
    Emitter<PaymentsState> emit,
  ) async {
    final method = state.selectedMethod;

    if (method != 'robi' && method != 'airtel_cirkle') {
      debugPrint('[PaymentsBloc] Unsupported payment method: $method');
      return;
    }

    try {
      final token = await TokenManager.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('[PaymentsBloc] No access token available');
        return;
      }

      final carrier = method == 'robi' ? 'robi' : 'airtel_cirkle';

      final plansResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/dcb/plans'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (plansResponse.statusCode != 200) {
        debugPrint('[PaymentsBloc] Failed to fetch plans: ${plansResponse.statusCode}');
        return;
      }

      final plansBody = jsonDecode(plansResponse.body) as Map<String, dynamic>;
      final plans = (plansBody['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final matchingPlan = plans.firstWhere(
        (plan) => plan['carrier_specific_code'] != null && plan['carrier_specific_code'].toString().startsWith(carrier.toUpperCase()),
        orElse: () => plans.first,
      );

      final planId = matchingPlan['id']?.toString();
      if (planId == null || planId.isEmpty) {
        debugPrint('[PaymentsBloc] No plan found for carrier: $carrier');
        return;
      }

      final initiateResponse = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/dcb/initiate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'carrier': carrier,
          'plan_id': planId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (initiateResponse.statusCode != 200) {
        debugPrint('[PaymentsBloc] Failed to initiate payment: ${initiateResponse.statusCode}');
        return;
      }

      final initiateBody = jsonDecode(initiateResponse.body) as Map<String, dynamic>;
      final redirectUrl = initiateBody['redirect_url']?.toString();

      if (redirectUrl == null || redirectUrl.isEmpty) {
        debugPrint('[PaymentsBloc] No redirect URL in response');
        return;
      }

      final callbackUrlScheme = 'quickcvpro';
      final result = await FlutterWebAuth2.authenticate(
        url: redirectUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      final uri = Uri.parse(result);
      final status = uri.queryParameters['status'];
      final returnedTxnId = uri.queryParameters['transaction_id'];

      if (status == 'success' && returnedTxnId != null) {
        await UserStorage.updateSubscriptionStatus(true);
        debugPrint('[PaymentsBloc] Payment success: $returnedTxnId');
      } else {
        debugPrint('[PaymentsBloc] Payment failed or cancelled');
      }
    } catch (e) {
      debugPrint('[PaymentsBloc] Payment flow error: $e');
    }
  }
}
