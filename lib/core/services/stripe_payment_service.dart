import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Centralized Stripe Payment Sheet handler for all modules.
class StripePaymentService {
  StripePaymentService._();
  static final StripePaymentService instance = StripePaymentService._();

  static const String _publishableKey =
      'pk_test_51TEU3bRUR61owESQttkPiKVVjJHAHEF6h9JEmYM5wvJ1byUJCFu4P6hW8JziKnhfLVuxvz5RRz1igszZmZlEIOQC00sC75NC5J';

  bool _initialized = false;

  /// Call once at app startup (e.g. in main.dart)
  void init() {
    if (_initialized) return;
    Stripe.publishableKey = _publishableKey;
    _initialized = true;
  }

  /// Present the Stripe Payment Sheet using a clientSecret.
  /// Returns true if payment succeeded, false if cancelled/failed.
  Future<bool> presentPaymentSheet({
    required String clientSecret,
    String? merchantDisplayName,
  }) async {
    try {
      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName ?? 'Catalyst Dance Studio',
          style: ThemeMode.dark,
        ),
      );

      // Present the payment sheet to the user
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      return true;
    } on StripeException catch (e) {
      // User cancelled or payment failed
      debugPrint('[Stripe] Payment failed: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      debugPrint('[Stripe] Unexpected error: $e');
      return false;
    }
  }
}
