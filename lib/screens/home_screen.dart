import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/channel.dart';
import '../store/channel_store.dart';
import '../services/playlist.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import '../widgets/channel_card.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/parental_gate.dart';
import '../widgets/vpn_banner.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _query = '';
  String? _selectedCat;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Grid columns that grow with screen width (phones 3, tablets more).
  int _gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w / 170).floor().clamp(2, 6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildBody(context.watch<ChannelStore>()),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: AppColors.navSurface,
        indicatorColor: AppColors.sky.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'পছন্দ',
          ),
          NavigationDestination(
            icon: Icon(Icons.file_download_outlined),
            selectedIcon: Icon(Icons.file_download_rounded),
            label: 'ইমপোর্ট',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChannelStore store) {
    switch (_tab) {
      case 0:
        return _homeTab(store);
      case 1:
        return _favoritesTab(store);
      default:
        return const _ImportTab();
    }
  }

  // ---------------- Home ----------------
  Widget _homeTab(ChannelStore store) {
    final searching = _query.trim().isNotEmpty;
    final recents = store.recents;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(store)),
        const SliverToBoxAdapter(child: VpnBanner()),
        SliverToBoxAdapter(child: _categoryChips(store)),
        if (searching) ...[
          SliverToBoxAdapter(child: _searchMeta(store)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: _gridSliver(context, store.search(_query)),
          ),
        ] else if (_selectedCat != null) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: _gridSliver(context, store.byCategory(_selectedCat!)),
          ),
        ] else if (store.channels.isEmpty)
          SliverToBoxAdapter(child: _kidsEmptyState())
        else ...[
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          const SliverToBoxAdapter(child: FeaturedCarousel()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          if (recents.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _sectionHeader('🕘 আবার দেখো', recents.length,
                  onClear: () => store.clearRecents(), clearLabel: 'মুছো'),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 172,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recents.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SizedBox(
                    width: 140,
                    child: ChannelCard(channel: recents[i]),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
          ],
          for (final cat in store.categories) ...[
            SliverToBoxAdapter(
              child: _sectionHeader(
                '${CategoryStyle.emojiFor(cat)} $cat',
                store.byCategory(cat).length,
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CategoryScreen(category: cat)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 172,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: store.byCategory(cat).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => SizedBox(
                    width: 140,
                    child: ChannelCard(channel: store.byCategory(cat)[i]),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 22)),
          ],
        ],
      ],
    );
  }

  Widget _kidsEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Kids Mode চালু আছে 🧒',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'এখনো কোনো kids চ্যানেল যোগ হয়নি।\n"ইমপোর্ট" ট্যাব থেকে kids গ্রুপের M3U প্লেলিস্ট যোগ করো।',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _header(ChannelStore store) {
    final kidsOn = store.kidsOnly;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sky.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.live_tv_rounded, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SKY LIVE',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        )),
                    SizedBox(height: 3),
                    Text('তোমার বিনোদন, এক জায়গায়',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
              // Kids-mode toggle with parental gate on switch-off.
              GestureDetector(
                onTap: () => _toggleKidsMode(store),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: kidsOn
                        ? AppColors.sky.withValues(alpha: 0.18)
                        : AppColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: kidsOn
                          ? AppColors.sky.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        kidsOn
                            ? Icons.shield_rounded
                            : Icons.shield_outlined,
                        color:
                            kidsOn ? AppColors.sky : AppColors.textSecondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'KIDS',
                        style: TextStyle(
                          color: kidsOn
                              ? AppColors.sky
                              : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: AppColors.live, size: 7),
                      SizedBox(width: 6),
                      Text('LIVE',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          )),
                    ]),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(_greeting(),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w800,
                height: 1.15,
              )),
          const SizedBox(height: 7),
          const Text('লাইভ চ্যানেল খুঁজে নাও এবং উপভোগ করো',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              )),
          const SizedBox(height: 17),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    ),
              hintText: 'চ্যানেল, স্পোর্টস, মুভি খুঁজো...',
              filled: true,
              fillColor: AppColors.searchSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.04)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: AppColors.sky, width: 1.2),
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ],
      ),
    );
  }

  /// Time-aware Bengali greeting for the home header.
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 4) return 'শুভ রাত্রি 🌙';
    if (h < 12) return 'শুভ সকাল ☀️';
    if (h < 16) return 'শুভ দুপুর 🌤️';
    if (h < 19) return 'শুভ বিকাল 🌇';
    return 'শুভ সন্ধ্যা 🌃';
  }

  /// Horizontal category filter chips under the search bar.
  Widget _categoryChips(ChannelStore store) {
    final cats = store.categories;
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
        itemCount: cats.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = i == 0 ? null : cats[i - 1];
          final selected = _selectedCat == cat;
          final label =
              cat == null ? '✨ সব' : '${CategoryStyle.emojiFor(cat)} $cat';
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.headerGradient : null,
                color: selected ? null : AppColors.surface2,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.06),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.sky.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// "Nটি চ্যানেল পাওয়া গেছে" line above search results.
  Widget _searchMeta(ChannelStore store) {
    final n = store.search(_query).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
      child: Text(
        n == 0 ? 'কিছু পাওয়া যায়নি' : '$nটি চ্যানেল পাওয়া গেছে',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _toggleKidsMode(ChannelStore store) async {
    if (store.kidsOnly) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => const ParentalGateDialog(),
      );
      if (ok == true && mounted) {
        await store.setKidsOnly(false);
      }
    } else {
      await store.setKidsOnly(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🧒 Kids Mode চালু — শুধু kids চ্যানেল দেখা যাবে'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _sectionHeader(String title, int count,
      {VoidCallback? onClear, String? clearLabel, VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'সব দেখো',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sky,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.sky,
                  ),
                ],
              ),
            ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                clearLabel ?? 'মুছো',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gridSliver(BuildContext context, List<Channel> items) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'কিছু পাওয়া যায়নি 🔍',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ),
      );
    }
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridColumns(context),
        childAspectRatio: 0.78,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => ChannelCard(channel: items[i]),
    );
  }

  // ---------------- Favorites ----------------
  Widget _favoritesTab(ChannelStore store) {
    final favs = store.favorites;
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'পছন্দের চ্যানেল',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (favs.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'এখনো পছন্দের চ্যানেল নেই\n❤️ চাপ দিয়ে যোগ করো!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: _gridSliver(context, favs),
          ),
      ],
    );
  }
}

