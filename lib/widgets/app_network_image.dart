import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';
import '../services/image_cache_service.dart';

/// Resilient, bounded network image widget designed to prevent CanvasKit
/// GPU texture budget exhaustion, image decode thrashing, and black-box artifacts.
class AppNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int maxRetries;
  final Duration initialRetryDelay;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.placeholder,
    this.errorWidget,
    this.maxRetries = 3,
    this.initialRetryDelay = const Duration(milliseconds: 1000),
  });

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  int _retryAttempt = 0;
  bool _isRetrying = false;
  Timer? _retryTimer;
  Key _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _resetRetryState();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.memCacheWidth != widget.memCacheWidth ||
        oldWidget.memCacheHeight != widget.memCacheHeight) {
      _retryTimer?.cancel();
      _resetRetryState();
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _resetRetryState() {
    _retryAttempt = 0;
    _isRetrying = false;
    _imageKey = UniqueKey();
  }

  void _scheduleRetry() {
    if (!mounted || _isRetrying) return;
    if (_retryAttempt < widget.maxRetries) {
      _retryAttempt++;
      setState(() {
        _isRetrying = true;
      });

      _retryTimer?.cancel();
      final delay = widget.initialRetryDelay * _retryAttempt;
      _retryTimer = Timer(delay, () async {
        if (!mounted) return;
        await _evictCache();

        if (mounted) {
          setState(() {
            _isRetrying = false;
            _imageKey = UniqueKey();
          });
        }
      });
    }
  }

  Future<void> _evictCache() async {
    try {
      await AppImageCacheManager.instance.removeFile(widget.imageUrl);
      await CachedNetworkImage.evictFromCache(
        widget.imageUrl,
        cacheManager: AppImageCacheManager.instance,
      );
      PaintingBinding.instance.imageCache.evict(NetworkImage(widget.imageUrl));
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }

  void _manualRetry() async {
    _retryTimer?.cancel();
    await _evictCache();
    if (mounted) {
      setState(() {
        _retryAttempt = 0;
        _isRetrying = false;
        _imageKey = UniqueKey();
      });
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (widget.placeholder != null) return widget.placeholder!;
    return Shimmer.fromColors(
      baseColor: AppColors.of(context).surface,
      highlightColor: AppColors.of(context).glassBorder,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.of(context).surface,
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    if (widget.errorWidget != null) return widget.errorWidget!;
    final isCompact = (widget.height != null && widget.height! < 60) ||
        (widget.width != null && widget.width! < 60);

    return GestureDetector(
      onTap: _manualRetry,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.of(context).surface,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              color: AppColors.of(context).textSecondary,
              size: isCompact ? 18 : 26,
            ),
            if (!isCompact) ...[
              const SizedBox(height: 4),
              Text(
                'Tap to retry',
                style: TextStyle(
                  color: AppColors.of(context).textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.trim().isEmpty) {
      return _buildError(context);
    }

    // Bound image decode dimensions to protect CanvasKit's WebGL texture budget.
    // CRITICAL: We only constrain ONE dimension (width by default) and leave the other
    // null. In Flutter's ResizeImage, specifying both dimensions forces ResizeImagePolicy.exact,
    // which distorts/squishes the decoded bitmap. Leaving one dimension null guarantees that
    // ResizeImage preserves the intrinsic aspect ratio of the image.
    int? resolvedCacheWidth;
    int? resolvedCacheHeight;

    if (widget.memCacheWidth != null) {
      resolvedCacheWidth = widget.memCacheWidth;
      resolvedCacheHeight = null;
    } else if (widget.memCacheHeight != null) {
      resolvedCacheHeight = widget.memCacheHeight;
      resolvedCacheWidth = null;
    } else if (widget.width != null && widget.width! > 0) {
      resolvedCacheWidth = (widget.width! * 2.0).round().clamp(100, 1200);
      resolvedCacheHeight = null;
    } else if (widget.height != null && widget.height! > 0) {
      resolvedCacheHeight = (widget.height! * 2.0).round().clamp(100, 1200);
      resolvedCacheWidth = null;
    } else {
      // Safe default ceiling: bounds decode width to 800 while preserving aspect ratio
      resolvedCacheWidth = 800;
      resolvedCacheHeight = null;
    }

    // On Flutter Web, use HttpGet so dimensions are respected by ResizeImage
    // and bytes are downloaded via the single shared cache manager.
    // If subsequent retries occur, fallback to HtmlImage in case of host CORS issues.
    final webRenderMethod = (!kIsWeb || _retryAttempt >= 2)
        ? ImageRenderMethodForWeb.HtmlImage
        : ImageRenderMethodForWeb.HttpGet;

    Widget content;
    if (_isRetrying) {
      content = _buildPlaceholder(context);
    } else {
      content = CachedNetworkImage(
        key: _imageKey,
        imageUrl: widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheManager: AppImageCacheManager.instance,
        memCacheWidth: resolvedCacheWidth,
        memCacheHeight: resolvedCacheHeight,
        maxWidthDiskCache: resolvedCacheWidth,
        maxHeightDiskCache: resolvedCacheHeight,
        imageRenderMethodForWeb: webRenderMethod,
        fadeInDuration: const Duration(milliseconds: 120),
        fadeOutDuration: const Duration(milliseconds: 80),
        useOldImageOnUrlChange: false,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) {
          if (_retryAttempt < widget.maxRetries) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scheduleRetry();
            });
            return _buildPlaceholder(context);
          }
          return _buildError(context);
        },
      );
    }

    if (widget.shape == BoxShape.circle) {
      return ClipOval(child: content);
    }

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }
}
