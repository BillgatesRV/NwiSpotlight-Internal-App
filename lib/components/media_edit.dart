import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotlight/core/helpers.dart';

class MediaEdit extends StatefulWidget {
  final File imgFile;
  final double height;
  final double width;

  MediaEdit({
    super.key,
    required this.imgFile,
    required this.height,
    required this.width,
  });

  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  @override
  State<MediaEdit> createState() => _MediaEditState();
}

class _MediaEditState extends State<MediaEdit> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(top: 35, left: 2, right: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () {
                  Helpers.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: const Color.fromARGB(255, 27, 20, 20),
                  height: widget.height,
                  width: widget.width,
                  child: ExtendedImage.file(
                    widget.imgFile,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    extendedImageEditorKey: widget.editorKey,
                    cacheRawData: true,
                    initEditorConfigHandler: (state) {
                      return EditorConfig(
                        maxScale: 8.0,
                        cropAspectRatio: widget.width / widget.height,
                        cropRectPadding: const EdgeInsets.all(0),
                        hitTestSize: 20.0,
                        cropLayerPainter: CustomEditorCropLayerPainter(),
                        initCropRectType: InitCropRectType.layoutRect,
                        editorMaskColorHandler: (context, pointerDown) {
                          return Colors.black.withOpacity(
                            pointerDown ? 0.6 : 0.4,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          TextButton(
            onPressed: cropImage,
            child: Text(
              "Done",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> cropImage() async {
    try {
      final state = widget.editorKey.currentState;
      if (state == null) return;

      final rect = state.getCropRect();
      final rawImage = state.rawImageData;

      if (rect == null || rawImage.isEmpty) return;

      final cropped = await ImageEditor.editImage(
        image: rawImage,
        imageEditorOption: ImageEditorOption()
          ..addOption(ClipOption.fromRect(rect)),
      );

      if (cropped != null) {
       final dir = await getTemporaryDirectory();

        final file = File(
          '${dir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        Navigator.pop(context, file);
      }
    } catch (e) {
      Helpers.showErrorSnackBar(context, message: e.toString());
    }
  }
}

class CustomEditorCropLayerPainter extends EditorCropLayerPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
    ExtendedImageCropLayerPainter painter,
    Rect rect,
  ) {
    final cropRect = rect;

    final borderPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 0
      ..style = PaintingStyle.stroke;

    // Border
    canvas.drawRect(cropRect, borderPaint);

    const corner = 20.0;

    final cornerPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 0;

    // TOP LEFT
    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft + Offset(corner, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.topLeft,
      cropRect.topLeft + Offset(0, corner),
      cornerPaint,
    );

    // TOP RIGHT
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight + Offset(-corner, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.topRight,
      cropRect.topRight + Offset(0, corner),
      cornerPaint,
    );

    // BOTTOM LEFT
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft + Offset(corner, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.bottomLeft,
      cropRect.bottomLeft + Offset(0, -corner),
      cornerPaint,
    );

    // BOTTOM RIGHT
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight + Offset(-corner, 0),
      cornerPaint,
    );
    canvas.drawLine(
      cropRect.bottomRight,
      cropRect.bottomRight + Offset(0, -corner),
      cornerPaint,
    );
  }
}
