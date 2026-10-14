import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Centralized, single shared cache manager for all network images.
/// Prevents ad-hoc cache manager creation and bounds cache size.
class AppImageCacheManager {
  static const String key = 'nis_app_image_cache';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );
}
