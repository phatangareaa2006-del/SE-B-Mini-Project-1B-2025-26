import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class RegisterComplaintScreen extends StatefulWidget {
  final Function(Complaint) onSubmit;

  const RegisterComplaintScreen({super.key, required this.onSubmit});

  @override
  State<RegisterComplaintScreen> createState() =>
      _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState extends State<RegisterComplaintScreen> {
  String? _selectedCategory;
  String _priority = 'Medium';
  String _ward = 'Ward 1';
  bool _submitted = false;
  String _newId = '';

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  bool get _canSubmit =>
      _selectedCategory != null &&
      _titleCtrl.text.isNotEmpty &&
      _descCtrl.text.isNotEmpty &&
      _locationCtrl.text.isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    final id = 'CMP-2024-${DateTime.now().millisecondsSinceEpoch % 1000 + 6}';
    final c = Complaint(
      id: id,
      category: _selectedCategory!,
      title: _titleCtrl.text,
      description: _descCtrl.text,
      status: 'Pending',
      date: DateTime.now().toIso8601String().split('T').first,
      ward: _ward,
      priority: _priority,
      upvotes: 0,
      assignedTo: 'Unassigned',
      location: _locationCtrl.text,
    );
    widget.onSubmit(c);
    setState(() {
      _newId = id;
      _submitted = true;
    });
  }

  void _reset() {
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _titleCtrl.clear();
    _descCtrl.clear();
    _locationCtrl.clear();
    setState(() {
      _selectedCategory = null;
      _priority = 'Medium';
      _ward = 'Ward 1';
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _SuccessView(id: _newId, onFileAnother: _reset);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'File a Complaint',
                subtitle:
                    'Report a civic issue in your area. Fields marked * are required.',
              ),
              const SizedBox(height: 24),

              // ── Category ──────────────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Issue Category *',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                      children: categories.map((c) {
                        final selected = _selectedCategory == c.id;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = c.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? c.color.withOpacity(0.1)
                                  : const Color(0xFFFAFBFD),
                              border: Border.all(
                                color:
                                    selected ? c.color : const Color(0xFFE2E8F0),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.icon,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 6),
                                Text(c.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? c.color
                                            : const Color(0xFF4A5568),
                                        height: 1.2)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Personal + Complaint Details ──────────────────────────────
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: AppTextField(
                                label: 'Your Name',
                                placeholder: 'Full name',
                                controller: _nameCtrl)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: AppTextField(
                                label: 'Phone Number',
                                placeholder: '+91 XXXXX XXXXX',
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: 'Complaint Title *',
                        placeholder: 'Brief description of the issue',
                        controller: _titleCtrl),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Detailed Description *',
                      placeholder:
                          'Describe the issue in detail — when it started, severity, who it affects...',
                      controller: _descCtrl,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                              label: 'Location / Address *',
                              placeholder: 'Street, landmark, area...',
                              controller: _locationCtrl),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppDropdown<String>(
                            label: 'Ward Number',
                            value: _ward,
                            items: List.generate(
                                20,
                                (i) => DropdownMenuItem(
                                    value: 'Ward ${i + 1}',
                                    child: Text('Ward ${i + 1}'))),
                            onChanged: (v) =>
                                setState(() => _ward = v ?? _ward),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AppDropdown<String>(
                            label: 'Priority',
                            value: _priority,
                            items: ['Low', 'Medium', 'High', 'Critical']
                                .map((p) => DropdownMenuItem(
                                    value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _priority = v ?? _priority),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Attach Evidence ───────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attach Evidence',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFC5D2EA),
                            width: 2,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFAFBFD),
                      ),
                      child: const Column(
                        children: [
                          Text('📸',
                              style: TextStyle(fontSize: 36)),
                          SizedBox(height: 8),
                          Text('Tap to upload photos',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A5568))),
                          SizedBox(height: 4),
                          Text('JPG, PNG up to 10MB. Multiple files supported.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Actions ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(label: 'Clear Form', onTap: _reset),
                  const SizedBox(width: 12),
                  Opacity(
                    opacity: _canSubmit ? 1.0 : 0.5,
                    child: PrimaryButton(
                        label: 'Submit Complaint →', onTap: _submit),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Success View ─────────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String id;
  final VoidCallback onFileAnother;

  const _SuccessView({required this.id, required this.onFileAnother});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AppCard(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                      child:
                          Text('✓', style: TextStyle(fontSize: 32, color: Colors.white))),
                ),
                const SizedBox(height: 20),
                const Text('Complaint Registered!',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Georgia',
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                const Text(
                    'Your complaint has been submitted successfully and assigned to the relevant department.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    border: Border.all(
                        color: const Color(0xFFC5D2EA), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('YOUR COMPLAINT ID',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(id,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.navyPrimary,
                              fontFamily: 'Georgia')),
                      const SizedBox(height: 4),
                      const Text('Save this ID to track your complaint status',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrimaryButton(label: 'Track Status', onTap: () {}),
                    const SizedBox(width: 10),
                    SecondaryButton(
                        label: 'File Another', onTap: onFileAnother),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
