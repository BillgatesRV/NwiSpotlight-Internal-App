import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/all_media_response.dart';
import 'package:spotlight/models/media_liked_by_response.dart';
import 'package:spotlight/provider/home_provider.dart';
import 'package:spotlight/provider/profile_provider.dart';
import 'package:spotlight/services/auth_service/auth_storage.dart';
import 'package:spotlight/services/media_service/media_base_service.dart';
import 'package:spotlight/services/media_service/media_service.dart';

class UserPostProvider extends ChangeNotifier {
  final AuthStorage _authStorage = AuthStorage();
  final MediaBaseService _mediaService = MediaService();
  List<AllMediaResponse> mediaFeeds = [];
  List<MediaLikedByResponse> likedBy = [];

  var isLoggedUser = false;

  int _pageNumber = 1;
  final int _pageSize = 30;
  String userGuid = "";

  bool isLoading = true;
  bool isPaginating = false;
  bool isLikedByLoading = false;
  bool hasMore = true;
  String? errorMessage;

  Future<void> initialize(String userGuid) async {
    this.userGuid = userGuid;

    var loggedUserGuid = await _authStorage.getUserGuid();
    isLoggedUser = loggedUserGuid == userGuid ? true : false;
    await fetchFeeds(userGuid);
  }

  Future<void> fetchFeeds(String userGuid) async {
    if (!hasMore) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newData = await _mediaService.fetchAllUserMediaData(
        userGuid,
        _pageNumber,
        _pageSize,
      );

      if (newData.isEmpty) {
        hasMore = false;
      } else {
        mediaFeeds.addAll(newData);
        _pageNumber++;

        hasMore = mediaFeeds.length < newData.first.totalCount!;
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Pagination error: $e");
    } finally {
      isLoading = false;
      isPaginating = false;
      notifyListeners();
    }
  }

  Future<void> fetchLikedBy(String mediaGuid) async {
    try {
      likedBy.clear();
      isLikedByLoading = true;
      notifyListeners();

      final likedData = await _mediaService.manageLikedBy(mediaGuid: mediaGuid);

      if (likedData.isNotEmpty) {
        likedBy.addAll(likedData);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("error: $e");
    } finally {
      isLikedByLoading = false;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    mediaFeeds.clear();
    _pageNumber = 1;
    hasMore = true;
    errorMessage = null;

    await fetchFeeds(userGuid);
  }

  Future<void> toggleLike(String mediaGuid) async {
    try {
      final mediaIndex = mediaFeeds.indexWhere(
        (media) => media.mediaGuid == mediaGuid,
      );

      final media = mediaFeeds[mediaIndex];

      // make it faster by updating the UI before the API call
      media.isUserLiked = media.isUserLiked! ? false : true;
      media.likesCount = media.likesCount! + (media.isUserLiked! ? 1 : 0);
      notifyListeners();

      final response = await _mediaService.manageMediaLikes(
        mediaGuid: mediaGuid,
      );

      final likeResponse = response;

      if (mediaIndex != -1) {
        media.isUserLiked = likeResponse.isUserLiked;
        media.likesCount = likeResponse.likesCount;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  void removeFeed(BuildContext context, String mediaGuid) async {
    try {
      if (!isLoggedUser) {
        Helpers.showErrorSnackBar(
          context,
          message: "Unauthorized access cannot delete the post",
        );
        return;
      }
      final response = await _mediaService.deleteFeed(mediaGuid: mediaGuid);

      if (response.isSuccess) {
        var index = mediaFeeds.indexWhere((m) => m.mediaGuid == mediaGuid);
        if (index != -1) {
          mediaFeeds.removeWhere((m) => m.mediaGuid == mediaGuid);

          await Provider.of<HomeProvider>(context, listen: false).reset();
          await Provider.of<ProfileProvider>(context, listen: false).reset();

          if (mediaFeeds.isEmpty && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          notifyListeners();
        }
      } else {
        Helpers.showErrorSnackBar(
          context,
          message: response.message,
        );
      }
    } catch (e) {
      debugPrint("Remove feed Error: $e");
      Helpers.showErrorSnackBar(
        context,
      );
    }
  }
}
