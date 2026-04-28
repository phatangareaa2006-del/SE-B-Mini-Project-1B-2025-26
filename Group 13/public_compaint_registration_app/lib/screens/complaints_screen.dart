import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AllComplaintsScreen extends StatefulWidget {
  final List<Complaint> complaints;
  final VoidCallback onNewComplaint;
  final Function(String) onTrack;

  const AllComplaintsScreen({
    super.key,
    required this.complaints,
    required this.onNewComplaint,
    required this.onTrack,
  });

  @override
  State<AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<AllComplaintsScreen> {
  String _filterStatus = 'All';
  String _filterCategory = 'All';

  List<Complaint> get _filtered => widget.complaints.where((c) {
        final statusOk =
            _filterStatus == 'All' || c.status == _filterStatus;
        final catOk =
            _filterCategory == 'All' || c.category == _filterCategory;
        return statusOk && catOk;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Complaints',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Georgia',
                          color: Color(0xFF1A1A2E))),
                  Text('${filtered.length} complaints found',
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF6B7280))),
                ],
              ),
              PrimaryButton(
                  label: '+ New Complaint',
                  onTap: widget.onNewComplaint,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10)),
            ],
          ),
          const SizedBox(height: 18),

          // ── Filters ───────────────────────────────────────────────────────
          _FiltersRow(
            filterStatus: _filterStatus,
            filterCategory: _filterCategory,
            onStatusChange: (s) => setState(() => _filterStatus = s),
            onCategoryChange: (c) => setState(() => _filterCategory = c),
          ),
          const SizedBox(height: 16),

          // ── List ─────────────────────────────────────────────────────────
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: Column(
                  children: [
                    Text('📭', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('No complaints found',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            )
          else
            ...filtered.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ComplaintRow(
                    complaint: c,
                    onTap: () => widget.onTrack(c.id),
                    onUpvote: () => setState(() => c.upvotes++),
                  ),
                )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Filters Row ──────────────────────────────────────────────────────────────
class _FiltersRow extends StatelessWidget {
  final String filterStatus;
  final String filterCategory;
  final ValueChanged<String> onStatusChange;
  final ValueChanged<String> onCategoryChange;

  const _FiltersRow({
    required this.filterStatus,
    required this.filterCategory,
    required this.onStatusChange,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = ['All', 'Pending', 'In Progress', 'Resolved'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('Status:',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280))),
        ...statuses.map((s) {
          final active = filterStatus == s;
          return GestureDetector(
            onTap: () => onStatusChange(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active ? AppTheme.navyPrimary : Colors.white,
                border: Border.all(
                    color: active
                        ? AppTheme.navyPrimary
                        : const Color(0xFFDDE1EA),
                    width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(s,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: active ? Colors.white : const Color(0xFF4A5568))),
            ),
          );
        }),
        const SizedBox(width: 4),
        const Text('Category:',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280))),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: filterCategory,
            isDense: true,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Roboto'),
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 9),
            ),
            items: [
              const DropdownMenuItem(
                  value: 'All', child: Text('All Categories')),
              ...categories.map((c) => DropdownMenuItem(
                  value: c.id, child: Text(c.label))),
            ],
            onChanged: (v) => onCategoryChange(v ?? 'All'),
          ),
        ),
      ],
    );
  }
}

// ─── Complaint Row ────────────────────────────────────────────────────────────
class _ComplaintRow extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onTap;
  final VoidCallback onUpvote;

  const _ComplaintRow(
      {required this.complaint,
      required this.onTap,
      required this.onUpvote});

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(complaint.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: cat.color, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CategoryIconBox(cat: cat),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(complaint.title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E))),
                      ),
                      const SizedBox(width: 8),
                      PriorityBadge(priority: complaint.priority),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _MetaChip(icon: '🆔', text: complaint.id),
                      _MetaChip(icon: '📅', text: complaint.date),
                      _MetaChip(icon: '📍', text: complaint.location),
                      _MetaChip(icon: '🏛️', text: complaint.ward),
                      _MetaChip(icon: '👤', text: complaint.assignedTo),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: complaint.status),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onUpvote,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      border: Border.all(
                          color: const Color(0xFFC5D2EA), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('▲ ${complaint.upvotes}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.navyPrimary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String icon;
  final String text;
  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text('$icon $text',
        style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)));
  }
}
