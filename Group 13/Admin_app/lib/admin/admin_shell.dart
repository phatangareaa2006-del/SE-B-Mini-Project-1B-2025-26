import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'complaint_model.dart';
import 'firebase_service.dart';
import 'auth_provider.dart' as ap;
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import 'complaint_detail.dart';
import 'package:provider/provider.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _tab = 0;

  static const _navItems = [
    {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
    {'icon': Icons.list_alt_rounded,  'label': 'Complaints'},
    {'icon': Icons.bar_chart_rounded, 'label': 'Analytics'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgGray,
      body: Column(
        children: [
          _AdminHeader(
            onLogout: () => context.read<ap.AuthProvider>().signOut(),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:         _tab,
        onTap:                (i) => setState(() => _tab = i),
        type:                 BottomNavigationBarType.fixed,
        backgroundColor:      AppTheme.navyDark,
        selectedItemColor:    AppTheme.gold,
        unselectedItemColor:  Colors.white54,
        selectedFontSize:     11,
        unselectedFontSize:   11,
        items: _navItems
            .map((n) => BottomNavigationBarItem(
          icon:  Icon(n['icon'] as IconData),
          label: n['label'] as String,
        ))
            .toList(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case 0:  return const _AdminDashboard();
      case 1:  return const _AdminComplaintsList();
      case 2:  return const _AdminAnalytics();
      default: return const SizedBox.shrink();
    }
  }
}

// ─── Admin Header ─────────────────────────────────────────────────────────────
class _AdminHeader extends StatelessWidget {
  final VoidCallback onLogout;
  const _AdminHeader({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<ap.AuthProvider>().admin;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A3C6E), Color(0xFF0F2548)],
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            // Logo
            Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE8A020), Color(0xFFF0C040)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('🏛️', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CivicVoice Admin',
                    style: TextStyle(
                        fontFamily:  'Georgia',
                        fontWeight:  FontWeight.w800,
                        fontSize:    18,
                        color:       Colors.white)),
                Text(
                  admin != null ? admin.name : 'COMPLAINT MANAGEMENT PANEL',
                  style: const TextStyle(
                      fontSize: 9, color: Color(0x99FFFFFF), letterSpacing: 1.2),
                ),
              ],
            ),
            const Spacer(),

            // Live pending badge
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('status', isEqualTo: 'Pending')
                  .snapshots(),
              builder: (ctx, snap) {
                final count = snap.data?.docs.length ?? 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: count > 0
                        ? const Color(0xFFE74C3C)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$count Pending',
                      style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   12,
                          fontWeight: FontWeight.w600)),
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded,
                  color: Colors.white70, size: 22),
              tooltip: 'Sign out',
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Admin Dashboard ──────────────────────────────────────────────────────────
class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: FirebaseService().complaintsStream(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all        = snap.data!;
        final total      = all.length;
        final resolved   = all.where((c) => c.status == 'Resolved').length;
        final inProgress = all.where((c) => c.status == 'In Progress').length;
        final pending    = all.where((c) => c.status == 'Pending').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin Dashboard',
                  style: TextStyle(
                      fontSize:    22,
                      fontWeight:  FontWeight.w700,
                      fontFamily:  'Georgia',
                      color:       Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              Text('Managing $total total complaints',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 18),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap:     true,
                physics:        const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing:  12,
                childAspectRatio: 1.7,
                children: [
                  _AdminStatCard(
                      label: 'Total',       value: total,
                      icon: '📋', color: AppTheme.navyPrimary),
                  _AdminStatCard(
                      label: 'Resolved',    value: resolved,
                      icon: '✅', color: const Color(0xFF27AE60)),
                  _AdminStatCard(
                      label: 'In Progress', value: inProgress,
                      icon: '⚙️', color: const Color(0xFF2980B9)),
                  _AdminStatCard(
                      label: 'Pending',     value: pending,
                      icon: '⏳', color: const Color(0xFFE67E22)),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Recent Complaints',
                  style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia')),
              const SizedBox(height: 10),
              ...all.take(5).map((c) => _AdminComplaintTile(complaint: c)),
            ],
          ),
        );
      },
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final int    value;
  final String icon;
  final Color  color;
  const _AdminStatCard(
      {required this.label,
        required this.value,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset:     const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color:        color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize:    26,
                      fontWeight:  FontWeight.w700,
                      color:       color,
                      fontFamily:  'Georgia')),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Admin Complaints List ────────────────────────────────────────────────────
