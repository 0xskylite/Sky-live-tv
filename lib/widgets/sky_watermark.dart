import 'package:flutter/material.dart';

/// "Sky Tv" watermark with the app icon — overlaid on the video player
/// while streaming.
class SkyWatermark extends StatelessWidget {
  const SkyWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 16,
                height: 16,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Sky Tv',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
