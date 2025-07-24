class ServerException implements Exception {
  final String? message;

  const ServerException([this.message]);
}

class CacheException implements Exception {}

class FirestoreException implements Exception {
  final String? message;

  const FirestoreException([this.message]);
}

class OtherException implements Exception {
  final String? message;

  const OtherException([this.message]);
}