import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../services/ads_service.dart';

/// شريط إعلان بانر ثابت أسفل الشاشة، لا يظهر إلا بعد جاهزية التهيئة
/// ويتم إخفاؤه تلقائيًا بهدوء في حال فشل التحميل بدل ترك مساحة فارغة مزعجة.
class BannerAdBar extends StatefulWidget {
  const BannerAdBar({super.key});

  @override
  State<BannerAdBar> createState() => _BannerAdBarState();
}

class _BannerAdBarState extends State<BannerAdBar> {
  bool _failed = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      alignment: Alignment.center,
      child: UnityBannerAd(
        placementId: AdIds.banner,
        onLoad: (placementId) {},
        onClick: (placementId) {},
        onShown: (placementId) {},
        onFailed: (placementId, error, message) {
          if (mounted) setState(() => _failed = true);
        },
      ),
    );
  }
}
