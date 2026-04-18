import 'dart:typed_data';

class UserAllMediaResponse {
  String mediaGuid;
  String mediaTittle;
  String mediaDesc;
  String mediaType;
  DateTime addedOn;
  String mediaThumb;
  int totalCount;
  Uint8List? videoThumb;

  UserAllMediaResponse({
    required this.mediaGuid,
    required this.mediaTittle,
    required this.mediaDesc,
    required this.mediaType,
    required this.addedOn,
    required this.mediaThumb,
    required this.totalCount,
    this.videoThumb,
  });

  static UserAllMediaResponse fromJson (Map<String, dynamic> json) {
    return UserAllMediaResponse(
      mediaGuid: json['mediaGuid'],
      mediaTittle: json['mediaTittle'],
      mediaDesc: json['mediaDesc'],
      mediaType: json['mediaType'],
      addedOn: json['addedOn'] = DateTime.parse(json['addedOn']),
      mediaThumb: json['mediaThumb'],
      totalCount: json['totalCount'],
    );
  }
}