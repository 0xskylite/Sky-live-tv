/// A single channel / video source in the catalog.
class Channel {
  final String id;
  final String name;
  final String category;
  final String logoUrl;
  final String streamUrl; // HLS (.m3u8) or mp4 URL. Empty = not linked yet.
  final bool isKids;
  final bool isFeatured;
  bool isFavorite;

  Channel({
    required this.id,
    required this.name,
    required this.category,
    this.logoUrl = '',
    this.streamUrl = '',
    this.isKids = false,
    this.isFeatured = false,
    this.isFavorite = false,
  });
}
