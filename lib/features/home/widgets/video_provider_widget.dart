import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme.dart';

class VideoProviderWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const VideoProviderWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<VideoProviderWidget> createState() => _VideoProviderWidgetState();
}

class _VideoProviderWidgetState extends State<VideoProviderWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      log('Error initializing video player: $e');
    }
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void didUpdateWidget(VideoProviderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _isInitialized = false;
      _isPlaying = false;
      _initializeController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _togglePlay,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail shown initially and while video is loading/paused
            if (widget.thumbnailUrl != null)
              Image.network(
                widget.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.white.withAlpha(5)),
              ),

            // Video Player
            if (_isInitialized)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _isPlaying ? 1.0 : 0.0,
                child: SizedOverflowBox(
                  size: Size.infinite,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              ),

            // Overlay with Play/Pause Button
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: (!_isPlaying || _isHovered) ? 1.0 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha(60),
                      Colors.transparent,
                      Colors.black.withAlpha(60),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isPlaying ? 30 : 50,
                    height: _isPlaying ? 30 : 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withAlpha(200),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withAlpha(80),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: _isPlaying ? 18 : 26,
                    ),
                  ),
                ),
              ),
            ),

            // Loading indicator if play was pressed but video not initialized (fallback)
            if (_isPlaying && !_isInitialized)
              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGold,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
