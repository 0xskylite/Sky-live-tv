import '../models/channel.dart';

// Free, legal sample streams used for demo channels marked "(Sample)".
// Replace streamUrl values with your own / licensed sources.
const _bbb =
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
const _sintel =
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4';
const _bipbop =
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_hevc/master.m3u8';

/// Demo catalog. The Kids section is intentionally the biggest.
/// Channels with an empty streamUrl show an "add your stream" state in the player.
final List<Channel> demoCatalog = [
  // ---------- Kids (biggest section) ----------
  Channel(id: 'k1', name: 'Toon Time (Sample)', category: 'Kids', streamUrl: _bbb, isKids: true),
  Channel(id: 'k2', name: 'Kids Cinema (Sample)', category: 'Kids', streamUrl: _sintel, isKids: true),
  Channel(id: 'k3', name: 'Cartoon Club', category: 'Kids', isKids: true),
  Channel(id: 'k4', name: 'Rhymes & Songs', category: 'Kids', isKids: true),
  Channel(id: 'k5', name: 'Learn & Play', category: 'Kids', isKids: true),
  Channel(id: 'k6', name: 'Bedtime Stories', category: 'Kids', isKids: true),
  Channel(id: 'k7', name: 'Animal Friends', category: 'Kids', isKids: true),
  Channel(id: 'k8', name: 'Super Toons', category: 'Kids', isKids: true),
  Channel(id: 'k9', name: 'Kids Puzzles', category: 'Kids', isKids: true),
  // ---------- Sports ----------
  Channel(id: 's1', name: 'Football Live', category: 'Sports'),
  Channel(id: 's2', name: 'Cricket Zone', category: 'Sports'),
  Channel(id: 's3', name: 'Sports Arena', category: 'Sports'),
  // ---------- Movies ----------
  Channel(id: 'm1', name: 'Movie Night (Sample)', category: 'Movies', streamUrl: _bipbop),
  Channel(id: 'm2', name: 'Cinema Hall', category: 'Movies'),
  Channel(id: 'm3', name: 'Classic Films', category: 'Movies'),
  // ---------- News ----------
  Channel(id: 'n1', name: 'News 24', category: 'News'),
  Channel(id: 'n2', name: 'World News', category: 'News'),
  // ---------- Entertainment ----------
  Channel(id: 'e1', name: 'Drama House', category: 'Entertainment'),
  Channel(id: 'e2', name: 'Comedy Club', category: 'Entertainment'),
  Channel(id: 'e3', name: 'Music Beats', category: 'Entertainment'),
];
