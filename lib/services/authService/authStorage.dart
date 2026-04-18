import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthStorage {
  final _storage = const FlutterSecureStorage();

  static const _keyToken = "accessToken";
  static const _keyRefreshToken = "refreshToken";
  static const _keyUserGuid = "userGuid";

  Future<void> saveLoginData(String token, String refreshToken, String userGuid) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserGuid, value: userGuid);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<String?> getUserGuid() async {
    return await _storage.read(key: _keyUserGuid);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}