import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smart VPN helper.
///
/// Android does not allow one app to start another app's VPN tunnel —
/// the tunnel itself must be connected inside the VPN app (system
/// consent is per-app). This helper removes the friction around that:
/// it detects when no VPN tunnel is up, shows a one-tap banner that
/// opens the user's VPN app, and suggests the VPN app when a stream
/// fails while the VPN is off.
class VpnHelper {
  static const _kEnabled = 'skylive_vpn_helper_enabled';
  static const _kPackage = 'skylive_vpn_package';

  /// Common VPN apps: package name -> display label.
  static const Map<String, String> presets = {
    'com.cloudflare.onedotonedotone': '1.1.1.1',
    'com.jrzheng.supervpnfree': 'SuperVPN',
    'com.free.piebridge.vpn': 'Turbo VPN',
    'ch.protonvpn.android': 'Proton VPN',
    'com.windscribe.vpn': 'Windscribe',
    'com.expressvpn.vpn': 'ExpressVPN',
    'com.nordvpn.android': 'NordVPN',
    'com.surfshark.vpnclient.android': 'Surfshark',
    'app.elevenvpn.android': 'ElevenVPN',
  };

  /// True when a tun/ppp interface exists (a VPN tunnel looks up),
  /// false when clearly off, null when detection failed.
  static Future<bool?> isVpnActive() async {
    try {
      final ifaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final i in ifaces) {
        final n = i.name.toLowerCase();
        if (n.startsWith('tun') ||
            n.startsWith('ppp') ||
            n.startsWith('tap') ||
            n.startsWith('utun')) {
          return true;
        }
      }
      return false;
    } catch (_) {
      return null;
    }
  }

  /// Opens the user's VPN app (its launcher activity) so they can
  /// connect with one more tap inside it.
  static Future<void> openVpnApp(String packageName) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: packageName.trim(),
    );
    await intent.launch();
  }

  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kEnabled) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, value);
  }

  static Future<String?> getPackage() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_kPackage);
    return (v == null || v.trim().isEmpty) ? null : v.trim();
  }

  static Future<void> setPackage(String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kPackage, value.trim());
  }
}
