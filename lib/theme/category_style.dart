import 'package:flutter/material.dart';

/// Single source of truth for per-category visuals:
/// section-header emoji + fallback-card gradient.
class CategoryStyle {
  static const Map<String, String> _emoji = {
    'SPORTS': '⚽',
    'BANGLADESH': '🇧🇩',
    'INDIAN BANGLA': '🎭',
    'HINDI': '📺',
    'HINDI MOVIE': '🎬',
    'HINDI MUSIC': '🎵',
    'BANGLA MUSIC': '🎶',
    'ENGLISH MOVIES': '🎞️',
    'DOCUMENTARY': '🔍',
    'ISLAMIC': '☪️',
    'NEWS INTERNASIONAL': '🌍',
    'KIDS': '🧒',
    'KIDS MUSIC': '🎶',
    'MOVIES': '🎬',
    'NEWS': '📰',
    'MUSIC': '🎵',
    'ENTERTAINMENT': '🎪',
    'IMPORTED': '📥',
    'অন্যান্য': '📺',
  };

  static String emojiFor(String category) =>
      _emoji[category.toUpperCase()] ?? '📺';

  static const Map<String, List<Color>> _gradients = {
    'SPORTS': [Color(0xFF0EA5E9), Color(0xFF1D4ED8)],
    'BANGLADESH': [Color(0xFF059669), Color(0xFFDC2626)],
    'INDIAN BANGLA': [Color(0xFFA855F7), Color(0xFF6D28D9)],
    'HINDI': [Color(0xFFF59E0B), Color(0xFFEA580C)],
    'HINDI MOVIE': [Color(0xFFEF4444), Color(0xFF7F1D1D)],
    'HINDI MUSIC': [Color(0xFFEC4899), Color(0xFF9D174D)],
    'BANGLA MUSIC': [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
    'ENGLISH MOVIES': [Color(0xFF38BDF8), Color(0xFF1E3A8A)],
    'DOCUMENTARY': [Color(0xFF10B981), Color(0xFF065F46)],
    'ISLAMIC': [Color(0xFF14B8A6), Color(0xFF0F766E)],
    'NEWS INTERNASIONAL': [Color(0xFFF43F5E), Color(0xFF881337)],
    'KIDS': [Color(0xFFFFB347), Color(0xFFFF5E8A)],
  };

  static const _fallbackGradient = [
    Color(0xFF1A263B),
    Color(0xFF111A2B),
  ];

  static List<Color> gradientFor(String category) =>
      _gradients[category.toUpperCase()] ?? _fallbackGradient;
}
