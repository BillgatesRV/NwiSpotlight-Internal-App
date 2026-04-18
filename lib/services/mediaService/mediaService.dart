import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:spotlight/core/urls.dart';
import 'package:spotlight/models/allMediaResponse.dart';
import 'package:spotlight/models/apiResponse.dart';
import 'package:spotlight/models/mediaLikeResponse.dart';
import 'package:spotlight/models/mediaLikedByResponse.dart';
import 'package:spotlight/models/userAllMediaResponse.dart';
import 'package:spotlight/services/authService/authStorage.dart';
import 'package:spotlight/services/mediaService/mediaBaseService.dart';

class MediaService extends MediaBaseService {
  final AuthStorage _authStorage = AuthStorage();

  @override
  Future<List<AllMediaResponse>> fetchAllMediaFeeds(
    int pageNumber,
    int pageSize,
  ) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/media/get-all-media-feed-v2?pageNumber=$pageNumber&pageSize=$pageSize",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return List<AllMediaResponse>.from(
            responseData["result"].map((x) => AllMediaResponse.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "Media retrival failed");
      }
    } catch (e) {
      debugPrint("Media retrival Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<MediaLikeResponse> manageMediaLikes({
    required String mediaGuid,
  }) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/media/handle-media-like?mediaGuid=$mediaGuid",
      );

      String? token = await _authStorage.getToken();

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return MediaLikeResponse.fromJson(responseData["result"]);
        } else {
          return MediaLikeResponse(
            isUserLiked: false,
            likesCount: 0,
            mediaGuid: mediaGuid,
          );
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "failed to manage media like");
      }
    } catch (e) {
      debugPrint("Media manage Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<MediaLikedByResponse>> manageLikedBy({
    required String mediaGuid,
  }) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/media/get-likes-for-media?mediaGuid=$mediaGuid",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return List<MediaLikedByResponse>.from(
            responseData["result"].map((x) => MediaLikedByResponse.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "failed to manage liked users");
      }
    } catch (e) {
      debugPrint("liked manage Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> addFeed({
    required String caption,
    required List<XFile> media,
  }) async {
    try {
      final url = Uri.parse("${Urls.baseUrl}employee/media-upload/birthday");

      String? token = await _authStorage.getToken();

      var request = http.MultipartRequest("POST", url);

      request.headers["Authorization"] = "Bearer $token";

      request.fields["PersonName"] = caption;

      for (var file in media) {
        request.files.add(
          await http.MultipartFile.fromPath("Attachments", file.path),
        );
      }

      final streamedData = await request.send();
      final response = await http.Response.fromStream(streamedData);

      final responseData = jsonDecode(response.body);

      if (responseData["responseCode"] == 200 ||
          responseData["responseCode"] == 201) {
        return (responseData["message"] ?? "feed added sucessfully");
      } else {
        throw Exception(responseData["message"] ?? "failed to add feed");
      }
    } catch (e) {
      debugPrint("Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<UserAllMediaResponse>> fetchAllUserMedia(
    int pageNumber,
    int pageSize,
  ) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/media/get-employee-all-media?pageNumber=$pageNumber&pageSize=$pageSize",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return List<UserAllMediaResponse>.from(
            responseData["result"].map((x) => UserAllMediaResponse.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "User all Media retrival failed");
      }
    } catch (e) {
      debugPrint("User all Media retrival Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<UserAllMediaResponse>> fetchAllOthersUserMedia(
    String empGuid,
    int pageNumber,
    int pageSize,
  ) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/common/get-other-employee-all-media?userGuid=$empGuid&pageNumber=$pageNumber&pageSize=$pageSize",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return List<UserAllMediaResponse>.from(
            responseData["result"].map((x) => UserAllMediaResponse.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "User all Media retrival failed");
      }
    } catch (e) {
      debugPrint("User all Media retrival Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<AllMediaResponse>> fetchAllUserMediaData(
    String empGuid,
    int pageNumber,
    int pageSize,
  ) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/common/get-employee-all-media-data?userGuid=$empGuid&pageNumber=$pageNumber&pageSize=$pageSize",
      );

      String? token = await _authStorage.getToken();

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData["result"] != null) {
          return List<AllMediaResponse>.from(
            responseData["result"].map((x) => AllMediaResponse.fromJson(x)),
          );
        } else {
          return [];
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? "User Media data retrival failed");
      }
    } catch (e) {
      debugPrint("User Media data retrival Error: $e");
      throw Exception(e.toString());
    }
  }

  @override
  Future<ApiResponse> deleteFeed({required String mediaGuid}) async {
    try {
      final url = Uri.parse(
        "${Urls.baseUrl}employee/media/delete-employee-media?mediaGuid=$mediaGuid",
      );

      String? token = await _authStorage.getToken();

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final responseData = jsonDecode(response.body);

      return ApiResponse.fromJson(responseData);
    } catch (e) {
      debugPrint("Error: $e");
      return ApiResponse(
        result: null,
        isSuccess: false,
        message: "Something went wrong",
        responseCode: 500,
      );
    }
  }
}
