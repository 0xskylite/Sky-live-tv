import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/channel.dart';
import '../store/channel_store.dart';
import '../screens/player_screen.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import 'live_badge.dart';

/// Channel card: rounded dark card, logo art (or a per-category
/// gradient + emoji fallback), LIVE badge and favorite button overlaid.
/// Sizes itself to the parent — wrap in a SizedBox for fixed width.
class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ChannelStore>().addRecent(channel);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(channel: channel)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: SizedBox.expand(child: _logo()),
                  ),
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: LiveBadge(),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _FavButton(channel: channel),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Text(
                channel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    if (channel.logoUrl.isEmpty) return _fallback();
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(14),
      child: Image.network(
        channel.logoUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback(),
        loadingBuilder: (c, child, prog) => prog == null
            ? child
            : const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.sky,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _fallback() {
    final gradient = CategoryStyle.gradientFor(channel.category);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CategoryStyle.emojiFor(channel.category),
              style: const TextStyle(fontSize: 42),
            ),
            const SizedBox(height: 6),
            Text(
              channel.name.isNotEmpty ? channel.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  final Channel channel;

  const _FavButton({required this.channel});

  @override
  Widget build(BuildContext context) {
    final isFav = context.select<ChannelStore, bool>(
      (s) => s.channels.any((c) => c.id == channel.id && c.isFavorite),
    );
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.read<ChannelStore>().toggleFavorite(channel),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: isFav ? AppColors.live : Colors.white,
          ),
        ),
      ),
    );
  }
}
