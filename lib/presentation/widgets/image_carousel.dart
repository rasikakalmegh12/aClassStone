import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Lightweight replacement for `carousel_slider` using [PageView].
///
/// Supports:
/// - items or builder constructor
/// - autoPlay with configurable interval & animation
/// - infinite scroll (by mapping indices)
/// - controller (next/prev/jump)
class ImageCarouselController {
  _ImageCarouselState? _state;

  bool get attached => _state != null;

  Future<void> nextPage({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.ease}) async {
    return _state?._nextPage(duration: duration, curve: curve) ?? Future.value();
  }

  Future<void> previousPage({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.ease}) async {
    return _state?._previousPage(duration: duration, curve: curve) ?? Future.value();
  }

  void jumpToPage(int page) {
    _state?._jumpToPage(page);
  }

  Future<void> animateToPage(int page, {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.ease}) async {
    return _state?._animateToPage(page, duration: duration, curve: curve) ?? Future.value();
  }
}

class ImageCarousel extends StatefulWidget {
  final List<Widget>? items;
  final IndexedWidgetBuilder? itemBuilder;
  final int? itemCount;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enableInfiniteScroll;
  final double viewportFraction;
  final double? height;
  final ImageCarouselController? controller;

  const ImageCarousel({
    super.key,
    required this.items,
    this.itemBuilder,
    this.itemCount,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enableInfiniteScroll = true,
    this.viewportFraction = 1.0,
    this.height,
    this.controller,
  }) : assert(items != null || (itemBuilder != null && itemCount != null));

  ImageCarousel.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enableInfiniteScroll = true,
    this.viewportFraction = 1.0,
    this.height,
    this.controller,
  }) : items = null;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _realPage = 0;

  int get _itemCount => widget.items?.length ?? widget.itemCount!;

  int _initialPageForInfinite() => widget.enableInfiniteScroll ? (_itemCount * 1000) : 0;

  @override
  void initState() {
    super.initState();
    final initial = _initialPageForInfinite();
    _realPage = initial;
    _pageController = PageController(viewportFraction: widget.viewportFraction, initialPage: initial);
    widget.controller?._state = this;
    if (widget.autoPlay) _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay) {
      if (widget.autoPlay)
        _startAutoPlay();
      else
        _stopAutoPlay();
    }
    widget.controller?._state = this;
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (_) async {
      if (!mounted) return;
      try {
        await _nextPage();
      } catch (_) {}
    });
  }

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _nextPage({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.ease}) async {
    if (_itemCount == 0) return;
    await _pageController.nextPage(duration: duration, curve: curve);
  }

  Future<void> _previousPage({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.ease}) async {
    if (_itemCount == 0) return;
    await _pageController.previousPage(duration: duration, curve: curve);
  }

  void _jumpToPage(int page) {
    if (_itemCount == 0) return;
    final base = widget.enableInfiniteScroll ? _initialPageForInfinite() : 0;
    _pageController.jumpToPage(base + (page % _itemCount));
  }

  Future<void> _animateToPage(int page, {Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.ease}) async {
    if (_itemCount == 0) return;
    final base = widget.enableInfiniteScroll ? _initialPageForInfinite() : 0;
    await _pageController.animateToPage(base + (page % _itemCount), duration: duration, curve: curve);
  }

  @override
  void dispose() {
    _stopAutoPlay();
    widget.controller?._state = null;
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? MediaQuery.of(context).size.width * 9 / 16;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final effectiveIndex = _itemCount == 0 ? 0 : index % _itemCount;
              if (widget.items != null) return widget.items![effectiveIndex];
              return widget.itemBuilder!(context, effectiveIndex);
            },
            itemCount: widget.enableInfiniteScroll ? null : _itemCount,
            onPageChanged: (index) {
              setState(() {
                _realPage = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        if (_itemCount > 1)
          SmoothPageIndicator(
            controller: _pageController,
            count: _itemCount,
            effect: const WormEffect(dotHeight: 8, dotWidth: 8),
            onDotClicked: (i) {
              _animateToPage(i);
            },
          ),
      ],
    );
  }
}

