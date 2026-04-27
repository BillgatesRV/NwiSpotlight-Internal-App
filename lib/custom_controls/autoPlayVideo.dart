import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AutoPlayVideo extends StatefulWidget {
  final AssetEntity asset;

  const AutoPlayVideo({super.key, required this.asset});

  @override
  State<AutoPlayVideo> createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<AutoPlayVideo> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      File? file = await widget.asset.originFile;

      if (_disposed) return;

      VideoPlayerController controller;

      if (file != null && await file.exists() && await file.length() > 1000) {
        controller = VideoPlayerController.file(file);
      } else {
        final uri = await widget.asset.getMediaUrl();
        if (uri == null || _disposed) return;
        controller = VideoPlayerController.networkUrl(Uri.parse(uri));
      }

      controller.setLooping(true);
      await controller.initialize();

      if (_disposed || !mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initialized = true;
      });

      _controller!.play();
    } catch (e) {
      debugPrint("VIDEO INIT ERROR: $e");
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _handleVisibility(double visible) {
    if (_disposed || !mounted || !_initialized || _controller == null) return;
    try {
      if (visible >= 0.5) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    } catch (e) {
      debugPrint("VISIBILITY HANDLE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key("video-${widget.asset.id}"),
      onVisibilityChanged: (info) {
        _handleVisibility(info.visibleFraction);
      },
      child: _initialized && _controller != null
          ? SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
