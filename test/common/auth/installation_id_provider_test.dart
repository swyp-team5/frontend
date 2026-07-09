import 'package:chack_chack/common/auth/social/social_identity_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reuses the persisted installation id', () async {
    final store = _MemoryInstallationIdStore('existing-installation-id');
    final provider = InstallationIdProvider(
      store: store,
      randomBytes: (_) => throw StateError('must not generate'),
    );

    expect(await provider.load(), 'existing-installation-id');
    expect(store.writeCount, 0);
  });

  test('generates and persists an installation id once', () async {
    final store = _MemoryInstallationIdStore();
    final provider = InstallationIdProvider(
      store: store,
      randomBytes: (length) => List<int>.generate(length, (index) => index),
    );

    final first = await provider.load();
    final second = await provider.load();

    expect(first, isNotEmpty);
    expect(second, first);
    expect(store.value, first);
    expect(store.writeCount, 1);
  });
}

class _MemoryInstallationIdStore implements InstallationIdStore {
  String? value;
  int writeCount = 0;

  _MemoryInstallationIdStore([this.value]);

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String installationId) async {
    value = installationId;
    writeCount += 1;
  }
}
