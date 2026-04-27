import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ImageZoomController {
  final TransformationController transformationController;
  final GlobalKey boundaryKey = GlobalKey();

  ImageZoomController() : transformationController = TransformationController();

  double get currentScale => transformationController.value.getMaxScaleOnAxis();

  Offset get currentOffset => Offset(
        transformationController.value.getTranslation().x,
        transformationController.value.getTranslation().y,
      );

  List<double> get matrixForApi =>
      transformationController.value.storage.toList();

  Future<Uint8List?> captureAsBytes() async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  void dispose() => transformationController.dispose();
}

class ZoomableImage extends StatefulWidget {
  final File image;
  final ImageZoomController? controller;
  final double height;
  final BoxFit fit;
  final VoidCallback? onInteractionStart;
  final VoidCallback? onInteractionEnd;
  final double minScale;
  final double maxScale;

  const ZoomableImage({
    super.key,
    required this.image,
    this.controller,
    this.height = 350,
    this.fit = BoxFit.cover,
    this.onInteractionStart,
    this.onInteractionEnd,
    this.minScale = 0.5, 
    this.maxScale = 5.0,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  late final ImageZoomController _ctrl;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ctrl = ImageZoomController();
      _ownsController = true;
    } else {
      _ctrl = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _ctrl.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return SizedBox(
    height: widget.height,
    width: double.infinity,
    child: RepaintBoundary(
      key: _ctrl.boundaryKey,
      child: ClipRect(      
        child: InteractiveViewer(
          transformationController: _ctrl.transformationController,
          minScale:  widget.minScale,
          maxScale: widget.maxScale,
          clipBehavior: Clip.hardEdge,
          onInteractionStart: (_) => widget.onInteractionStart?.call(),
          onInteractionEnd: (_) => widget.onInteractionEnd?.call(),
          child: Image.file(
            widget.image,
            fit: widget.fit,
            width: double.infinity,
            height: widget.height,
          ),
        ),
      ),
    ),
  );
}
}