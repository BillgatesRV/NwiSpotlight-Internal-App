import 'package:image_picker/image_picker.dart';
import 'package:spotlight/models/all_media_response.dart';
import 'package:spotlight/models/api_response.dart';
import 'package:spotlight/models/media_like_response.dart';
import 'package:spotlight/models/media_liked_by_response.dart';
import 'package:spotlight/models/user_all_media_response.dart';

abstract class MediaBaseService {
  Future<List<AllMediaResponse>> fetchAllMediaFeeds(int pageNumber, int pageSize,);
  Future<MediaLikeResponse> manageMediaLikes({required String mediaGuid});
  Future<List<MediaLikedByResponse>> manageLikedBy({required String mediaGuid});
  Future<String> addFeed({required String caption, required List<XFile> media});
  Future<List<UserAllMediaResponse>> fetchAllUserMedia(int pageNumber, int pageSize);
  Future<List<UserAllMediaResponse>> fetchAllOthersUserMedia(String empGuid, int pageNumber, int pageSize);
  Future<List<AllMediaResponse>> fetchAllUserMediaData(String empGuid, int pageNumber, int pageSize);
  Future<ApiResponse> deleteFeed({required String mediaGuid});
}