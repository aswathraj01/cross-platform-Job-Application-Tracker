import 'package:flutter/material.dart';

/// Ad banner widget — stub for web deployment (no mobile ads).
/// On Android, you can re-add google_mobile_ads and restore this widget.
class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // No ads for web PWA deployment
    return const SizedBox.shrink();
  }
}
