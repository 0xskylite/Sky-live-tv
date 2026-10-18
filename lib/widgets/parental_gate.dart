import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Simple parental gate: answer a small arithmetic question
/// to switch Kids Mode off. Pops `true` when answered correctly.
class ParentalGateDialog extends StatefulWidget {
  const ParentalGateDialog({super.key});

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late final int _a;
  late final int _b;
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = Random();
    _a = 4 + r.nextInt(9);
    _b = 3 + r.nextInt(9);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _check() {
    final answer = int.tryParse(_ctrl.text.trim());
    if (answer == _a + _b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _error = 'উত্তর ভুল হয়েছে, আবার চেষ্টা করো।');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.sky),
          SizedBox(width: 8),
          Text('প্যারেন্টাল গেট', style: TextStyle(fontSize: 17)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kids Mode বন্ধ করতে নিচের যোগটা করো:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '$_a + $_b = ?',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            onSubmitted: (_) => _check(),
            decoration: const InputDecoration(hintText: 'উত্তর লেখো'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.live, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'বাতিল',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _check,
          child: const Text('যাচাই করো'),
        ),
      ],
    );
  }
}
