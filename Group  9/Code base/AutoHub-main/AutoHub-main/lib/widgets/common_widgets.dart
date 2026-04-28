import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ── Primary Button ─────────────────────────────────────────────────────────
class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final Color? color;
  final IconData? icon;
  final double? width;

  const PrimaryBtn({super.key, required this.label, this.onTap,
    this.loading = false, this.color, this.icon, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primary,
          disabledBackgroundColor: AppTheme.textSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
      ),
    );
  }
}

// ── Outline Button ─────────────────────────────────────────────────────────
class OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;
  final double? width;

  const OutlineBtn({super.key, required this.label, this.onTap,
    this.color, this.icon, this.width});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          side: BorderSide(color: c),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(label, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: c)),
        ]),
      ),
    );
  }
}

// ── App TextField ──────────────────────────────────────────────────────────
class AppField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final bool obscure;
  final int maxLines, maxLength;
  final Widget? suffix, prefix;
  final String? prefixText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppField({
    super.key, required this.label, required this.hint,
    required this.controller, this.keyboard, this.obscure = false,
    this.maxLines = 1, this.maxLength = 200,
    this.suffix, this.prefix, this.prefixText,
    this.validator, this.onChanged,
    this.inputFormatters, this.readOnly = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller, keyboardType: keyboard,
        obscureText: obscure, maxLines: maxLines,
        maxLength: maxLength > 200 ? maxLength : null,
        inputFormatters: inputFormatters,
        readOnly: readOnly, onTap: onTap,
        validator: validator, onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint, suffixIcon: suffix, prefixIcon: prefix,
          prefixText: prefixText, counterText: '',
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }
}

// ── Section Header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle, actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title,
    this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ])),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: const TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
      ]),
    );
  }
}

// ── Status Badge ───────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const StatusBadge({super.key, required this.label,
    required this.color, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(
          color: color, fontSize: fontSize, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Rating Row ─────────────────────────────────────────────────────────────
class RatingRow extends StatelessWidget {
  final double rating;
  final int count;
  final double size;
  final bool showCount;

  const RatingRow({super.key, required this.rating,
    required this.count, this.size = 14, this.showCount = true});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, size: size, color: AppTheme.starColor),
      const SizedBox(width: 3),
      Text(rating.toStringAsFixed(1), style: TextStyle(
          fontSize: size - 1, fontWeight: FontWeight.w600)),
      if (showCount) ...[
        const SizedBox(width: 4),
        Text('($count)', style: TextStyle(
            fontSize: size - 2, color: AppTheme.textSecondary)),
      ],
    ]);
  }
}

// ── Info Row ───────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const InfoRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 14)),
        Text(value, style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14,
            color: valueColor ?? AppTheme.textPrimary)),
      ]),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon,
    required this.title, required this.subtitle,
    this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 72, color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(
              fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 20),
            PrimaryBtn(label: actionLabel!, onTap: onAction, width: 160),
          ],
        ]),
      ),
    );
  }
}

// ── Shimmer Box ────────────────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double width, height, borderRadius;
  const ShimmerBox({super.key, required this.width,
    required this.height, this.borderRadius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _anim = Tween<double>(begin: -1, end: 2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            stops: [
              (_anim.value - 0.3).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 0.3).clamp(0.0, 1.0),
            ],
            colors: const [Color(0xFFE8E8E8), Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
          ),
        ),
      ),
    );
  }
}

// ── Sheet Handle ───────────────────────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

// ── Gradient App Bar ───────────────────────────────────────────────────────
class GradientHeader extends StatelessWidget {
  final String title, subtitle;
  final List<Widget>? actions;

  const GradientHeader({super.key, required this.title,
    required this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, Color(0xFF800000)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
          if (actions != null) ...actions!,
        ]),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(
            color: Colors.white.withOpacity(0.85), fontSize: 14)),
      ]),
    );
  }
}

// ── Admin Confirm Banner ────────────────────────────────────────────────────
class AdminConfirmBanner extends StatelessWidget {
  const AdminConfirmBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppTheme.primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
    ),
    child: const Row(children: [
      Icon(Icons.admin_panel_settings, color: AppTheme.primary, size: 18),
      SizedBox(width: 8),
      Expanded(child: Text(
        'Admin confirmation required — your request will be reviewed before processing.',
        style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
      )),
    ]),
  );
}

// ── Privacy Policy Sheet ────────────────────────────────────────────────────
class PrivacySheet extends StatelessWidget {
  final VoidCallback onAccept;
  const PrivacySheet({super.key, required this.onAccept});

  static Future<void> show(BuildContext ctx, {required VoidCallback onAccept}) =>
      showModalBottomSheet(
        context: ctx, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PrivacySheet(onAccept: onAccept),
      );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(children: [
              const Text('Terms & Privacy Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
          ),
          Expanded(
            child: ListView(controller: ctrl, padding: const EdgeInsets.all(20),
              children: const [
                _PolicySection('1. Rental Agreement',
                    'By renting a vehicle through AutoHub, you agree to return the vehicle in the same condition. Late returns incur additional charges at the hourly rate. Cancellations made within 2 hours of pickup are non-refundable.'),
                _PolicySection('2. Customer Verification',
                    'A valid driving license is MANDATORY for vehicle rentals. Your documents will be verified by our admin team before confirming any booking.'),
                _PolicySection('3. Admin Confirmation',
                    'ALL requests require admin confirmation within 2-4 hours. You will receive a notification once your request is approved or rejected.'),
                _PolicySection('4. Payment Policy',
                    'AutoHub accepts UPI, Credit/Debit cards, and Cash on Delivery. UPI payments are processed via secure deep-link integration. Refunds are processed within 5-7 business days.'),
                _PolicySection('5. Data Privacy',
                    'Your personal data is stored securely on Firebase servers and never shared with third parties without consent. You may request data deletion at any time by contacting support@autohub.com.'),
                _PolicySection('6. Liability',
                    'AutoHub is not liable for accidents caused by driver negligence. The renter is responsible for any damage to the vehicle during the rental period.'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20,
                MediaQuery.of(context).padding.bottom + 20),
            child: PrimaryBtn(
              label: '✅  I Accept Terms & Conditions',
              onTap: () { Navigator.pop(context); onAccept(); },
            ),
          ),
        ]),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title, body;
  const _PolicySection(this.title, this.body);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(body, style: const TextStyle(
          fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
    ]),
  );
}

// ── Snack helpers ───────────────────────────────────────────────────────────
void showSuccess(BuildContext ctx, String msg) =>
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 18),
        const SizedBox(width: 8), Expanded(child: Text(msg)),
      ]),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));

void showError(BuildContext ctx, String msg) =>
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error, color: Colors.white, size: 18),
        const SizedBox(width: 8), Expanded(child: Text(msg)),
      ]),
      backgroundColor: AppTheme.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));