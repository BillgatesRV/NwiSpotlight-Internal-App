import 'package:image_picker/image_picker.dart';
import 'package:spotlight/models/allMediaResponse.dart';
import 'package:spotlight/models/apiResponse.dart';
import 'package:spotlight/models/mediaLikeResponse.dart';
import 'package:spotlight/models/mediaLikedByResponse.dart';
import 'package:spotlight/models/userAllMediaResponse.dart';

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