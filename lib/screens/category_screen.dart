import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/channel_store.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import '../widgets/channel_card.dart';

/// Full grid view of one category, opened from "সব দেখো".
class CategoryScreen extends StatelessWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  int _gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return (w / 170).floor().clamp(2, 6);
  }

  @override
  Widget build(BuildContext context) {
    final channels = context.watch<ChannelStore>().byCategory(category);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CategoryStyle.emojiFor(category),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                category,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
            child: Text(
              '${channels.length}টি চ্যানেল',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _gridColumns(context),
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: channels.length,
              itemBuilder: (_, i) => ChannelCard(channel: channels[i]),
            ),
          ),
        ],
      ),
    );
  }
}
