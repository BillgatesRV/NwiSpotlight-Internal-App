import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:spotlight/core/Enum.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/custom_controls/imageResizeController.dart';
import 'package:spotlight/custom_controls/video_playerUpload.dart';
import 'package:spotlight/provider/homeProvider.dart';
import 'package:spotlight/provider/profileProvider.dart';
import 'package:spotlight/provider/uploadsProvider.dart';
import 'package:vibration/vibration.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _captionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isMediaError = false;
  bool isCaptionError = false;
  bool _isZooming = false;
  final FocusNode _captionFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: GestureDetector(
            onTap: () => _captionFocusNode.unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 5, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'New Post',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Lexend",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          var provider = Provider.of<UploadsProvider>(
                            context,
                            listen: false,
                          );
                          if (provider.pickedMedia.isNotEmpty &&
                              _captionController.text.isNotEmpty) {
                            setState(() {
                              isMediaError = false;
                              isCaptionError = false;
                            });
                            try {
                              Helpers.showLoading(context);
                              final message = await provider.addFeed(
                                _captionController.text,
                              );
            
                              provider.pickedMedia.clear();
                              provider.item = null;
                              _captionController.text = "";
            
                              if (context.mounted && Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
            
                              if (context.mounted) {
                                Provider.of<HomeProvider>(
                                  context,
                                  listen: false,
                                ).reset();
                                Provider.of<ProfileProvider>(
                                  context,
                                  listen: false,
                                ).reset();
            
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message.toString()),
                                    margin: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 0,
                                      bottom: 100,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted && Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
            
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst("Exception: ", ""),
                                  ),
                                  margin: EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                    top: 0,
                                    bottom: 100,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } else {
                            setState(() {
                              isMediaError = provider.pickedMedia.isEmpty
                                  ? true
                                  : false;
                              isCaptionError = _captionController.text.isEmpty
                                  ? true
                                  : false;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.blue,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 5,
                                color: Colors.grey.shade200,
                              ),
                            ],
                          ),
                          child: Text(
                            'Share',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Lexend",
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 350,
                          width: double.infinity,
                          child: Consumer<UploadsProvider>(
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  value.item != null
                                      ? value.isVideo(value.item!.path)
                                            ? Center(
                                                child: CustomVideoPlayerUpload(
                                                  videoUrl: value.item!.path,
                                                ),
                                              )
                                            : ZoomableImage(
                                                key: ValueKey(value.item!.path),
                                                image: File(value.item!.path),
                                                controller: value.controllerFor(
                                                  value.item!,
                                                ),
                                                onInteractionStart: () =>
                                                    setState(
                                                      () => _isZooming = true,
                                                    ),
                                                onInteractionEnd: () => setState(
                                                  () => _isZooming = false,
                                                ),
                                              )
                                      : Image.asset(
                                          'assets/images/no_media_resized.jpg',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
            
                                  if (_isZooming)
                                    IgnorePointer(
                                      child: AnimatedOpacity(
                                        opacity: _isZooming ? 1.0 : 0.0,
                                        duration: Duration(milliseconds: 200),
                                        child: CustomPaint(
                                          size: Size(double.infinity, 350),
                                          painter: _GridPainter(),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 40),
                        Stack(
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              height: 130,
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              padding: EdgeInsets.only(
                                top: 40,
                                left: 10,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey.shade400,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                    color: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                              child: Consumer<UploadsProvider>(
                                builder: (context, value, child) {
                                  return value.pickedMedia.isNotEmpty
                                      ? SingleChildScrollView(
                                          controller: _scrollController,
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            spacing: 8,
                                            children: value.pickedMedia
                                                .asMap()
                                                .entries
                                                .map((e) {
                                                  return AddedMediaCard(
                                                    addedMedia: e.value,
                                                    isVideo: value.isVideo(
                                                      e.value.path,
                                                    ),
                                                    onRemove: () =>
                                                        value.removeMedia(e.key),
                                                  );
                                                })
                                                .toList(),
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/no_media_added.png',
                                        );
                                },
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 15,
                              child: Row(
                                spacing: 6,
                                children: [
                                  isMediaError
                                      ? Icon(
                                          Icons.error_outline_outlined,
                                          color: Colors.red,
                                          size: 20,
                                        )
                                      : SizedBox.shrink(),
                                  Builder(
                                    builder: (context) => GestureDetector(
                                      onTap: () {
                                        final RenderBox button =
                                            context.findRenderObject()
                                                as RenderBox;
                                        final RenderBox overlay =
                                            Overlay.of(
                                                  context,
                                                ).context.findRenderObject()
                                                as RenderBox;
                                        final Offset offset = button
                                            .localToGlobal(
                                              Offset.zero,
                                              ancestor: overlay,
                                            );
                                        final RelativeRect position =
                                            RelativeRect.fromLTRB(
                                              offset.dx + button.size.width,
                                              offset.dy + 25,
                                              offset.dx + button.size.width,
                                              offset.dy,
                                            );
                                        showMenu(
                                          context: context,
                                          position: position,
                                          color: Colors.white,
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          items: [
                                            PopupMenuItem(
                                              height: 40,
                                              onTap: () async {
                                                final provider =
                                                    Provider.of<UploadsProvider>(
                                                      context,
                                                      listen: false,
                                                    );
                                                await provider.openGallery(
                                                  UploadType.images,
                                                );
            
                                                if (mounted && provider.errorMessage != null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        provider.errorMessage!,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        top: 0,
                                                        bottom: 100,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                  provider.errorMessage = null;
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.image,
                                                    size: 20,
                                                    color: Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    "Add images",
                                                    style: TextStyle(
                                                      fontFamily: "Lexend",
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              height: 40,
                                              onTap: () async {
                                                final provider = Provider.of<UploadsProvider>(
                                                  context,
                                                  listen: false,
                                                );
                                                
                                                await provider.openGallery(UploadType.videos);
            
                                                if (mounted && provider.errorMessage != null) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        provider.errorMessage!,
                                                      ),
                                                      margin: EdgeInsets.only(
                                                        left: 10,
                                                        right: 10,
                                                        top: 0,
                                                        bottom: 100,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                  provider.errorMessage = null;
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.video_collection,
                                                    size: 20,
                                                    color: Colors.grey[700],
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    "Add videos",
                                                    style: TextStyle(
                                                      fontFamily: "Lexend",
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.blue,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 1,
                                              color: Colors.grey.shade100,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "Manage media",
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.white,
                                            fontFamily: "Lexend",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 12,
                          ),
                          child: TextFormField(
                            focusNode: _captionFocusNode,
                            controller: _captionController,
                            minLines: 1,
                            maxLines: null,
                            cursorColor: Colors.grey[500],
                            cursorHeight: 20,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'Write a caption...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                fontFamily: "Lexend",
                                fontWeight: FontWeight.w400,
                                color: isCaptionError ? Colors.red : Colors.grey,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddedMediaCard extends StatefulWidget {
  final XFile addedMedia;
  final VoidCallback? onRemove;
  final bool isVideo;

  const AddedMediaCard({
    super.key,
    required this.addedMedia,
    required this.isVideo,
    this.onRemove,
  });

  @override
  State<AddedMediaCard> createState() => _AddedMediaCardState();
}

class _AddedMediaCardState extends State<AddedMediaCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Vibration.vibrate(duration: 40);
            Provider.of<UploadsProvider>(
              context,
              listen: false,
            ).setItem(widget.addedMedia);
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.isVideo
                ? Container(
                    width: 70,
                    height: 70,
                    color: Colors.black,
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : Image.file(
                    File(widget.addedMedia.path),
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                  ),
          ),
        ),
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Container(
              height: 22,
              width: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.close, size: 11, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.8;

    final colWidth = size.width / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(colWidth * i, 0),
        Offset(colWidth * i, size.height),
        paint,
      );
    }

    final rowHeight = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(0, rowHeight * i),
        Offset(size.width, rowHeight * i),
        paint,
      );
    }

    // border
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}