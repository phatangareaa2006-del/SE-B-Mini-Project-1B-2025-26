import 'package:intl/intl.dart';

class Fmt {
  static String currency(double amount) {
    if (amount >= 10000000) return '₹${(amount/10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000)   return '₹${(amount/100000).toStringAsFixed(1)}L';
    if (amount >= 1000)     return '₹${(amount/1000).toStringAsFixed(0)}K';
    return '₹${amount.toInt()}';
  }

  static String rupees(double amount) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(amount);

  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String dateTime(DateTime d) => DateFormat('dd MMM yyyy, hh:mm a').format(d);
  static String time(DateTime d) => DateFormat('hh:mm a').format(d);
  static String monthYear(DateTime d) => DateFormat('MMM yyyy').format(d);

  static String km(int km) {
    if (km >= 100000) return '${(km/100000).toStringAsFixed(1)}L km';
    if (km >= 1000)   return '${(km/1000).toStringAsFixed(0)}K km';
    return '$km km';
  }

  static double emi(double principal, int months, {double ratePercent = 9.5}) {
    final r = ratePercent / 12 / 100;
    return principal * r * pow(1 + r, months) / (pow(1 + r, months) - 1);
  }

  static double pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) { result *= base; }
    return result;
  }
}

class Validators {
  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.]+@[\w.]+\.\w+$').hasMatch(v)) return 'Enter valid email';
    return null;
  }
  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone is required';
    if (!RegExp(r'^\d{10}$').hasMatch(v)) return 'Enter 10-digit number';
    return null;
  }
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Min 6 characters';
    return null;
  }
  static String? pincode(String? v) {
    if (v == null || v.isEmpty) return 'Pincode required';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'Enter 6-digit pincode';
    return null;
  }
  static String? upiId(String? v) {
    if (v == null || v.isEmpty) return 'UPI ID required';
    if (!v.contains('@')) return 'Enter valid UPI ID (eg: name@upi)';
    return null;
  }
  static String? cardNumber(String? v) {
    if (v == null || v.isEmpty) return 'Card number required';
    if (v.replaceAll(' ', '').length != 16) return 'Enter 16-digit number';
    return null;
  }
}