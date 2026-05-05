import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotlight/core/Enum.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/custom_controls/image_resize_controller.dart';
import 'package:spotlight/services/media_service/media_base_service.dart';
import 'package:spotlight/services/media_service/media_service.dart';

class UploadsProvider extends ChangeNotifier {
  bool isLoading = false;
  XFile? item;
  final List<XFile> pickedMedia = [];
  final Map<String, ImageZoomController> _controllers = {};
  final _picker = ImagePicker();
  String? errorMessage;

  final MediaBaseService _mediaService = MediaService();

  ImageZoomController controllerFor(XFile file) {
    _controllers[file.path] ??= ImageZoomController();
    return _controllers[file.path]!;
  }

  Future<void> openGallery(UploadType mediaType) async {
    try {
      if (pickedMedia.length >= 10) {
        errorMessage = "You can only select up to 10 media items";
        notifyListeners();
        return;
      }

      final List<XFile> picked = mediaType == UploadType.images
          ? await _picker.pickMultiImage(limit: 10)
          : await _picker.pickMultiVideo(limit: 10);

      if (picked.isEmpty) return;

      if (mediaType == UploadType.videos) {
         final List<XFile> toRemove = [];

        for (final video in picked) {
          final tempFile = File(video.path);
          final duration = await Helpers.getVideoDuration(tempFile.path); 
          if (duration != null && duration.inSeconds > 180) {
            toRemove.add(video);
          }
        }

        if(toRemove.isNotEmpty) {
          picked.removeWhere((v) => toRemove.contains(v));
          errorMessage = "Make sure your video is less than 3 minutes long";
          notifyListeners();
        }
      }


      if (picked.length + pickedMedia.length > 10) {
        var lengthToAdd = 10 - pickedMedia.length;
        if (lengthToAdd > 0) {
          pickedMedia.addAll(picked.take(lengthToAdd));
          item ??= pickedMedia.first;
        }

        errorMessage = "You can only select up to 10 media items";
        notifyListeners();
        return;
      }

      if (picked.isNotEmpty) {
        pickedMedia.addAll(picked);
        item ??= pickedMedia.first;
      }

      notifyListeners();
    } on PlatformException catch (e) {
      if (e.code == 'already_active') return;
      debugPrint('Gallery error: $e');
    } catch (e) {
      debugPrint('Gallery error: $e');
    }
  }

  void setItem(XFile selected) {
    item = selected;
    notifyListeners();
  }

  void removeMedia(int index) {
    final removed = pickedMedia[index];
    _controllers[removed.path]?.dispose();
    _controllers.remove(removed.path);
    pickedMedia.removeAt(index);
    if (item?.path == removed.path) {
      item = pickedMedia.isNotEmpty ? pickedMedia.first : null;
    }
    notifyListeners();
  }

  void clearAll() {
    for (final c in _controllers.values) {
      c.dispose();
    }

    _controllers.clear();
    pickedMedia.clear();
    errorMessage = null;
    item = null;
    notifyListeners();
  }

  Future<List<XFile>> _captureAllMediaAsXFiles() async {
    final List<XFile> results = [];
    final tempDir = await getTemporaryDirectory();

    for (final file in pickedMedia) {
      final controller = _controllers[file.path];
      if (controller != null && file.path == item?.path) {
        final bytes = await controller.captureAsBytes();
        if (bytes != null) {
          final tempFile = File(
            '${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}.png',
          );
          await tempFile.writeAsBytes(bytes);
          results.add(XFile(tempFile.path));
          continue;
        }
      }
      results.add(file);
    }

    return results;
  }

  Future<String> addFeed(String caption) async {
    try {
      isLoading = true;
      notifyListeners();

      final processedMedia = await _captureAllMediaAsXFiles();

      final responseMessage = await _mediaService.addFeed(
        caption: caption,
        media: processedMedia,
      );

      return responseMessage;
    } catch (e) {
      notifyListeners();
      debugPrint("Add feed Error: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
