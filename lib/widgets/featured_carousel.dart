import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/channel.dart';
import '../store/channel_store.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import 'live_badge.dart';
import '../screens/player_screen.dart';

/// Auto-scrolling hero banner with featured channels.
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final _pageCtrl = PageController(viewportFraction: 0.88);
  int _page = 0;
  int _count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageCtrl.hasClients || _count == 0 || !mounted) return;
      _pageCtrl.animateToPage(
        (_page + 1) % _count,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ChannelStore>().featured;
    _count = items.length;
    if (items.isEmpty) return const SizedBox.shrink();
    if (_page >= items.length) _page = 0;
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _heroCard(context, items[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _page == i ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _page == i ? AppColors.sky : Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _heroCard(BuildContext context, Channel c) {
    return GestureDetector(
      onTap: () {
        context.read<ChannelStore>().addRecent(c);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen(channel: c)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surface,
          border: Border.all(color: Colors.white.withValues(alpha: 20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (c.logoUrl.isNotEmpty)
              Image.network(
                c.logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _heroFallback(c),
              )
            else
              _heroFallback(c),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 224)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const Positioned(
              top: 12,
              left: 12,
              child: LiveBadge(),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.headerGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sky.withValues(alpha: 102),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroFallback(Channel c) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: CategoryStyle.gradientFor(c.category),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          CategoryStyle.emojiFor(c.category),
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }
}
