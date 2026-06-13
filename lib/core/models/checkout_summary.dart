import 'package:equatable/equatable.dart';

/// Line items for the payments / order summary UI, driven by dashboard checkout state.
class CheckoutSummary extends Equatable {
  final String packageId;
  final String orderTitle;
  final String orderSubtitle;
  final String linePrice;
  final String subtotal;
  final String vatLineLabel;
  final String vatLineValue;
  final String total;

  const CheckoutSummary({
    required this.packageId,
    required this.orderTitle,
    required this.orderSubtitle,
    required this.linePrice,
    required this.subtotal,
    required this.vatLineLabel,
    required this.vatLineValue,
    required this.total,
  });

  /// Default order shown when user opens Payments without a service checkout.
  static const CheckoutSummary quickCvProAnnual = CheckoutSummary(
    packageId: 'quickcv_pro_annual',
    orderTitle: 'QuickCV Pro Annual',
    orderSubtitle: 'Full access to all templates',
    linePrice: '৳1,100.00',
    subtotal: '৳1,100.00',
    vatLineLabel: 'VAT (5%)',
    vatLineValue: '৳55.00',
    total: '৳1,155.00',
  );

  /// Foreign / global mobility package (matches Services screen card).
  static const CheckoutSummary foreignGlobal = CheckoutSummary(
    packageId: 'foreign_global',
    orderTitle: 'Foreign Package',
    orderSubtitle:
        'Global mobility suite — ATS CV, SOP, LinkedIn & academic CV',
    linePrice: '\$299',
    subtotal: '\$299.00',
    vatLineLabel: 'VAT (5%)',
    vatLineValue: '\$14.95',
    total: '\$313.95',
  );

  /// Premium Monthly package ($10).
  static const CheckoutSummary premiumMonthly = CheckoutSummary(
    packageId: 'premium_monthly',
    orderTitle: 'Premium Plan',
    orderSubtitle: 'Unlimited CVs & Templates',
    linePrice: '৳ 1100',
    subtotal: '৳ 1100.00',
    vatLineLabel: 'VAT (0%)',
    vatLineValue: '৳ 0.00',
    total: '৳ 1100.00',
  );

  @override
  List<Object?> get props => [
        packageId,
        orderTitle,
        orderSubtitle,
        linePrice,
        subtotal,
        vatLineLabel,
        vatLineValue,
        total,
      ];
}

abstract final class PackageIds {
  static const foreignGlobal = 'foreign_global';
  static const premiumMonthly = 'premium_monthly';
}

