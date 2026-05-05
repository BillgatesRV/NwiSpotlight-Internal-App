import 'package:flutter/material.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/employee_profile_response.dart';
import 'package:spotlight/models/user_all_media_response.dart';
import 'package:spotlight/services/employee_profile_service/profile_base_service.dart';
import 'package:spotlight/services/employee_profile_service/profile_service.dart';
import 'package:spotlight/services/media_service/media_base_service.dart';
import 'package:spotlight/services/media_service/media_service.dart';

class AllUserProfileProvider extends ChangeNotifier {
  final ProfileBaseService _profileService = ProfileService();
  final MediaBaseService _mediaService = MediaService();

  EmployeeProfileResponse? profileDate;
  List<UserAllMediaResponse> userMedia = [];

  int _pageNumber = 1;
  final int _pageSize = 10;

  bool isLoading = false;
  bool isUserFeed = false;
  bool hasMore = true;
  String? errorMessage;
  String empGuid = "";

  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  Future<void> initialize(String empGuid) async {
    isLoading = true;
    this.empGuid = empGuid;
    notifyListeners();
    await fetchOthersProfileData(empGuid);
    await fetchOthersFeeds(empGuid);

    isLoading = false;
    
    if(!isDisposed) notifyListeners();
  }

  Future<void> fetchOthersProfileData(String empGuid) async {
    try {
      final profileResponse = await _profileService
          .fetchOtherEmployeeProfileDetail(empGuid);

      profileDate = profileResponse;

    } catch (e) {
      errorMessage = e.toString();
      debugPrint("profile data Error: $e");
    }
  }

  Future<void> fetchOthersFeeds(String empGuid) async {
    if (!hasMore) return;
    try {
      final newData = await _mediaService.fetchAllOthersUserMedia(
        empGuid,
        _pageNumber,
        _pageSize,
      );

      if (newData.isEmpty) {
        isUserFeed = true;
        hasMore = false;
      } else {
        for (var media in newData) {
          if (isDisposed) return;

          var isVideo = Helpers.isVideo(media.mediaThumb);
          if (isVideo) {
            media.videoThumb = await Helpers.getThumbnail(media.mediaThumb);
          }
        }

        userMedia.addAll(newData);
        _pageNumber++;
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Pagination error: $e");
    }

    if (!isDisposed) {
      notifyListeners();
    }
  }

  Future<void> reset() async {
    userMedia.clear();
    _pageNumber = 1;
    hasMore = true;
    errorMessage = null;
    notifyListeners();

    await fetchOthersFeeds(empGuid);
  }
}
