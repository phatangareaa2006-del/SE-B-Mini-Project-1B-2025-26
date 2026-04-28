import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common_widgets.dart';

class WriteReviewScreen extends StatefulWidget {
  final String targetId, targetType, targetName;
  const WriteReviewScreen({super.key, required this.targetId,
    required this.targetType, required this.targetName});
  @override State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _rating = 0;
  final _titleCtrl   = TextEditingController();
  final _commentCtrl = TextEditingController();
  final List<String> _selectedTags = [];
  bool _submitting = false;

  @override
  void dispose() { _titleCtrl.dispose(); _commentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0) { showError(context, 'Please select a rating'); return; }
    if (_commentCtrl.text.trim().length < 20) {
      showError(context, 'Review must be at least 20 characters'); return;
    }
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    if (auth.user == null) { showError(context, 'Please login'); return; }

    final ok = await context.read<ReviewProvider>().submitReview(
      targetId:   widget.targetId,
      targetType: widget.targetType,
      userId:     auth.user!.uid,
      userName:   auth.user!.displayName,
      userPhoto:  auth.user!.profilePhoto,
      rating:     _rating,
      title:      _titleCtrl.text.trim(),
      comment:    _commentCtrl.text.trim(),
      tags:       _selectedTags,
    );

    setState(() => _submitting = false);
    if (ok && mounted) {
      Navigator.pop(context);
      showSuccess(context, 'Review submitted! Thank you 🙏');
    } else if (mounted) {
      showError(context, 'Failed to submit review. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review'), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reviewing: ${widget.targetName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),

          // Star rating
          const Text('Your Rating *', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Center(child: RatingBar.builder(
            initialRating: _rating,
            minRating: 1, direction: Axis.horizontal,
            allowHalfRating: true, itemCount: 5, itemSize: 40,
            itemBuilder: (_, __) =>
            const Icon(Icons.star_rounded, color: AppTheme.starColor),
            onRatingUpdate: (r) => setState(() => _rating = r),
          )),
          Center(child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _rating == 0 ? 'Tap to rate'
                  : _rating >= 4.5 ? '⭐ Excellent!'
                  : _rating >= 3.5 ? '👍 Good'
                  : _rating >= 2.5 ? '😐 Average'
                  : '👎 Poor',
              style: TextStyle(
                  color: _rating >= 3.5 ? AppTheme.success : AppTheme.warning,
                  fontWeight: FontWeight.w600),
            ),
          )),
          const SizedBox(height: 20),

          AppField(label: 'Review Title', hint: 'Summarise your experience',
              controller: _titleCtrl),
          AppField(label: 'Your Review *',
              hint: 'Share your experience in detail (min 20 characters)...',
              controller: _commentCtrl, maxLines: 5, maxLength: 1000),

          // Tags
          const Text('Tags (optional)', style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
              children: AppConstants.reviewTags.map((tag) {
                final sel = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () => setState(() {
                    sel ? _selectedTags.remove(tag) : _selectedTags.add(tag);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: sel ? AppTheme.primary : AppTheme.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel ? AppTheme.primary : AppTheme.border)),
                    child: Text(tag, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : AppTheme.textSecondary)),
                  ),
                );
              }).toList()),
          const SizedBox(height: 24),

          PrimaryBtn(label: 'Submit Review', onTap: _submit, loading: _submitting),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}