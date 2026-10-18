import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store/channel_store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SkyLiveTvApp());
}

class SkyLiveTvApp extends StatelessWidget {
  const SkyLiveTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChannelStore(),
      child: MaterialApp(
        title: 'Sky Live TV',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
