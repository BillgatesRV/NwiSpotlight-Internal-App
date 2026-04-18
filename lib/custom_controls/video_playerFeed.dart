import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CustomVideoPlayerFeed extends StatefulWidget {
  final String videoUrl;
  const CustomVideoPlayerFeed({super.key, required this.videoUrl});

  @override
  State<CustomVideoPlayerFeed> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayerFeed> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayerFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.removeListener(_onControllerUpdate);
      _controller.dispose();
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    if (widget.videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
    } else if (widget.videoUrl.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }
    _controller.addListener(_onControllerUpdate);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final isPlaying = _controller.value.isPlaying;
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    final hasEnded =
        !isPlaying &&
        duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 100;
    if (hasEnded && _isPlaying) setState(() => _isPlaying = false);
  }

  void _togglePlayPause() {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _isPlaying = false);
    } else {
      final position = _controller.value.position;
      final duration = _controller.value.duration;
      if (duration.inMilliseconds > 0 &&
          position.inMilliseconds >= duration.inMilliseconds - 100) {
        _controller.seekTo(Duration.zero);
      }
      _controller.play();
      setState(() => _isPlaying = true);
    }
  }

  void _openFullscreen() async {
    _controller.pause();
    setState(() => _isPlaying = false);

    final position = _controller.value.position;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPlayer(
          videoUrl: widget.videoUrl,
          startPosition: position,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const AspectRatio(aspectRatio: 9 / 16, child: SizedBox.shrink());
    }

    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        if (!_controller.value.isInitialized) return;

        final visible = info.visibleFraction;

        if (visible == 0) {
          _controller.pause();
          setState(() {
            _isPlaying = false;
          });
        }

        if (visible < 0.5) {
          _controller.pause();
          setState(() {
            _isPlaying = false;
          });
        }

        _controller.seekTo(Duration.zero);
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),

              // play/pause overlay
              AnimatedOpacity(
                opacity: _isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: _isPlaying,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 38,
                right: 2,
                child: GestureDetector(
                  onTap: _openFullscreen,
                  child: Icon(Icons.fullscreen, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Duration startPosition;

  const FullscreenVideoPlayer({
    super.key,
    required this.videoUrl,
    this.startPosition = Duration.zero,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.videoUrl.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
    } else if (widget.videoUrl.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }

    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.seekTo(widget.startPosition); // resume from same point
      _controller.play();
      setState(() => _isPlaying = true);
    });

    _controller.addListener(() {
      if (!mounted) return;
      final isPlaying = _controller.value.isPlaying;
      final position = _controller.value.position;
      final duration = _controller.value.duration;
      final hasEnded =
          !isPlaying &&
          duration.inMilliseconds > 0 &&
          position.inMilliseconds >= duration.inMilliseconds - 100;
      if (hasEnded && _isPlaying) setState(() => _isPlaying = false);
    });
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _isPlaying = false);
    } else {
      _controller.play();
      setState(() => _isPlaying = true);
    }
    // auto hide controls after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _isPlaying) setState(() => _showControls = false);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _controller.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : CircularProgressIndicator(color: Colors.white),

            // controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  color: Colors.black26,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // top bar — back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: SafeArea(
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),

                      // center play/pause
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),

                      // bottom — progress bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (context, value, child) {
                            final position = value.position.inSeconds
                                .toDouble();
                            final duration = value.duration.inSeconds
                                .toDouble();
                            return Column(
                              children: [
                                Slider(
                                  value: position.clamp(
                                    0,
                                    duration > 0 ? duration : 1,
                                  ),
                                  min: 0,
                                  max: duration > 0 ? duration : 1,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white38,
                                  onChanged: (val) {
                                    _controller.seekTo(
                                      Duration(seconds: val.toInt()),
                                    );
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(value.position),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(value.duration),
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
