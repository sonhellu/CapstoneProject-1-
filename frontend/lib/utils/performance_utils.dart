import 'package:flutter/material.dart';

/// Performance utilities for optimization
class PerformanceUtils {
  /// Debounce function calls
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    Future.delayed(delay, callback);
  }
  
  /// Throttle function calls
  static DateTime? _lastCallTime;
  static void throttle(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    final now = DateTime.now();
    if (_lastCallTime == null || 
        now.difference(_lastCallTime!) > duration) {
      _lastCallTime = now;
      callback();
    }
  }
  
  /// Check if widget is visible in viewport
  static bool isWidgetVisible(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    
    return offset.dy + size.height > 0 && 
           offset.dy < screenSize.height;
  }
  
  /// Preload images
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    for (final url in imageUrls) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (e) {
        debugPrint('Failed to preload image: $url');
      }
    }
  }
}

/// Lazy loading widget wrapper
class LazyLoadWidget extends StatefulWidget {
  final Widget child;
  final double threshold;
  
  const LazyLoadWidget({
    super.key,
    required this.child,
    this.threshold = 200.0,
  });
  
  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }
  
  void _checkVisibility() {
    if (mounted && PerformanceUtils.isWidgetVisible(context)) {
      setState(() {
        _isVisible = true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return SizedBox(
        height: widget.threshold,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return widget.child;
  }
}

