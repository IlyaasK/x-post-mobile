import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();
  
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  Future<bool> containsKey({required String key}) async {
    return await _secureStorage.containsKey(key: key);
  }
}
