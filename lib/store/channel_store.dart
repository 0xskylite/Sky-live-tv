import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel.dart';
import '../data/playlist_channels.dart';

/// App-wide state: channel list, favorites, recents, kids mode, search,
/// M3U imports. Favorites / recents / kids-mode persist on device.
class ChannelStore extends ChangeNotifier {
  static const _kFavs = 'skylive_favs';
  static const _kRecents = 'skylive_recents';
  static const _kKids = 'skylive_kids_mode';
  static const _kMaxRecents = 12;

  final List<Channel> _channels = List.of(playlistChannels);
  final List<String> _recentIds = [];
  bool _kidsOnly = false;
  bool _ready = false;

  ChannelStore() {
    _restore();
  }

  bool get ready => _ready;
  bool get kidsOnly => _kidsOnly;

  /// Channels visible right now (kids-mode filter applied).
  List<Channel> get channels => _kidsOnly
      ? _channels.where((c) => c.isKids).toList()
      : List.unmodifiable(_channels);

  List<Channel> get favorites {
    final favs = _channels.where((c) => c.isFavorite);
    return _kidsOnly ? favs.where((c) => c.isKids).toList() : favs.toList();
  }

  List<Channel> get recents {
    final out = <Channel>[];
    for (final id in _recentIds) {
      for (final c in _channels) {
        if (c.id == id && (!_kidsOnly || c.isKids)) {
          out.add(c);
          break;
        }
      }
    }
    return out;
  }

  List<Channel> get featured {
    final marked = channels.where((c) => c.isFeatured).toList();
    if (marked.isNotEmpty) return marked;
    return channels.take(5).toList();
  }

  /// Category names, alphabetically.
  List<String> get categories {
    final cats = <String>[];
    for (final c in channels) {
      if (!cats.contains(c.category)) cats.add(c.category);
    }
    cats.sort();
    return cats;
  }

  List<Channel> byCategory(String cat) =>
      channels.where((c) => c.category == cat).toList();

  List<Channel> search(String q) {
    final needle = q.trim().toLowerCase();
    if (needle.isEmpty) return [];
    return channels
        .where((c) => c.name.toLowerCase().contains(needle))
        .toList();
  }

  void toggleFavorite(Channel c) {
    c.isFavorite = !c.isFavorite;
    notifyListeners();
    _persistFavs();
  }

  void addRecent(Channel c) {
    _recentIds.remove(c.id);
    _recentIds.insert(0, c.id);
    if (_recentIds.length > _kMaxRecents) {
      _recentIds.removeRange(_kMaxRecents, _recentIds.length);
    }
    notifyListeners();
    _persistRecents();
  }

  void clearRecents() {
    _recentIds.clear();
    notifyListeners();
    _persistRecents();
  }

  Future<void> setKidsOnly(bool value) async {
    if (_kidsOnly == value) return;
    _kidsOnly = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kKids, value);
    } catch (_) {}
  }

  void addAll(List<Channel> items) {
    _channels.addAll(items);
    notifyListeners();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _kidsOnly = prefs.getBool(_kKids) ?? false;
      final favIds = prefs.getStringList(_kFavs) ?? const <String>[];
      if (favIds.isNotEmpty) {
        for (final c in _channels) {
          if (favIds.contains(c.id)) c.isFavorite = true;
        }
      }
      _recentIds
        ..clear()
        ..addAll(prefs.getStringList(_kRecents) ?? const <String>[]);
    } catch (_) {
      // Storage unavailable — run fully in-memory.
    }
    _ready = true;
    notifyListeners();
  }

  void _persistFavs() {
    final ids = _channels.where((c) => c.isFavorite).map((c) => c.id).toList();
    SharedPreferences.getInstance()
        .then((p) => p.setStringList(_kFavs, ids))
        .catchError((_) => false);
  }

  void _persistRecents() {
    final ids = List<String>.of(_recentIds);
    SharedPreferences.getInstance()
        .then((p) => p.setStringList(_kRecents, ids))
        .catchError((_) => false);
  }
}
