import 'package:flutter/material.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/allMediaResponse.dart';
import 'package:spotlight/models/mediaLikedByResponse.dart';
import 'package:spotlight/models/userResponse.dart';
import 'package:spotlight/services/employeeProfileService/profileBaseService.dart';
import 'package:spotlight/services/employeeProfileService/profileService.dart';
import 'package:spotlight/services/mediaService/mediaBaseService.dart';
import 'package:spotlight/services/mediaService/mediaService.dart';

class HomeProvider extends ChangeNotifier {
  final MediaBaseService _mediaService = MediaService();
  final ProfileBaseService _profileService = ProfileService();
  List<AllMediaResponse> mediaFeeds = [];
  List<MediaLikedByResponse> likedBy = [];
  List<UserResponse> usersList = [];

  int _pageNumber = 1;
  final int _pageSize = 5;

  int _userPageNumber = 1;
  final int _userPageSize = 10;

  bool isLoading = true;
  bool isPaginating = false;
  bool isUserLoading = true;
  bool isUserPaginating = false;
  bool isLikedByLoading = false;
  bool hasMore = true;
  bool userHasMore = true;
  String? errorMessage;

  Future<void> initialize() async {
    await Future.wait([fetchUsers(), fetchFeeds()]);
  }

  Future<void> fetchFeeds() async {
    if (!hasMore) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final newData = await _mediaService.fetchAllMediaFeeds(
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
    usersList.clear();
    _pageNumber = 1;
    _userPageNumber = 1;
    hasMore = true;
    userHasMore = true;
    errorMessage = null;

    await Future.wait([fetchUsers(), fetchFeeds()]);
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

  Future<void> fetchUsers() async {
    if (!userHasMore) return;

    isUserLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _profileService.fetchAllUsers(
        _userPageNumber,
        _userPageSize,
      );

      if (response.isEmpty) {
        userHasMore = false;
      } else {
        for (var user in response) {
          user.employeeName = user.employeeName.capitalizeFirst();
        }
        usersList.addAll(response);
        _userPageNumber++;

        userHasMore = usersList.length < response.first.totalCount;
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Pagination error: $e");
    } finally {
      isUserLoading = false;
      isUserPaginating = false;
      notifyListeners();
    }
  }
}
