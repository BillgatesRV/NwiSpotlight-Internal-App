class MediaLikeResponse {
  String mediaGuid;
  bool isUserLiked;
  int likesCount;

  MediaLikeResponse({
    required this.mediaGuid,
    required this.isUserLiked,
    required this.likesCount,
  });

  factory MediaLikeResponse.fromJson(Map<String, dynamic> json) {
    return MediaLikeResponse(
      mediaGuid: json['mediaGuid'],
      isUserLiked: json['isUserLiked'],
      likesCount: json['likesCount'],
    );
  }
}