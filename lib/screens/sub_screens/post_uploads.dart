import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:provider/provider.dart';
import 'package:spotlight/components/media_edit.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/custom_controls/auto_play_video.dart';
import 'package:spotlight/provider/post_uploads_provider.dart';

class PostUploads extends StatefulWidget {
  const PostUploads({super.key});

  @override
  State<PostUploads> createState() => _PostUploadsState();
}

class _PostUploadsState extends State<PostUploads> {
  final ScrollController _scrollController = ScrollController();
  // bool _isZooming = false;
  // double _aspectRatio = 1.0;
  double _height = 300;
  double _width = 330;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Future.microtask(() {
      final provider = context.read<PostUploadsProvider>();
      provider.init(context);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PostUploadsProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.only(top: 35, left: 2, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
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
                    Text(
                      "New Post",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Lexend",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.blue[500],
                    fontFamily: "Lexend",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            child: Stack(
              children: [
                Consumer<PostUploadsProvider>(
                  builder: (context, value, child) {
                    if (value.originalAssets.isEmpty) {
                      return const SizedBox();
                    }

                    return PageView.builder(
                      controller: PageController(viewportFraction: 1),
                      itemCount: value.originalAssets.length,
                      itemBuilder: (context, index) {
                        final asset = value.originalAssets[index];
                        final isVideo = asset.type == AssetType.video;

                        return FutureBuilder<File?>(
                          future: asset.originFile,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }

                            final file = snapshot.data!;

                            return Center(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      height: _height,
                                      width: _width,
                                      child: isVideo
                                          ? AutoPlayVideo(asset: asset)
                                          : GestureDetector(
                                              // onTap: () {
                                              //   Navigator.push(
                                              //     context,
                                              //   MaterialPageRoute(
                                              //     builder: (_) =>
                                              //     MediaEdit(
                                              //       imgFile: file,
                                              //       height: _height,
                                              //       width: _width,
                                              //     ),
                                              //   ),
                                              //   );
                                              // },
                                              onTap: () async {
                                                final croppedFile =
                                                    await Navigator.push<File>(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            MediaEdit(
                                                              imgFile: file,
                                                              height: _height,
                                                              width: _width,
                                                            ),
                                                      ),
                                                    );

                                                if (croppedFile != null) {
                                                  value.updateCroppedImage(
                                                    index,
                                                    croppedFile,
                                                  );
                                                }
                                              },
                                              child: Image.file(
                                                file,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        value.onTapRemove(asset);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                Positioned(
                  bottom: 10,
                  left: 15,
                  child: Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final RenderBox overlay =
                            Overlay.of(context).context.findRenderObject()
                                as RenderBox;
                        final Offset offset = button.localToGlobal(
                          Offset.zero,
                          ancestor: overlay,
                        );
                        final position = RelativeRect.fromLTRB(
                          offset.dx,
                          offset.dy - 60,
                          overlay.size.width - offset.dx,
                          overlay.size.height - offset.dy,
                        );
                        showMenu(
                          context: context,
                          position: position,
                          color: Color(0xF04A4A4A),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          items: [
                            PopupMenuItem(
                              height: 40,
                              onTap: () {
                                setState(() {
                                  _height = 350;
                                  _width = 250;
                                });
                              },
                              child: Row(
                                spacing: 6,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/portrait_bx.svg',
                                    height: 18,
                                    width: 18,
                                  ),
                                  Text(
                                    "Portrait",
                                    style: TextStyle(
                                      fontFamily: "Lexend",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              height: 40,
                              onTap: () {
                                setState(() {
                                  _height = 330;
                                  _width = 330;
                                });
                              },
                              child: Row(
                                spacing: 6,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/square_bx.svg',
                                    height: 16,
                                    width: 16,
                                  ),
                                  Text(
                                    "Square",
                                    style: TextStyle(
                                      fontFamily: "Lexend",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),

          Consumer<PostUploadsProvider>(
            builder: (context, value, child) {
              return Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Media",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Lexend",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              value.toggleMultiSelect();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: value.isMultiSelect
                                    ? Colors.blue
                                    : Colors.grey.shade500,
                              ),
                              child: Row(
                                spacing: 5,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/multi_select_icon.svg',
                                    height: 14,
                                    width: 14,
                                  ),
                                  Text(
                                    "select",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Lexend",
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select photos or videos from your gallery.",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontFamily: "Lexend",
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        cacheExtent: 150,
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 30),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              childAspectRatio: 1,
                            ),
                        itemCount: value.galleryAssets.length,
                        itemBuilder: (context, index) {
                          var feed = value.galleryAssets[index];
                          final isVideo = feed.type == AssetType.video;

                          final selectedIndex = value.getSelectionIndex(feed);
                          final isSelected = selectedIndex != -1;

                          return GestureDetector(
                            onLongPress: () {
                              if (!value.isMultiSelect) {
                                value.toggleMultiSelect();
                              }
                              value.onTapAsset(feed);
                            },
                            onTap: () {
                              value.onTapAsset(feed);
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image(
                                    image: AssetEntityImageProvider(
                                      feed,
                                      isOriginal: false,
                                      thumbnailSize: const ThumbnailSize(
                                        200,
                                        200,
                                      ),
                                    ),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 22,
                                      ),
                                    ),
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(color: Colors.grey[900]);
                                    },
                                  ),
                                ),

                                if (isVideo)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        Helpers.formatDuration(
                                          feed.videoDuration,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),

                                if (isSelected)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.grey.withOpacity(0.7),
                                    ),
                                  ),

                                if (isSelected)
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: Container(
                                      height: 22,
                                      width: 22,
                                      decoration: BoxDecoration(
                                        border: value.isMultiSelect
                                            ? BoxBorder.all(
                                                color: value.isMultiSelect
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                width: value.isMultiSelect
                                                    ? 1
                                                    : 0,
                                              )
                                            : null,
                                        color: value.isMultiSelect
                                            ? Colors.blue
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        !value.isMultiSelect
                                            ? ""
                                            : "${selectedIndex + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
