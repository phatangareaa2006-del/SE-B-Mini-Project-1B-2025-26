import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class TrackScreen extends StatefulWidget {
  final List<Complaint> complaints;
  final String? initialId;

  const TrackScreen({super.key, required this.complaints, this.initialId});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  late final TextEditingController _ctrl;
  Complaint? _found;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialId ?? '');
    if (widget.initialId != null && widget.initialId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _track());
    }
  }

  void _track() {
    final id = _ctrl.text.trim().toLowerCase();
    final found = widget.complaints
        .where((c) => c.id.toLowerCase() == id)
        .firstOrNull;
    setState(() {
      _found = found;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Track Complaint',
                subtitle:
                    'Enter your complaint ID to see real-time status updates',
              ),
              const SizedBox(height: 24),

              // ── Search Bar ────────────────────────────────────────────────
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _track(),
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1A1A2E)),
                        decoration: InputDecoration(
                          hintText:
                              'Enter Complaint ID (e.g. CMP-2024-001)',
                          hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFFAFBFD),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFDDE1EA), width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFFDDE1EA), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppTheme.navyPrimary, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(label: 'Track →', onTap: _track),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Result ────────────────────────────────────────────────────
              if (_searched && _found == null)
                AppCard(
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text('🔍', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No complaint found',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF9CA3AF))),
                          SizedBox(height: 4),
                          Text('Please check the ID and try again',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ),
                ),

              if (_found != null) _ComplaintDetail(complaint: _found!),

              const SizedBox(height: 16),

              // ── Hint ──────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '💡 Try these IDs: CMP-2024-001, CMP-2024-002, CMP-2024-003, CMP-2024-004, CMP-2024-005',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Complaint Detail Card ───────────────────────────────────────────────────
class _ComplaintDetail extends StatelessWidget {
  final Complaint complaint;
  const _ComplaintDetail({required this.complaint});

  int _stepIndex() {
    switch (complaint.status) {
      case 'Resolved':
        return 4;
      case 'In Progress':
        return 3;
      case 'Pending':
        return 1;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(complaint.category);
    final stepIdx = _stepIndex();
    const steps = ['Submitted', 'Under Review', 'Assigned', 'In Progress', 'Resolved'];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(cat.icon,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(complaint.title,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF1A1A2E))),
                          Text('${complaint.id} · Filed on ${complaint.date}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusBadge(status: complaint.status),
            ],
          ),
          const SizedBox(height: 20),

          // Info Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(children: [
                  _InfoItem(label: 'Location', value: complaint.location),
                  _InfoItem(label: 'Ward', value: complaint.ward),
                  _InfoItem(label: 'Priority', value: complaint.priority),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  _InfoItem(label: 'Assigned To', value: complaint.assignedTo),
                  _InfoItem(
                      label: 'Category',
                      value: getCategoryById(complaint.category).label),
                  _InfoItem(
                      label: 'Community Support',
                      value: '${complaint.upvotes} upvotes'),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress Timeline
          const Text('Resolution Progress',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 14),
          _ProgressTimeline(steps: steps, currentStep: stepIdx),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }
}

class _ProgressTimeline extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  const _ProgressTimeline({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Line + dots
        SizedBox(
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              Positioned(
                left: 8,
                right: 8,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Filled track
              Positioned(
                left: 8,
                child: FractionallySizedBox(
                  widthFactor: currentStep / (steps.length - 1),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.navyPrimary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: steps.asMap().entries.map((e) {
                  final active = e.key <= currentStep;
                  return Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.navyPrimary
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: active
                              ? AppTheme.navyPrimary
                              : const Color(0xFFE2E8F0),
                          width: 3),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((e) {
            final active = e.key <= currentStep;
            return SizedBox(
              width: 60,
              child: Text(e.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: active
                          ? AppTheme.navyPrimary
                          : const Color(0xFF9CA3AF),
                      fontWeight: active
                          ? FontWeight.w600
                          : FontWeight.w400,
                      height: 1.2)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
