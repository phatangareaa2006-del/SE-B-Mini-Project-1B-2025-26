import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'complaint_model.dart';
import 'firebase_service.dart';
import '../theme/app_theme.dart';

class ComplaintDetailPage extends StatefulWidget {
  final String docId;
  const ComplaintDetailPage({super.key, required this.docId});

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  Future<void> _openMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ComplaintModel?>(
      stream: FirebaseService().complaintStream(widget.docId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            backgroundColor: AppTheme.bgGray,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.data == null) {
          return const Scaffold(
            body: Center(child: Text('Complaint not found')),
          );
        }

        final c   = snap.data!;
        final cat = getCategoryById(c.category);

        return Scaffold(
          backgroundColor: AppTheme.bgGray,
          body: CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 130,
                pinned:         true,
                backgroundColor: AppTheme.navyPrimary,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: c.displayId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Complaint ID copied'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded,
                        color: Colors.white70, size: 20),
                    tooltip: 'Copy ID',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                      left: 56, bottom: 14, right: 16),
                  title: Column(
                    mainAxisSize:     MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.title,
                        style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w700,
                          color:      Colors.white,
                        ),
                        maxLines:  2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        c.displayId,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xAAFFFFFF)),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                        colors: [Color(0xFF1A3C6E), Color(0xFF0F2548)],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + Priority row
                      Row(children: [
                        _StatusBadge(status: c.status),
                        const SizedBox(width: 8),
                        _PriorityBadge(priority: c.priority),
                        const Spacer(),
                        Text(
                          c.formattedDateTime,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // Category + Location card
                      _InfoCard(children: [
                        _InfoRow(
                          icon: Text(cat.icon,
                              style: const TextStyle(fontSize: 18)),
                          label: 'Category',
                          value: cat.label,
                          valueColor: cat.color,
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: const Icon(Icons.location_on_rounded,
                              size: 18, color: Color(0xFFE74C3C)),
                          label: 'Location',
                          value: c.location,
                          trailing: (c.latitude != null && c.longitude != null)
                              ? IconButton(
                                  onPressed: () => _openMaps(c.latitude!, c.longitude!),
                                  icon: const Icon(Icons.map_outlined, size: 20, color: AppTheme.navyPrimary),
                                  tooltip: 'Show on Map',
                                  visualDensity: VisualDensity.compact,
                                )
                              : null,
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: const Icon(Icons.map_rounded,
                              size: 18, color: Color(0xFF2980B9)),
                          label: 'Ward',
                          value: c.ward.isEmpty ? 'Not specified' : c.ward,
                        ),
                        const _Divider(),
                        _InfoRow(
                          icon: const Icon(Icons.assignment_ind_rounded,
                              size: 18, color: Color(0xFF27AE60)),
                          label: 'Assigned To',
                          value: c.assignedTo,
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // Description
                      _SectionHeader('Description'),
                      const SizedBox(height: 8),
                      _InfoCard(children: [
                        Text(
                          c.description,
                          style: const TextStyle(
                            fontSize:  14,
                            color:     Color(0xFF374151),
                            height:    1.55,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      // Citizen Info
                      _SectionHeader('Filed By'),
                      const SizedBox(height: 8),
                      _InfoCard(children: [
                        Row(children: [
                          Container(
                            width:  42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:        AppTheme.navyPrimary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(21),
                            ),
                            child: const Center(
                              child: Icon(Icons.person_rounded,
                                  color: AppTheme.navyPrimary, size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.userName,
                                  style: const TextStyle(
                                    fontSize:   15,
                                    fontWeight: FontWeight.w600,
                                    color:      Color(0xFF1A1A2E),
                                  ),
                                ),
                                if (c.userEmail.isNotEmpty)
                                  Text(c.userEmail,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:    Color(0xFF6B7280))),
                                if (c.userPhone.isNotEmpty)
                                  Text(c.userPhone,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:    Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                        ]),
                      ]),
                      const SizedBox(height: 14),

                      // Images
                      if (c.imageUrls.isNotEmpty) ...[
                        _SectionHeader(
                            'Complaint Photos (${c.imageUrls.length})'),
                        const SizedBox(height: 8),
                        _ImageGallery(imageUrls: c.imageUrls),
                        const SizedBox(height: 14),
                      ] else ...[
                        _SectionHeader('Complaint Photos'),
                        const SizedBox(height: 8),
                        _InfoCard(children: [
                          const Row(children: [
                            Icon(Icons.image_not_supported_outlined,
                                color: Color(0xFF9CA3AF), size: 20),
                            SizedBox(width: 8),
                            Text('No photos attached',
                                style: TextStyle(
                                    color:   Color(0xFF9CA3AF),
                                    fontSize: 13)),
                          ]),
                        ]),
                        const SizedBox(height: 14),
                      ],

                      // Admin note (if any)
                      if (c.adminNote.isNotEmpty) ...[
                        _SectionHeader('Admin Note'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:        const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFFCC80), width: 1.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📝',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  c.adminNote,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color:    Color(0xFF7B4F00),
                                    height:   1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Timeline
                      _SectionHeader('Timeline'),
                      const SizedBox(height: 8),
                      _TimelineCard(complaint: c),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Floating Update Button ─────────────────────────────────────────
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showUpdateSheet(context, c),
            backgroundColor: AppTheme.navyPrimary,
            foregroundColor: Colors.white,
            icon:  const Icon(Icons.edit_rounded),
            label: const Text('Update Status',
                style: TextStyle(fontWeight: FontWeight.w700)),
            elevation: 4,
          ),
        );
      },
    );
  }

  void _showUpdateSheet(BuildContext context, ComplaintModel complaint) {
    showModalBottomSheet(
      context:          context,
      isScrollControlled: true,
      backgroundColor:  Colors.transparent,
      builder:          (_) => _UpdateStatusSheet(complaint: complaint),
    );
  }
}

// ─── Image Gallery ────────────────────────────────────────────────────────────
class _ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  const _ImageGallery({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   2,
        crossAxisSpacing: 10,
        mainAxisSpacing:  10,
        childAspectRatio: 1.15,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (_, i) => _ImageTile(
        url:   imageUrls[i],
        index: i,
        all:   imageUrls,
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String       url;
  final int          index;
  final List<String> all;
  const _ImageTile(
      {required this.url, required this.index, required this.all});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImageViewerPage(
            imageUrls:    all,
            initialIndex: index,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:    url,
              fit:         BoxFit.cover,
              placeholder: (_, __) => Container(
                color: const Color(0xFFE8EDF5),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.navyPrimary,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFE8EDF5),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_rounded,
                        color: Color(0xFF9CA3AF), size: 28),
                    SizedBox(height: 4),
                    Text('Load failed',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            ),
            // Overlay with view icon
            Positioned(
              right:  6,
              bottom: 6,
              child: Container(
                padding:     const EdgeInsets.all(4),
                decoration:  BoxDecoration(
                  color:        Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.fullscreen_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            if (all.length > 1)
              Positioned(
                left:   6,
                top:    6,
                child:  Container(
                  padding:     const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration:  BoxDecoration(
                    color:        Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}/${all.length}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Full-screen Image Viewer ─────────────────────────────────────────────────
class _ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int          initialIndex;
  const _ImageViewerPage(
      {required this.imageUrls, required this.initialIndex});

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late int _current;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _current  = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Images
          PageView.builder(
            controller:  _pageCtrl,
            itemCount:   widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: Image.network(
                widget.imageUrls[i],
                fit:   BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.white38, size: 48),
                ),
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              child: Row(children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 26),
                ),
                const Spacer(),
                if (widget.imageUrls.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color:        Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_current + 1} / ${widget.imageUrls.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ]),
            ),
          ),

          // Dot indicators
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 30,
              left:   0,
              right:  0,
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                      (i) => AnimatedContainer(
                    duration:   const Duration(milliseconds: 250),
                    margin:     const EdgeInsets.symmetric(horizontal: 3),
                    width:      i == _current ? 20 : 7,
                    height:     7,
                    decoration: BoxDecoration(
                      color:        i == _current
                          ? Colors.white
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Timeline Card ────────────────────────────────────────────────────────────
class _TimelineCard extends StatelessWidget {
  final ComplaintModel complaint;
  const _TimelineCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        icon:   '📝',
        title:  'Complaint Filed',
        sub:    'By ${complaint.userName}',
        date:   complaint.formattedDateTime,
        color:  AppTheme.navyPrimary,
      ),
      if (complaint.status == 'In Progress' ||
          complaint.status == 'Resolved' ||
          complaint.status == 'Rejected')
        _TimelineEvent(
          icon:  '⚙️',
          title: 'Assigned to ${complaint.assignedTo}',
          sub:   'Status updated',
          date:  complaint.updatedDateFormatted,
          color: const Color(0xFF2980B9),
        ),
      if (complaint.status == 'Resolved')
        _TimelineEvent(
          icon:  '✅',
          title: 'Resolved',
          sub:   'Complaint closed successfully',
          date:  complaint.updatedDateFormatted,
          color: const Color(0xFF27AE60),
        ),
      if (complaint.status == 'Rejected')
        _TimelineEvent(
          icon:  '❌',
          title: 'Rejected',
          sub:   complaint.adminNote.isEmpty
              ? 'Complaint rejected'
              : complaint.adminNote,
          date:  complaint.updatedDateFormatted,
          color: const Color(0xFFE74C3C),
        ),
    ];

    return _InfoCard(
      children: [
        for (int i = 0; i < events.length; i++) ...[
          _TimelineTile(event: events[i], isLast: i == events.length - 1),
        ],
      ],
    );
  }
}

class _TimelineEvent {
  final String icon, title, sub, date;
  final Color  color;
  const _TimelineEvent({
    required this.icon,
    required this.title,
    required this.sub,
    required this.date,
    required this.color,
  });
}

class _TimelineTile extends StatelessWidget {
  final _TimelineEvent event;
  final bool           isLast;
  const _TimelineTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line + dot
        SizedBox(
          width: 32,
          child: Column(children: [
            Container(
              width:  32,
              height: 32,
              decoration: BoxDecoration(
                color:        event.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(event.icon,
                    style: const TextStyle(fontSize: 15)),
              ),
            ),
            if (!isLast)
              Container(
                  width: 2, height: 32, color: const Color(0xFFE8EDF5)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color:      Color(0xFF1A1A2E))),
                Text(event.sub,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Text(event.date,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF))),
                if (!isLast) const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Update Status Bottom Sheet ───────────────────────────────────────────────
class _UpdateStatusSheet extends StatefulWidget {
  final ComplaintModel complaint;
  const _UpdateStatusSheet({required this.complaint});

  @override
  State<_UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<_UpdateStatusSheet> {
  late String _status;
  late String _assignedTo;
  final _noteCtrl = TextEditingController();
  bool _loading   = false;

  @override
  void initState() {
    super.initState();
    _status     = widget.complaint.status;
    _assignedTo = widget.complaint.assignedTo;
    if (widget.complaint.adminNote.isNotEmpty) {
      _noteCtrl.text = widget.complaint.adminNote;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    await FirebaseService().updateComplaintStatus(
      docId:      widget.complaint.docId,
      status:     _status,
      assignedTo: _assignedTo,
      adminNote:  _noteCtrl.text.trim(),
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Complaint updated to $_status'),
          backgroundColor: const Color(0xFF27AE60),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:     const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left:   20,
          right:  20,
          top:    20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize:     MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width:  40,
                height: 4,
                decoration: BoxDecoration(
                  color:        const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Complaint',
              style: TextStyle(
                fontFamily:  'Georgia',
                fontSize:    18,
                fontWeight:  FontWeight.w700,
                color:       Color(0xFF1A1A2E),
              ),
            ),
            Text(
              widget.complaint.displayId,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 20),

            // Status selector
            const Text('STATUS',
                style: TextStyle(
                    fontSize:     11,
                    fontWeight:   FontWeight.w700,
                    color:        Color(0xFF4A5568),
                    letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Wrap(
              spacing:    8,
              runSpacing: 8,
              children: kStatuses.map((s) {
                final selected = _status == s;
                final sc = kStatusColors[s]!;
                return GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color:  selected ? sc.dot : Colors.white,
                      border: Border.all(
                        color: selected ? sc.dot : const Color(0xFFDDE1EA),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: selected
                          ? [BoxShadow(
                        color:      sc.dot.withOpacity(0.3),
                        blurRadius: 8,
                        offset:     const Offset(0, 2),
                      )]
                          : [],
                    ),
                    child: Text(s,
                        style: TextStyle(
                          fontSize:   13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : sc.text,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Assign to
            const Text('ASSIGN TO',
                style: TextStyle(
                    fontSize:     11,
                    fontWeight:   FontWeight.w700,
                    color:        Color(0xFF4A5568),
                    letterSpacing: 0.8)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _assignedTo,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:   const BorderSide(
                        color: Color(0xFFDDE1EA), width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:   const BorderSide(
                        color: Color(0xFFDDE1EA), width: 1.5)),
                filled:    true,
                fillColor: const Color(0xFFFAFBFD),
              ),
              items: kDepartments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _assignedTo = v ?? _assignedTo),
            ),
            const SizedBox(height: 16),

            // Admin note
            const Text('ADMIN NOTE (OPTIONAL)',
                style: TextStyle(
                    fontSize:     11,
                    fontWeight:   FontWeight.w700,
                    color:        Color(0xFF4A5568),
                    letterSpacing: 0.8)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines:   3,
              decoration: InputDecoration(
                hintText:   'Add a note or update for the citizen...',
                hintStyle:  const TextStyle(
                    color: Color(0xFF9CA3AF), fontSize: 13),
                filled:     true,
                fillColor:  const Color(0xFFFAFBFD),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:   const BorderSide(
                        color: Color(0xFFDDE1EA), width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:   const BorderSide(
                        color: Color(0xFFDDE1EA), width: 1.5)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFDDE1EA)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                      width:  18,
                      height: 18,
                      child:  CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color:      Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset:     const Offset(0, 1),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final Widget  icon;
  final String  label;
  final String  value;
  final Color?  valueColor;
  final Widget? trailing;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 28, child: icon),
      const SizedBox(width: 8),
      SizedBox(
        width: 80,
        child: Text(label,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF9CA3AF))),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
          textAlign: TextAlign.end,
        ),
      ),
      if (trailing != null) ...[
        const SizedBox(width: 4),
        trailing!,
      ],
    ]),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
      height: 1, thickness: 1, color: Color(0xFFF4F6FB));
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize:   15,
      fontWeight: FontWeight.w700,
      fontFamily: 'Georgia',
      color:      Color(0xFF1A1A2E),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final sc = kStatusColors[status] ?? kStatusColors['Pending']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color:        sc.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sc.dot.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: sc.dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(status,
            style: TextStyle(
                color:      sc.text,
                fontSize:   12,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = kPriorityColors[priority] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${_priorityIcon(priority)} $priority',
        style: TextStyle(
          color:       color,
          fontSize:    11,
          fontWeight:  FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _priorityIcon(String p) {
    switch (p) {
      case 'High':   return '🔴';
      case 'Medium': return '🟡';
      case 'Low':    return '🟢';
      default:       return '⚪';
    }
  }
}