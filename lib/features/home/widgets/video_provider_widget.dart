import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProviderWidget extends StatefulWidget {
  final String videoUrl;
  final bool isMuted;
  final bool autoPlay;

  const VideoProviderWidget({
    super.key,
    required this.videoUrl,
    this.isMuted = true,
    this.autoPlay = true,
  });

  @override
  State<VideoProviderWidget> createState() => _VideoProviderWidgetState();
}

class _VideoProviderWidgetState extends State<VideoProviderWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      _controller.setLooping(true);
      if (widget.isMuted) {
        _controller.setVolume(0);
      }
      if (widget.autoPlay) {
        _controller.play();
      }
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void didUpdateWidget(VideoProviderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _isInitialized = false;
      _initializeController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
      );
    }

    return SizedOverflowBox(
      size: Size.infinite,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
