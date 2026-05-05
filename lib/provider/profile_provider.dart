import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotlight/core/Helpers.dart';
import 'package:spotlight/models/employee_profile_response.dart';
import 'package:spotlight/models/user_all_media_response.dart';
import 'package:spotlight/screens/pre_login/login_page.dart';
import 'package:spotlight/services/auth_service/auth_storage.dart';
import 'package:spotlight/services/employee_profile_service/profile_base_service.dart';
import 'package:spotlight/services/employee_profile_service/profile_service.dart';
import 'package:spotlight/services/media_service/media_base_service.dart';
import 'package:spotlight/services/media_service/media_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileBaseService _profileService = ProfileService();
  final MediaBaseService _mediaService = MediaService();
  final AuthStorage _authStorage = AuthStorage();

  EmployeeProfileResponse? profileDate;
  List<UserAllMediaResponse> userMedia = [];

  int _pageNumber = 1;
  final int _pageSize = 10;

  bool isLoading = false;
  bool isCoverImgLoading = false;
  bool isUserFeed = false;
  bool hasMore = true;
  String? errorMessage;
  String? coverImage;

  Future<void> initialize() async {
    isLoading = true;
    isCoverImgLoading = true;
    notifyListeners();

    await fetchProfileData();
    await fetchFeeds();

    isLoading = false;
    isCoverImgLoading = false;
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

  Future<void> pickCoverImage(BuildContext context) async {
    final picker = ImagePicker();

    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (picked == null) return;
    try {
      CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: CropAspectRatio(ratioX: 26, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: true,
        ),
      ],
    );

    if (cropped != null) {
      isCoverImgLoading = true;
      notifyListeners();
      
      File croppedImage = File(cropped.path);
      final response = await _profileService.addCoverImage(croppedImage);

      if(response.responseCode == 201) {
        profileDate!.coverImageUrl = croppedImage.path;
      } else {
        Helpers.showErrorSnackBar(context, message: response.message);
      }
    }
    } catch (e) {
       Helpers.showErrorSnackBar(context, message: e.toString());
    } finally {
      isCoverImgLoading = false;
      notifyListeners();
    }
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
