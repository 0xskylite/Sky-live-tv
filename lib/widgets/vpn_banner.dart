import 'package:flutter/material.dart';

import '../services/vpn_helper.dart';
import '../theme/app_theme.dart';

/// Slim banner shown on Home when the VPN helper is enabled and no
/// VPN tunnel looks active. One tap opens the user's VPN app.
class VpnBanner extends StatefulWidget {
  const VpnBanner({super.key});

  @override
  State<VpnBanner> createState() => _VpnBannerState();
}

class _VpnBannerState extends State<VpnBanner> {
  bool? _vpnOn; // null = still checking / unknown
  bool _enabled = true;
  String? _package;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final enabled = await VpnHelper.isEnabled();
    final pkg = await VpnHelper.getPackage();
    final on = await VpnHelper.isVpnActive();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _package = pkg;
      _vpnOn = on;
    });
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _VpnSettingsSheet(
        onSaved: _refresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hidden while checking, when disabled, when VPN is on,
    // or when detection failed (don't nag on unknown).
    if (!_enabled || _vpnOn != false) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1F0A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF8A6D1B).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.vpn_lock_rounded, color: Color(0xFFFFC53D), size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'VPN বন্ধ আছে — কিছু channel চলবে না',
                style: TextStyle(color: Color(0xFFFFE1A8), fontSize: 13),
              ),
            ),
            if (_package != null)
              TextButton(
                onPressed: () => VpnHelper.openVpnApp(_package!),
                child: const Text('VPN খোলো',
                    style: TextStyle(color: Color(0xFFFFC53D))),
              )
            else
              TextButton(
                onPressed: _openSettings,
                child: const Text('সেট করো',
                    style: TextStyle(color: Color(0xFFFFC53D))),
              ),
            IconButton(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings_outlined,
                  color: Color(0xFFFFE1A8), size: 20),
              tooltip: 'VPN সেটিংস',
            ),
          ],
        ),
      ),
    );
  }
}

class _VpnSettingsSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _VpnSettingsSheet({required this.onSaved});

  @override
  State<_VpnSettingsSheet> createState() => _VpnSettingsSheetState();
}

class _VpnSettingsSheetState extends State<_VpnSettingsSheet> {
  bool _enabled = true;
  String? _selected;
  final _customCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await VpnHelper.isEnabled();
    final pkg = await VpnHelper.getPackage();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      if (pkg != null && VpnHelper.presets.containsKey(pkg)) {
        _selected = pkg;
      } else if (pkg != null) {
        _customCtrl.text = pkg;
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pkg = _selected ?? _customCtrl.text.trim();
    await VpnHelper.setEnabled(_enabled);
    if (pkg.isNotEmpty) await VpnHelper.setPackage(pkg);
    widget.onSaved();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('VPN Helper',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'তোমার VPN app বেছে নাও — VPN বন্ধ থাকলে এক tap-এ app খুলে যাবে।',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('VPN helper চালু'),
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                  const Text('VPN app:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: VpnHelper.presets.entries.map((e) {
                      final sel = _selected == e.key;
                      return ChoiceChip(
                        label: Text(e.value),
                        selected: sel,
                        onSelected: (_) => setState(() {
                          _selected = e.key;
                          _customCtrl.clear();
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _customCtrl,
                    onChanged: (_) => setState(() => _selected = null),
                    decoration: const InputDecoration(
                      labelText: 'অন্য app হলে package name লেখো',
                      hintText: 'যেমন: com.example.myvpn',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('সেভ করো'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
