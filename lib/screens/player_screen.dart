import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/channel.dart';
import '../store/channel_store.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import '../widgets/channel_card.dart';
import '../widgets/live_badge.dart';

/// Video player for HLS (.m3u8) and mp4 streams, with a channel
/// info card and related channels below the video.
class PlayerScreen extends StatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStream();
  }

  void _loadStream() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;

    final url = widget.channel.streamUrl.trim();
    if (url.isEmpty) {
      _error =
          'এই চ্যানেলের স্ট্রিম লিংক এখনো যোগ করা হয়নি।\n"ইমপোর্ট" ট্যাব থেকে M3U ইমপোর্ট করো।';
      _loading = false;
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _error = 'স্ট্রিম লিংকটি সঠিক নয়।';
      _loading = false;
      return;
    }
    _error = null;
    _loading = true;
    _videoController = VideoPlayerController.networkUrl(uri);
    _videoController!
        .initialize()
        .then((_) {
          if (!mounted) return;
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: true,
            looping: false,
            allowFullScreen: true,
            allowMuting: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: AppColors.sky,
              handleColor: AppColors.sky,
              backgroundColor: Colors.white24,
              bufferedColor: Colors.white38,
            ),
          );
          setState(() => _loading = false);
        })
        .catchError((Object e) {
          if (!mounted) return;
          setState(() {
            _error = 'স্ট্রিম চালু করা যায়নি।\nইন্টারনেট চেক করে আবার চেষ্টা করো।';
            _loading = false;
          });
        });
  }

  void _retry() {
    // _loadStream resets error/loading synchronously, so one
    // setState around it is enough to refresh the UI.
    setState(_loadStream);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final related = context
        .watch<ChannelStore>()
        .byCategory(widget.channel.category)
        .where((c) => c.id != widget.channel.id)
        .take(10)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.channel.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const LiveBadge(),
          ],
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.09)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sky.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _playerArea()),
                      if (_error == null)
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: LiveBadge(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.bg,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _infoCard(context),
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const Text(
                      'একই ক্যাটাগরির আরও',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, i) => SizedBox(
                          width: 136,
                          child: ChannelCard(channel: related[i]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerArea() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_off_rounded,
              size: 52,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('আবার চেষ্টা করো'),
            ),
          ],
        ),
      );
    }
    if (_loading || _chewieController == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.sky),
          SizedBox(height: 12),
          Text('লোড হচ্ছে...', style: TextStyle(color: Colors.white54)),
        ],
      );
    }
    return Chewie(controller: _chewieController!);
  }

  Widget _infoCard(BuildContext context) {
    final store = context.watch<ChannelStore>();
    final isFav = store.channels
        .any((c) => c.id == widget.channel.id && c.isFavorite);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: CategoryStyle.gradientFor(widget.channel.category),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                CategoryStyle.emojiFor(widget.channel.category),
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.channel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.channel.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.surface2,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => store.toggleFavorite(widget.channel),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isFav ? AppColors.live : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
