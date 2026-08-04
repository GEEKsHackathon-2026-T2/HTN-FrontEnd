import 'dart:io';

/// Backend base URL (docs/05-api.md — global prefix `/api/v1`).
///
/// The Android emulator can't reach the host's `localhost` directly; it
/// must go through the `10.0.2.2` alias instead. iOS simulators and real
/// devices on the same network can use `localhost`/the host's LAN IP.
String get apiBaseUrl {
  return 'http://165.140.22.56:3000/api/v1';
  // if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
  // return 'http://localhost:3000/api/v1';
}
