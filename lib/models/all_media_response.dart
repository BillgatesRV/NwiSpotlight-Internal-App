class AllMediaResponse {
  AllMediaResponse({
    this.employeeGuid,
    this.employeeName,
    this.designation,
    required this.profileImage,
    this.mediaGuid,
    this.mediaDesc,
    this.mediaType,
    this.mediaTittle,
    this.totalCount,
    this.addedOn,
    this.isUserLiked,
    this.likesCount, 
    this.mediaFiles
  });

  String? employeeGuid;
  String? employeeName;
  String? designation;
  String profileImage;
  String? mediaGuid;
  String? mediaType;
  String? mediaTittle;
  String? mediaDesc;
  int? totalCount;
  DateTime? addedOn;
  int? likesCount;
  bool? isUserLiked;
  List<MediaFilesResponse>? mediaFiles;

  factory AllMediaResponse.fromJson(Map<String, dynamic> json) {
    return AllMediaResponse(
      employeeGuid: json["employeeGuid"],
      employeeName: json["employeeName"],
      designation: json["designation"],
      profileImage: json["profileImage"],
      mediaGuid: json["mediaGuid"],
      mediaType: json["mediaType"],
      mediaTittle: json["mediaTittle"],
      mediaDesc: json["mediaDesc"],
      totalCount: json["totalCount"],
      likesCount: json["likesCount"],
      isUserLiked: json["isUserLiked"],
      addedOn: json["addedOn"] != null
          ? DateTime.parse(json["addedOn"])
          : null,
      mediaFiles: json["mediaFiles"] != null
          ? List<MediaFilesResponse>.from(
              json["mediaFiles"].map(
                (x) => MediaFilesResponse.fromJson(x),
              ),
            )
          : [],
    );
  }
}

class MediaFilesResponse {
  MediaFilesResponse({
    this.mediaGuid,
    this.fileGuid,
    this.fileType,
    this.fileName,
    this.filePath,
    this.addedOn,
    this.addedBy,
    this.profile,
    this.postedBy,
    this.canDelete,
  });

  String? mediaGuid;
  String? fileGuid;
  String? fileType;
  String? fileName;
  String? filePath;
  DateTime? addedOn;
  String? addedBy;
  String? profile;
  String? postedBy;
  bool? canDelete;

  factory MediaFilesResponse.fromJson(Map<String, dynamic> json) {
    return MediaFilesResponse(
      mediaGuid: json["mediaGuid"],
      fileGuid: json["fileGuid"],
      fileType: json["fileType"],
      fileName: json["fileName"],
      filePath: json["filePath"],
      addedOn: json["addedOn"] != null
          ? DateTime.parse(json["addedOn"])
          : null,
      addedBy: json["addedBy"],
      profile: json["profile"],
      postedBy: json["postedBy"],
      canDelete: json["canDelete"],
    );
  }
}