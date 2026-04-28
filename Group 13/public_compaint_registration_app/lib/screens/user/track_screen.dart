import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/complaint_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final _ctrl = TextEditingController();
  String? _searchedId;
  bool _searched = false;

  void _search() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _searched = false;
        _searchedId = null;
      });
      return;
    }
    setState(() {
      _searched = true;
      _searchedId = null;
    });
    // Stream search: scan all complaints for matching displayId
    FirebaseService().complaintsStream().first.then((list) {
      final found = list
          .where(
            (c) =>
                c.displayId.toLowerCase() == q.toLowerCase() ||
                c.docId.toLowerCase().startsWith(q.toLowerCase()),
          )
          .firstOrNull;
      if (mounted) {
        setState(() => _searchedId = found?.docId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track Complaint',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Georgia',
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter your complaint ID to see real-time status',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onSubmitted: (_) => _search(),
                    onChanged: (val) {
                      if (val.isEmpty && _searched) {
                        setState(() {
                          _searched = false;
                          _searchedId = null;
                        });
                      }
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter Complaint ID (e.g. CMP-XXXXXXXX)',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF9CA3AF),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAFBFD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFDDE1EA),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFDDE1EA),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1A3C6E),
                          width: 1.5,
                        ),
                      ),
                      suffixIcon: _ctrl.text.isNotEmpty || _searched
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFF9CA3AF),
                                size: 18,
                              ),
                              splashRadius: 20,
                              onPressed: () {
                                _ctrl.clear();
                                setState(() {
                                  _searched = false;
                                  _searchedId = null;
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Track →',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Result
          if (_searched && _searchedId == null)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Center(
                child: Column(
                  children: [
                    Text('🔍', style: TextStyle(fontSize: 44)),
                    SizedBox(height: 10),
                    Text(
                      'No complaint found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Please check the ID and try again',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),

          if (_searched && _searchedId != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  _ctrl.clear();
                  setState(() {
                    _searched = false;
                    _searchedId = null;
                  });
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                label: const Text(
                  'Back to Recent Complaints',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ComplaintDetail(docId: _searchedId!),
          ],

          if (!_searched) ...[
            const SizedBox(height: 16),
            const Text(
              'Your Recent Complaints',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<ComplaintModel>>(
              stream: FirebaseService().userComplaintsStream(
                FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snap.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final complaints = snap.data!;
                if (complaints.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No complaints filed yet.',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: complaints.length,
                  itemBuilder: (ctx, i) {
                    final c = complaints[i];
                    final cat = getCategoryById(c.category);
                    final sc =
                        kStatusColors[c.status] ?? kStatusColors['Pending']!;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _ctrl.text = c.displayId;
                          _search();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cat.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  cat.icon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${c.displayId} · ${c.formattedDate}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: sc.bg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                c.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: sc.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],

          const SizedBox(height: 12),

          // Hint box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '💡 Your complaint ID is shown after filing. It starts with CMP- followed by 8 characters.',
              style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Real-time complaint detail ───────────────────────────────────────────────
class _ComplaintDetail extends StatelessWidget {
  final String docId;
  const _ComplaintDetail({required this.docId});

  int _stepIndex(String status) {
    switch (status) {
      case 'Resolved':
        return 4;
      case 'In Progress':
        return 3;
      case 'Rejected':
        return 4;
      default:
        return 1; // Pending → Under Review
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ComplaintModel?>(
      stream: FirebaseService().singleComplaintStream(docId),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final c = snap.data;
        if (c == null) {
          return const Text('Complaint not found');
        }
        final cat = getCategoryById(c.category);
        final sc = kStatusColors[c.status] ?? kStatusColors['Pending']!;
        final stepIdx = _stepIndex(c.status);
        const steps = [
          'Submitted',
          'Under Review',
          'Assigned',
          'In Progress',
          'Resolved',
        ];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Georgia',
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          '${c.displayId} · Filed ${c.formattedDate}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sc.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: sc.dot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          c.status,
                          style: TextStyle(
                            color: sc.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Info grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () async {
                                  if (c.latitude != null && c.longitude != null) {
                                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${c.latitude},${c.longitude}');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  }
                                },
                                child: Text(c.location, 
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w700, 
                                    color: (c.latitude != null && c.longitude != null) ? AppTheme.navyPrimary : const Color(0xFF1A1A2E),
                                    decoration: (c.latitude != null && c.longitude != null) ? TextDecoration.underline : TextDecoration.none,
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        _InfoCell(label: 'State', value: c.state),
                        _InfoCell(label: 'Priority', value: c.priority),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoCell(label: 'Assigned To', value: c.assignedTo),
                        _InfoCell(label: 'Category', value: cat.label),
                        _InfoCell(
                          label: 'Upvotes',
                          value: '${c.upvotes} votes',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Admin note if present
              if (c.adminNote != null && c.adminNote!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.navyPrimary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💬 ', style: TextStyle(fontSize: 13)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Admin Note',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.navyPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              c.adminNote!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Progress timeline
              const Text(
                'Resolution Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              _Timeline(steps: steps, currentStep: stepIdx),

              // Activity log from timeline
              if (c.timeline.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Activity Log',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 10),
                ...c.timeline.reversed.take(5).map((t) {
                  final tStatus = t['status'] as String? ?? '';
                  final tNote = t['note'] as String? ?? '';
                  final tTime = t['timestamp'] as String? ?? '';
                  final tSc =
                      kStatusColors[tStatus] ?? kStatusColors['Pending']!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: tSc.dot,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: tSc.text,
                                ),
                              ),
                              if (tNote.isNotEmpty)
                                Text(
                                  tNote,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              Text(
                                tTime.length > 10
                                    ? tTime.substring(0, 10)
                                    : tTime,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── Timeline widget ──────────────────────────────────────────────────────────
class _Timeline extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  const _Timeline({required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
              Positioned(
                left: 8,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final fraction = currentStep / (steps.length - 1);
                    return FractionallySizedBox(
                      widthFactor: fraction,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.navyPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                        width: 3,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((e) {
            final active = e.key <= currentStep;
            return SizedBox(
              width: 56,
              child: Text(
                e.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: active
                      ? AppTheme.navyPrimary
                      : const Color(0xFF9CA3AF),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  height: 1.2,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
