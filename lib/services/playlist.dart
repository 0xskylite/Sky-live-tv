import '../models/channel.dart';

/// Minimal M3U parser: reads #EXTINF entries (name, tvg-logo, group-title)
/// followed by the stream URL on the next line.
List<Channel> parseM3U(String text) {
  final channels = <Channel>[];
  final lines = text.split(RegExp(r'\r?\n'));

  String? name;
  var logo = '';
  var group = '';

  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('#EXTINF')) {
      final nameMatch = RegExp(r',([^,]*)$').firstMatch(line);
      name = (nameMatch?.group(1) ?? 'Unknown').trim();
      logo = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line)?.group(1) ?? '';
      group =
          RegExp(r'group-title="([^"]*)"').firstMatch(line)?.group(1) ?? '';
    } else if (line.isNotEmpty && !line.startsWith('#') && name != null) {
      final cat = group.isEmpty ? 'Imported' : group;
      channels.add(Channel(
        id: 'imp_${DateTime.now().millisecondsSinceEpoch}_${channels.length}',
        name: name,
        category: cat,
        logoUrl: logo,
        streamUrl: line,
        isKids: cat.toLowerCase().contains('kid'),
      ));
      name = null;
      logo = '';
      group = '';
    }
  }
  return channels;
}