class _AdminComplaintsList extends StatefulWidget {
  const _AdminComplaintsList();

  @override
  State<_AdminComplaintsList> createState() => _AdminComplaintsListState();
}

class _AdminComplaintsListState extends State<_AdminComplaintsList> {
  String _filterStatus = 'All';
  String _searchQuery  = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: FirebaseService().complaintsStream(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snap.data!;

        // Apply filters
        var filtered = _filterStatus == 'All'
            ? all
            : all.where((c) => c.status == _filterStatus).toList();

        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          filtered = filtered
              .where((c) =>
          c.title.toLowerCase().contains(q) ||
              c.userName.toLowerCase().contains(q) ||
              c.location.toLowerCase().contains(q) ||
              c.displayId.toLowerCase().contains(q))
              .toList();
        }

        return Column(
          children: [
            // Search bar
            Container(
              color:   Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText:    'Search by title, name, ID...',
                  hintStyle:   const TextStyle(
                      fontSize: 13, color: Color(0xFF9CA3AF)),
                  prefixIcon:  const Icon(Icons.search_rounded,
                      size: 20, color: Color(0xFF9CA3AF)),
                  suffixIcon:  _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () =>
                        setState(() => _searchQuery = ''),
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
              ),
            ),

            // Status filter chips
            Container(
              color:   Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Pending', 'In Progress', 'Resolved', 'Rejected']
                      .map((s) {
                    final active = _filterStatus == s;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filterStatus = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color:  active ? AppTheme.navyPrimary : Colors.white,
                            border: Border.all(
                                color: active
                                    ? AppTheme.navyPrimary
                                    : const Color(0xFFDDE1EA),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s,
                              style: TextStyle(
                                  fontSize:   13,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF4A5568))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${filtered.length} complaints',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF6B7280))),
              ),
            ),

            // List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📭',
                        style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No results for "$_searchQuery"'
                          : 'No complaints found',
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding:     const EdgeInsets.symmetric(horizontal: 16),
                itemCount:   filtered.length,
                itemBuilder: (ctx, i) =>
                    _AdminComplaintTile(complaint: filtered[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Admin Complaint Tile ─────────────────────────────────────────────────────
class _AdminComplaintTile extends StatelessWidget {
  final ComplaintModel complaint;
  const _AdminComplaintTile({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final cat = getCategoryById(complaint.category);
    final sc  = kStatusColors[complaint.status] ?? kStatusColors['Pending']!;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ComplaintDetailPage(docId: complaint.docId),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: cat.color, width: 4)),
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset:     const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(complaint.title,
                              style: const TextStyle(
                                  fontSize:   14,
                                  fontWeight: FontWeight.w600,
                                  color:      Color(0xFF1A1A2E))),
                        ),
                        _StatusChip(status: complaint.status),
                      ]),
                      const SizedBox(height: 6),
                      Text(
                        '${complaint.displayId} · ${complaint.formattedDate} · ${complaint.ward}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Text('📍 ', style: TextStyle(fontSize: 11)),
                        Expanded(
                          child: Text(complaint.location,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF6B7280))),
                        ),
                      ]),
                    ],
                  ),
                ),
                if (complaint.imageUrls.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: complaint.imageUrls.first,
                    width:  54,
                    height: 54,
                    fit:    BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width:  54,
                      height: 54,
                      color:  const Color(0xFFF3F4F6),
                      child:  const Center(
                        child: SizedBox(
                          width:  16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width:  54,
                      height: 54,
                      color:  const Color(0xFFF3F4F6),
                      child:  const Icon(Icons.broken_image_rounded,
                          size: 18, color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

            Row(children: [
              const Icon(Icons.touch_app_rounded,
                  size: 13, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              const Text('Tap to view & update',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              const Spacer(),
              _PriorityChip(priority: complaint.priority),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Analytics ────────────────────────────────────────────────────────────────
class _AdminAnalytics extends StatelessWidget {
  const _AdminAnalytics();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService().analyticsStream(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data       = snap.data!;
        final total      = data['total']      as int;
        final resolved   = data['resolved']   as int;
        final inProgress = data['inProgress'] as int;
        final pending    = data['pending']    as int;
        final byCategory = data['byCategory'] as List<Map<String, dynamic>>;
        final monthly    = data['monthly']    as List<int>;
        const months = ['J','F','M','A','M','J','J','A','S','O','N','D'];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analytics & Reports',
                  style: TextStyle(
                      fontSize:   22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Georgia')),
              const SizedBox(height: 4),
              const Text('Live data from Firestore',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(height: 18),

              // KPI tiles
              Row(children: [
                _AnalyticsKpi(
                    label: 'Resolution Rate',
                    value: total > 0
                        ? '${(resolved / total * 100).round()}%'
                        : '0%',
                    icon:  '✅',
                    color: const Color(0xFF27AE60)),
                const SizedBox(width: 12),
                _AnalyticsKpi(
                    label: 'Pending Rate',
                    value: total > 0
                        ? '${(pending / total * 100).round()}%'
                        : '0%',
                    icon:  '⏳',
                    color: const Color(0xFFE67E22)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _AnalyticsKpi(
                    label: 'In Progress',
                    value: '$inProgress',
                    icon:  '⚙️',
                    color: const Color(0xFF2980B9)),
                const SizedBox(width: 12),
                _AnalyticsKpi(
                    label: 'Total Filed',
                    value: '$total',
                    icon:  '📋',
                    color: AppTheme.navyPrimary),
              ]),
              const SizedBox(height: 20),

              // Monthly bar chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color:      Colors.black.withOpacity(0.06),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly Complaints',
                        style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Georgia')),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: monthly.asMap().entries.map((e) {
                          final max = monthly
                              .reduce((a, b) => a > b ? a : b)
                              .toDouble();
                          final pct = max > 0 ? e.value / max : 0.0;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (e.value > 0)
                                    Text('${e.value}',
                                        style: const TextStyle(
                                            fontSize: 8,
                                            color:    Color(0xFF9CA3AF))),
                                  const SizedBox(height: 2),
                                  Flexible(
                                    child: FractionallySizedBox(
                                      heightFactor: pct.toDouble(),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.navyPrimary
                                              .withOpacity(0.4 + pct * 0.5),
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(3)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(months[e.key],
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color:    Color(0xFF9CA3AF))),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // By category
              if (byCategory.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color:      Colors.black.withOpacity(0.06),
                          blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('By Category',
                          style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Georgia')),
                      const SizedBox(height: 14),
                      ...byCategory.map((item) {
                        final cat = getCategoryById(item['id'] as String);
                        final pct = item['pct'] as int;
                        final color = pct >= 80
                            ? const Color(0xFF27AE60)
                            : pct >= 60
                            ? const Color(0xFFE67E22)
                            : const Color(0xFFE74C3C);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(children: [
                            Row(children: [
                              Text(cat.icon,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(item['category'] as String,
                                      style: const TextStyle(
                                          fontSize:   13,
                                          fontWeight: FontWeight.w500))),
                              Text('${item['count']} total',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color:    Color(0xFF9CA3AF))),
                              const SizedBox(width: 8),
                              Text('$pct%',
                                  style: TextStyle(
                                      fontSize:   13,
                                      fontWeight: FontWeight.w700,
                                      color:      color)),
                            ]),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:           pct / 100,
                                backgroundColor: const Color(0xFFE8EDF5),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                minHeight: 8,
                              ),
                            ),
                          ]),
                        );
                      }),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsKpi extends StatelessWidget {
  final String label, value, icon;
  final Color  color;
  const _AnalyticsKpi(
      {required this.label,
        required this.value,
        required this.icon,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withOpacity(0.06),
                blurRadius: 10)
          ],
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    fontSize:   22,
                    fontWeight: FontWeight.w700,
                    color:      color,
                    fontFamily: 'Georgia')),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF6B7280))),
          ]),
        ]),
      ),
    );
  }
}

// ─── Shared chips ─────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final sc = kStatusColors[status] ?? kStatusColors['Pending']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: sc.bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width:  6,
            height: 6,
            decoration: BoxDecoration(color: sc.dot, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(status,
            style: TextStyle(
                color:      sc.text,
                fontSize:   11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String priority;
  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = kPriorityColors[priority] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(priority.toUpperCase(),
          style: TextStyle(
              color:       color,
              fontSize:    9,
              fontWeight:  FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}