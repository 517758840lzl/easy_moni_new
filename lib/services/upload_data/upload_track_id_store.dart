abstract final class UploadTrackIdStore {
  UploadTrackIdStore._();

  static int? _trackId;

  static int? get value => _trackId;

  static void save(int trackId) {
    if (trackId > 0) {
      _trackId = trackId;
    }
  }

  static void clear() {
    _trackId = null;
  }
}
