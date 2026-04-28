import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  RAZORPAY KEY
//  1. Go to https://dashboard.razorpay.com
//  2. Sign up with just email (no documents for test mode)
//  3. Settings → API Keys → Generate Test Key
//  4. Paste the rzp_test_XXXXXXXX key below
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const String kRazorpayKey = 'rzp_test_SahNDTtym78EY7';

class UpiService {
  static final _db = FirebaseFirestore.instance;
  static Razorpay? _razorpay;

  static String generateRef() =>
      'AH${DateTime.now().millisecondsSinceEpoch}';

  static Future<void> saveTransaction({
    required String txnRef,
    required double amount,
    required String type,
    required String itemTitle,
    required String userId,
    required String userName,
    required String upiId,
    String status = 'initiated',
  }) async {
    try {
      await _db.collection('transactions').doc(txnRef).set({
        'txnRef':    txnRef,
        'amount':    amount,
        'type':      type,
        'itemTitle': itemTitle,
        'userId':    userId,
        'userName':  userName,
        'upiId':     upiId,
        'status':    status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('saveTransaction error: $e');
    }
  }

  static Future<void> updateStatus(String txnRef, String status) async {
    try {
      await _db.collection('transactions').doc(txnRef).update({
        'status':    status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('updateStatus error: $e');
    }
  }

  static Future<bool> launch({
    required double amount,
    required String note,
    required String txnRef,
    String? type,
    String? itemTitle,
    String? userId,
    String? userName,
    String? upiId,
    String contact = '9999999999',
    String email   = 'customer@autohub.com',
    void Function(PaymentSuccessResponse)? onSuccess,
    void Function(PaymentFailureResponse)? onFailure,
  }) async {
    if (kIsWeb) return false;

    if (userId != null) {
      await saveTransaction(
        txnRef:    txnRef,
        amount:    amount,
        type:      type      ?? 'payment',
        itemTitle: itemTitle ?? note,
        userId:    userId,
        userName:  userName  ?? '',
        upiId:     upiId     ?? '',
        status:    'initiated',
      );
    }

    final options = {
      'key':         kRazorpayKey,
      'amount':      (amount * 100).toInt(), // paise
      'name':        'AutoHub',
      'description': note,
      'prefill': {
        'contact': contact,
        'email':   email,
      },
      'notes': {
        'txn_ref': txnRef,  // store our reference in notes instead
      },
      'theme': {'color': '#E41E24'},
      'method': {
        'upi':        true,
        'card':       true,
        'netbanking': true,
        'wallet':     true,
      },
    };

    _razorpay = Razorpay();

    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS,
            (PaymentSuccessResponse res) async {
          debugPrint('✅ Razorpay success: ${res.paymentId}');
          await updateStatus(txnRef, 'success');
          onSuccess?.call(res);
        });

    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR,
            (PaymentFailureResponse res) async {
          debugPrint('❌ Razorpay error: ${res.message}');
          await updateStatus(txnRef, 'failed');
          onFailure?.call(res);
        });

    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET,
            (ExternalWalletResponse res) {
          debugPrint('Wallet: ${res.walletName}');
        });

    try {
      _razorpay!.open(options);
      return true;
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      return false;
    }
  }

  static void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}