// ---------------- Import (M3U) ----------------
class _ImportTab extends StatefulWidget {
  const _ImportTab();

  @override
  State<_ImportTab> createState() => _ImportTabState();
}

class _ImportTabState extends State<_ImportTab> {
  final _ctrl = TextEditingController();
  String _msg = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.file_download_rounded, color: Colors.white, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M3U প্লেলিস্ট ইমপোর্ট',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'নিজের চ্যানেল যোগ করো',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'তোমার বৈধ স্ট্রিম সোর্সের M3U টেক্সট নিচে পেস্ট করো। group-title দিলে সেই নামে ক্যাটাগরি হবে; গ্রুপের নামে "kid" থাকলে সেটা Kids Mode-এ দেখা যাবে।',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          maxLines: 8,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText:
                '#EXTM3U\n#EXTINF:-1 group-title="Sports",My Channel\nhttps://...',
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          icon: const Icon(Icons.download_rounded),
          label: const Text('ইমপোর্ট করো'),
          onPressed: () {
            final items = parseM3U(_ctrl.text);
            if (items.isEmpty) {
              setState(() => _msg = 'কোনো চ্যানেল পাওয়া যায়নি।');
              return;
            }
            context.read<ChannelStore>().addAll(items);
            setState(() {
              _msg = '✅ ${items.length}টি চ্যানেল যোগ হয়েছে!';
              _ctrl.clear();
            });
          },
        ),
        if (_msg.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _msg,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.sky,
            ),
          ),
        ],
      ],
    );
  }
}
