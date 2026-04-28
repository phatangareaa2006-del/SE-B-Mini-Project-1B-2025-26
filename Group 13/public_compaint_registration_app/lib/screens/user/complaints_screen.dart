import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AllComplaintsScreen extends StatefulWidget {
  final VoidCallback onNewComplaint;

  const AllComplaintsScreen({super.key, required this.onNewComplaint});

  @override
  State<AllComplaintsScreen> createState() =>
      _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<AllComplaintsScreen> {
  String _filterStatus = 'All';
  String _filterCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: FirebaseService().complaintsStream(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snap.data!;
        final filtered = all.where((c) {
          final statusOk =
              _filterStatus == 'All' || c.status == _filterStatus;
          final catOk =
              _filterCategory == 'All' || c.category == _filterCategory;
          return statusOk && catOk;
        }).toList();

        return Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('All Complaints',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Georgia',
                              color: Color(0xFF1A1A2E))),
                      Text('${filtered.length} complaints found',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280))),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.onNewComplaint,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New',
                        style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navyPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Status filters ────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusChip('All', all.length),
                    ...[
                      'Pending',
                      'In Progress',
                      'Resolved',
                      'Rejected'
                    ].map((s) => _buildStatusChip(
                        s, all.where((c) => c.status == s).length)),
                  ],
                ),
              ),
            ),

            // ── Category filter ───────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All', 'All'),
                    ...kCategories.map(
                        (c) => _buildCategoryChip(c.id, c.icon)),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('📭',
                              style: TextStyle(fontSize: 44)),
                          SizedBox(height: 12),
                          Text('No complaints found',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) =>
                          _ComplaintCard(complaint: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String label, int count) {
    final active = _filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterStatus = label),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppTheme.navyPrimary : Colors.white,
            border: Border.all(
                color: active
                    ? AppTheme.navyPrimary
                    : const Color(0xFFDDE1EA),
                width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$label ($count)',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF4A5568))),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String id, String icon) {
    final active = _filterCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterCategory = id),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.navyPrimary.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
                color: active
                    ? AppTheme.navyPrimary
                    : const Color(0xFFDDE1EA),
                width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(id == 'All' ? 'All' : icon,
              style: TextStyle(
                  fontSize: id == 'All' ? 12 : 18,
                  color: active
                      ? AppTheme.navyPrimary
                      : const Color(0xFF4A5568))),
        ),
      ),
    );
  }
}

// ─── Complaint card ───────────────────────────────────────────────────────────
class _ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  const _ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(complaint.category);
    final sc =
        kStatusColors[complaint.status] ?? kStatusColors['Pending']!;
    final pColor = kPriorityColors[complaint.priority] ?? Colors.grey;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
              left: BorderSide(color: cat.color, width: 4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child:
                        Text(cat.icon, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(complaint.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: pColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(complaint.priority.toUpperCase(),
                            style: TextStyle(
                                color: pColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ),
                    ]),
                    const SizedBox(height: 3),
                    Text(
                        '${complaint.displayId} · ${complaint.formattedDate}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 12, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 3),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (complaint.latitude != null && complaint.longitude != null) {
                      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${complaint.latitude},${complaint.longitude}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                  child: Text(complaint.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: (complaint.latitude != null && complaint.longitude != null) ? AppTheme.navyPrimary : const Color(0xFF9CA3AF),
                        decoration: (complaint.latitude != null && complaint.longitude != null) ? TextDecoration.underline : TextDecoration.none,
                      )
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: sc.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: sc.dot, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(complaint.status,
                        style: TextStyle(
                            color: sc.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
                GestureDetector(
                  onTap: () =>
                      FirebaseService().toggleUpvote(complaint.docId, FirebaseAuth.instance.currentUser?.uid ?? ''),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      border: Border.all(
                          color: const Color(0xFFC5D2EA), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.keyboard_arrow_up_rounded,
                          size: 14,
                          color: AppTheme.navyPrimary),
                      Text('${complaint.upvotes}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.navyPrimary)),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComplaintDetailSheet(complaint: complaint),
    );
  }
}

// ─── Complaint detail bottom sheet ───────────────────────────────────────────
class _ComplaintDetailSheet extends StatelessWidget {
  final ComplaintModel complaint;
  const _ComplaintDetailSheet({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(complaint.category);
    final sc =
        kStatusColors[complaint.status] ?? kStatusColors['Pending']!;

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
      child: DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        initialChildSize: 0.6,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Text(cat.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(complaint.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Georgia')),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: sc.bg,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(complaint.status,
                      style: TextStyle(
                          color: sc.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text(
                    '${complaint.displayId} · ${complaint.state}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ]),
              const Divider(height: 20),
              const Text('DESCRIPTION',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(complaint.description,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF374151))),
              const Divider(height: 20),
              _DetailRow(icon: '📍', label: 'Location', value: complaint.location),
              _DetailRow(icon: '👤', label: 'Assigned To', value: complaint.assignedTo),
              _DetailRow(icon: '📅', label: 'Filed On', value: complaint.formattedDate),
              _DetailRow(icon: '⚡', label: 'Priority', value: complaint.priority),
              if (complaint.adminNote != null && complaint.adminNote!.isNotEmpty) ...[
                const Divider(height: 20),
                const Text('ADMIN NOTE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 1)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(complaint.adminNote!,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF374151))),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF374151))),
        ),
      ]),
    );
  }
}
