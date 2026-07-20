import 'dart:async';

class AuthSessionEvents {
  final StreamController<void> _expiredController =
      StreamController<void>.broadcast(sync: true);
  bool _expirationNotified = false;

  Stream<void> get onExpired => _expiredController.stream;

  void markAuthenticated() {
    _expirationNotified = false;
  }

  void notifyExpired() {
    if (_expirationNotified) {
      return;
    }
    _expirationNotified = true;
    _expiredController.add(null);
  }

  Future<void> close() => _expiredController.close();
}
