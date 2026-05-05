class MediaLikedByResponse {
  String mediaGuid;
  String userGuid;
  DateTime addedOn;
  String profileImage;
  String employeeName;
  String designation;
  int totalLikes;

  MediaLikedByResponse({
      required this.mediaGuid,
      required this.userGuid, 
      required this.addedOn, 
      required this.profileImage,
      required this.employeeName,
      required this.designation,
      required this.totalLikes,
  });

  factory MediaLikedByResponse.fromJson(Map<String, dynamic> json) {
    return MediaLikedByResponse (
      mediaGuid : json['mediaGuid'],
      userGuid : json['userGuid'],
      addedOn: json["addedOn"] = DateTime.parse(json["addedOn"]),
      profileImage : json['profileImage'],
      employeeName : json['employeeName'],
      designation : json['designation'],
      totalLikes : json['totalLikes']
    );
  }
}