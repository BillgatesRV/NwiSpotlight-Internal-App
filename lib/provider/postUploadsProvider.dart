import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:spotlight/core/Helpers.dart';

class PostUploadsProvider extends ChangeNotifier {
  List<AssetEntity> galleryAssets = [];
  List<AssetEntity> selectedAssets = [];

  int _currentPage = 0;
  final int _pageSize = 60;

  bool _isLoading = false;
  bool _hasMore = true;

  AssetPathEntity? _album;

  bool isMultiSelect = false;

  void toggleMultiSelect() {
    isMultiSelect = !isMultiSelect;

    if (!isMultiSelect) {
      selectedAssets.clear();
    }

    notifyListeners();
  }

  void onTapRemove(AssetEntity asset) {
    if (selectedAssets.contains(asset)) {
      selectedAssets.remove(asset);
    }
    notifyListeners();
  }

  void onTapAsset(AssetEntity asset) {
    if (!isMultiSelect) {
      if (selectedAssets.contains(asset)) {
        selectedAssets.remove(asset);
      } else {
        selectedAssets = [asset];
      }
    } else {
      if (selectedAssets.contains(asset)) {
        selectedAssets.remove(asset);
      } else {
        if (selectedAssets.length >= 10) return;
        selectedAssets.add(asset);
      }
    }

    notifyListeners();
  }

  int getSelectionIndex(AssetEntity asset) {
    return selectedAssets.indexOf(asset);
  }

  Future<void> init(BuildContext context) async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      Helpers.pop(context);
      return;
    }
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.common,
    );

    if (albums.isEmpty) return;

    _album = albums.first;

    galleryAssets.clear();
    _currentPage = 0;
    _hasMore = true;

    await loadMore();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore || _album == null) return;

    _isLoading = true;

    final media = await _album!.getAssetListPaged(
      page: _currentPage,
      size: _pageSize,
    );

    if (media.isEmpty) {
      _hasMore = false;
    } else {
      final filtered = media.where((e) {
        if (e.type == AssetType.image) {
          final mime = e.mimeType?.toLowerCase() ?? '';
          return mime == 'image/jpeg' ||
              mime == 'image/jpg' ||
              mime == 'image/png' ||
              mime == 'image/webp';
        }

        if (e.type == AssetType.video) {
          final mime = e.mimeType?.toLowerCase() ?? '';
          final validVideo =
              mime == 'video/mp4' ||
              mime == 'video/webm' ||
              mime == 'video/3gpp';
          return validVideo &&
              e.videoDuration.inSeconds >= 3 &&
              e.videoDuration.inSeconds <= 300;
        }

        return false;
      }).toList();

      galleryAssets.addAll(filtered);
      _currentPage++;
    }

    _isLoading = false;
    notifyListeners();
  }
}
