import 'package:flutter/material.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/employeeProfileResponse.dart';
import 'package:spotlight/models/userAllMediaResponse.dart';
import 'package:spotlight/screens/preLogin/login_page.dart';
import 'package:spotlight/services/authService/authStorage.dart';
import 'package:spotlight/services/employeeProfileService/profileBaseService.dart';
import 'package:spotlight/services/employeeProfileService/profileService.dart';
import 'package:spotlight/services/mediaService/mediaBaseService.dart';
import 'package:spotlight/services/mediaService/mediaService.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileBaseService _profileService = ProfileService();
  final MediaBaseService _mediaService = MediaService();
  final AuthStorage _authStorage = AuthStorage();

  EmployeeProfileResponse? profileDate;
  List<UserAllMediaResponse> userMedia = [];

  int _pageNumber = 1;
  final int _pageSize = 10;

  bool isLoading = false;
  bool isUserFeed = false;
  bool hasMore = true;
  String? errorMessage;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    await fetchProfileData();
    await fetchFeeds();

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProfileData() async {
    try {
      final profileResponse = await _profileService
          .fetchEmployeeProfileDetail();

      profileDate = profileResponse;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("profile data Error: $e");
    }
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
        userMedia.addAll(newData);
        _pageNumber++;
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Pagination error: $e");
    }

    notifyListeners();
  }

  Future<void> fetchFeeds() async {
    if (!hasMore) return;

    try {
      final newData = await _mediaService.fetchAllUserMedia(
        _pageNumber,
        _pageSize,
      );

      if (newData.isEmpty) {
        isUserFeed = true;
        hasMore = false;
      } else {
        for (var media in newData) {
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

    notifyListeners();
  }

  void logout(BuildContext context) async {
    await _authStorage.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> reset() async {
    userMedia.clear();
    _pageNumber = 1;
    hasMore = true;
    errorMessage = null;
    notifyListeners();

    await fetchFeeds();
  }
}
